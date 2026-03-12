#!/usr/bin/env bash
set -euo pipefail

issue=""
repo=""
pr=""
branch=""
repo_root=""
history_days="90"
repo_autodetected="false"
linked_prs_cap="3"
candidate_file_limit="40"
candidate_test_limit="20"
api_errors=()

sanitize_error() {
  tr '\n' ' ' < "$1" | sed 's/[[:space:]]\+/ /g' | sed "s/\"/'/g"
}

emit_error_json() {
  local message="$1"
  jq -n \
    --arg error "$message" \
    --arg repo "${repo:-}" \
    --arg issue "${issue:-}" \
    --arg repo_root "${repo_root:-}" '
      {
        error: $error,
        repo_detected: (if $repo == "" then null else $repo end),
        repo_root_detected: (if $repo_root == "" then null else $repo_root end),
        issue: (if $issue == "" then null else $issue end)
      }
    '
  exit 1
}

join_json_arrays() {
  jq -sc 'add | unique'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --issue)
      issue="${2:-}"
      shift 2
      ;;
    --repo)
      repo="${2:-}"
      shift 2
      ;;
    --pr)
      pr="${2:-}"
      shift 2
      ;;
    --branch)
      branch="${2:-}"
      shift 2
      ;;
    --repo-root)
      repo_root="${2:-}"
      shift 2
      ;;
    --history-days)
      history_days="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      echo "Usage: collect-evidence.sh --issue <number|issue-url> [--repo owner/name] [--repo-root /path/to/repo] [--pr <number>] [--branch <name>] [--history-days <days>]" >&2
      exit 1
      ;;
  esac
done

if [[ "$issue" =~ /issues/[0-9]+([/?#].*)?$ ]]; then
  issue="$(sed -E 's#^.*/issues/([0-9]+)([/?#].*)?$#\1#' <<<"$issue")"
fi

if [[ -z "$issue" ]]; then
  echo "Usage: collect-evidence.sh --issue <number|issue-url> [--repo owner/name] [--repo-root /path/to/repo] [--pr <number>] [--branch <name>] [--history-days <days>]" >&2
  exit 1
fi

if [[ ! "$issue" =~ ^[0-9]+$ ]]; then
  emit_error_json "issue must be a numeric issue number or a GitHub issue URL"
fi

if ! command -v gh >/dev/null 2>&1; then
  emit_error_json "gh CLI is required"
fi

if ! command -v jq >/dev/null 2>&1; then
  emit_error_json "jq is required"
fi

if ! gh auth status >/dev/null 2>&1; then
  emit_error_json "gh auth status failed; authenticate before running this script"
fi

git_cmd=(git)
if [[ -n "$repo_root" ]]; then
  if ! resolved_repo_root="$(git -C "$repo_root" rev-parse --show-toplevel 2>/dev/null)"; then
    emit_error_json "repo_root is not a git repository: $repo_root"
  fi
  repo_root="$resolved_repo_root"
elif resolved_repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  repo_root="$resolved_repo_root"
fi

if [[ -n "$repo_root" ]]; then
  git_cmd=(git -C "$repo_root")
fi

if [[ -z "$repo" ]]; then
  if [[ -n "$repo_root" ]]; then
    if ! repo="$(cd "$repo_root" && gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null)"; then
      emit_error_json "could not auto-detect GitHub repository from repo_root; pass --repo explicitly"
    fi
  elif ! repo="$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null)"; then
    emit_error_json "could not auto-detect GitHub repository from the current directory; pass --repo explicitly"
  fi
  repo_autodetected="true"
fi

default_branch_error_file="$(mktemp)"
if ! default_branch="$(gh repo view "$repo" --json defaultBranchRef -q '.defaultBranchRef.name' 2>"$default_branch_error_file")"; then
  error_message="$(sanitize_error "$default_branch_error_file")"
  rm -f "$default_branch_error_file"
  emit_error_json "failed to resolve default branch for $repo: $error_message"
fi
rm -f "$default_branch_error_file"

issue_error_file="$(mktemp)"
if ! issue_json="$(gh issue view "$issue" --repo "$repo" --json number,title,body,url,state,labels,author 2>"$issue_error_file")"; then
  error_message="$(sanitize_error "$issue_error_file")"
  rm -f "$issue_error_file"
  emit_error_json "failed to fetch issue #$issue from $repo: $error_message"
fi
rm -f "$issue_error_file"

timeline_json='[]'
timeline_error_file="$(mktemp)"
if ! timeline_json="$(gh api -H "Accept: application/vnd.github+json" "repos/$repo/issues/$issue/timeline?per_page=100" 2>"$timeline_error_file")"; then
  api_errors+=("issue timeline API failed: $(sanitize_error "$timeline_error_file")")
  timeline_json='[]'
fi
rm -f "$timeline_error_file"

linked_prs_json="$(
  jq '
    [
      .[]
      | select(.event == "cross-referenced")
      | .source.issue
      | select(.pull_request)
      | {
          number: (.number // null),
          title: (.title // null),
          state: (.state // null),
          url: (.html_url // null)
        }
    ]
    | unique_by(.number // .url)
  ' <<<"$timeline_json"
)"

linked_commits_json="$(
  jq '
    [
      .[]
      | select((.commit_id? // "") != "")
      | {
          sha: (.commit_id[0:12]),
          event: .event,
          created_at: (.created_at // null)
        }
    ]
    | unique_by(.sha)
  ' <<<"$timeline_json"
)"

search_prs_json="$(
  search_error_file="$(mktemp)"
  if gh search prs "\"#$issue\" repo:$repo" --limit 10 --json number,title,url,state,mergedAt,headRefName,baseRefName 2>"$search_error_file"; then
    :
  else
    api_errors+=("PR search failed: $(sanitize_error "$search_error_file")")
    echo '[]'
  fi
  rm -f "$search_error_file"
)"

recent_commits_json='[]'
recent_commit_files_json='[]'
if [[ -n "$repo_root" ]]; then
  all_recent_commits_raw="$(
    "${git_cmd[@]}" log --since="${history_days} days ago" --no-merges --format='%H%x09%s' 2>/dev/null || true
  )"
  recent_commits_json="$(
    printf '%s\n' "$all_recent_commits_raw" \
      | jq -Rsc --arg issue "$issue" '
          split("\n")
          | map(select(length > 0))
          | map(split("\t"))
          | map({
              sha: .[0][0:12],
              subject: .[1]
            })
          | map(select(
              (.subject | test("(^|[^0-9])#" + $issue + "([^0-9]|$)"; "i"))
              or (.subject | test("\\(#" + $issue + "\\)"; "i"))
              or (.subject | test("(close[sd]?|fix(e[sd])?|resolve[sd]?)[: ]+?#" + $issue + "([^0-9]|$)"; "i"))
            ))
        '
  )"

  if [[ "$(jq 'length' <<<"$recent_commits_json")" -gt 0 ]]; then
    recent_commits_raw="$(jq -r '.[] | [.sha, .subject] | @tsv' <<<"$recent_commits_json")"
    recent_commits_json="$(
      jq '.' <<<"$recent_commits_json"
    )"

    recent_commit_files_json="$(
      while IFS=$'\t' read -r commit_sha _subject; do
        [[ -z "$commit_sha" ]] && continue
        "${git_cmd[@]}" show --pretty='' --name-only "$commit_sha" 2>/dev/null || true
      done <<<"$recent_commits_raw" \
        | jq -Rsc 'split("\n") | map(select(length > 0)) | unique'
    )"
  fi
fi

pr_target_json='null'
pr_files_json='[]'
if [[ -n "$pr" ]]; then
  pr_error_file="$(mktemp)"
  if ! pr_target_json="$(
    gh pr view "$pr" --repo "$repo" \
      --json number,title,url,state,isDraft,mergedAt,headRefName,baseRefName,files 2>"$pr_error_file"
  )"; then
    api_errors+=("target PR lookup failed: $(sanitize_error "$pr_error_file")")
    pr_target_json='null'
  fi
  rm -f "$pr_error_file"
  if [[ "$pr_target_json" != "null" ]]; then
    pr_files_json="$(jq '[.files[].path] | unique' <<<"$pr_target_json")"
  fi
fi

branch_files_json='[]'
branch_gap=""
if [[ -n "$branch" ]] && [[ -n "$repo_root" ]]; then
  base_ref=""
  if "${git_cmd[@]}" rev-parse --verify "origin/$default_branch" >/dev/null 2>&1; then
    base_ref="origin/$default_branch"
  elif "${git_cmd[@]}" rev-parse --verify "$default_branch" >/dev/null 2>&1; then
    base_ref="$default_branch"
  fi

  if [[ -z "$base_ref" ]]; then
    branch_gap="default branch ref not found locally for branch comparison"
  elif ! "${git_cmd[@]}" rev-parse --verify "$branch" >/dev/null 2>&1; then
    branch_gap="target branch '$branch' not found locally"
  else
    merge_base="$("${git_cmd[@]}" merge-base "$branch" "$base_ref" 2>/dev/null || true)"
    if [[ -n "$merge_base" ]]; then
      branch_files_json="$(
        "${git_cmd[@]}" diff --name-only "$merge_base...$branch" \
          | jq -Rsc 'split("\n") | map(select(length > 0)) | unique'
      )"
    else
      branch_gap="could not compute merge-base for branch comparison"
    fi
  fi
fi

linked_pr_file_sets='[]'
all_candidate_prs_json="$(
  printf '%s\n%s\n' \
    "$(jq '[.[] | {number, title, url, state}]' <<<"$linked_prs_json")" \
    "$(jq '[.[] | {number, title, url, state}]' <<<"$search_prs_json")" \
    | join_json_arrays
)"
all_candidate_prs_count="$(jq 'length' <<<"$all_candidate_prs_json")"

while IFS= read -r linked_pr_number; do
  [[ -z "$linked_pr_number" || "$linked_pr_number" == "null" ]] && continue
  linked_pr_error_file="$(mktemp)"
  if ! pr_paths="$(gh pr view "$linked_pr_number" --repo "$repo" --json files --jq '[.files[].path] | unique' 2>"$linked_pr_error_file")"; then
    api_errors+=("linked PR file lookup failed for #$linked_pr_number: $(sanitize_error "$linked_pr_error_file")")
    pr_paths='[]'
  fi
  rm -f "$linked_pr_error_file"
  linked_pr_file_sets="$(
    printf '%s\n%s\n' "$linked_pr_file_sets" "$pr_paths" | join_json_arrays
  )"
done < <(jq -r '.[].number // empty' <<<"$all_candidate_prs_json" | sed -n '1,3p')

combined_candidate_paths_json="$(
  printf '%s\n%s\n%s\n%s\n' "$pr_files_json" "$branch_files_json" "$linked_pr_file_sets" "$recent_commit_files_json" \
    | join_json_arrays
)"

candidate_files_json="$(
  jq --argjson limit "$candidate_file_limit" '
        map(select(test("(^|/)(test|tests|__tests__)/") | not))
        | map(select(test("\\.(spec|test)\\.[[:alnum:]]+$") | not))
        | .[:$limit]
      ' <<<"$combined_candidate_paths_json"
)"

candidate_tests_json="$(
  jq --argjson limit "$candidate_test_limit" '
        map(select(
          test("(^|/)(test|tests|__tests__)/")
          or test("\\.(spec|test)\\.[[:alnum:]]+$")
        ))
        | .[:$limit]
      ' <<<"$combined_candidate_paths_json"
)"

candidate_file_count_total="$(jq '
        map(select(test("(^|/)(test|tests|__tests__)/") | not))
        | map(select(test("\\.(spec|test)\\.[[:alnum:]]+$") | not))
        | length
      ' <<<"$combined_candidate_paths_json")"

candidate_test_count_total="$(jq '
        map(select(
          test("(^|/)(test|tests|__tests__)/")
          or test("\\.(spec|test)\\.[[:alnum:]]+$")
        ))
        | length
      ' <<<"$combined_candidate_paths_json")"

issue_summary_json="$(
  jq '
    {
      number,
      title,
      url,
      state,
      author: (.author.login // null),
      labels: [.labels[].name],
      body_excerpt: ((.body // "") | gsub("\\r"; "") | split("\n") | map(select(length > 0)) | .[:8] | join("\n")),
      body_truncated: (((.body // "") | gsub("\\r"; "") | split("\n") | map(select(length > 0)) | length) > 8),
      has_acceptance_clues: ((.body // "") | test("acceptance criteria|expected behavior|definition of done"; "i")),
      has_repro_clues: ((.body // "") | test("steps to reproduce|repro|reproduction"; "i"))
    }
  ' <<<"$issue_json"
)"

gaps_json="$(
  jq -n \
    --arg branch_gap "$branch_gap" \
    --argjson linked_prs "$linked_prs_json" \
    --argjson linked_commits "$linked_commits_json" \
    --argjson recent_commits "$recent_commits_json" \
    --argjson candidate_files "$candidate_files_json" \
    --argjson candidate_tests "$candidate_tests_json" \
    --argjson issue_summary "$issue_summary_json" '
      [
        (if ($linked_prs | length) == 0 then "no linked PRs found from issue timeline" else empty end),
        (if ($linked_commits | length) == 0 then "no linked commits found from issue timeline" else empty end),
        (if ($recent_commits | length) == 0 then "no recent local commits referencing the issue number were found" else empty end),
        (if ($candidate_files | length) == 0 then "no candidate implementation files identified from target diff sources" else empty end),
        (if ($candidate_tests | length) == 0 then "no candidate tests identified from target diff sources" else empty end),
        (if $issue_summary.has_acceptance_clues then empty else "issue body has no obvious acceptance-criteria markers" end),
        (if $issue_summary.has_repro_clues then empty else "issue body has no obvious reproduction markers" end),
        (if $issue_summary.body_truncated then "issue body excerpt was truncated; fetch the full body if acceptance details may appear later" else empty end),
        (if $branch_gap == "" then empty else $branch_gap end)
      ]
    '
)"

api_errors_json="$(
  printf '%s\n' "${api_errors[@]:-}" | jq -Rsc 'split("\n") | map(select(length > 0))'
)"

jq -n \
  --arg repo "$repo" \
  --arg repo_root "$repo_root" \
  --arg repo_autodetected "$repo_autodetected" \
  --arg linked_prs_cap "$linked_prs_cap" \
  --argjson all_candidate_prs_count "$all_candidate_prs_count" \
  --argjson candidate_file_limit "$candidate_file_limit" \
  --argjson candidate_test_limit "$candidate_test_limit" \
  --argjson candidate_file_count_total "$candidate_file_count_total" \
  --argjson candidate_test_count_total "$candidate_test_count_total" \
  --arg issue_id "$issue" \
  --arg default_branch "$default_branch" \
  --arg history_days "$history_days" \
  --argjson issue "$issue_summary_json" \
  --argjson linked_prs "$linked_prs_json" \
  --argjson linked_commits "$linked_commits_json" \
  --argjson referenced_prs "$search_prs_json" \
  --argjson recent_commits "$recent_commits_json" \
  --argjson pr_target "$pr_target_json" \
  --arg branch "$branch" \
  --argjson candidate_files "$candidate_files_json" \
  --argjson candidate_tests "$candidate_tests_json" \
  --argjson api_errors "$api_errors_json" \
  --argjson gaps "$gaps_json" '
    {
      repo_detected: $repo,
      repo_root_detected: (if $repo_root == "" then null else $repo_root end),
      repo_autodetected: ($repo_autodetected == "true"),
      issue: ($issue + {repo: $repo}),
      target: {
        mode:
          (if ($pr_target | type) != "null" then "issue-vs-pr"
           elif $branch != "" then "issue-vs-branch"
           else "issue-only"
           end),
        default_branch: $default_branch,
        pr:
          (if ($pr_target | type) == "null"
           then null
           else {
             number: $pr_target.number,
             title: $pr_target.title,
             url: $pr_target.url,
             state: $pr_target.state,
             mergedAt: $pr_target.mergedAt,
             headRefName: $pr_target.headRefName,
             baseRefName: $pr_target.baseRefName
           }
           end),
        branch: (if $branch == "" then null else $branch end),
        history_days: ($history_days | tonumber)
      },
      linked_prs: $linked_prs,
      referenced_prs: ($referenced_prs | map({
        number,
        title,
        url,
        state,
        mergedAt,
        headRefName,
        baseRefName
      })),
      all_candidate_prs_count: $all_candidate_prs_count,
      linked_prs_cap: ($linked_prs_cap | tonumber),
      has_more_candidate_prs: ($all_candidate_prs_count > ($linked_prs_cap | tonumber)),
      linked_commits: $linked_commits,
      recent_commits: $recent_commits,
      candidate_file_limit: $candidate_file_limit,
      candidate_test_limit: $candidate_test_limit,
      candidate_file_count_total: $candidate_file_count_total,
      candidate_test_count_total: $candidate_test_count_total,
      has_more_candidate_files: ($candidate_file_count_total > $candidate_file_limit),
      has_more_candidate_tests: ($candidate_test_count_total > $candidate_test_limit),
      candidate_files: $candidate_files,
      candidate_tests: $candidate_tests,
      api_errors: $api_errors,
      gaps: $gaps,
      notes: [
        "Inspect candidate_files first; widen only if evidence is ambiguous.",
        "Use candidate_tests to check for issue-specific behavior coverage.",
        "Use linked_prs and referenced_prs as hints, not proof.",
        (if ($repo_autodetected == "true") then "Repository was auto-detected; confirm it matches the intended target repo." else empty end)
      ]
    }
  '

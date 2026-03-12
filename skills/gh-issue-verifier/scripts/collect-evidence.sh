#!/usr/bin/env bash
set -euo pipefail

issue=""
repo=""
pr=""
branch=""
history_days="90"

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
    --history-days)
      history_days="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      echo "Usage: collect-evidence.sh --issue <number> [--repo owner/name] [--pr <number>] [--branch <name>] [--history-days <days>]" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$issue" ]]; then
  echo "Usage: collect-evidence.sh --issue <number> [--repo owner/name] [--pr <number>] [--branch <name>] [--history-days <days>]" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo '{"error":"gh CLI is required"}' >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo '{"error":"jq is required"}' >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo '{"error":"gh auth status failed; authenticate before running this script"}' >&2
  exit 1
fi

if [[ -z "$repo" ]]; then
  repo="$(gh repo view --json nameWithOwner -q '.nameWithOwner')"
fi

default_branch="$(gh repo view "$repo" --json defaultBranchRef -q '.defaultBranchRef.name')"

issue_json="$(gh issue view "$issue" --repo "$repo" --json number,title,body,url,state,labels,author)"

timeline_json="$(gh api -H "Accept: application/vnd.github+json" "repos/$repo/issues/$issue/timeline?per_page=100")"

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
  gh search prs "\"#$issue\" repo:$repo" --limit 10 --json number,title,url,state,mergedAt,headRefName,baseRefName 2>/dev/null \
    || echo '[]'
)"

recent_commits_json='[]'
recent_commit_files_json='[]'
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  recent_commits_raw="$(
    git log --since="${history_days} days ago" --no-merges --regexp-ignore-case --grep="#$issue" \
      --format='%H%x09%s' 2>/dev/null || true
  )"
  if [[ -n "$recent_commits_raw" ]]; then
    recent_commits_json="$(
      printf '%s\n' "$recent_commits_raw" \
        | jq -Rsc '
            split("\n")
            | map(select(length > 0))
            | map(split("\t"))
            | map({
                sha: .[0][0:12],
                subject: .[1]
              })
          '
    )"

    recent_commit_files_json="$(
      while IFS=$'\t' read -r commit_sha _subject; do
        [[ -z "$commit_sha" ]] && continue
        git show --pretty='' --name-only "$commit_sha" 2>/dev/null || true
      done <<<"$recent_commits_raw" \
        | jq -Rsc 'split("\n") | map(select(length > 0)) | unique'
    )"
  fi
fi

pr_target_json='null'
pr_files_json='[]'
if [[ -n "$pr" ]]; then
  pr_target_json="$(
    gh pr view "$pr" --repo "$repo" \
      --json number,title,url,state,isDraft,mergedAt,headRefName,baseRefName,files
  )"
  pr_files_json="$(jq '[.files[].path] | unique' <<<"$pr_target_json")"
fi

branch_files_json='[]'
branch_gap=""
if [[ -n "$branch" ]] && git rev-parse --show-toplevel >/dev/null 2>&1; then
  base_ref=""
  if git rev-parse --verify "origin/$default_branch" >/dev/null 2>&1; then
    base_ref="origin/$default_branch"
  elif git rev-parse --verify "$default_branch" >/dev/null 2>&1; then
    base_ref="$default_branch"
  fi

  if [[ -z "$base_ref" ]]; then
    branch_gap="default branch ref not found locally for branch comparison"
  elif ! git rev-parse --verify "$branch" >/dev/null 2>&1; then
    branch_gap="target branch '$branch' not found locally"
  else
    merge_base="$(git merge-base "$branch" "$base_ref" 2>/dev/null || true)"
    if [[ -n "$merge_base" ]]; then
      branch_files_json="$(
        git diff --name-only "$merge_base...$branch" \
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

while IFS= read -r linked_pr_number; do
  [[ -z "$linked_pr_number" || "$linked_pr_number" == "null" ]] && continue
  pr_paths="$(gh pr view "$linked_pr_number" --repo "$repo" --json files --jq '[.files[].path] | unique' 2>/dev/null || echo '[]')"
  linked_pr_file_sets="$(
    printf '%s\n%s\n' "$linked_pr_file_sets" "$pr_paths" | join_json_arrays
  )"
done < <(jq -r '.[].number // empty' <<<"$all_candidate_prs_json" | sed -n '1,3p')

candidate_files_json="$(
  printf '%s\n%s\n%s\n%s\n' "$pr_files_json" "$branch_files_json" "$linked_pr_file_sets" "$recent_commit_files_json" \
    | join_json_arrays \
    | jq '
        map(select(test("(^|/)(test|tests|__tests__)/") | not))
        | map(select(test("\\.(spec|test)\\.[[:alnum:]]+$") | not))
        | .[:40]
      '
)"

candidate_tests_json="$(
  printf '%s\n%s\n%s\n%s\n' "$pr_files_json" "$branch_files_json" "$linked_pr_file_sets" "$recent_commit_files_json" \
    | join_json_arrays \
    | jq '
        map(select(
          test("(^|/)(test|tests|__tests__)/")
          or test("\\.(spec|test)\\.[[:alnum:]]+$")
        ))
        | .[:20]
      '
)"

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
        (if $branch_gap == "" then empty else $branch_gap end)
      ]
    '
)"

jq -n \
  --arg repo "$repo" \
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
  --argjson gaps "$gaps_json" '
    {
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
      linked_commits: $linked_commits,
      recent_commits: $recent_commits,
      candidate_files: $candidate_files,
      candidate_tests: $candidate_tests,
      gaps: $gaps,
      notes: [
        "Inspect candidate_files first; widen only if evidence is ambiguous.",
        "Use candidate_tests to check for issue-specific behavior coverage.",
        "Use linked_prs and referenced_prs as hints, not proof."
      ]
    }
  '

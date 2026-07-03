#!/usr/bin/env bash
# Regression test for audit-skill.sh `relative_bundled_script_calls` detection.
#
# Bare invocations of a bundled script break after the plugin is copied to the
# install cache. The auditor must flag them across runtimes
# (bash/sh/node/python/python3/./), while ${CLAUDE_SKILL_DIR} paths and markdown
# doc links must NOT be flagged.
#
# Guards the python-prefix gap: audit-skill.sh once matched only
# (bash|sh|node|./) and silently reported 0 for `python3 scripts/x.py`.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
AUDIT="$HERE/../audit-skill.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

SK="$TMP/rel-calls-skill"
mkdir -p "$SK"
cat > "$SK/SKILL.md" <<'EOF'
---
name: rel-calls-skill
description: Fixture exercising bare bundled-script call detection across runtimes.
---
# Rel Calls Skill

Bare invocations that MUST be flagged (break after cache-copy):

    python3 scripts/a.py < in > out
    python scripts/b.py
    bash scripts/c.sh
    node scripts/d.mjs
    ./scripts/e.sh

Safe invocation that must NOT be flagged:

    python3 "${CLAUDE_SKILL_DIR}/scripts/ok.py"

Doc link that must NOT be flagged: [parser](scripts/f.py)
EOF
printf '{"version":"0.0.0","author":"t","date":"2026-01-01","abstract":"x"}\n' > "$SK/metadata.json"

# The rel_calls scan only runs when the skill has a scripts/ dir; create the
# referenced scripts (executable, so unrelated findings stay quiet).
mkdir -p "$SK/scripts"
for s in a.py b.py c.sh d.mjs e.sh f.py ok.py; do
  printf '#!/usr/bin/env sh\n:\n' > "$SK/scripts/$s"
  chmod +x "$SK/scripts/$s"
done

got="$(bash "$AUDIT" "$SK" \
  | python3 -c 'import sys,json;print(json.load(sys.stdin)["skills"][0]["context_efficiency"]["relative_bundled_script_calls"])')"
want=5

if [[ "$got" == "$want" ]]; then
  echo "OK (relative_bundled_script_calls=$got: bash/sh/node/python/python3/./ counted; \${CLAUDE_SKILL_DIR} + md-link excluded)"
else
  echo "FAIL: expected $want bare calls, got $got" >&2
  exit 1
fi

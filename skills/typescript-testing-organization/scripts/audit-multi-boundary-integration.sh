#!/bin/bash
set -e

# audit-multi-boundary-integration.sh — Heuristic detection of multi-boundary integration tests.
# Outputs JSON to stdout, status messages to stderr.
#
# Rationale:
# Boundary integration tests MUST exercise exactly one real boundary.
# This script heuristically flags integration-tier files that appear to touch
# multiple real boundary categories (DB + HTTP, DB + filesystem, etc.).
#
# IMPORTANT:
# This is heuristic. It is designed to surface candidates for review, not to
# be a perfect classifier.
#
# Usage: bash scripts/audit-multi-boundary-integration.sh [PROJECT_ROOT]

PROJECT_ROOT="${1:-.}"

echo "Auditing multi-boundary integration (heuristic) in: $PROJECT_ROOT" >&2

files_scanned=0
files_flagged=0
flagged=""

append_flagged() {
  local entry="$1"
  if [ -z "$flagged" ]; then
    flagged="$entry"
  else
    flagged="$flagged,$entry"
  fi
}

# Patterns per boundary category (conservative; reduce false positives)
db_re='testcontainers|\\bpg\\b|postgres|mysql|prisma|kysely|knex|typeorm|sequelize|mongoose|mongodb|sqlite'
http_re='supertest|undici|\\bfetch\\s*\\(|fastify|express|koa|hono|createServer\\s*\\(|\\.listen\\s*\\('
fs_re='\\bfs\\b|fs/promises|readFile\\s*\\(|writeFile\\s*\\(|createReadStream\\s*\\(|createWriteStream\\s*\\('
queue_re='kafkajs|amqplib|bullmq|@aws-sdk/client-sqs|sqs|pubsub|nats'

integration_files=$(find "$PROJECT_ROOT/test/integration" -type f \( -name "*.int.spec.ts" -o -name "*.int.spec.tsx" \) \
  ! -path "*/node_modules/*" ! -path "*/.cursor/*" ! -path "*/dist/*" 2>/dev/null | sort)

while IFS= read -r file; do
  [ -z "$file" ] && continue
  files_scanned=$((files_scanned + 1))
  rel_file="${file#"$PROJECT_ROOT"/}"

  db_count=$(grep -Eic "$db_re" "$file" 2>/dev/null || echo "0")
  http_count=$(grep -Eic "$http_re" "$file" 2>/dev/null || echo "0")
  fs_count=$(grep -Eic "$fs_re" "$file" 2>/dev/null || echo "0")
  queue_count=$(grep -Eic "$queue_re" "$file" 2>/dev/null || echo "0")

  categories=0
  [ "$db_count" -gt 0 ] && categories=$((categories + 1))
  [ "$http_count" -gt 0 ] && categories=$((categories + 1))
  [ "$fs_count" -gt 0 ] && categories=$((categories + 1))
  [ "$queue_count" -gt 0 ] && categories=$((categories + 1))

  if [ "$categories" -ge 2 ]; then
    files_flagged=$((files_flagged + 1))
    append_flagged "{\"file\":\"$rel_file\",\"categories\":$categories,\"db\":$db_count,\"http\":$http_count,\"fs\":$fs_count,\"queue\":$queue_count,\"flag\":\"review\"}"
  fi
done <<< "$integration_files"

echo "Done. Scanned $files_scanned integration files, flagged $files_flagged." >&2

cat <<EOF
{
  "project_root": "$PROJECT_ROOT",
  "files_scanned": $files_scanned,
  "files_flagged": $files_flagged,
  "flagged": [$flagged]
}
EOF


#!/usr/bin/env bash
set -euo pipefail

SKILL_FILE="${1:-SKILL.md}"

if [ ! -f "$SKILL_FILE" ]; then
  echo "Missing file: $SKILL_FILE"
  exit 1
fi

echo "Checking $SKILL_FILE..."

grep -q "^---$" "$SKILL_FILE" || { echo "Missing YAML frontmatter"; exit 1; }
grep -q "^name:" "$SKILL_FILE" || { echo "Missing name"; exit 1; }
grep -q "^description:" "$SKILL_FILE" || { echo "Missing description"; exit 1; }
grep -q "^# " "$SKILL_FILE" || { echo "Missing title"; exit 1; }
grep -qi "^## When this triggers" "$SKILL_FILE" || { echo "Missing trigger section"; exit 1; }
grep -qi "^## Workflow" "$SKILL_FILE" || { echo "Missing workflow section"; exit 1; }
grep -qi "^## Gotchas" "$SKILL_FILE" || { echo "Missing gotchas section"; exit 1; }

echo "Basic skill structure looks valid."

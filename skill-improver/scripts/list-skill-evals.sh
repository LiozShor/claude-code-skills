#!/usr/bin/env bash
# Survey eval coverage across all installed skills.
# Default scope: ~/.claude/skills/. Override by passing a folder as $1.
set -euo pipefail

SKILLS_ROOT="${1:-$HOME/.claude/skills}"

if [ ! -d "$SKILLS_ROOT" ]; then
  echo "Skills root not found: $SKILLS_ROOT"
  exit 1
fi

printf '%-32s  %5s  %s\n' "skill" "evals" "status"
printf '%-32s  %5s  %s\n' "--------------------------------" "-----" "-----------------------------"

TOTAL_SKILLS=0
WITH_EVALS=0
WITH_THREE_PLUS=0

for skill_dir in "$SKILLS_ROOT"/*/; do
  skill_name=$(basename "$skill_dir")
  [ -f "$skill_dir/SKILL.md" ] || continue
  TOTAL_SKILLS=$((TOTAL_SKILLS + 1))

  evals_dir="$skill_dir/evals"
  if [ ! -d "$evals_dir" ]; then
    printf '%-32s  %5d  %s\n' "$skill_name" 0 "no evals/ folder"
    continue
  fi

  count=0
  invalid=0
  while IFS= read -r ef; do
    if grep -q '"query"' "$ef" && grep -q '"expected_behavior"' "$ef"; then
      count=$((count + 1))
    else
      invalid=$((invalid + 1))
    fi
  done < <(find "$evals_dir" -maxdepth 1 -type f -name '*.json' -not -name '.*')

  WITH_EVALS=$((WITH_EVALS + 1))
  if [ "$count" -ge 3 ]; then
    WITH_THREE_PLUS=$((WITH_THREE_PLUS + 1))
    status="OK"
  elif [ "$count" -gt 0 ]; then
    status="WARN: <3 evals"
  else
    status="WARN: 0 valid evals"
  fi
  if [ "$invalid" -gt 0 ]; then
    status="$status ($invalid invalid)"
  fi
  printf '%-32s  %5d  %s\n' "$skill_name" "$count" "$status"
done

echo
echo "Summary: $WITH_THREE_PLUS / $TOTAL_SKILLS skills meet the ≥3-evals bar ($WITH_EVALS have any)."

#!/usr/bin/env bash
# Fleet-wide structural survey: runs review-skill-structure.sh on every skill
# under a skills directory and prints a summary table sorted by MISSING count.
# Usage: survey-skill-fleet.sh [skills-dir]   (default: ~/.claude/skills)
set -uo pipefail

SKILLS_DIR="${1:-$HOME/.claude/skills}"
REVIEW="$(cd "$(dirname "$0")" && pwd)/review-skill-structure.sh"

if [ ! -f "$REVIEW" ]; then
  echo "Cannot find review-skill-structure.sh next to this script." >&2
  exit 1
fi
if [ ! -d "$SKILLS_DIR" ]; then
  echo "Not a directory: $SKILLS_DIR" >&2
  exit 1
fi

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

TOTAL=0
NO_SKILLMD=0

for dir in "$SKILLS_DIR"/*/; do
  name=$(basename "$dir")
  f="$dir/SKILL.md"
  if [ ! -f "$f" ]; then
    NO_SKILLMD=$((NO_SKILLMD + 1))
    printf "%s\t%s\t%s\t%s\n" "999" "$name" "-" "no SKILL.md" >> "$TMP"
    continue
  fi
  TOTAL=$((TOTAL + 1))
  out=$(bash "$REVIEW" "$f" 2>/dev/null || true)
  missing=$(printf '%s\n' "$out" | grep -c '^MISSING' || true)
  warn=$(printf '%s\n' "$out" | grep -c '^WARN' || true)
  if [ "$missing" -eq 0 ] && [ "$warn" -eq 0 ]; then
    status="clean"
  elif [ "$missing" -eq 0 ]; then
    status="warns only"
  else
    status="NEEDS WORK"
  fi
  printf "%s\t%s\t%s\t%s\n" "$missing" "$name" "$warn" "$status" >> "$TMP"
done

echo "Skill fleet survey: $SKILLS_DIR"
echo
printf "%-35s %8s %6s  %s\n" "SKILL" "MISSING" "WARN" "STATUS"
printf "%-35s %8s %6s  %s\n" "-----" "-------" "----" "------"
sort -t$'\t' -k1,1nr -k2,2 "$TMP" | while IFS=$'\t' read -r missing name warn status; do
  [ "$missing" = "999" ] && missing="-"
  printf "%-35s %8s %6s  %s\n" "$name" "$missing" "$warn" "$status"
done

echo
CLEAN=$(awk -F'\t' '$1=="0" && $3=="0"' "$TMP" | wc -l | tr -d ' ')
BROKEN=$(awk -F'\t' '$1!="0" && $1!="999"' "$TMP" | wc -l | tr -d ' ')
echo "Skills scanned: $TOTAL · clean: $CLEAN · with MISSING: $BROKEN · folders without SKILL.md: $NO_SKILLMD"
echo "Detail per skill: bash $REVIEW <skills-dir>/<name>/SKILL.md"

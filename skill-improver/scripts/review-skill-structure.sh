#!/usr/bin/env bash
set -euo pipefail

SKILL_FILE="${1:-SKILL.md}"

if [ ! -f "$SKILL_FILE" ]; then
  echo "Missing file: $SKILL_FILE"
  exit 1
fi

echo "Reviewing $SKILL_FILE..."

check() {
  local pattern="$1"
  local message="$2"
  if grep -qi "$pattern" "$SKILL_FILE"; then
    echo "OK: $message"
  else
    echo "MISSING: $message"
  fi
}

check "^---$" "YAML frontmatter"
check "^name:" "name field"
check "^description:" "description field"
check "^allowed-tools:" "allowed-tools field"
check "^## When this triggers" "trigger section"
check "^## When this does not trigger" "non-trigger section"
check "^## Required inputs\|^## Inputs required" "inputs section"
check "^## Workflow\|^## .*workflow" "workflow section"
check "^## Decision gates" "decision gates section"
check "^## Output format" "output format section"
check "^## Gotchas" "gotchas section"
check "^## Evaluation checklist" "evaluation checklist"

# ---- Length check -------------------------------------------------------
LINES=$(wc -l < "$SKILL_FILE" | tr -d ' ')
if [ "$LINES" -le 200 ]; then
  echo "OK: length under 200 lines ($LINES)"
elif [ "$LINES" -le 300 ]; then
  echo "WARN: length $LINES — consider moving content to references/"
else
  echo "MISSING: length $LINES exceeds 300-line ceiling — restructure required"
fi

# ---- Dead-file detection in references/ assets/ scripts/ ---------------
SKILL_DIR=$(dirname "$SKILL_FILE")
for sub in references assets scripts; do
  subdir="$SKILL_DIR/$sub"
  [ -d "$subdir" ] || continue
  while IFS= read -r f; do
    base=$(basename "$f")
    if grep -qF "$base" "$SKILL_FILE"; then
      echo "OK: $sub/$base referenced from SKILL.md"
    else
      echo "MISSING: $sub/$base not referenced from SKILL.md (dead file)"
    fi
  done < <(find "$subdir" -maxdepth 1 -type f -not -name '.*')
done

# ---- Empty-heading detection (Fix E) -----------------------------------
# For each required ## heading, confirm there is at least one substantive
# (alphanumeric) line between it and the next ## heading.
REQUIRED_HEADINGS=(
  "## When this triggers"
  "## When this does not trigger"
  "## Required inputs"
  "## Inputs required"
  "## Workflow"
  "## Decision gates"
  "## Output format"
  "## Gotchas"
  "## Evaluation checklist"
)

for heading in "${REQUIRED_HEADINGS[@]}"; do
  # Skip if the heading isn't present at all (already reported as MISSING above
  # for the canonical names). awk extracts the body and checks for content.
  result=$(awk -v h="$heading" '
    BEGIN { in_section = 0; has_content = 0; found = 0 }
    {
      if ($0 ~ "^" h) { in_section = 1; found = 1; next }
      if (in_section && /^## /) { in_section = 0 }
      if (in_section) {
        # strip whitespace
        line = $0
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
        if (line == "") next
        # ignore lines that are only an HTML comment
        if (line ~ /^<!--.*-->$/) next
        # require at least one alphanumeric char
        if (line ~ /[A-Za-z0-9]/) has_content = 1
      }
    }
    END {
      if (!found) print "absent"
      else if (has_content) print "ok"
      else print "empty"
    }
  ' "$SKILL_FILE")

  if [ "$result" = "empty" ]; then
    echo "MISSING: $heading exists but has no content"
  fi
done

# ---- Tier 1 (Anthropic spec) -------------------------------------------

# Extract frontmatter values (between the first two `---` lines)
NAME_VAL=$(awk '/^---$/{n++; next} n==1 && /^name:/{sub(/^name:[[:space:]]*/, ""); gsub(/"|'\''/, ""); print; exit}' "$SKILL_FILE")
DESC_VAL=$(awk '/^---$/{n++; next} n==1 && /^description:/{sub(/^description:[[:space:]]*/, ""); print; exit}' "$SKILL_FILE")

# name: ≤64 chars, lowercase letters/digits/hyphens only, no reserved words
if [ -n "$NAME_VAL" ]; then
  if [ ${#NAME_VAL} -gt 64 ]; then
    echo "MISSING: name field is ${#NAME_VAL} chars (max 64 per Anthropic spec)"
  fi
  if ! echo "$NAME_VAL" | grep -qE '^[a-z0-9][a-z0-9-]*$'; then
    echo "MISSING: name '$NAME_VAL' must contain only lowercase letters, digits, and hyphens"
  fi
  if echo "$NAME_VAL" | grep -qiE 'anthropic|claude'; then
    echo "MISSING: name '$NAME_VAL' contains reserved word (anthropic/claude)"
  fi
fi

# name == parent directory basename
DIR_BASE=$(basename "$(cd "$SKILL_DIR" && pwd)")
if [ -n "$NAME_VAL" ] && [ "$NAME_VAL" != "$DIR_BASE" ]; then
  echo "MISSING: name '$NAME_VAL' does not match directory basename '$DIR_BASE'"
fi

# description: ≤1024 chars, third-person voice
if [ -n "$DESC_VAL" ]; then
  # strip surrounding quotes for length count
  DESC_STRIP=$(echo "$DESC_VAL" | sed -E 's/^"//;s/"$//;s/^'\''//;s/'\''$//')
  if [ ${#DESC_STRIP} -gt 1024 ]; then
    echo "MISSING: description is ${#DESC_STRIP} chars (max 1024 per Anthropic spec)"
  fi
  # Third-person check: bare "I " / "You " / "I'm" / "You're" near the start
  if echo "$DESC_STRIP" | grep -qE '^[[:space:]]*(I |I'\''m |You |You'\''re |You can |I can |I will |We )'; then
    echo "WARN: description appears to use first/second person — Anthropic recommends third-person voice"
  fi
fi

# Junk human-facing files inside the skill folder
for junk in README.md CHANGELOG.md INSTALL.md INSTALLATION.md INSTALL_GUIDE.md; do
  if [ -f "$SKILL_DIR/$junk" ]; then
    echo "MISSING: $junk inside skill folder — skills are for agents not humans (move outside)"
  fi
done

# Forward-slash check: backslash paths in markdown code spans/blocks
if grep -nE '`[^`]*\\[A-Za-z][^`]*`' "$SKILL_FILE" >/dev/null 2>&1; then
  echo "WARN: SKILL.md contains backslash paths in code spans — use forward slashes for cross-platform"
fi

# ---- Evals coverage (forward-looking — WARN, not MISSING) ---------------
EVALS_DIR="$SKILL_DIR/evals"
if [ -d "$EVALS_DIR" ]; then
  VALID_EVALS=0
  INVALID_EVALS=0
  while IFS= read -r ef; do
    if grep -q '"query"' "$ef" && grep -q '"expected_behavior"' "$ef"; then
      VALID_EVALS=$((VALID_EVALS + 1))
    else
      INVALID_EVALS=$((INVALID_EVALS + 1))
      echo "WARN: evals/$(basename "$ef") missing 'query' or 'expected_behavior' field"
    fi
  done < <(find "$EVALS_DIR" -maxdepth 1 -type f -name '*.json' -not -name '.*')
  if [ "$VALID_EVALS" -ge 3 ]; then
    echo "OK: $VALID_EVALS evals (Anthropic recommends ≥3)"
  else
    echo "WARN: only $VALID_EVALS valid evals (Anthropic recommends ≥3 — see skill-improver/assets/eval-template.json)"
  fi
else
  echo "WARN: no evals/ folder — recommended ≥3 evals per skill (see skill-improver/assets/eval-template.json)"
fi

echo
echo "This is a structural check only. Human/agent review is still required."

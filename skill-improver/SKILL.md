---
name: skill-improver
description: 'Review or improve an existing agent skill (SKILL.md structure, triggers, permissions, splitting). Not for new skills — use skills-build.'
allowed-tools: Read, Edit, Grep, Glob, Bash
---

# Skill Improver

Inspect an existing agent skill and improve it safely. The goal is to make it more reliable, safer, clearer, easier to trigger correctly, and easier to evaluate. Preserve what works. Fix what is vague, risky, missing, or bloated. Do not rewrite aggressively just because you can.

## Safety modes

Classify the requested work into one of four modes before touching anything:

1. **Review-only** — read the skill and produce findings. No edits.
2. **Safe-edit** — apply low-risk improvements that preserve intent: clearer wording, sharper trigger description, missing sections, formatting, stronger gotchas, more explicit output format.
3. **Permission-changing or destructive** — ask the user before any change that expands `allowed-tools`, deletes files, removes major sections, alters core behavior, renames the skill, moves files, modifies scripts, or splits the skill.
4. **Structural-defect repair** — adding *missing* required frontmatter fields (`name`, `description`, `allowed-tools`) is not a permission change; it is documentation of behavior the skill already exhibits. Infer the minimum tools the visible workflow uses (shell snippets ⇒ `Bash`; file creates ⇒ `Write`; file edits ⇒ `Edit`). Apply the fix and flag the inference in the diagnosis. Do **not** block on user approval for adding a missing field — only for *expanding* a field that is already present.

If the user's request is ambiguous, start in review-only mode and ask before editing.

## When this triggers

Reviewing or improving EXISTING skills only. For greenfield skill creation, use `skills-build`.

Use this skill when the user asks to:

- Check, audit, or review an existing skill or `SKILL.md`.
- Improve triggers, descriptions, gotchas, gates, output format, or evaluation checklist.
- Review or tighten `allowed-tools` permissions.
- Validate folder structure (`references/`, `assets/`, `scripts/`).
- Split an over-broad skill into focused ones.
- Diagnose why a skill is not triggering or is triggering too often.
- Refactor a skill without changing its purpose.

## When this does not trigger

- Creating a brand-new skill from scratch → use `skills-build`.
- Anything not about agent skills.
- Generic writing edits unrelated to a skill.
- Project-level instructions like `AGENTS.md` / `CLAUDE.md`, unless the question is specifically whether content should move into a skill.

## Required inputs

- The skill folder path.
- Whether the user wants review-only or edits.
- Whether permission changes are allowed.
- Whether scripts may be edited.
- Whether the user wants minimal cleanup or a deeper refactor.

If these are missing but the skill files are available, proceed in review-only mode and state assumptions.

## Inspection workflow

1. Locate the skill folder and confirm `SKILL.md` exists.
2. Inspect the folder structure (which of `references/`, `assets/`, `scripts/` exist and what is in them).
3. Run `bash scripts/review-skill-structure.sh <path>/SKILL.md` to mechanically detect missing sections.
4. Read `SKILL.md` end-to-end. Note declared `name`, `description`, and `allowed-tools`.
5. Check whether the description is an agent-facing trigger spec (not human marketing copy) and whether overlapping sibling skills are explicitly named as non-triggers.
6. Check for clear `When this triggers` and `When this does not trigger` sections.
7. Check that the workflow is actionable, gates are surfaced as a list, output format is explicit, and gotchas are concrete (not decorative).
8. Check whether long material belongs in `references/`, templates in `assets/`, deterministic checks in `scripts/`, and whether any existing files in those subfolders are dead (never referenced from SKILL.md).
9. Classify `allowed-tools` as minimal / acceptable / risky / missing — load `references/permission-review.md` for the classification rubric.
10. Check whether the skill is trying to cover more than one workflow.
11. Produce a diagnosis using the review-only template in `assets/skill-review-template.md`.
12. **If edits are approved:** apply changes following the improvement workflow in `references/permission-review.md`. Ask before any change in the "Edit approval rules" list below.
13. Re-read the changed files.
14. **Hard gate.** Re-run `bash scripts/review-skill-structure.sh <path>/SKILL.md`. If any MISSING remains, the skill is **not improved**. Either fix the missing section or downgrade the verdict to "Needs major refactor" with structural failures listed as the top issue. Record pre-edit and post-edit MISSING/OK counts in the output.
15. Summarize what changed using the post-edit output format.

## Decision gates

- If the user's request is ambiguous about edit scope, default to review-only and ask.
- If a finding requires expanding `allowed-tools`, deleting/moving files, modifying scripts, renaming, or splitting — stop and ask before applying.
- If the skill covers two distinct workflows, recommend a split but do not split without approval.
- If `references/`/`assets/`/`scripts/` contain files never referenced from SKILL.md, flag them as dead and propose wiring or deletion — do not delete without approval.
- If `scripts/review-skill-structure.sh` reports MISSING sections, they must be fixed before step 14 passes, or the verdict downgrades to "Needs major refactor."

## Edit approval rules

Edit without asking only when ALL are true:

- The user explicitly asked you to improve the skill.
- The change is low-risk and preserves the skill's purpose.
- The change does not expand permissions.
- The change does not delete files, modify scripts, rename, or split the skill.
- Adding a missing required frontmatter field counts as structural-defect repair (mode 4), not permission expansion. Apply without asking. Record the inference in the diagnosis.

Ask before:

- *Expanding* an existing `allowed-tools` line (especially `Bash`, `Write`, `Edit`, `MultiEdit`, network/browser/external) — adding a missing `allowed-tools` is mode 4, not expansion.
- Removing permissions that may still be needed.
- Deleting or moving files.
- Renaming the skill.
- Splitting one skill into multiple.
- Rewriting the skill in full.
- Modifying scripts or external service usage.
- Adding commands that may affect files or systems.

Use direct language:

```md
I found one risky change: adding `Bash` would let the skill run commands. Do you want me to add it, or should I keep the skill read/edit-only?
```

## Output format — review-only mode

Fill out `assets/skill-review-template.md` and return it. The template covers: verdict, structural check, main issues, permissions classification, safe vs approval-required changes, suggested next step. The `## Structural check` field is required, not optional — fill it from the script run in workflow step 3 (and step 14 if edits were applied).

## Output format — after edits

```md
# Skill Improved

## Files changed
- `<file>`

## Changes made
- <change>
- <change>

## Permissions
<what changed or did not change>

## Remaining issues
- <issue, if any>

## Suggested test
<one test prompt the user can run>
```

## Gotchas

- Do not expand `allowed-tools` without explicit user approval.
- Do not modify `scripts/` files without asking — they may be tested or shared.
- Do not delete or move files without asking.
- Do not rename the skill without asking.
- Do not split a skill without asking.
- Do not rewrite the whole skill when a surgical edit is enough.
- Do not treat a clean-looking skill as good if the trigger description is vague — agent routing depends on the description.
- Do not leave generic gotchas ("be careful", "think step by step") in place.
- Do not bury stop conditions inside paragraphs — surface them as a decision-gates list.
- Do not confuse always-on project instructions (`CLAUDE.md`/`AGENTS.md`) with skill-specific workflow content.
- Do not add references, assets, or scripts just to make the folder look complete. If a file is never referenced from SKILL.md, it is dead — wire it in or delete it.

## References

- `references/permission-review.md` — load when classifying `allowed-tools`, diagnosing common SKILL.md problems, or running the full 15-step improvement sequence.

## Assets

- `assets/skill-review-template.md` — fill this out for review-only output (workflow step 11).
- `assets/eval-template.json` — canonical structure for skill evals (one positive + one negative + one edge-case per skill, ≥3 total per Anthropic spec).

## Scripts

- `scripts/review-skill-structure.sh` — run on the target SKILL.md (workflow step 3 + step 14 hard gate) to mechanically detect missing frontmatter fields, required sections, length-budget violations, dead subfolder files, empty headings, frontmatter-spec violations (name/description/voice), and eval coverage.
- `scripts/list-skill-evals.sh` — fleet-wide eval coverage survey across `~/.claude/skills/`. Run when the user asks "which skills have evals" or before a periodic skill-fleet audit.

## Evaluation checklist

After improving a skill, check:

- Does it still do one focused job?
- Is the trigger description precise, with overlapping siblings named as non-triggers?
- Are non-trigger cases explicit?
- Are permissions minimal and justified?
- Are approval boundaries explicit?
- Are workflow steps actionable and gates surfaced as a list?
- Is the output format clear?
- Are gotchas concrete?
- Is every file under `references/`/`assets/`/`scripts/` referenced from SKILL.md?
- Can the user test the skill with one realistic prompt?
- Does the skill have an `evals/` folder with ≥3 valid evals (one positive, one negative-trigger, one edge-case)? See `assets/eval-template.json`.

**Exit criterion.** The skill is not improved unless: (1) `review-skill-structure.sh` reports zero MISSING, (2) every checklist item above is yes, (3) every file under `references/`, `assets/`, `scripts/` is referenced from `SKILL.md`. If any of the three fails, the verdict is at most "Needs minor cleanup" and the failures are listed in the output.

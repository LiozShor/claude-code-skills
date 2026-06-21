---
name: skills-build
description: "Build a NEW agent skill from a real repeated workflow. Use when the user asks to create a skill, scaffold `SKILL.md`, convert a recurring task into a skill, or decide whether a process deserves a skill. Do NOT use to review or audit an existing skill — use `skill-improver` for that."
allowed-tools: Read, Write, Edit, Bash
---

# Skills Build

Create focused, reliable, measurable agent skills from real workflows. A skill is a reusable procedural capability — it teaches the agent when to act, how to act, what decisions to make, what tools/references to use, what output to produce, and what mistakes to avoid. The goal is not impressive documentation; it is a skill that improves agent performance on repeated work.

## When this triggers

Building NEW skills only. For audits or improvements of existing skills, use `skill-improver`.

Use this skill when the user asks to:

- Create a new skill.
- Convert a recurring workflow into a skill.
- Scaffold a `SKILL.md` file.
- Decide whether something should be a skill.
- Build a skill for Claude Code, Codex, Gemini, OpenCode, Copilot, or any environment supporting skill folders.

## When this does not trigger

- Reviewing, auditing, or improving an existing skill → use `skill-improver`.
- One-off requests, or work that a `CLAUDE.md` / `AGENTS.md` line already covers.
- General prompting advice, or generic knowledge the model already has.
- Inventing a skill with no real workflow evidence and no concrete use case.

If the user asks for a skill but the workflow is too vague, create a minimal draft, mark assumptions explicitly, and do not pretend it is production-ready.

## Skill decision filter

Create a skill when most of these are true:

- The same multi-step process repeats across sessions.
- The workflow has decision points, gates, or conditional logic.
- The task requires specific deliverables in specific formats.
- The process uses reference material too large for always-on context.
- Other agents or team members should run the same process consistently.
- The workflow benefits from scripts, templates, or reusable assets.
- The user has examples of past failures or edge cases.

Do not create a skill when a `CLAUDE.md`/`AGENTS.md` rule covers it, when it is one-off, when there is no clear trigger, or when the only reason is that "a skill sounds nice."

## Inputs required

- The repeated workflow being captured (concrete steps, not abstract goal).
- Real failure examples or edge cases.
- Target skill folder path. Use `.claude/skills/<name>/` for project skills or `~/.claude/skills/<name>/` for user-global. **NEVER use `.agent/skills/`** — Claude Code does not load skills from there, so `/<skill-name>` will not be recognized (real incident: 2026-05-03 `security-deep-audit` was committed under `.agent/skills/` and was invisible to the harness until moved).
- Whether scripts/assets are needed.

## Workflow

1. Identify the repeated workflow and confirm it passes the decision filter.
2. Pick a lowercase kebab-case name (see `references/skill-design-reference.md` for naming rules).
3. Copy `assets/skill-template.md` as the starting `SKILL.md` scaffold.
4. Load `references/skill-design-reference.md` to flesh out frontmatter description, body structure, and gotcha quality.
5. Write the frontmatter `description` as a precise agent-facing trigger spec, naming any sibling skill explicitly as a non-trigger to prevent router overlap.
6. Set `allowed-tools` to the minimum needed.
7. Fill `When this triggers` and `When this does not trigger` with concrete cases.
8. List required inputs.
9. Write the workflow as actionable numbered steps.
10. Add decision gates (stop/continue/escalate rules).
11. Define the output format explicitly.
12. Add concrete gotchas based on real or likely failures.
13. Move long explanations into `references/`, templates into `assets/`, deterministic checks into `scripts/`.
14. Add an evaluation checklist.
15. Author ≥3 evals in `evals/` (one positive trigger, one negative trigger, one edge-case). Use `~/.claude/skills/skill-improver/assets/eval-template.json` as the canonical structure. Without evals, "built" is unmeasurable.
16. Run `bash scripts/validate-skill.sh <path>/SKILL.md` to confirm structural soundness.
17. **Hard gate.** Run `bash ~/.claude/skills/skill-improver/scripts/review-skill-structure.sh <path>/SKILL.md`. If any MISSING remains, the skill is **not built**. Either fix the section or downgrade the deliverable to "Draft (incomplete)" with structural failures listed at the top of the output.
18. Review for scope creep and remove generic filler.

## Decision gates

- If required inputs are missing, ask one targeted question or proceed with stated assumptions.
- If the task is one-off, do not create a skill unless the user explicitly insists.
- If one skill contains two workflows, split it.
- If a step can be done deterministically by code, prefer a script.
- If the skill needs current external facts, require live source verification.
- If a workflow step fails, stop and report — do not pretend it passed.
- If the output format is unclear, use a minimal standard format and flag the assumption.

## Output format

When the user asks to build a skill, return:

```md
# Proposed Skill

## Folder
`.claude/skills/<skill-name>/`

## Files
- `SKILL.md`
- `evals/01-positive-trigger.json`
- `evals/02-negative-trigger.json`
- `evals/03-edge-case.json`
- `references/...` (only if used)
- `assets/...` (only if used)
- `scripts/...` (only if used)

## SKILL.md
<full content>

## Notes
<assumptions, missing inputs, suggested evals>
```

If creating actual files, write them directly to the folder.

## Gotchas

- Do not write the description for humans — write it as an invocation trigger for agents, and explicitly name overlapping sibling skills as non-triggers.
- Do not merge unrelated workflows into one skill. One workflow = one skill.
- Do not create a skill before understanding the repeated process.
- Do not hide branching logic inside prose paragraphs — surface it as a decision gate.
- Do not rely on the model for deterministic validation a script can run.
- Do not keep large reference material in `SKILL.md`; move it to `references/`.
- Do not treat the first version as final. Skills need evaluation and cleanup.
- Do not place skills under `.agent/skills/`, `docs/`, or any custom directory — Claude Code only auto-loads from `.claude/skills/` (project) and `~/.claude/skills/` (user). A skill outside those paths is dead code.

For long-form gotcha examples and anti-patterns ("Be careful" / "Do a good job" / etc.), see `references/skill-design-reference.md`.

## References

- `references/skill-design-reference.md` — load when fleshing out frontmatter, naming, body structure, or distinguishing good vs bad gotchas.

## Assets

- `assets/skill-template.md` — copy as the starting scaffold for any new `SKILL.md` (step 3).

## Scripts

- `scripts/validate-skill.sh` — run on the new `SKILL.md` (step 15) to confirm frontmatter, title, trigger/workflow/gotcha sections exist.

## Evaluation checklist

- Does the name describe one focused workflow?
- Is the description an agent-facing trigger spec, with sibling-skill non-triggers named?
- Is `When this does not trigger` explicit?
- Are workflow steps actionable?
- Are decision gates surfaced as a list?
- Is the output format explicit?
- Are gotchas concrete (no decorative filler)?
- Is long material in `references/`, templates in `assets/`, deterministic checks in `scripts/`?
- Does `scripts/validate-skill.sh` pass on the new file?
- Can the skill be tested against a real example prompt?
- Does the skill have an `evals/` folder with ≥3 valid evals (positive trigger, negative trigger, edge case)?

**Exit criterion.** The skill is not built unless: (1) `validate-skill.sh` passes, (2) `~/.claude/skills/skill-improver/scripts/review-skill-structure.sh` reports zero MISSING, (3) every checklist item above is yes, (4) `evals/` has ≥3 valid entries. If any of the four fails, the deliverable is at most "Draft" and the failures are listed at the top of the output.

Curate, do not generate. A useful skill is built from repeated work, tested against real tasks, improved through failures, and deleted when it creates noise.

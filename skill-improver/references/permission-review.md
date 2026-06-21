# Permission Review & Improvement Reference

Load this when classifying `allowed-tools`, diagnosing common SKILL.md problems, or running the full improvement sequence on an existing skill. Kept out of always-on context to avoid bloat.

## Principle

Permissions are not decoration. They define what the agent can do while using the skill. Prefer the smallest set of tools that can complete the workflow.

## Common permission levels

### Read-only review

```yaml
allowed-tools: Read, Grep, Glob
```

Use for skills that only inspect files and produce recommendations.

### File editing

```yaml
allowed-tools: Read, Write, Edit, MultiEdit, Grep, Glob
```

Use when the skill needs to create or modify files.

### Command execution

```yaml
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
```

Use only when command execution is required. Explain why.

## Approval required before adding

Ask the user before adding tools that can:

- Run shell commands (`Bash`).
- Create files (`Write`).
- Modify files (`Edit`, `MultiEdit`).
- Delete files.
- Access network or external systems.
- Send messages.
- Access secrets.
- Change production systems.

## Permission classification

For every permission issue, label it as one of:

- **Minimal** — only the tools required for the skill.
- **Acceptable** — slightly broader but justified.
- **Risky** — includes powerful tools without clear need.
- **Missing** — skill cannot perform its workflow with the declared tools.

For each finding, report:

- Current permission line.
- Why it is needed or why it is risky.
- Suggested change.
- Whether user approval is required before applying.

## Approval-question pattern

Use direct language:

```md
I found one risky change: adding `Bash` would let the skill run commands. Do you want me to add it, or should I keep the skill read/edit-only?
```

One question, two clear options, no padding.

## Common problems and fixes

### Vague description

Bad:

```yaml
description: "Helps improve skills."
```

Better:

```yaml
description: "Review and improve an existing agent skill. Use when checking SKILL.md structure, triggers, permissions, gotchas, decision gates, output format, folder layout, or whether the skill should be split. Do NOT use to create a new skill — use `skills-build` for that."
```

A good description names sibling skills explicitly as non-triggers to prevent router coin-flips.

### Missing non-trigger cases

Add a `When this does not trigger` section so the skill does not pollute unrelated tasks. List the specific sibling skill that should win in each excluded case.

### No decision gates

Add gates that tell the agent when to stop, ask, continue, or escalate. Surface them as a bulleted list, not buried in prose.

### Weak gotchas

Replace generic advice with concrete failure patterns.

Bad:

```md
- Be careful.
- Think step by step.
```

Better:

```md
- Do not expand `allowed-tools` without explicit user approval.
- Do not modify `scripts/` files without asking — they may be tested or shared.
```

### Over-broad skill

If a skill covers two distinct workflows, recommend splitting. Do not split without asking — file moves are destructive.

### Bloated SKILL.md

Move long examples, background, or reference material into `references/`. Keep SKILL.md as the router and core workflow. Target ~120–160 lines.

### Missing templates

If the skill repeatedly produces the same output shape, add a template under `assets/`.

### Missing scripts

If the skill performs deterministic checks, add a script under `scripts/`. Ask before adding or editing executable scripts.

### Dead `references/` / `assets/` / `scripts/`

If a subfolder file exists but is never invoked from the SKILL.md workflow, either wire it in or delete it. Unreferenced files are a maintenance trap and a token cost.

## Improvement workflow (when edits are approved)

1. Understand the original structure before editing.
2. Preserve the skill's purpose.
3. Improve the frontmatter description (precise trigger spec, name overlapping siblings as non-triggers).
4. Tighten permissions only if safe; ask before expanding.
5. Add missing trigger and non-trigger sections.
6. Add required inputs.
7. Make workflow steps actionable.
8. Add decision gates as a visible list.
9. Add or improve the output format.
10. Replace vague gotchas with concrete ones.
11. Add the evaluation checklist.
12. Move oversized material into `references/`.
13. Add templates or scripts only when justified.
14. Re-read the updated skill end-to-end.
15. Summarize exact changes and remaining risks for the user.

## Quality bar

A strong skill has: focused name, precise agent-facing description, clear triggers, clear non-triggers, required inputs, concrete workflow, visible decision gates, explicit output format, concrete gotchas, evaluation checklist, minimal permissions, references/assets/scripts only when used, no vague filler.

# Skill Design Reference

Load this file when fleshing out frontmatter, naming a skill, or structuring `SKILL.md` body sections. Kept out of always-on context to avoid bloat.

## Good skill characteristics

A good skill is focused, triggerable, procedural, measurable, and failure-aware.

It has:

- One clear workflow.
- A precise trigger description.
- Explicit non-trigger cases.
- Required inputs.
- Workflow steps.
- Decision gates.
- Output format.
- Gotchas.
- Optional references, assets, and scripts.

## Bad skill characteristics

A bad skill is broad, vague, generic, and untested.

Warning signs:

- The skill name could apply to almost anything.
- The description is written like marketing copy.
- The workflow is just generic advice.
- There are no stop conditions.
- The skill contains multiple unrelated workflows.
- There are no gotchas.
- It depends on the model for deterministic checks.
- It duplicates always-on project instructions.

## Naming rules

The skill name must be lowercase, kebab-case, short, action-oriented when possible, and specific enough to describe one workflow.

Per the Agent Skills spec, the `name` must also: be **≤64 characters**; contain **only lowercase letters, digits, and hyphens** (no consecutive `--`, no leading/trailing `-`); and **match the skill's parent directory name** exactly (folder `airtable/` ⇒ `name: airtable`). `review-skill-structure.sh` enforces all three.

Good names:

- `tech-research`
- `deploy-checklist`
- `invoice-review`
- `support-triage`
- `skills-build`

Bad names:

- `helper`
- `super-workflow`
- `general-agent`
- `everything-automation`
- `make-things-better`

## Frontmatter rules

Every `SKILL.md` must start with YAML frontmatter:

```yaml
---
name: skill-name
description: "Clear trigger spec for agents, not a human-facing summary."
allowed-tools: Read, Grep
---
```

The `description` is the most load-bearing field — it is what the model uses to decide whether to invoke the skill. It must include trigger phrases, task types, boundaries, AND an explicit non-trigger pointer to any sibling skill that overlaps. Per the spec it must be **non-empty and ≤1024 characters**. `allowed-tools` is optional and experimental — set it to the minimum tools needed; the spec defines it as a space-separated list, though Claude Code also accepts commas.

Bad description:

```yaml
description: "Helps with research."
```

Useless. It does not tell the agent when to invoke the skill.

Good description:

```yaml
description: "Research current technical documentation before recommending or implementing libraries, frameworks, dependencies, cloud services, AI tooling, or architecture patterns. Use when the user asks 'what should I use', 'which library', 'best current approach', or implementation planning in fast-moving technical domains."
```

If a sibling skill has overlapping triggers, name it explicitly in the description as a non-trigger:

```yaml
description: "Build a NEW agent skill ... Do NOT use to review or audit an existing skill — use `skill-improver` for that."
```

This kills router coin-flips between similar skills.

## Body structure

Use `assets/skill-template.md` as the starting scaffold. The canonical sections are:

- `# Skill Title` + 1–2 line purpose
- `## When this triggers`
- `## When this does not trigger`
- `## Inputs required`
- `## Workflow`
- `## Decision gates`
- `## Output format`
- `## Gotchas`
- `## References` / `## Assets` / `## Scripts` (only the ones used)
- `## Evaluation checklist`

Not every skill needs every section. Keep it focused. Do not pad. Target ~120–160 lines for SKILL.md; relocate longer material here under `references/`.

## Gotchas — examples

Good gotchas (concrete, name a specific failure mode):

- Do not write the description for humans. Write it as an invocation trigger for agents.
- Do not merge unrelated workflows into one skill.
- Do not create a skill before understanding the repeated process.
- Do not hide important branching logic inside prose.
- Do not rely on the model for deterministic validation if a script can check it.
- Do not keep large reference material in `SKILL.md`; move it into `references/`.
- Do not treat the first version as final. Skills need evaluation and cleanup.

Bad gotchas (decorative — delete these):

- Be careful.
- Do a good job.
- Think step by step.
- Make it accurate.

A gotcha earns its place by naming a specific failure pattern that has actually happened or is demonstrably likely. If removing it would not change agent behavior, remove it.

## Folder structure

```text
.claude/skills/<skill-name>/
├── SKILL.md
├── references/   # long material loaded on demand
├── assets/       # templates copied/filled in
└── scripts/      # deterministic checks
```

Only include folders you actually populate and reference from `SKILL.md`. Empty subfolders or unreferenced files are dead weight — either wire them into the workflow or delete them.

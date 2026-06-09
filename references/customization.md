# Customizing design-log for your project

This skill works out of the box with **zero setup** — drop it in and run `/design-log`. Everything below is optional tuning. Read it only when you want to adapt the skill to a specific repo's conventions.

## Defaults the skill assumes

| Thing | Default | Where it's referenced |
|-------|---------|----------------------|
| Where logs live | `.agent/design-logs/` | SKILL.md, protocol-detail.md, template |
| Log filename | `NNN-kebab-case-description.md` (sequential) | protocol-detail.md § Naming |
| Catalog file | `.agent/design-logs/INDEX.md` | Phase A1, C, E |
| Running TODO file | `.agent/current-status.md` | Phase D housekeeping, E |
| Research tool | context7 / Tavily MCP if installed, else `WebSearch` + `WebFetch` | Phase B2 |
| Git workflow | your project's standard commit/push flow | Phase D |

If those defaults are fine, you're done — no edits needed. The `.agent/design-logs/` and `.agent/current-status.md` files are created on first use.

## Optional adaptations

**1. Change where logs live.** Prefer `docs/design/` or `.claude/design-logs/`? Find-and-replace `.agent/design-logs/` in `SKILL.md` + `references/protocol-detail.md` + `assets/design-log-template.md`. Same for `.agent/current-status.md`.

**2. Use your own research tool.** Phase B2 uses context7 MCP (library docs) or Tavily MCP (general web) when present and falls back to the built-in `WebSearch`/`WebFetch` otherwise. If you have a dedicated research skill/subagent, mention it in the "Optional delegation" note in `protocol-detail.md` § B2. If you want to *force* a specific MCP, edit `allowed-tools` in `SKILL.md` to add/remove its tool names.

**3. Wire in a git/commit skill.** This skill defers to "your project's standard git workflow" for all commit/push/merge ops. If you have a dedicated git skill (e.g. one that enforces conventional commits or a branch-guard), name it in `protocol-detail.md` § Phase D housekeeping and add it to `allowed-tools` via `Skill`.

**4. Add log-number reservation (parallel sessions).** With several Claude sessions open at once, two can pick the same `NNN`. If that's a risk, add a small script that atomically reserves the next number (e.g. via git refs like `refs/dl-claims/*`, or a lock file) and reference it in `protocol-detail.md` § A0 + § C step 3. Without one, the skill just computes `max(existing)+1` and warns about collisions.

**5. Add a close script.** Phase E sets `[COMPLETED]` by editing the DL file + `INDEX.md` directly. If you want guardrails (PII scan, lint, consistent staging), add a `close-design-log.sh <NNN>` script and point Phase E at it.

**6. Plug in subagent-driven implementation.** Phase D mentions an optional subagent-driven implementation skill for parallel tasks. If you have one, name it; otherwise the skill implements directly.

## Removing the "books" framing

Phase B leans on a books → articles → case-studies tier model (see `research-sources.md`). If your team prefers docs-only research, trim Tier 1 and adjust `research-sources.md` to your preferred source list.

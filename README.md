# design-log — a "Stop & Think" planning skill for Claude Code

A reusable Claude Code skill that forces **research-driven design before coding**. Instead of jumping straight to implementation, it runs a 5-phase protocol — Discovery → Research → Explore & Document → Implement → Test Handoff — gated by a single approval and recorded in a persistent design-log file.

Built on top of Claude Code's plan mode. One approval gate, one documented artifact per feature.

## Install

Drop the `design-log/` folder into your skills directory:

- **Per-project:** `<your-repo>/.claude/skills/design-log/`
- **Global (all projects):** `~/.claude/skills/design-log/`

That's it. No build step, no config. Then in Claude Code run:

```
/design-log add a rate limiter to the upload endpoint
```

## What it does

1. **Discovery** — checks existing design logs, scans the codebase for reuse, asks you 5+ clarifying questions before touching anything.
2. **Research** — reads 3+ sources on the relevant domain (resilience, search UX, concurrency, etc.) and extracts principles/patterns/anti-patterns.
3. **Explore & Document** — enters plan mode, explores your code, writes a `[DRAFT]` design log, then asks for approval via plan mode's exit gate.
4. **Implement** — only after approval. Tracks status, records deviations.
5. **Test Handoff** — persists outstanding tests so nothing is lost between sessions.

The artifact lives at `.agent/design-logs/NNN-description.md` (created automatically).

## Requirements

- **Claude Code** with plan mode (`EnterPlanMode` / `ExitPlanMode`).
- A **git repo** (the skill checks branch state and won't implement on `main`).
- A **web research tool** — works with any of:
  - **Built-in `WebSearch` + `WebFetch`** — always available, zero setup. ✅ default
  - **Tavily MCP** — better multi-source web research, if you have it installed.
  - **context7 MCP** — for library/framework/SDK/API docs, if you have it installed.

  The skill prefers an MCP tool when present and falls back to the built-ins otherwise — so it runs fine with nothing extra installed.

## Customizing

It works with zero config. To adapt log location, research tool, git workflow, or add log-number reservation for parallel sessions, see `references/customization.md`.

## Files

```
design-log/
├── SKILL.md                          # the protocol router + hard gates
├── README.md                         # this file
├── assets/
│   └── design-log-template.md        # the Section 1–8 design-log template
└── references/
    ├── protocol-detail.md            # full step-by-step for each phase
    ├── research-sources.md           # book/article/case-study tiers by domain
    └── customization.md              # optional per-project adaptation
```

## License

Do whatever you want with it. Share freely.

---
name: design-log
description: 'Plan non-trivial features, fixes, refactors, UI/workflow changes before coding — clarify, research, get approval (Stop & Think protocol).'
model: opus
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, WebSearch, WebFetch, mcp__tavily__tavily_search, mcp__tavily__tavily_extract, mcp__exa__web_search_exa, mcp__exa__crawling_exa, mcp__exa__deep_researcher_start, mcp__exa__deep_researcher_check, mcp__firecrawl__firecrawl_search, mcp__firecrawl__firecrawl_scrape, mcp__firecrawl__firecrawl_crawl, mcp__firecrawl__firecrawl_extract, mcp__context7__resolve-library-id, mcp__context7__query-docs, Task, Skill, EnterPlanMode, ExitPlanMode, AskUserQuestion
---

# Design Log Skill

Generic "Stop & Think" protocol that combines **research-driven design** with Claude Code's plan mode. Research first, then code. One workflow, one approval gate, persistent documentation. Project-specific rules belong in your repo docs or in clearly labeled adaptation notes — not in this skill.

> **Portability note:** This skill is self-contained. It works in any git repo with no extra setup. Optional integrations (Tavily MCP for research, custom git/subagent skills) are used *only if you have them installed* and degrade gracefully to built-in tools otherwise. See `references/customization.md` to adapt paths, the research tool, or the git workflow to your project.

## How This Integrates With Plan Mode

- **Plan mode** handles codebase exploration (reading files, searching code, understanding architecture).
- **Research phase** handles domain knowledge gathering (books, articles, case studies) BEFORE codebase exploration.
- **Design log** handles persistent documentation and status tracking across sessions.
- **They share a single approval gate** via `ExitPlanMode` — no double-approval.

## When This Triggers

Use this skill when the user explicitly invokes `/design-log`, asks for a design log, requests stop-and-think planning, or asks for documented design before a non-trivial feature, bug fix, refactor, workflow change, UI change, automation, or architecture decision.

Implicit use is appropriate only when the task clearly needs persistent design documentation before implementation. If the task is small and the user did not ask for `/design-log`, use the normal workflow instead.

## When this does not trigger

Not every task needs a design log. Skip for:

- Single-line fixes, typos, small tweaks.
- Tasks where the user gives very specific instructions with no ambiguity and does not explicitly invoke `/design-log`.
- Pure research or exploration questions — answer them directly instead.
- Routine implementation that is already covered by an existing `[APPROVED]` design log — extend the existing log instead of creating a new one.

For these, just do the work directly — no plan mode, no design log. Even when skipping, if the task touches a non-trivial domain, consider a quick 2-minute research check before implementing.

## Required Inputs

Before writing the design log, identify:

- The project root and current branch/worktree state.
- The requested change and the user's success criteria.
- Relevant prior logs, unfinished logs, and prior research.
- The domain(s) that need research.
- The existing code paths, helpers, tests, docs, and architecture diagrams that may be reused.
- Whether implementation should continue after approval or stop at the approved plan.

If an input is missing, ask through `AskUserQuestion` unless existing logs, user instructions, or pre-scan findings already answer it.

## Decision Gates

Stop and wait when:

- The user has not answered required Phase A questions.
- Research is incomplete.
- `EnterPlanMode` has not been called before Phase C exploration.
- The design log has not been saved with `[DRAFT]` status.
- `ExitPlanMode` approval has not been granted.
- The next action would merge to `main`, delete a branch, change secrets, perform destructive operations, or run an undocumented production-impacting command.

Continue without another approval only after `ExitPlanMode` approval, and only for routine implementation decisions inside the approved plan.

## Workflow (Protocol)

The protocol runs in five phases. Each phase summary below is enough to know what to do; the full step-by-step procedure for every phase lives in `references/protocol-detail.md` — load it when you actually enter the phase.

### Phase A Is Non-Negotiable When User Invokes `/design-log`

If the user explicitly typed `/design-log` (or otherwise invoked this skill by name), Phase A clarifying questions are **mandatory** — "specific instructions" and "seems simple" are NOT valid reasons to skip. The user asked for the Stop & Think protocol; give them the Stop & Think protocol. Silently jumping to implementation is a protocol violation.

The "When this does not trigger" section above applies to deciding whether to invoke the skill in the first place — NOT to partially running it. If you run the skill, you run Phase A. If you believe the task genuinely doesn't warrant Phase A, say so out loud before proceeding: "Skipping Phase A questions because [specific reason] — proceed or ask questions anyway?" and wait for the user.

### Planning Phases Come Before Any "Just Build It" Instinct

During Phases A, B, and C (Discovery, Research, Explore & Document) the planning discipline takes priority over any "prefer action / minimize interruptions" instinct:

- Phase A: ask decision-shaping clarifying questions via `AskUserQuestion`; wait for answers.
- Phase B: do the research — do not skip because "the task seems simple".
- Phase C: exit plan mode and wait for user approval — do not self-approve and proceed.

Once the user approves via `ExitPlanMode`, execute the approved plan end-to-end, stopping only at the hard gates (merge to main, destructive ops, etc.).

### Phase A — Discovery

**STOP. Do not implement anything.** Steps: A0 Branch Setup → A1 Check Existing Logs → A2 Light Codebase Pre-Scan → A3 Ask Clarifying Questions via `AskUserQuestion` (usually 5+) → A4 Wait for answers. Full procedure in `references/protocol-detail.md` § Phase A.

### Phase B — Research

**Mandatory.** B0 Fetch current date via `Bash` (`date +%Y-%m-%d`) BEFORE any research call → B1 Identify domain → B2 Read 3+ sources via your research tool → B3 Extract principles, patterns, anti-patterns, deviations into Section 3 of the log. Time-box 5–10 min. Full procedure + research rules + domain table in `references/protocol-detail.md` § Phase B.

> **HARD GATE — DATE FIRST:** Before any research/web call, run `Bash` with `date +%Y-%m-%d` to anchor "current" in real time. The session's date context can be stale or absent. Pass the fetched date into recency-dependent queries ("as of YYYY-MM-DD", "latest stable", "deprecated in YYYY"). Do NOT rely on training-data dates or assumed year.

> **Research tool (use whichever you have):** Read 3+ sources using any of these, picked by job. Tool-name prefixes follow your own MCP server names.
> - **context7 MCP** (`mcp__context7__resolve-library-id` → `mcp__context7__query-docs`) — library/framework/SDK/API docs.
> - **Exa MCP** (`mcp__exa__web_search_exa`, `deep_researcher_start`/`deep_researcher_check`, `crawling_exa`) — semantic/neural source discovery + agentic deep-research; best for "find the best writing on X".
> - **Tavily MCP** (`mcp__tavily__tavily_search` / `mcp__tavily__tavily_extract`) — general multi-source web search + extraction.
> - **Firecrawl MCP** (`mcp__firecrawl__firecrawl_search`/`firecrawl_scrape`/`firecrawl_crawl`/`firecrawl_extract`) — full-page extraction, JS-heavy sites, crawling a whole docs site.
> - **Built-in `WebSearch` + `WebFetch`** — always available, zero setup; the universal fallback.
>
> All names are in `allowed-tools`. If an MCP isn't installed it simply won't be callable — fall back to the built-ins. Any path satisfies Phase B.

### Phase C — Explore & Document

> **HARD GATE — READ BEFORE ANY TOOL CALL IN THIS PHASE:**
> The FIRST tool call in Phase C **must** be `EnterPlanMode`. Do NOT run Glob/Grep/Read for codebase exploration, and do NOT call `Write`/`Edit` on the design log file, until plan mode is active. The design log file must be created INSIDE plan mode. Phase C ends with `ExitPlanMode` — a plain-text "approve to proceed?" message is NOT a substitute approval gate. If you catch yourself mid-exploration without having called `EnterPlanMode`, stop immediately, call it, and resume — do NOT rationalize continuing outside plan mode because "exploration already started."

Steps: enter plan mode → explore codebase + load architecture diagrams → create the design log file at `.agent/design-logs/NNN-kebab-case-description.md` from `assets/design-log-template.md` with status `[DRAFT]` → `ExitPlanMode` for the single approval. Full procedure in `references/protocol-detail.md` § Phase C.

### Phase D — Implementation (After Approval Only)

Steps: status → `[BEING IMPLEMENTED — DL-NNN]` → build per Proposed Solution → update Implementation Notes on deviations → status → `[IMPLEMENTED — NEED TESTING]` → housekeeping (update INDEX, `current-status.md`, architecture diagrams, commit/push, deploy if applicable). Full housekeeping checklist (NO auto-merge, do-not-delete-branch, do-not-edit-after-merge) in `references/protocol-detail.md` § Phase D.

### Phase E — Test Handoff

Collect unchecked Section 7 items → write to `current-status.md` Active TODOs in the documented format → mark log `[COMPLETED]` only when all Section 7 items pass. Patch status in both the DL file and `INDEX.md` when closing. Full procedure + format template in `references/protocol-detail.md` § Phase E.

### Handling Mid-Implementation Feedback

Classify feedback (clarification / bug / missed constraint / scope expansion / refinement) and respond accordingly. Full table in `references/protocol-detail.md` § Handling Mid-Implementation Feedback. **When uncertain:** state your assumptions, propose options (quick fix vs. proper solution), ask for preference. Don't guess.

## Output format

The persistent artifact this skill produces is a design log file at `.agent/design-logs/NNN-kebab-case-description.md`, filled in from the canonical template at `assets/design-log-template.md`. Read that file when you need the structure; do not paste it into chat.

Sections in order: 1. Context & Problem · 2. User Requirements (Q&A) · 3. Research (Domain, Sources, Principles, Patterns, Anti-Patterns, Verdict) · 4. Codebase Analysis · 5. Constraints & Risks · 6. Proposed Solution · 7. Validation Plan · 8. Implementation Notes.

Status values (`[DRAFT]` / `[APPROVED]` / `[BEING IMPLEMENTED — DL-NNN]` / `[IMPLEMENTED — NEED TESTING]` / `[COMPLETED]` / `[DEPRECATED]`) and naming convention (`NNN-description.md`, sequential, lowercase-hyphens, English) are documented in `references/protocol-detail.md`.

Do not leave template placeholders such as `[Question]`, `[Key takeaway]`, or `Test Case 1` in a real design log. Replace every placeholder with concrete project-specific content before calling `ExitPlanMode`.

## Critical Rules

1. **NEVER implement before approval** — `[DRAFT]` means no coding.
2. **ALWAYS ask clarifying questions first** — understanding before action. If the user invoked `/design-log` explicitly, this is non-negotiable. To skip, state the reason out loud and wait for confirmation.
3. **ALWAYS research before designing** — knowledge before architecture.
4. **ONE approval gate** — `ExitPlanMode` is the single approval for both plan and design log.
5. **ALWAYS save a design log file** — plan mode is ephemeral, the log persists.
6. **ALWAYS update Implementation Notes** — document deviations and which research principles were applied.
7. **ALWAYS run Phase E** — persist test items to `current-status.md` and mark `[COMPLETED]` only once all tests pass.

## Pre-Phase-A Check (when this skill is invoked)

This skill has `disable-model-invocation: true` — it does NOT run automatically at session start. It runs only when the user types `/design-log` or otherwise invokes it by name. When invoked, before Phase A:

1. Scan `.agent/design-logs/` for unfinished work.
2. Report any `[APPROVED]` logs not marked `[COMPLETED]`.
3. Summarize last 3 logs for context.
4. Note domains already researched (for cumulative knowledge rule).

## Gotchas

- Do not treat plan mode text as persistent documentation; always save the design log file.
- Do not let template placeholders survive into a real design log.
- Do not create a new log when an active related log should be extended; if creating a new one anyway, explain why.
- Do not use filename-only triage for prior logs; grep bodies and read related logs in full.
- Do not let Phase A's light pre-scan become full Phase C exploration before `EnterPlanMode`.
- Do not repeat old research verbatim; do targeted delta research and cite the prior log.
- Do not bypass your project's standard git workflow for commit/push/merge operations.
- Do not mark `[COMPLETED]` until every Section 7 validation item is checked off.

## References

- `references/protocol-detail.md` — load when entering a phase and you need the full step-by-step procedure (Phase A0–A4, B1–B3, C, D housekeeping, E test handoff, mid-implementation feedback table, status values, naming convention).
- `references/research-sources.md` — load in Phase B (B2) when picking book recommendations and source tiers for the identified domain.
- `references/customization.md` — read once when adapting this skill to your project (paths, research tool, git workflow, log-number automation).

## Assets

- `assets/design-log-template.md` — fill this out as the persistent design log file in Phase C; read it for the canonical Section 1–8 structure rather than reproducing it inline.

## Evaluation checklist

Self-check after the skill runs. If any answer is "no" you skipped a phase:

- [ ] **Phase A:** Asked decision-shaping clarifying questions via `AskUserQuestion` (not plain text), usually 5+ unless prior context answered enough, and waited for answers?
- [ ] **Phase A:** Read `INDEX.md` (+ any archive index) + relevant domain folders, grepped log bodies for keywords, surfaced findings before asking questions?
- [ ] **Phase A:** Codebase pre-scan done — existing solutions/reuse opportunities surfaced?
- [ ] **Phase B:** 3+ research sources cited (via Tavily MCP if installed, else `WebSearch`/`WebFetch`); time-boxed to 5–10 min?
- [ ] **Phase C:** First tool call was `EnterPlanMode` — no Glob/Grep/Read/Write happened before plan mode was active?
- [ ] **Phase C:** Design log file written using the template at `assets/design-log-template.md`, status `[DRAFT]`?
- [ ] **Phase C:** Exited via `ExitPlanMode` (the single approval gate) — not a plain-text "approve?" prompt?
- [ ] **Phase D:** Status moved through `[BEING IMPLEMENTED]` → `[IMPLEMENTED — NEED TESTING]`; INDEX.md and `current-status.md` updated; changes committed?
- [ ] **Phase E:** All unchecked Section 7 items copied to `current-status.md` "Active TODOs"; log marked `[COMPLETED]` only after all tests pass?

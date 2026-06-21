# Design-Log Protocol — Detailed Phases

Load this file when entering a phase and you need the full step list. SKILL.md keeps the router, hard gates, and one-line phase summaries; everything below is the elaborated procedure.

---

## Phase A: Discovery

**STOP. Do not implement anything.**

### A0 — Branch Setup (MANDATORY)

Detect environment first:

- Run `git rev-parse --git-dir`, `git branch --show-current`, and `git status` before changing files.
- If you are in a worktree, verify the branch matches the current task and continue.
- If you are on `main`/`master`, do not implement there. Ask the user whether to create/use a feature branch or worktree, then stop until the branch/worktree is safe.
- If another active feature branch appears unrelated to this task, do not switch branches without user approval.

Log-number selection:

- If your repository documents a design-log reservation script, worktree launcher, or branch-naming convention, follow that repo-specific workflow. (See `references/customization.md` for how to wire one in — useful when multiple parallel sessions could pick the same number.)
- If no reservation automation exists, determine the next log number from `.agent/design-logs/INDEX.md` (and any archive index) plus existing filenames, then warn about possible collision in parallel sessions.

### A1 — Check Existing Logs (MANDATORY — do not skip)

> **Cost discipline:** A1 + A2 are pure retrieval. Dispatch an `explore` or `model="haiku"` subagent to do the scan/grep/pre-scan and return a findings summary; reason over that summary on your main model rather than reading every log and file on it. See SKILL.md § Model Routing.

- Read `.agent/design-logs/INDEX.md` (and any archive index) first — these are the authoritative catalogs.
- Identify the relevant domain folder(s) under `.agent/design-logs/` (e.g. `ui/`, `api/`, `documents/`, `email/`, `infrastructure/`, `security/`, `research/`, or project-specific equivalents) and list their contents — a top-level scan alone will miss everything.
- **Grep log bodies** for 2–3 keywords from the user's request across all domain folders — filename triage is not enough.
- **Read in full** any log whose title, index entry, or grep hit looks related — do not rely on filenames alone.
- If a related log exists: extend it, or explicitly justify creating a new one.
- **Surface findings to the user before asking discovery questions** (e.g., "DL-12 already decided X — does this still apply?") — prior decisions may change the requirements or make new questions unnecessary.
- Check for any `[APPROVED]` or `[BEING IMPLEMENTED]` logs not yet `[COMPLETED]` (unfinished work that may conflict).
- **Check for prior research** on the same domain — if found, reference it and add only incremental findings.

### A2 — Light Codebase Pre-Scan (Reuse First)

Before designing anything, do a quick reuse scan to find existing solutions in the codebase. This is not full plan-mode exploration; it is a bounded check to avoid asking questions or writing plans that ignore obvious existing work:

- Search for functions, modules, utilities, or patterns similar to what's being requested (Grep/Glob).
- Look for partial implementations that could be extended rather than replaced.
- Identify shared helpers or components already doing related work.
- **Document findings** in a short "Existing Solutions" note: what exists, what it does, and whether it can be reused/extended.
- **Default to reuse/extension** — only design from scratch if nothing relevant exists.
- If something relevant is found: surface it to the user before asking clarifying questions.

### A3 — Ask Clarifying Questions

- **ALWAYS use the `AskUserQuestion` tool** with predefined options for each question — never ask questions as plain text.
- Usually ask 5+ questions, but fewer is acceptable when prior logs, user instructions, or pre-scan findings already answer the remaining decisions.
- Each question should have 2–4 concrete options with descriptions.
- Mark the recommended option with "(Recommended)" suffix.
- Questions must be specific, not generic.
- Bad: "How do you want this?"
- Good: "Should the automation trigger on 'Status Changed' or on a scheduled interval?"

### A4 — Wait for user answers before proceeding

---

## Phase B: Research

**After user answers discovery questions, BEFORE entering plan mode.** This phase is mandatory. Even if the task seems simple, research it — you often discover better approaches.

### B1 — Identify the Domain

Determine the technical/UX/architectural domain(s) the request falls into. Examples:

| Request | Domain(s) |
|---------|-----------|
| "Add error handling" | Resilience Engineering, UX Error States |
| "Build a search feature" | Information Retrieval, Search UX |
| "Fix a race condition" | Concurrency, Distributed Systems |
| "Add authentication" | Security, Identity Management |
| "Improve performance" | Web Performance, Optimization |
| "Build a form" | Form Design, Validation Patterns, Accessibility |
| "Add notifications" | Messaging Patterns, Notification UX |
| "Fix layout issues" | CSS Architecture, Responsive Design |
| "Build a workflow" | Workflow Orchestration, State Machines |
| "Add email automation" | Email Deliverability, Transactional Email Patterns |
| "Process documents with AI" | Document AI, Classification Patterns |

Not exhaustive — use judgment for the specific task.

### B0.5 — Check the Research Index (cache hit = delta research only)

Before any search, read `.agent/design-logs/research-index.md` (if you maintain one):

- **Entry < 90 days old for this domain** → do **delta research only**: 1 targeted search asking "what changed since [date] / what didn't the prior log cover for this specific task?", and cite the prior log in Section 3 (`**Prior research:** DL-NNN ([domain], YYYY-MM-DD) — delta only`).
- **Entry > 90 days old** → re-validate the key claims (a quick search confirming the principles still hold) before reusing them, then proceed with whatever delta research the task needs.
- **No entry / file missing** → full B2 below.

### B2 — Research Sources (3+ minimum)

> **Cost discipline:** Reading 3+ full sources is token-heavy. Run the searches/extraction in a `model="sonnet"` research subagent and fold back only its **distilled** findings (principles, patterns, anti-patterns) — avoid loading multiple full pages into your main context. See SKILL.md § Model Routing.

Find and read substantive content from **at least 3 sources** across these tiers.

**Which tool to use** (use whichever you have installed; all are in `allowed-tools`; tool-name prefixes follow your own MCP server names):
- **context7 MCP** — best for library/framework/SDK/API docs. `mcp__context7__resolve-library-id` (resolve a library name to its ID) → `mcp__context7__query-docs` (fetch current docs). Prefer this when the domain is a specific library/tool's API or config.
- **Exa MCP** — semantic/neural discovery; best for finding the highest-quality writing on a topic rather than keyword matches. `mcp__exa__web_search_exa` (neural search), `mcp__exa__crawling_exa` (fetch a known URL), `mcp__exa__deep_researcher_start` / `mcp__exa__deep_researcher_check` (start an agentic deep-research task and poll for the report).
- **Tavily MCP** — best for general multi-source web research. `mcp__tavily__tavily_search` (ranked results with snippets; one query per call, issue parallel calls for independent searches) and `mcp__tavily__tavily_extract` (fetch full URL content as Markdown; accepts a `urls` array for batch).
- **Firecrawl MCP** — full-page extraction, JS-heavy sites, crawling a whole docs site. `mcp__firecrawl__firecrawl_search` (search + scrape), `mcp__firecrawl__firecrawl_scrape` (clean markdown from one page), `mcp__firecrawl__firecrawl_crawl` (crawl linked pages), `mcp__firecrawl__firecrawl_extract` (structured extraction).
- **Built-in `WebSearch` + `WebFetch`** — always available, zero setup. `WebSearch` to find sources, `WebFetch` to read a page. The universal fallback when no MCP is installed.

**Tier 1 — Books:** Find the 1–2 most respected books in the identified domain. Search for core concepts, chapter summaries, key takeaways.
**Tier 2 — Authoritative articles & documentation.**
**Tier 3 — Real-world case studies.**

For book recommendations and source tiers by domain, see `references/research-sources.md`.

**Efficiency rule:** Time-box research to 5–10 minutes of tool calls. Read the most relevant sections, not entire books. Use `Task` with parallel agents for independent searches when useful.

**Optional delegation:** For fast-moving technical domains (AI/ML tooling, agent frameworks, LLM SDKs, JS/TS frameworks, cloud, DevOps, package status checks), you MAY delegate research to a general-purpose research subagent (via `Task`) or a dedicated research skill if your setup has one, then fold its output into Section 3 of the design log. For UX, architecture, and domain-pattern research where the book/principles framing matters more than current docs, the inline web flow above is usually better. Do not over-delegate when a direct search is sufficient.

> **HARD GATE:** If you delegated research to a subagent/skill, you MUST wait for its result before calling `EnterPlanMode`. Do NOT enter Phase C while research is still running.

### B3 — Extract & Document Findings

Synthesize research into actionable findings (documented in Section 3 of the design log template). Focus on:

- **Principles** that directly apply to our specific case.
- **Patterns** we should use (with brief description of how).
- **Anti-patterns** to avoid (and why they're tempting but wrong for us).
- **Deviations** — if a source recommends something that doesn't fit our constraints, note the recommendation AND why we're deviating.

**Update the research index:** after research, upsert the domain row in `.agent/design-logs/research-index.md` — domain, log number(s), today's date, a 1-line principles summary, top 1–3 sources. If the file doesn't exist, create it from `assets/research-index-template.md`. (Optional but recommended — it's what makes B0.5 cache hits possible on later logs.)

**Cross-project principles (optional):** if a principle is genuinely project-agnostic (a domain truth, not tied to this codebase/stack) and your setup keeps a cross-project memory/notes store, save it there too so other projects benefit. Only reusable principles — don't store project-specific findings.

### Research Rules

1. **No skipping.** Even if the task seems simple or familiar, do the research.
2. **Quality over quantity.** Reading 3 excellent sources deeply beats skimming 10.
3. **Be specific to our context.** Don't quote generic advice — explain how each principle applies to this feature/bug.
4. **Time-box it.** 5–10 minutes of tool calls.
5. **Cumulative knowledge.** If you've already researched a domain in a previous design log, reference it (`See design-log NNN for prior research on [domain]`) and add only new/incremental findings. Research is still mandatory for explicit `/design-log` runs; in already-researched domains, satisfy it with targeted delta research that checks what has changed or what the prior log did not cover.
6. **Disagree with books when warranted.** Note the recommendation AND why we're deviating.

---

## Phase C: Explore & Document

After research is complete:

1. **Enter Plan Mode** — call `EnterPlanMode` to begin codebase exploration.
2. **Explore the codebase** using Glob, Grep, Read to understand:
   - **Load relevant architecture diagram(s)** from repo docs when present (e.g., `docs/architecture/`) to understand how the feature area fits into the overall system before exploring individual files.
   - Existing patterns and architecture relevant to the task.
   - Files that will need to change.
   - Dependencies and potential risks.
   - **How research findings map to our actual codebase** (do existing patterns align with best practices? where do they diverge?).
3. **Create the Design Log File:**
   - Determine next log number — if the branch was already renamed `DL-NNN-*` in A0, use that NNN. If the repository documents a reservation script, run it from the documented repo root. Otherwise scan `.agent/design-logs/INDEX.md` (and any archive index) plus existing filenames, then warn about possible collision in parallel sessions.
   - Path: `.agent/design-logs/NNN-kebab-case-description.md`.
   - Fill in the canonical template (`assets/design-log-template.md`) using findings from **both research and exploration**.
   - Set status to `[DRAFT]`.
   - Write the plan-mode plan content AND save the design log file.
4. **Exit Plan Mode** — call `ExitPlanMode` to present the plan for approval.
   - This is the **single approval gate** for both the plan and the design log.
   - User reviews and approves (or requests changes).

---

## Phase D: Implementation (After Approval Only)

**Optional:** If your setup has a subagent-driven implementation skill, you may use it when the plan has independent tasks that can run in parallel. Otherwise implement directly.

1. **Update design log status to `[BEING IMPLEMENTED — DL-NNN]`** (replace NNN with the actual log number).
2. **Build strictly according to "Proposed Solution".**
3. **Reference research in code comments where relevant** (e.g., `// Pattern: Circuit Breaker — see design-log NNN`).
4. **Run any validation steps that can be verified immediately** (build passes, deploys, no errors in logs).
5. **Update "Implementation Notes" section if any deviations occur.**
6. **Update design log status to `[IMPLEMENTED — NEED TESTING]`.**
7. **Housekeeping (always the last task in every implementation plan):**
   - Update design log status → `[IMPLEMENTED — NEED TESTING]`.
   - Update the design log INDEX.
   - Update `.agent/current-status.md`: summarize what was done this session, add next-session TODOs (including unchecked Section 7 items), remove completed items from existing TODOs.
   - If the implementation added/removed/changed workflows, API endpoints, client pages, or other architecture surfaces — update the relevant architecture diagram(s) in your repo docs.
   - Git commit & push the feature branch using your project's standard git workflow and commit conventions. All file edits MUST be done before this point if your repo has a branch-guard hook that blocks edits on main.
   - **Deploys:** If the change touches a deployment surface, follow the project deployment workflow for live testing. Ask before destructive operations, secret changes, production-impacting changes, or any deployment command the repo does not clearly document.
   - **NO auto-merge to main.** Never merge to main without explicit approval, even for "testing" convenience. Commit locally, push the feature branch when requested by the workflow, then **pause for explicit approval** before merging or pushing to main.
   - **Frontend/static hosting changes** may only go live after the project-specific release path runs (such as merge-to-main or a hosting deploy). Surface this as a blocker the user needs to decide about, not something to bypass.
   - **DO NOT delete the branch.** Follow-up improvements are common after live testing. Feature branches persist; merge or delete the branch when truly done.
   - Tell the user (template):
     > "Feature branch `{branch}` pushed. Backend deployed if applicable. Frontend/static hosting changes may not be live until the project release path runs. Approve merge/release when ready."
   - **Do NOT edit any files after merging to main** if your repo's branch-guard hook blocks it. If follow-up is needed, check out the feature branch again first.

---

## Phase E: Test Handoff

After implementation, persist outstanding test items so nothing gets lost between sessions.

1. **Collect:** Gather all unchecked items from the log's **Section 7 (Validation Plan)** — these are the tests that still need manual verification or end-to-end testing.
2. **Write to `current-status.md`:** Add a test entry under **"Active TODOs"** with this format:
   ```
   N. **Test DL-NNN: [Feature Name]** — [1-line summary of what to verify]
      - [ ] [Test item 1 from Section 7]
      - [ ] [Test item 2 from Section 7]
      - [ ] ...
      Design log: `.agent/design-logs/NNN-feature-name.md`
   ```
   * Place it right after the implementation TODO it relates to (same priority number).
   * If the design log is now `[IMPLEMENTED — NEED TESTING]` or `[COMPLETED]`, the test entry is what keeps it on the radar.
3. **Mark the log:**
   - If all Section 7 tests passed in-session → set status to `[COMPLETED]` in BOTH the DL file and `INDEX.md`. (If your repo has a close script — see `references/customization.md` — run it instead so any PII/lint guards run consistently.)
   - If tests are still outstanding → leave as `[IMPLEMENTED — NEED TESTING]`.

**Rule:** A design log is NOT `[COMPLETED]` until all Section 7 items are checked off.

---

## Handling Mid-Implementation Feedback

When the user gives feedback during or after implementation, assess the type and respond accordingly:

| Feedback Type | Action |
|---------------|--------|
| **Clarification** | Answer directly, no log change needed |
| **Bug in implementation** | Fix it, append to Section 8 (Implementation Notes) |
| **Missed constraint / edge case** | Append to Section 8, update Section 7 with new test case |
| **Scope expansion / new feature** | Create a **new** design log — don't overload the current one |
| **Refinement of existing design** | Append to existing log's Section 8 |

**When uncertain:** State your assumptions, propose options (quick fix vs. proper solution), ask for preference. Don't guess.

---

## Status Values

| Status | Meaning |
|--------|---------|
| `[DRAFT]` | In plan mode. Researching, exploring, documenting. **NO CODING** |
| `[APPROVED]` | User approved via ExitPlanMode. Ready to implement. |
| `[BEING IMPLEMENTED — DL-NNN]` | Implementation actively in progress. |
| `[IMPLEMENTED — NEED TESTING]` | Code deployed. Test checklist being written to `current-status.md`. |
| `[COMPLETED]` | Implemented, ALL Section 7 tests passed, and committed. |
| `[DEPRECATED]` | Feature removed or superseded by a newer log. |

## Naming Convention

- Format: `NNN-description.md`
- Numbering: Sequential (001, 002, 003...)
- Casing: Lowercase with hyphens
- Language: English only

---

## Lite Mode

Triggered by `/design-log lite` (or a request for a "light/quick design log"). Same protocol, same hard gates — what shrinks is **volume**, never **gates**.

| Phase | Full mode | Lite mode |
|-------|-----------|-----------|
| A0 Branch setup | Mandatory | **Mandatory — unchanged** |
| A1 Existing logs | INDEX + archive + grep bodies + read related logs in full | INDEX + research-index check; read related logs only on a direct hit |
| A2 Pre-scan | Bounded reuse scan | Same, but cap at the most obvious reuse candidates |
| A3 Questions | Usually 5+ | **2–3 decision-shaping questions** (still via `AskUserQuestion`, still wait for answers) |
| B Research | 3+ sources, 5–10 min | **1 source minimum**; a fresh research-index hit (<90 days) satisfies Phase B with **zero new searches** (cite the prior log) |
| C Plan mode | `EnterPlanMode` first → DL file `[DRAFT]` → `ExitPlanMode` | **Unchanged — all three gates apply** |
| Template | All sections fully filled | Sections 3–5 may be compressed to a few bullets each; Sections 1, 2, 6, 7 stay concrete |
| D Implementation | Per approved plan + housekeeping | Unchanged |
| E Test handoff | Mandatory | **Mandatory — unchanged** |

**Never skipped in lite mode:** A0 branch setup, the `[DRAFT]` status, the `EnterPlanMode`/`ExitPlanMode` approval gate, saving the DL file, Phase E handoff. Lite mode is a smaller log, not a different protocol.

---

## Gotchas

- Do not treat plan mode text as persistent documentation; always save the design log file.
- Do not create a new log when an active related log should be extended; if creating a new one anyway, explain why.
- Do not use filename-only triage for prior logs; grep bodies and read related logs in full.
- Do not repeat old research verbatim; check the research index (B0.5), do targeted delta research, and cite the prior log.
- Do not mark `[COMPLETED]` until every Section 7 validation item is checked off.
- Do not patch INDEX.md or the DL file by hand when closing if your project has a close-design-log script (see `references/customization.md`) — run it so any PII/lint guards run and both files stay consistent.

---

## Evaluation Checklist

Self-check after the skill runs. If any answer is "no" you skipped a phase:

- [ ] **Phase A:** Asked decision-shaping clarifying questions via `AskUserQuestion` (not plain text), usually 5+ (2–3 in lite mode) unless prior context answered enough, and waited for answers?
- [ ] **Phase A (HARD):** Ran the A1 relevance grep — task-derived search terms (incl. any non-English UI labels) across `INDEX.md` + any archive index + **all DL bodies**; read any related prior DL in full and cited it in the new DL's Related Logs; surfaced findings to the user before A3 questions. **A recency summary ("last N logs") alone = FAIL.**
- [ ] **Phase A:** Codebase pre-scan done — existing solutions/reuse opportunities surfaced?
- [ ] **Phase B:** 3+ research sources cited, OR a fresh research-index hit with delta research; time-boxed to 5–10 min? Research index updated afterward?
- [ ] **Phase C:** First tool call was `EnterPlanMode` — no Glob/Grep/Read/Write happened before plan mode was active?
- [ ] **Phase C:** Design log file written using the template at `assets/design-log-template.md`, status `[DRAFT]`, no template placeholders left?
- [ ] **Phase C:** Exited via `ExitPlanMode` (the single approval gate) — not a plain-text "approve?" prompt?
- [ ] **Phase D:** Status moved through `[BEING IMPLEMENTED]` → `[IMPLEMENTED — NEED TESTING]`; INDEX and status file updated; committed via your standard git workflow (e.g. the `git-ship` skill), not ad-hoc?
- [ ] **Phase E:** All unchecked Section 7 items copied to the status file's "Active TODOs"; cost/notes line appended to Section 8; log marked `[COMPLETED]` only after all tests pass?

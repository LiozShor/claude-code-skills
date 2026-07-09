# Design Log NNN: [Feature Name]
**Status:** [DRAFT]
**Date:** YYYY-MM-DD
**Related Logs:** [Related design logs, or "None found"]

> Template rule: replace every bracketed placeholder before calling `ExitPlanMode`. A real design log must contain concrete facts, decisions, risks, and tests.

## 1. Context & Problem

[Explain why this work is needed, what is broken or missing, who is affected, and what happens if nothing changes.]

## 2. User Requirements

[Record the Phase A questions and answers. Include only questions that shaped the decision.]

1. **Q:** [Concrete question]
   **A:** [User answer]

## 3. Research

**Prior research:** [DL-NNN ([domain], YYYY-MM-DD) — delta only · include this line on a research-index cache hit; delete it otherwise]

### Domain

[Name the technical, UX, architectural, reliability, security, or workflow domain being researched.]

### Sources Consulted

1. **[Book/source name]** — [Specific takeaway and why it matters here]
2. **[Authoritative article/doc]** — [Specific takeaway and why it matters here]
3. **[Case study/source]** — [Specific takeaway and why it matters here]

### Key Principles Extracted

- [Principle and how it applies to this project]
- [Principle and how it applies to this project]
- [Principle and how it applies to this project]

### Patterns to Use

- **[Pattern name]:** [How the implementation will apply it]

### Anti-Patterns to Avoid

- **[Anti-pattern]:** [Why it is tempting and why it is wrong here]

### Research Verdict

[State the recommended approach based on the research. If deviating from a source, explain why.]

## 4. Codebase Analysis

[Summarize findings from Phase A pre-scan and Phase C plan-mode exploration.]

- **Existing Solutions Found:** [Reusable functions, modules, workflows, components, docs, or partial implementations]
- **Reuse Decision:** [What will be reused or extended, what will be new, and why]
- **Relevant Files:** [Files examined and why they matter]
- **Existing Patterns:** [How similar work is handled today]
- **Alignment with Research:** [Where the codebase matches or diverges from researched best practices]
- **Dependencies:** [External services, data stores, workflows, APIs, packages, or none]

## 5. Technical Constraints & Risks

- **Security:** [Secrets, auth, permissions, PII, data exposure, or none]
- **Operational Risks:** [Deploy, rollback, concurrency, rate limits, manual process risks]
- **Breaking Changes:** [Compatibility concerns, migration needs, or none]
- **Mitigations:** [Specific steps that reduce each meaningful risk]

## 6. Proposed Solution

### Success Criteria

[One or two sentences describing the observable done state.]

### Logic Flow

1. [Step 1]
2. [Step 2]
3. [Step 3]

### Data Structures / Schema Changes

[Field updates, API shapes, config changes, migrations, or "None".]

### Boundary Contracts

[For a change that crosses **module / service / agent boundaries** (e.g. frontend ↔ Worker, ingestion → engine, LLM step → next step), define the **validated schema** of the data passed across each boundary — name the schema, its source of truth, and where it is enforced. A single shared, runtime-validated contract per boundary (e.g. one Zod schema imported by both sides) prevents shape-drift and cascading errors. Write "None — single-module change" for trivial in-process work.]

### Files to Change

| File | Action | Description |
|------|--------|-------------|
| [path/to/file] | [Create/Modify/Delete] | [Concrete change] |

### Final Step

- Update design log status to `[IMPLEMENTED — NEED TESTING]`.
- Update the design log index.
- Copy unchecked Section 7 items to `.agent/current-status.md` under Active TODOs.
- Invoke `git-ship` for commit/push/merge workflow when implementation is complete.

## 7. Validation Plan

- [ ] [Automated validation, build, lint, unit test, integration test, or targeted command]
- [ ] [Manual or end-to-end test]
- [ ] [Regression check for adjacent behavior]

### Trajectory / Acceptance Criteria

[For **non-deterministic or high-stakes output** (LLM-generated text, recommendations, multi-step pipelines, anything where a plausible-but-wrong result is costly), verify the **path, not just the final answer**: were the right inputs/config used, were steps taken in the correct order, were the correct rules applied, did required guards/warnings fire on edge cases? List the path-level checks here. Omit this subsection for deterministic, easily-asserted output.]

## 8. Implementation Notes

[During implementation, record deviations from the approved plan, research principles actually applied, commands run, validation results, and unresolved follow-up work. Leave this blank only while status is `[DRAFT]`.]

**Cost:** [N dispatches (X haiku / Y sonnet / Z opus), M searches — filled in Phase E]
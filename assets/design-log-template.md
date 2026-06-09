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

### Files to Change

| File | Action | Description |
|------|--------|-------------|
| [path/to/file] | [Create/Modify/Delete] | [Concrete change] |

### Final Step

- Update design log status to `[IMPLEMENTED — NEED TESTING]`.
- Update the design log index.
- Copy unchecked Section 7 items to `.agent/current-status.md` under Active TODOs.
- Commit/push using your project's standard git workflow when implementation is complete.

## 7. Validation Plan

- [ ] [Automated validation, build, lint, unit test, integration test, or targeted command]
- [ ] [Manual or end-to-end test]
- [ ] [Regression check for adjacent behavior]

## 8. Implementation Notes

[During implementation, record deviations from the approved plan, research principles actually applied, commands run, validation results, and unresolved follow-up work. Leave this blank only while status is `[DRAFT]`.]

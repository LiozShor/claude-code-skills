# Research Sources Reference

Static reference for the design-log skill's research phase. Loaded on demand, not on every invocation.

> **These are starting hints, not the answer.** Books anchor the *principles*; Phase B still verifies current practice against live sources (the field moves, editions change). When a book and current docs disagree on specifics, trust the docs and note the deviation.

## Key Books by Domain

### Foundations / Architecture

| Domain | Key Books |
|--------|-----------|
| System Design / Data | "Designing Data-Intensive Applications" — Martin Kleppmann |
| Microservices | "Building Microservices" (2nd ed) — Sam Newman |
| Software Design / Complexity | "A Philosophy of Software Design" (2nd ed) — John Ousterhout |
| Refactoring / Code Quality | "Refactoring" (2nd ed) — Martin Fowler |
| Resilience / Error Handling | "Release It!" (2nd ed) — Michael Nygard |
| Concurrency / Distributed Systems | "Designing Data-Intensive Applications" — Kleppmann; "Release It!" — Nygard |

### Web / Frontend / UX

| Domain | Key Books |
|--------|-----------|
| UX / Usability | "Don't Make Me Think" — Steve Krug |
| Accessibility | "Inclusive Components" — Heydon Pickering |
| CSS / Layout | "Every Layout" — Heydon Pickering & Andy Bell |
| Forms / Validation | "Form Design Patterns" — Adam Silver |
| JavaScript Patterns | "Learning JavaScript Design Patterns" (2nd ed, 2023) — Addy Osmani |
| State Management | "Constructing the User Interface with Statecharts" — Ian Horrocks; XState docs |
| Web Performance | "High Performance Browser Networking" — Ilya Grigorik; web.dev Core Web Vitals |

### APIs / Backend / Security

| Domain | Key Books |
|--------|-----------|
| API Design | "Principles of Web API Design" — James Higginbotham; "Designing Web APIs" — Brenda Jin |
| Security / AppSec | "Alice and Bob Learn Application Security" — Tanya Janca; OWASP ASVS + Cheat Sheet Series (living docs) |
| Auth / Identity | "API Security in Action" — Neil Madden; OAuth 2.1 / OIDC specs |
| Testing | "Unit Testing Principles, Practices, and Patterns" — Vladimir Khorikov; "Testing JavaScript Applications" — Lucas da Costa |

### AI / LLM / Data

| Domain | Key Books |
|--------|-----------|
| LLM Application Engineering | "AI Engineering" — Chip Huyen (2025) |
| ML Systems | "Designing Machine Learning Systems" — Chip Huyen |
| Prompt Engineering | "Prompt Engineering for LLMs" — John Berryman & Albert Ziegler |
| RAG / Information Retrieval | "AI Engineering" — Huyen (RAG chapters); "Relevant Search" — Turnbull & Berryman |
| AI Agents | Fast-moving — anchor on current framework docs (Anthropic, OpenAI Agents SDK, LangGraph) plus "AI Engineering" |
| Data Engineering | "Fundamentals of Data Engineering" — Reis & Housley |

### Ops / Delivery / Comms

| Domain | Key Books |
|--------|-----------|
| Observability | "Observability Engineering" — Majors, Fong-Jones & Miranda |
| DevOps / Delivery | "Accelerate" — Forsgren, Humble & Kim; "The DevOps Handbook" — Kim et al |
| Team / Platform | "Team Topologies" — Skelton & Pais |
| Email | "Email Marketing Rules" — Chad S. White |
| Automation / Workflow | Workflow-automation patterns; n8n official docs & community workflows |

This is NOT exhaustive — use judgment to find the most relevant books for the specific task.

## Tier 2 — Authoritative Articles & Documentation

- Official documentation of the relevant library/framework/tool (always check first).
- Nielsen Norman Group (nngroup.com) — UX research.
- Web.dev / Chrome Developers — web performance, Core Web Vitals.
- MDN Web Docs — web platform reference.
- OWASP (Top 10, ASVS, Cheat Sheet Series) — security.
- Smashing Magazine / CSS-Tricks — frontend patterns.
- For AI/LLM: Anthropic docs & cookbook, OpenAI cookbook, Hugging Face docs, Simon Willison's blog, Latent Space.

## Tier 3 — Real-World Case Studies

- How do top-tier products (Stripe, Linear, Notion, GitHub, Vercel, Figma) solve this specific problem?
- Engineering blogs from companies that faced similar challenges.
- Postmortems if the task involves fixing reliability issues.
- For AI: vendor engineering posts and reproducible eval write-ups, not benchmark marketing.

---
name: tech-researcher
description: 'Compare libraries/frameworks/tools and verify current APIs via live sources before choosing or implementing (X vs Y, latest, deprecated?). Also handles decision-grade questions — pivots, build-vs-buy, stack changes — via a weighted-criteria brief. Not for research already running inside a /design-log Phase B, and not for pure conceptual questions with no implementation impact.'
allowed-tools: Read, Grep, Glob, Bash, mcp__claude_ai_Tavily__tavily_search, mcp__claude_ai_Tavily__tavily_extract, mcp__claude_ai_Tavily__tavily_crawl, mcp__claude_ai_Tavily__tavily_map, mcp__exa__web_search_exa, mcp__exa__web_fetch_exa, mcp__exa__web_search_advanced_exa, mcp__firecrawl__firecrawl_search, mcp__firecrawl__firecrawl_scrape, mcp__firecrawl__firecrawl_crawl, mcp__firecrawl__firecrawl_extract, Edit
---

# Tech Researcher

Use this skill when the agent needs current technical information before giving advice, writing implementation plans, choosing tools, or editing code.

The purpose of this skill is to prevent stale, confident, outdated technical recommendations. Many technical domains change quickly. A model may remember an old API, deprecated library, renamed package, outdated best practice, or abandoned framework. This skill forces the agent to verify current information before making a recommendation.

It uses **the research MCP (Tavily/Exa/Firecrawl)** tools (the same tooling pattern as `/design-log` Phase B) — built-in `WebSearch`/`WebFetch` are intentionally not in `allowed-tools` because these MCPs return full-page markdown and support parallel batch fetches, which is what this skill needs for primary-source verification.

## When this triggers

Use this skill when the user asks about:

- The best current way to implement something.
- Which library, framework, package, API, SDK, tool, or platform to use.
- **Direction decisions:** pivoting an approach, build-vs-buy, replacing part of the stack, "what's the best thing to implement X with" — run these in decision-grade mode (below).
- Whether a package or framework is still maintained; current setup, syntax, APIs, or version-specific behavior.
- Technical architecture choices; comparing tools before implementation.
- Fast-moving domains: AI/ML tooling, agent frameworks, RAG, MCP, LLM SDKs, JS/TS frameworks, Python tooling, cloud platforms, CI/CD, databases, auth, deployment.
- Debugging that may depend on current package versions or changed APIs.

Trigger phrases: "what is the best way to…", "which library/tool should I use", "is this still recommended / maintained / deprecated?", "latest version", "current best practice", "compare these", "should I use X or Y?", "should I switch to…", "before implementing".

## When this does not trigger

Do not use this skill when:

- The question is basic and stable, or purely conceptual with no implementation impact.
- The user explicitly asks not to search or not to verify externally.
- The task is only formatting, rewriting, translating, or summarizing user-provided text/docs.
- The answer can be safely handled from the project's existing local files.
- The user is already inside a `/design-log` Phase B run — that workflow already handles research and this skill would duplicate it (but both share the same research index — see step 2).

If there is any realistic chance that the answer changed recently, use this skill.

## Standing user constraints

Apply these to every recommendation unless the user overrides them (they come from the user's global setup; verify against CLAUDE.md if in doubt):

- **Resale-readiness:** systems may be sold — anything requiring per-account hardcoding, heavy vendor lock-in, or non-transferable licensing scores worse. Everything must be configurable via env/config.
- **Solo maintenance:** one person operates everything — prefer boring, reliable, well-documented tools over powerful-but-fussy ones. Maintenance burden is a first-class criterion, not a footnote.
- **Existing stack first:** n8n, Airtable, Tally, Cloudflare (Workers/Pages), GitHub Pages, Base44, Node/JS/TS, Python. If the current stack can do it, say so before recommending anything new.
- **Hebrew/RTL** support matters for client-facing surfaces.

## Required inputs

Before researching, identify: the technical decision being made; target language/framework/platform; user constraints beyond the standing ones; whether the user wants a recommendation, comparison, implementation plan, or decision brief. If details are missing, make a reasonable assumption, state it, and continue unless it blocks the task.

## Workflow

0. **Anchor on the current date FIRST.** Fetch today's date via `Bash` (`date +%Y-%m-%d`) or the injected session context. Do NOT rely on training-cutoff intuition. Use the anchored date to set year filters and `start_date`/`time_range` parameters on search calls, and to judge whether a source is actually recent.

1. **Classify the question:** *lookup* (verify an API/package/syntax) · *comparison* (X vs Y) · *decision-grade* (pivot, build-vs-buy, stack change — anything expensive to undo). Decision-grade adds the criteria table and reversibility analysis to the output; lookups stay fast — do NOT inflate a 2-minute lookup into a decision brief.

2. **Check the research index before searching.** If the project has `.agent/design-logs/research-index.md`, read it — a matching domain entry <90 days old means delta research only (verify what changed since), not from-scratch research. This is the same cache `/design-log` Phase B uses.

3. Define the research question in one sentence, and list what could be stale (package names, API syntax, install commands, versions, architecture advice, pricing/limits, deprecations, compatibility).

4. **Search current sources via a research MCP** — pick the tool by job using `references/research-mcp-tools.md` (Tavily = ranked search + batch extract · Exa = semantic discovery · Firecrawl = full-page/JS-heavy/docs crawls). Parallelize independent searches. Never `WebSearch`/`WebFetch`.

5. Prefer primary sources (official docs, repos, changelogs, registries, vendor docs); secondary sources (blogs, tutorials, discussions) only for context. Full ladder + date/version/maintenance rules in `references/research-quality-rules.md`.

6. Check dates and versions: latest stable, deprecations, migration notes, breaking changes, docs-vs-version match.

7. For comparisons/decisions: compare fit, maintenance, ecosystem, complexity, lock-in, learning curve, implementation risk — scored against the standing user constraints. For decision-grade: fill the criteria table, the reversibility call (one-way vs two-way door), and cost-of-change vs cost-of-staying.

8. Produce the answer in the matching format from `references/output-formats.md` (research answer · comparison · implementation plan · decision brief). Mention uncertainty when sources are weak, conflicting, or incomplete.

9. **Write back to the research index.** If the project has `.agent/design-logs/research-index.md`, upsert a dated entry (domain, verdict, key sources) via `Edit`. If it doesn't exist, do NOT create it — include the would-be entry at the end of the answer so a later `/design-log` run can seed it. This is what makes repeated research compound instead of restart.

**Time-box research to 5–10 minutes of tool calls.** Search smart — read the most relevant sections, not entire pages.

## Simplicity gate

Before recommending anything, check whether a simpler solution already suffices. Default to the least complex option that meets the stated need:

- Prefer built-in / standard-library / native-platform features over a new dependency; one well-maintained library over a framework + plugins.
- If the user's existing stack can already do this, say so instead of recommending something new.
- More popular ≠ more appropriate. More powerful ≠ better fit.
- State the simplest option that works FIRST; mention heavier alternatives only if a real constraint justifies them.

If you find yourself recommending added complexity, name the specific requirement that forces it. If you can't name one, drop it.

## Decision gates

Stop and report uncertainty when: official docs cannot be found; sources disagree on core facts; the package appears abandoned; the API changed and the correct version is unclear; the user's environment version is unknown and it matters; the recommendation could cause security, data-loss, production, or cost risk.

Ask the user before: production-impacting architecture changes; recommending migration away from an existing stack; adding a dependency with significant lock-in; choosing a paid service; changing auth, security, or deployment strategy.

Proceed without asking when: the user asked for research only; the change is informational; assumptions can be stated clearly and safely.

`Edit` is allowed ONLY for upserting the research index (step 9) — never for modifying project code; surface code changes to the user instead. `Bash` is allowed only for the step-0 date anchor.

## Output format

Pick the matching template from `references/output-formats.md`: research answer, tool comparison, implementation plan, or decision brief (for pivots/build-vs-buy). For shorter answers, compress the format but keep the logic: recommendation, evidence, risks, next step. Decision briefs must end with "what would change this call" — the condition that flips the recommendation.

## Gotchas

- Do not recommend from memory in fast-moving domains, and do not give implementation code until the current API has been verified.
- Do not assume package names, import paths, or API syntax are still current; do not ignore version differences.
- Do not treat a blog post as truth when official docs exist; do not cite community answers as the main source for current API behavior.
- Do not recommend an abandoned package without saying it appears abandoned, or a tool only because it is popular.
- Do not skip security implications for auth, deployment, cloud, or dependency decisions.
- Do not recommend migration unless the benefit clearly outweighs the cost — for decision-grade questions the switching cost is part of the answer, not an afterthought.
- Do not answer a pivot-level question with a library-level answer: if the choice is expensive to undo, it gets the decision brief (criteria + reversibility), not just "X is well-maintained."
- Do not skip the research-index check (step 2) — re-researching a <90-day-old domain from scratch wastes the whole time-box.
- Do not call `WebSearch`/`WebFetch` — they are not in `allowed-tools` and the call will fail. Use the research MCP.

## References

- `references/research-quality-rules.md` — source-quality ladder, date/version rules, maintenance/deprecation signals. Load at step 5.
- `references/research-mcp-tools.md` — per-tool job matching for Tavily/Exa/Firecrawl + worked examples. Load at step 4.
- `references/output-formats.md` — the four output templates (research answer, comparison, implementation plan, decision brief). Load at step 8.

## Evaluation checklist

Before finalizing the answer, verify:

- Did I classify the question (lookup / comparison / decision-grade) and match the output format to it?
- Did I check the research index before searching, and upsert it after?
- Did I anchor the date and check primary sources via the research MCP, with dates/versions verified?
- Did I score against the standing user constraints (resale, solo maintenance, existing stack)?
- Did I recommend the simplest option that meets the actual need, justifying any added complexity?
- For decision-grade: did I include reversibility, switching cost, and "what would change this call"?
- Did I distinguish recommendation from evidence, and state risks/uncertainty?
- Did I avoid `WebSearch`/`WebFetch` and avoid relying on memory?

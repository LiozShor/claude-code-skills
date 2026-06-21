---
name: tech-researcher
description: 'Compare libraries/frameworks/tools and verify current APIs via live sources before choosing or implementing (X vs Y, latest, deprecated?).'
allowed-tools: Read, Grep, Glob, Bash, mcp__claude_ai_Tavily__tavily_search, mcp__claude_ai_Tavily__tavily_extract, mcp__claude_ai_Tavily__tavily_crawl, mcp__claude_ai_Tavily__tavily_map, mcp__exa__web_search_exa, mcp__exa__web_fetch_exa, mcp__exa__web_search_advanced_exa, mcp__firecrawl__firecrawl_search, mcp__firecrawl__firecrawl_scrape, mcp__firecrawl__firecrawl_crawl, mcp__firecrawl__firecrawl_extract
---

# Tech Researcher

Use this skill when the agent needs current technical information before giving advice, writing implementation plans, choosing tools, or editing code.

The purpose of this skill is to prevent stale, confident, outdated technical recommendations. Many technical domains change quickly. A model may remember an old API, deprecated library, renamed package, outdated best practice, or abandoned framework. This skill forces the agent to verify current information before making a recommendation.

This skill is for technical research that affects implementation decisions. It uses **the research MCP (Tavily/Exa/Firecrawl)** tools (the same tooling pattern as `/design-log` Phase B) — built-in `WebSearch`/`WebFetch` are intentionally not in `allowed-tools` because these MCPs return full-page markdown and support parallel batch fetches, which is what this skill needs for primary-source verification.

## When this triggers

Use this skill when the user asks about:

- The best current way to implement something.
- Which library, framework, package, API, SDK, or tool to use.
- Whether a package or framework is still maintained.
- Current installation or setup instructions.
- Current syntax, APIs, or version-specific behavior.
- Technical architecture choices.
- AI/ML tooling, agent frameworks, RAG, embeddings, vector databases, MCP, LangChain, LangGraph, smolagents, OpenAI SDKs, Anthropic SDKs, or similar fast-moving tooling.
- JavaScript, TypeScript, React, Next.js, Vite, Node.js, Python, FastAPI, Django, cloud platforms, CI/CD, Docker, Kubernetes, databases, auth, security, or deployment workflows.
- Debugging that may depend on current package versions or changed APIs.
- Comparing tools before implementation.
- Writing code that depends on current docs.

Trigger phrases include:

- "What is the best way to…"
- "Which library should I use…"
- "Is this still recommended?"
- "Is this package maintained?"
- "How do I do this in the latest version?"
- "Check the docs"
- "Current best practice"
- "Up-to-date"
- "Latest version"
- "Before implementing"
- "Compare these tools"
- "Should I use X or Y?"
- "Is this deprecated?"

## When this does not trigger

Do not use this skill when:

- The question is basic and stable.
- The answer is purely conceptual and does not depend on current tooling.
- The user explicitly asks not to search or not to verify externally.
- The task is only formatting, rewriting, translating, or summarizing user-provided text.
- The user provides the exact docs or source material and asks only to summarize them.
- The answer can be safely handled from the project's existing local files.
- The recommendation has no practical implementation impact.
- The user is already inside a `/design-log` Phase B run — that workflow already handles research and this skill would duplicate it.

If there is any realistic chance that the answer changed recently, use this skill.

## Required inputs

Before researching, identify:

- The technical decision being made.
- The target language, framework, platform, or runtime.
- The user's constraints, if provided.
- Whether the answer needs current docs, package status, examples, or comparison.
- Whether the user wants a recommendation, implementation plan, code, or only research findings.

If important details are missing, do not ask a broad clarification question. Make a reasonable assumption, state it, and continue unless the missing detail blocks the task.

## Research workflow

Follow this process:

0. **Anchor on the current date FIRST.** Before any search, fetch today's date via Bash (`date +%Y-%m-%d` on POSIX, `Get-Date -Format yyyy-MM-dd` on PowerShell) — or read it from the injected session context if present (`Today's date is …`). Do NOT rely on training-cutoff intuition for "what year is it" — the model's internal sense of "recent" is often years stale. Use the anchored date to:
   - Pick correct year filters in `tavily_search` queries (e.g., current year + prior year, not "2024 2025" from memory).
   - Set `start_date` / `time_range` parameters on Tavily calls when freshness matters.
   - Judge whether a doc/post dated X is actually "recent" relative to today.

1. Define the research question in one sentence.

2. Identify what could be stale. Examples:
   - Package name.
   - API syntax.
   - Installation command.
   - Framework version.
   - Recommended architecture.
   - Pricing or limits.
   - Deprecation status.
   - Security guidance.
   - Compatibility.

3. Search current sources using a **research MCP** (use whichever is installed; pick by job — prefixes follow your MCP server names):

   **Tavily** — general ranked web search + extraction:
   - `mcp__claude_ai_Tavily__tavily_search` — web search returning ranked results with content snippets. One query per call; issue multiple calls in parallel (single message, multiple tool blocks) when running independent searches.
   - `mcp__claude_ai_Tavily__tavily_extract` — fetch full content of one or many URLs as Markdown (accepts a `urls` array — native batch up to ~20 URLs).
   - `mcp__claude_ai_Tavily__tavily_crawl` — crawl a site starting from a root URL when you need to traverse linked pages.
   - `mcp__claude_ai_Tavily__tavily_map` — get a sitemap-style structural map of a site without fetching content.

   **Exa** — semantic/neural discovery; best for finding the highest-quality writing on a topic rather than keyword matches:
   - `mcp__exa__web_search_exa` — neural web search tuned for relevance.
   - `mcp__exa__web_fetch_exa` — fetch full page content for a known URL.
   - `mcp__exa__web_search_advanced_exa` — advanced search with full control over filters, domains, dates, and content options (good for comparison-heavy questions).

   **Firecrawl** — full-page extraction, JS-heavy sites, crawling a docs site:
   - `mcp__firecrawl__firecrawl_search` — search + scrape in one.
   - `mcp__firecrawl__firecrawl_scrape` — clean markdown from a single page (handles JS rendering — better than snippet search for verifying exact API syntax).
   - `mcp__firecrawl__firecrawl_crawl` — crawl linked pages from a root (e.g. a whole docs section).
   - `mcp__firecrawl__firecrawl_extract` — structured extraction from one or many pages.

   Do NOT use `WebSearch` or `WebFetch` — they are intentionally not granted. Snippet-only results miss the maintenance signals and version-specific syntax this skill exists to verify.

4. Prefer primary sources:
   - Official documentation.
   - Official GitHub repositories.
   - Official changelogs.
   - Official package registries (npm, PyPI, crates.io, etc.).
   - Standards documents.
   - Vendor docs.
   - Maintainer announcements.

5. Use secondary sources only for context:
   - Engineering blogs.
   - Recent tutorials.
   - Community discussions.
   - Stack Overflow.
   - GitHub issues.

6. Check dates and versions.
   - Look for the latest stable version.
   - Look for deprecations.
   - Look for migration notes.
   - Look for breaking changes.
   - Look for whether the docs match the version being discussed.

7. Compare alternatives if the user is choosing between tools.
   - Compare fit, maintenance, ecosystem, complexity, lock-in, learning curve, and implementation risk.
   - Do not choose the trendiest tool by default.

8. Decide whether implementation advice is safe.

9. Produce a concise recommendation with evidence.

10. Mention uncertainty if the sources are weak, conflicting, outdated, or incomplete.

**Time-box research to 5-10 minutes of tool calls.** Search smart — read the most relevant sections, not entire pages. Use parallel `mcp__claude_ai_Tavily__tavily_search` calls and `mcp__claude_ai_Tavily__tavily_extract` with a `urls` array for parallelism instead of sequential calls.

## Source quality rules

Use this priority order:

1. Official documentation.
2. Official repository or changelog.
3. Official package registry.
4. Standards or protocol documentation.
5. Vendor documentation.
6. Maintainer comments or release notes.
7. Recent reputable technical articles.
8. Community discussions only as supporting context.

Do not rely on:

- Old tutorials.
- SEO blogs with no version/date.
- Random copied examples.
- Unmaintained GitHub repos.
- AI-generated articles.
- Answers that do not mention package versions.
- Stack Overflow answers without checking date and version.

For deeper guidance on source quality, date checks, version rules, maintenance signals, deprecation cues, and good vs. bad research patterns, see `references/research-quality-rules.md`.

## Simplicity gate

Before recommending anything, check whether a simpler solution already suffices. Default to the least complex option that meets the stated need.

- Prefer a built-in / standard-library / native-platform feature over a new dependency.
- Prefer one well-maintained library over a framework + plugins.
- Do not add abstraction, config, or tooling the user did not ask for and does not need yet.
- If the user's existing stack can already do this, say so instead of recommending something new.
- More popular ≠ more appropriate. More powerful ≠ better fit.
- State the simplest option that works FIRST, then mention heavier alternatives only if a real constraint justifies them.

If you find yourself recommending added complexity, name the specific requirement that forces it. If you can't name one, drop it.

## Decision gates

Stop and report uncertainty when:

- Official docs cannot be found.
- Sources disagree on core facts.
- The package appears abandoned.
- The API has changed and the correct version is unclear.
- The user's environment version is unknown and version differences matter.
- The recommendation could cause security, data loss, production, or cost risk.

Ask the user before:

- Making production-impacting architecture changes.
- Recommending migration away from an existing stack.
- Adding a dependency with significant lock-in.
- Choosing a paid service.
- Changing authentication, security, or deployment strategy.
- Editing files (this skill cannot — `Edit`/`Write` are not allowed; surface the change to the user instead). `Bash` is allowed only for the Step 0 date anchor, not for mutating the project.

Proceed without asking when:

- The user asked for research only.
- The change is only informational.
- You are producing a recommendation, not modifying files.
- Assumptions can be stated clearly and safely.

## Output format

Use this format for research answers:

```md
# Technical Research Result

## Question

<One sentence describing what was researched.>

## Recommendation

<Clear recommendation. No hedging unless uncertainty is real.>

## Why

- <reason>
- <reason>
- <reason>

## Current evidence

- <source or documentation checked — include URL and date/version where relevant>
- <source>
- <source>

## Alternatives considered

- `<option>` — <when it makes sense>
- `<option>` — <when it makes sense>

## Risks / stale assumptions

- <risk>
- <risk>

## Implementation notes

- <practical next step>
- <practical next step>
```

For shorter answers, compress the format but keep the same logic: recommendation, evidence, risks, and next step.

## Comparison format

When comparing tools, use:

```md
# Tool Comparison

## Best choice

<tool>

## Use this when

<conditions>

## Avoid this when

<conditions>

## Comparison

### <Tool A>

Strengths:
- <point>

Weaknesses:
- <point>

### <Tool B>

Strengths:
- <point>

Weaknesses:
- <point>

## Final recommendation

<direct answer>
```

## Implementation planning format

When the user wants an implementation plan, use:

```md
# Implementation Plan

## Recommended stack

- <tool/library/service>

## Assumptions

- <assumption>

## Steps

1. <step>
2. <step>
3. <step>

## Version-sensitive notes

- <note>

## Risks

- <risk>

## Validation

- <how to test>
```

## Gotchas

- Do not recommend from memory in fast-moving domains.
- Do not assume the package name, import path, or API syntax is still current.
- Do not treat a blog post as truth when official docs exist.
- Do not ignore version differences.
- Do not recommend an abandoned package without saying it appears abandoned.
- Do not recommend a tool only because it is popular.
- Do not overfit to a benchmark without checking practical constraints.
- Do not skip security implications for auth, deployment, cloud, or dependency decisions.
- Do not pretend certainty when official sources are missing.
- Do not give implementation code until the current API has been verified.
- Do not confuse "works in an old tutorial" with "recommended today."
- Do not cite community answers as the main source for current API behavior.
- Do not recommend migration unless the benefit clearly outweighs the cost.
- Do not call `WebSearch`/`WebFetch` — they are not in `allowed-tools` and the call will fail. Use the research MCP (Tavily/Exa/Firecrawl).

## Examples

### Example 1 — library choice

User asks:

```text
Which Python package should I use for structured LLM outputs?
```

Correct behavior:

1. Search current official docs for the model/provider SDKs (use parallel `mcp__claude_ai_Tavily__tavily_search` calls for queries across providers).
2. Check whether native structured output exists.
3. Compare native provider support with external libraries.
4. Recommend based on the user's stack and reliability needs.
5. Mention version-sensitive syntax.

### Example 2 — framework API

User asks:

```text
How do I do middleware in the latest Next.js?
```

Correct behavior:

1. Scrape official Next.js docs via `mcp__firecrawl__firecrawl_scrape`.
2. Verify current routing and middleware conventions.
3. Mention version-specific behavior.
4. Provide implementation only after verification.

### Example 3 — agent tooling

User asks:

```text
Should I use LangChain, LangGraph, or smolagents?
```

Correct behavior:

1. Use `mcp__claude_ai_Tavily__tavily_extract` with a `urls` array to fetch current docs for all three in parallel.
2. Compare based on workflow complexity, graph/state needs, simplicity, ecosystem, and debugging.
3. Recommend based on the user's actual use case.
4. Avoid generic "all are good" nonsense.

## Evaluation checklist

Before finalizing the answer, verify:

- Did I define the actual technical decision?
- Did I identify what could be stale?
- Did I check primary sources via the research MCP (Tavily/Exa/Firecrawl)?
- Did I check dates or versions?
- Did I distinguish recommendation from evidence?
- Did I mention risks or uncertainty?
- Did I avoid relying only on memory?
- Did I give a practical next step?
- Did I recommend the simplest option that meets the actual need?
- Did I justify any added complexity with a specific requirement?
- Did I avoid `WebSearch`/`WebFetch`?

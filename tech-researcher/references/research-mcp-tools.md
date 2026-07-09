# Research MCP Tools — Pick by Job

Load this when choosing which research MCP tool to call (workflow step 3). Use whichever server is installed; prefixes follow your MCP server names.

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

## Worked examples

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

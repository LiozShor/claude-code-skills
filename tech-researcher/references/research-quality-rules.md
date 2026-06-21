# Research Quality Rules

Use this reference when performing current technical research with the `tech-researcher` skill.

## Primary-source rule

Prefer official documentation, official repositories, official changelogs, official package registries, standards documents, and vendor documentation.

Secondary sources may help explain tradeoffs, but they should not override primary sources.

## Date rule

Always check whether the source is current enough for the decision.

This matters especially for:

- AI/ML frameworks.
- LLM provider SDKs.
- JavaScript frameworks.
- Python tooling.
- Cloud services.
- Security guidance.
- DevOps tools.
- Auth libraries.
- Package installation and setup instructions.

## Version rule

When APIs differ by version, mention the version.

Bad:

```md
Use this import.
```

Better:

```md
In version X, the docs show this import. Older examples may use a different path.
```

## Maintenance rule

Before recommending a package, check whether it appears maintained.

Signals:

- Recent releases.
- Active commits.
- Open issue activity.
- Maintainer responses.
- Official documentation updates.
- Compatibility with current platform versions.

## Deprecation rule

Look for:

- Deprecated packages.
- Renamed APIs.
- Migration guides.
- Breaking changes.
- Archived repositories.
- Warnings in documentation.

## Recommendation rule

A useful recommendation should say:

- What to use.
- Why it fits.
- When not to use it.
- What alternatives were considered.
- What risks remain.
- What the next implementation step is.

## Bad research patterns

Avoid:

- "I know this from memory."
- "Most people use X."
- "A blog said X."
- "This Stack Overflow answer worked once."
- "The package exists, so it is fine."
- "The docs probably have not changed."
- "The latest version is probably compatible."
- "This is the best tool" without constraints.

## Good research patterns

Prefer:

- "The official docs currently show…"
- "The package appears maintained because…"
- "The migration guide says…"
- "This API changed between versions…"
- "For your use case, X is better because…"
- "Use Y only if you need…"
- "I would avoid Z because…"

## Tavily tool selection

- Single targeted query → `mcp__claude_ai_Tavily__tavily_search`.
- Multiple independent queries → multiple parallel `mcp__claude_ai_Tavily__tavily_search` calls in a single message (Tavily takes one query per call; parallelism is at the tool-block level).
- Single page deep-read → `mcp__claude_ai_Tavily__tavily_extract` with one URL.
- Multiple pages to compare → `mcp__claude_ai_Tavily__tavily_extract` with a `urls` array (native batch — preferred over multiple calls).
- Need to traverse a site's linked pages → `mcp__claude_ai_Tavily__tavily_crawl`.
- Need only the URL structure of a site → `mcp__claude_ai_Tavily__tavily_map`.

Default to batched `tavily_extract` (urls array) and parallel `tavily_search` blocks whenever issuing more than one fetch/search — sequential calls waste turns.

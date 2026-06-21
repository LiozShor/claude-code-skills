---
name: visualize
description: >
  Create self-contained HTML visualizations (single .html file) from conversation content,
  data, or ideas. Trigger on: "visualize this," "make a deck/slide/infographic/dashboard,"
  "build a one-pager / poster / carousel / kanban / mind map / org chart / flowchart,"
  "show me a chart," "render as HTML," or any ask to convert text/data into a visual
  HTML artifact. Do NOT trigger when the user asks for a Figma design (use `figma-*`),
  a Tally form (use `tally`), a Canva file (use `canva-*`), a real multi-page website,
  a React/Vue component, or a screenshot of an existing page (use `agent-browser`).
allowed-tools: Write, Edit, Bash, WebFetch
license: MIT
metadata:
  author: careerhackeralex
  version: 0.4.0
  category: document-creation
  tags: [visualization, html, slides, dashboard, infographic]
---

# Visualize

Turn any idea, data, or content into a stunning single-file HTML visualization.

This SKILL.md is the operational layer. Detailed patterns live in `references/` and are loaded
on demand — see the [Reference map](#reference-map) at the bottom. Never inline that detail here.

## When this triggers
- User says "visualize," "make a deck/slide/dashboard/infographic/poster/carousel," or any visualization-type keyword.
- User pastes data (CSV, JSON, table, numbers) and wants it shown visually.
- User shares a URL and asks for a visual summary.
- User wants a single self-contained `.html` artifact (no server, no build step).

## When this does not trigger
- Figma / mockup / design-system work → `figma-generate-design`, `figma-use`.
- Tally form / questionnaire → `tally`.
- Canva file → `canva-*` tools.
- Real multi-page website, React/Vue/Next app → not a skill match; build with framework.
- Screenshotting or scraping an existing webpage → `agent-browser`.
- Editing an existing HTML file the user already has → use plain `Edit`.

## Required inputs
- The content to visualize (conversation context, pasted data, URL, or explicit description).
- Optional: visualization type (deck, dashboard, infographic, etc.) — infer if not given.
- Optional: output path (defaults to `~/Downloads/<kebab-case-name>.html`).

## Workflow
1. **Pick type.** Match the request to a row in the [Visualization Types](#visualization-types) table below. If ambiguous, pick the closest fit and proceed. Detailed per-type patterns: [references/types.md](references/types.md).
2. **Gather content.** Use the conversation context, pasted data, or `WebFetch` for URLs (see [Source content](#source-content)). Never use placeholder/Lorem ipsum.
3. **Copy skeleton.** Start from [references/skeleton.md](references/skeleton.md) — never write HTML from scratch. It carries the theme system, exact CSS-property names, menu, animations, print styles, and accessibility hooks the evaluator checks.
4. **Add content** to the `<!-- YOUR CONTENT HERE -->` block. Follow the type-specific rules in [references/types.md](references/types.md).
5. **Wire libraries** as needed — [references/libraries.md](references/libraries.md) for CDN URLs + the Chart.js / Reveal.js / Leaflet patterns, [references/menu.md](references/menu.md) for the required hamburger menu, [references/animations.md](references/animations.md) for entrance/scroll animation, [references/design-system.md](references/design-system.md) for typography/color/spacing/sizing, [references/css-techniques.md](references/css-techniques.md) for advanced CSS.
6. **Run the Evaluation checklist** below before saving.
7. **Write the file** with `Write` to `~/Downloads/<name>.html` (kebab-case).
8. **Open it.** Run `open <file>` (macOS) or `xdg-open <file>` (Linux) via `Bash`, and return a `file://` link in the response.

## Decision gates
- If the request matches a non-trigger (Figma, Tally, Canva, real website) → stop, suggest the correct skill.
- If skeleton.md required elements (menu, theme classes, exact CSS-property names) are missing from the output → evaluation will fail; fix before writing.
- If charts render blank → see the **Troubleshooting** checklist in [references/libraries.md](references/libraries.md#chartjs).
- If the layout overflows at 375px viewport → mandatory fix before write.
- If `Chart.defaults.animation = false` is not set immediately after the Chart.js CDN → must add.
- If the purpose is to let the user **choose between rendered options** → make options selectable and add a clipboard export ([Pick-and-Extract](#pick-and-extract)).

## Output format
- One `.html` file written to `~/Downloads/` (or user-specified path), kebab-case filename.
- File contains: inline CSS, inline JS, CDN libraries via `<script>`, no build step.
- Response to user: one short line + the `file://` URL. No additional summary unless asked.
- Evaluation rubric: [references/eval.md](references/eval.md) — the 8 scoring dimensions checked upstream.
- Background: [references/anthropic-skill-guide-notes.md](references/anthropic-skill-guide-notes.md) — the skill best-practices that shaped this structure.

## Gotchas
- **Skeleton is non-negotiable.** Starting from scratch loses the menu, theme classes, theme toggle, print styles, and accessibility hooks — all checked by the eval system.
- **Class-based themes only** (`html.theme-dark` / `html.theme-light`). Never `data-theme`, never `@media (prefers-color-scheme)` for the variables themselves.
- **`var` at top level, not `let`/`const`.** Function hoisting causes TDZ errors otherwise.
- **Chart.js: `Chart.defaults.animation = false` immediately after the CDN.** Required and auto-checked. Never disable tooltips.
- **No horizontal overflow at 375px.** Mandatory.
- **Single-screen posters use `overflow: hidden` + fixed dimensions** and no hamburger menu. A scrolling page screenshotted ≠ a poster.
- **Don't hand-draw SVG continents.** Use Leaflet for any geographic data.
- **Reveal.js needs numeric dimensions** (`width: 1280, height: 720`) — string `'100%'` causes blank slides.
- **Always use real content.** Never generate placeholder/Lorem ipsum data when real context exists.

## Evaluation checklist
- Does the output start from skeleton.md verbatim?
- Are both `.theme-light` and `.theme-dark` classes defined with the full, exact custom-property set?
- Is the `.viz-menu` component present (toggle, theme, download PNG, print)? (Posters exempt.)
- Is Chart.js wired with `Chart.defaults.animation = false` + theme-aware colors + tooltips enabled?
- Does every chart canvas have `role="img"` and `aria-label`?
- Is there ≥1 entrance animation (`.animate` class, `data-reveal`, or scroll-driven `view()`)?
- Does the file render without horizontal scroll at 375px?
- Is there ≥1 meaningful interaction beyond menu + theme?
- Was the file opened in browser and a `file://` link returned?
- Zero console errors on load?

## Visualization Types

Pick the right format. Detailed per-type patterns and rules: [references/types.md](references/types.md).

| Type | When to Use | Key Feature |
|------|-------------|-------------|
| **Slide Deck** | Presentations, pitches | 16:9, keyboard nav, transitions |
| **Infographic** | Data summaries, visual stories | Long scroll, big numbers, sections |
| **Dashboard** | Metrics, KPIs | Grid of cards + charts |
| **Flowchart** | Processes, architecture | Mermaid or SVG diagrams |
| **Timeline** | Chronological events | Alternating left/right, scroll-triggered |
| **Comparison** | Side-by-side analysis | Feature matrix, pros/cons |
| **Data Viz** | Charts, data stories | Chart.js or D3 |
| **One-Pager** | Summaries, briefs | Single viewport, print-friendly |
| **Mind Map** | Concept relationships | Radial SVG layout |
| **Kanban** | Status tracking | Column-based cards |
| **Carousel Cards** | Social (IG/LinkedIn) | 1080×1080 per card, swipeable, bold text |
| **Event Poster** | Conferences, meetups | Portrait A4/letter, bold headline, date/venue |
| **Resume/CV** | Job applications | One-page, two-column, print-optimized |
| **Banner/Header** | Email, blog, social cover | 1200×630 or 1500×500, centered text on visual bg |
| **Quote Card** | Social proof, testimonials | Portrait/square, large quote, attribution |
| **Process Guide** | How-to, step-by-step | Numbered steps, icons, clear flow |
| **Status Report** | Executive updates | KPIs + progress bars + highlights, one-page |
| **Org Chart** | Team structure | Hierarchical tree, photos/avatars, roles |
| **Data Story** | Narrative + data | Scrollytelling, charts woven with text |
| **Product Card** | Feature highlight, launch | Hero image area, feature pills, CTA |

Every file MUST have ≥1 interaction beyond theme + menu — see the Type-Specific Interactivity table in
[references/types.md](references/types.md#type-specific-interactivity-mandatory).

## Source content

This skill runs mid-conversation. Leverage everything as source material — never invent placeholder data:
- **Conversation context** — summarize, structure, or visualize what's been discussed.
- **URLs** — `WebFetch` to crawl and extract content, then visualize as a summary.
- **Pasted data** — CSV (parse, auto-detect headers → chart), JSON (keys = labels, values = data, nested = series), tables (→ comparison/chart), numbers in text (→ stat cards).
- **Ideas / concepts / code** — turn abstract discussions or system designs into diagrams and data flows.

## Pick-and-Extract

When the visualization's purpose is to let the user **choose between rendered options** and hand the
decision back to you (UI variants, color schemes, layouts, copy choices), make the options selectable on
the page and add a clipboard export — a standalone `.html` can't post back, so the clipboard is the bridge.
Trigger phrases: "let me pick on the HTML," "make the options selectable," "I'll choose and send it back."
Full pattern, wiring code, and gotchas: [references/pick-and-extract.md](references/pick-and-extract.md).

## Reference map

Load only the file relevant to the current step (progressive disclosure):

| File | Load when |
|------|-----------|
| [references/skeleton.md](references/skeleton.md) | Always — the mandatory starting template + evaluation requirements. |
| [references/types.md](references/types.md) | Picking a type and applying its layout/interaction rules. |
| [references/libraries.md](references/libraries.md) | Wiring a CDN library (Chart.js, D3, Mermaid, Reveal.js, Leaflet, Tailwind) or debugging blank charts. |
| [references/design-system.md](references/design-system.md) | Typography, color, spacing, sizing, layout, accessibility, anti-patterns. |
| [references/menu.md](references/menu.md) | Building/verifying the required hamburger menu. |
| [references/animations.md](references/animations.md) | Entrance, scroll-driven, hover, and counter animation patterns. |
| [references/css-techniques.md](references/css-techniques.md) | Advanced CSS — container queries, `:has()`, view transitions, conic gradients, fluid type. |
| [references/pick-and-extract.md](references/pick-and-extract.md) | Decision visualizations the user picks on and exports back. |
| [references/eval.md](references/eval.md) | The 8-dimension scoring rubric the output is graded against. |
| [references/anthropic-skill-guide-notes.md](references/anthropic-skill-guide-notes.md) | Background on the skill-authoring best practices behind this structure. |

The quality bar: **"good, period"** — not "good for AI-generated."

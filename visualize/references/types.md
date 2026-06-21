# Visualization Type Patterns

Detailed patterns for each visualization type. Load only the section relevant to the current task.

## Table of Contents
- [Slide Deck](#slide-deck)
- [Infographic](#infographic)
- [Dashboard](#dashboard)
- [Flowchart / Diagram](#flowchart--diagram)
- [Timeline](#timeline)
- [Comparison](#comparison)
- [Data Visualization](#data-visualization)
- [One-Pager](#one-pager)
- [Mind Map](#mind-map)
- [Kanban Board](#kanban-board)
- [Carousel Cards](#carousel-cards)
- [Event Poster](#event-poster)
- [Quote Card](#quote-card)
- [Single-Screen / Mobile-Fit (posters, cards, one-pagers)](#single-screen--mobile-fit-posters-cards-one-pagers)
- [Type-Specific Interactivity (mandatory)](#type-specific-interactivity-mandatory)

Other named types (Resume/CV, Banner/Header, Process Guide, Status Report, Org Chart, Data Story,
Product Card) follow the same skeleton + design system — pick the closest layout pattern above and
apply the relevant fixed-dimension or scroll rules.

---

## Slide Deck

### Structure
```html
<div class="deck">
  <section class="slide" data-notes="Speaker notes here">
    <!-- slide content -->
  </section>
</div>
```

### Navigation Pattern
```javascript
// Keyboard: ← → arrows, Space, Enter
// Click: left third = prev, right two-thirds = next
// Touch: swipe left/right
// URL hash: #slide-3 for direct linking
```

### Slide Types
1. **Title Slide** — big title, subtitle, optional author/date. Centered. Impactful.
2. **Content Slide** — heading + bullets or heading + visual. Never both walls of text AND a visual.
3. **Section Divider** — full-bleed color/gradient with section title. Breaks up the flow.
4. **Image/Visual Slide** — full-bleed image or large SVG diagram with minimal text.
5. **Two-Column** — split layout for comparisons, text+image, or code+explanation.
6. **Quote Slide** — large pull quote with attribution. Elegant typography.
7. **Data Slide** — chart/graph with one key insight called out.
8. **Closing Slide** — CTA, contact info, or summary. Memorable.

### Best Practices
- First slide hooks attention — bold statement or question
- One idea per slide
- Use progressive reveal within slides (CSS animation delays) for builds
- Consistent positioning: titles always same spot, content always same region
- Slide transitions: `transform: translateX()` with `transition: transform 0.5s cubic-bezier(0.4, 0, 0.2, 1)`

### Production rules (get these right — slides are the most common request)
- **16:9 aspect ratio** — `100vw × 100vh`, content centered.
- **Responsive** — `clamp()` + container queries: `.slide-title { font-size: clamp(2rem, 8vw, 4rem); }`,
  `.slide-container { container-type: inline-size; }`, `@container (width < 768px) { .slide-content { padding: 1rem; } }`.
- **Max 40 words per slide**; **headlines max 6 words**. One idea per slide.
- **Stat slides:** big number 3–5rem + small label 0.875rem + one insight sentence.
- **Nav:** keyboard ← → Space Enter; touch swipe; click left-third = prev / right two-thirds = next.
- **Progress bar** (thin gradient, top) + **slide counter** ("3 / 12").
- **Mobile nav prominence:** ≥44px touch targets, contrasting colors, backdrop-blur on floating nav.
- **Smooth transitions:** `transform: translateX()` with 500ms cubic-bezier; staggered entrance animations per slide.
- **Speaker notes:** `data-notes` attribute, visible in print only.

#### High-impact business decks (pitches / investor / exec)
- Hero slide visual weight — stronger gradients, 4–6rem typography, a compelling stat prominent.
- Value proposition readable in under 5 seconds.
- Enterprise/investment-grade typography, spacing, color.
- Each chart slide carries a clear insight callout — not raw data alone.

#### Theme-aware slide gradients (CRITICAL)
Decks MUST look intentional in both themes. Title/section slides use theme-specific gradient pairs;
content slides use `var(--bg)`/`var(--surface)` — never hardcoded dark colors.
```css
/* Dark: deep, saturated */
.theme-dark .slide-title { background: linear-gradient(135deg, #1e1b4b 0%, #312e81 50%, #1e3a5f 100%); }
.theme-dark .slide-content { background: var(--bg); }
/* Light: soft, pastel */
.theme-light .slide-title { background: linear-gradient(135deg, #e0e7ff 0%, #c7d2fe 50%, #dbeafe 100%); }
.theme-light .slide-content { background: var(--bg); }
```
Choose gradient hues that evoke the subject (tech = cool blues, game = vibrant purples/cyans,
healthcare = calming greens/teals). Toggle the theme and every slide should look designed for that mode.

#### Slide chart requirements
Chart slides follow the same container standards as dashboards, but larger for readability:
```html
<div class="chart-slide-container">
  <h2>Chart Title</h2>
  <div class="chart-container" style="height: 400px; padding: 40px; border-radius: 12px; background: var(--surface);">
    <canvas id="slideChart" role="img" aria-label="Description"></canvas>
  </div>
</div>
```
- Minimum height **400px** for slide charts (vs 360px dashboards).
- `maintainAspectRatio: false` required. See [libraries.md](libraries.md#chartjs) for the full chart pattern.

#### Slide types
1. **Title** — theme-aware gradient bg, big headline, subtitle, centered.
2. **Content** — heading + bullets OR heading + visual. Never text-heavy.
3. **Section divider** — full-bleed accent color, section title only.
4. **Stat** — one big number, one label, one insight sentence.
5. **Chart** — Chart.js viz with title + key takeaway; use `chart-container` wrapper.
6. **Two-column** — split layout for comparisons, text+visual.
7. **Quote** — large pull quote with attribution.
8. **Closing** — CTA, contact info, or summary + social links.

---

## Infographic

### Structure
- Single long-scroll page
- Clear visual hierarchy with sections
- Use icons (inline SVG) to break up text
- Number callouts for statistics
- Color-coded sections

### Layout Pattern
```
┌─────────────────────────┐
│      HERO / TITLE       │
├─────────────────────────┤
│   Key Stat  │  Key Stat │
├─────────────────────────┤
│     Section 1           │
│  ┌────┐ ┌────┐ ┌────┐  │
│  │Icon│ │Icon│ │Icon│  │
│  │Text│ │Text│ │Text│  │
│  └────┘ └────┘ └────┘  │
├─────────────────────────┤
│     Chart / Visual      │
├─────────────────────────┤
│     Section 2           │
│     Timeline/Flow       │
├─────────────────────────┤
│     CTA / Source        │
└─────────────────────────┘
```

### Best Practices
- Max width 800px, centered
- Use scroll-triggered animations (IntersectionObserver)
- Big numbers: 48px+ font size, bold, accent color
- Source citations at bottom
- Shareable: looks good when screenshotted

---

## Dashboard

### Structure
- CSS Grid layout with cards
- Header with title + date/time
- KPI cards at top (3-5 key metrics)
- Charts/tables below in grid
- Optional sidebar for filters

### KPI Card Pattern
```html
<div class="kpi-card">
  <span class="kpi-label">Revenue</span>
  <span class="kpi-value">$1.2M</span>
  <span class="kpi-change positive">↑ 12.3%</span>
</div>
```

### Chart Patterns (SVG)
- **Bar chart**: `<rect>` elements with CSS transitions on height
- **Line chart**: `<polyline>` or `<path>` with stroke-dasharray animation
- **Donut chart**: `<circle>` with stroke-dasharray/stroke-dashoffset
- **Sparkline**: tiny `<polyline>` in KPI cards

### Best Practices
- Use CSS Grid with `auto-fit` and `minmax()` for responsive cards
- Subtle card shadows, no borders
- Color-code positive (green) and negative (red) changes
- Tooltips on hover for data points
- Auto-refresh indicator (even if static — sells the "live" feel)

---

## Flowchart / Diagram

### Approach
Use SVG for the diagram. Position nodes with CSS Grid or absolute positioning within an SVG viewBox.

### Node Types
```svg
<!-- Rounded rectangle (process) -->
<rect rx="8" />
<!-- Diamond (decision) -->
<polygon points="50,0 100,50 50,100 0,50" />
<!-- Circle (start/end) -->
<circle />
<!-- Parallelogram (input/output) -->
<polygon points="20,0 100,0 80,50 0,50" />
```

### Connection Lines
- Use `<path>` with cubic bezier curves for smooth connections
- Arrow markers: `<marker>` element with `<polygon>` arrowhead
- Elbow connectors for orthogonal layouts

### Best Practices
- Left-to-right or top-to-bottom flow
- Consistent node sizes
- Labels centered in nodes
- Color-code different paths (success=green, error=red)
- Keep it simple: max 15-20 nodes before splitting into sub-diagrams

---

## Timeline

### Layout Options
1. **Vertical** — line down the center, events alternate left/right
2. **Horizontal** — scrollable timeline for fewer events
3. **Compact** — single column with dots and lines

### Vertical Timeline Pattern
```
     ┌──────────┐
     │ Event 1  │──── ●
     └──────────┘     │
                      │
          ● ────┌──────────┐
                │ Event 2  │
                └──────────┘
                      │
     ┌──────────┐     │
     │ Event 3  │──── ●
     └──────────┘
```

### Best Practices
- Alternating sides for visual balance
- Dates prominently displayed
- Color/icon differentiation for event types
- Scroll-triggered entrance animations
- "Now" marker for roadmaps

---

## Comparison

### Layout Options
1. **Side-by-side cards** — 2-3 options in columns
2. **Feature matrix** — rows = features, columns = options, checkmarks/values
3. **Before/After** — split screen

### Feature Matrix Pattern
- Sticky header row
- Alternating row backgrounds
- ✓ / ✗ icons (SVG) instead of text
- Highlight recommended option with accent border/badge

### Best Practices
- Max 4 comparison columns (more = overwhelming)
- Highlight key differentiators
- Use icons for quick scanning
- Color-code to guide toward recommended option (subtle, not pushy)

---

## Data Visualization

### Chart Types (all SVG-based)
- **Bar**: vertical or horizontal, grouped or stacked
- **Line**: single or multi-series, area fills
- **Pie/Donut**: max 6 segments, label percentages
- **Scatter**: for correlations, size for third dimension
- **Heatmap**: grid of colored cells

### SVG Chart Essentials
- Always include axes with labels
- Grid lines: subtle (`stroke: #eee`, `stroke-dasharray: 4`)
- Legend: positioned consistently (top-right or bottom)
- Responsive viewBox: `viewBox="0 0 600 400"` with `preserveAspectRatio`
- Animate on load: stroke-dasharray for lines, scaleY for bars

### Best Practices
- Lead with the insight, not the data
- Annotate key data points directly on the chart
- Don't use 3D effects
- Start y-axis at 0 for bar charts (line charts can break this rule)
- Max 5-7 data series per chart

---

## One-Pager

### Structure
- Hero section with headline + subtext
- 3-4 content sections
- Clear CTA or conclusion
- Max viewport: feels complete without scrolling (or minimal scroll)

### Best Practices
- Large hero text (48px+)
- Icon + text pairs for features
- Centered layout, max-width 960px
- Professional but not boring — one bold design choice
- Works as a screenshot/PDF

---

## Mind Map

### Approach
- Central node with radiating branches
- SVG with `<path>` curved connections
- Color-code branches by category
- Nodes expand on click (optional interactivity)

### Layout Algorithm (simplified)
- Center node at viewBox center
- First-level nodes in a circle around center
- Second-level nodes branch outward from their parent
- Use polar coordinates for positioning

### Best Practices
- Max 2-3 levels deep for readability
- Curved, organic-looking connections (bezier)
- Node size reflects importance
- Hover to highlight a branch and dim others

---

## Kanban Board

### Structure
```html
<div class="board">
  <div class="column">
    <h3>To Do</h3>
    <div class="card">Task</div>
  </div>
  <div class="column">
    <h3>In Progress</h3>
    <div class="card">Task</div>
  </div>
  <div class="column">
    <h3>Done</h3>
    <div class="card">Task</div>
  </div>
</div>
```

### Best Practices
- 3-5 columns (horizontal scroll if needed)
- Cards with title, optional tags/labels (color-coded chips), optional assignee avatar
- Column headers with item count
- Subtle drag-handle visual (even if not functional)
- WIP limits indicator
- Column background colors (very subtle) to differentiate stages

---

## Carousel Cards

Huge for social media (IG/LinkedIn). Get these right:
- **Square format** — `1080×1080px` (or configurable via CSS var).
- **One idea per card** — bold headline + 1–2 supporting points max.
- **Swipe nav** — arrows + dots + touch swipe + keyboard.
- **Card counter** — "3 / 8" visible.
- **Download all** — PNG export of individual cards or the full set.
- **Typography dominates** — headline 2.5–4rem, minimal body text.
- **Color-coded** — each card can have a subtle accent shift.
- **Print layout** — grid of all cards for printing.
- **Max 10 cards** — keep it focused.

---

## Event Poster

- **Portrait orientation** — A4/letter ratio or square.
- **Visual hierarchy** — Event name (largest) → Date/Time → Location → Description → CTA.
- **Bold headline** — 3–5rem, max 6 words.
- **Date/time prominent** — styled as a badge or highlighted block.
- **QR code area** — placeholder box for the registration link.
- **Print-first** — looks great printed, dark or light theme.

---

## Quote Card

- **Large quotation marks** — decorative " " in accent color, oversized.
- **Quote text** — 1.5–2.5rem, serif or italic weight for contrast.
- **Attribution** — name, title, company below the quote.
- **Square or portrait** — optimized for social sharing.
- **Minimal design** — the quote is the hero; everything else is subtle.

---

## Single-Screen / Mobile-Fit (posters, cards, one-pagers)

When the user asks for something that fits "one screen," "phone screen," "9:16," or "mobile-fit,"
create a **fixed-dimension single-viewport** visualization — NOT a scrolling page.

**Dimensions:**
- **9:16 portrait (phone):** `1080×1920px` — IG Story / phone screen
- **1:1 square:** `1080×1080px` — IG post
- **4:5 portrait:** `1080×1350px` — IG portrait post
- **16:9 landscape:** `1920×1080px` — presentation slide

**Critical CSS pattern:**
```css
body {
  width: 1080px; height: 1920px;   /* or chosen ratio */
  overflow: hidden;                 /* MUST — enforces single screen */
  display: flex; flex-direction: column;
}
.poster-header { padding: 44px 48px 0; }
.poster-grid { flex: 1; padding: 24px 48px 0; }  /* flex:1 fills remaining space */
.poster-footer { padding: 16px 48px 36px; }
```

**Layout rules:**
- `overflow: hidden` on body — this is what makes it "one screen." Non-negotiable.
- `justify-content: space-between` on the main container — even distribution, no dead gaps.
- `flex: 1` on the main content area so it fills ALL space between header and footer.
- Wrap each logical section in a `<div>` so flexbox distributes them.
- **Zero dead space rule:** 100% canvas utilization. If empty space shows, expand content or reduce padding.
- **No hamburger menu** for fixed-dimension posters — wasted space; meant for screenshot/export.

**Content density for 9:16:** Hero ~25%, 2–3 content sections ~55%, footer/CTA ~10%, gaps ~10%.
If it looks empty, the content is too small — scale up fonts, add grid items, use larger icons.

**Font sizing for 1080px-wide posters:** Hero h1 `68–80px`; section labels `15–18px` uppercase
(letter-spacing `0.06em`); card text `16–20px`; body `20–24px`.

**Common mistake:** making a scrolling page and screenshotting it. That's a webpage screenshot, not a
poster. A poster is a fixed canvas where every pixel is intentional.

---

## Type-Specific Interactivity (mandatory)

Every file MUST have at least ONE meaningful interaction beyond theme toggle + menu. Static-feeling
pages score low on interactivity.

| Type | Required Interaction |
|------|---------------------|
| **Cheatsheet** | Search/filter input + copy-to-clipboard on code blocks. `<details name="...">` for collapsible groups. |
| **Dashboard** | Filter toolbar or metric drill-down. At minimum: date range or category filter. |
| **Status Report** | Collapsible detail sections (`<details>`). Progress bars animate on scroll. |
| **Quote Card** | Auto-cycling quotes OR swipeable carousel. Share/copy button. |
| **Event Poster** | Animated countdown timer (days/hours/min/sec). RSVP/register button. |
| **Process Guide** | Steps as exclusive accordion (`<details name="steps">`). Or interactive progress tracker. |
| **Architecture** | Clickable nodes with popover details (Popover API). Hover highlights connections. |
| **Timeline** | Filter by era/category. Or click to expand event details. |
| **Comparison** | Toggle categories on/off. Or highlight winner per row. |
| **Carousel** | Touch swipe + keyboard + auto-advance option. Card counter always visible. |
| **Slide Deck** | Already interactive (nav). Add: presenter timer, slide overview grid. |

If a type isn't listed, add at minimum a filter, search, sort, or expand/collapse interaction.

---
name: tally
description: Edit Tally forms via MCP tools. Use when user mentions Tally, questionnaires, form building, form blocks, or Tally form IDs. Provides workflow patterns and gotchas for the Tally MCP.
---

# Tally Form Editor

You are a Tally form editor that helps users build and modify Tally forms using the Tally MCP tools. The tool prefix depends on how the server is registered: it may be `mcp__tally__*` OR `mcp__claude_ai_Tally__*` (the claude.ai-connected server). The `claude_ai_Tally` server is the more capable one and **CAN create conditional logic** via `apply_logic` (see §5). Check which prefix is available before assuming a tool is missing.

## Working with your forms

Get a form's ID from its share URL — `https://tally.so/r/<formId>` (or `https://tally.so/forms/<formId>/...`).
The user supplies the form ID(s) for the forms they want to edit.

**Multi-language mirrors:** if you maintain the same form in several languages, pick one language as the
source of truth and keep the others in sync. When syncing, diff the two forms and replicate **structure +
conditional logic**, not just the translated text.

## Required Workflow (CRITICAL)

The Tally MCP uses an **editing session** model. You MUST follow this exact sequence:

### Step 1: Load the form
```
mcp__tally__load_form(formId: "FORM_ID")
```
This starts an editing session. The response contains all blocks with their UUIDs, types, and properties in a **ledger** format.

### Step 2: Make changes
Use any combination of (prefix `mcp__tally__` or `mcp__claude_ai_Tally__`):
- `create_blocks` — add new blocks
- `remove_blocks` / `remove_questions` / `remove_pages` — delete blocks / whole questions / whole pages
- `update_text` — change text/HTML content (batch multiple blocks in one call)
- `configure_blocks` — change block properties (incl. `visibility` to hide/show, and `change_type` to convert a field e.g. TEXTAREA→INPUT_TEXT in place, preserving the blockUuid)
- `apply_logic` — create/update conditional logic rules via a `WHEN … THEN …` DSL (see §5)
- `reposition_questions` / `reposition_pages` — reorder

### Step 3: Save the form
```
mcp__tally__save_form(formId: "FORM_ID", status: "PUBLISHED")
```
**Changes are NOT persisted until you save.** If you skip this step, all edits are lost.

## Key Gotchas (Learned from Experience)

### 1. Response Format Errors (Transient)
The Tally MCP sometimes returns `MCP error -32602: Invalid tools/call result` on `content[1]`. This is a **transient** issue — retry the same call and it usually works. The `load_form` and `save_form` tools are most reliable; `create_blocks` and `list_blocks` may need a retry.

### 2. Block Positioning — Use the Ledger
Every mutation tool returns an updated ledger. Use `blockUuid` from the ledger for positioning:
- `insertAfterBlockUuid` = the `blockUuid` of the block you want to insert AFTER
- To insert BEFORE a block, use that block's `insertAfterBlockUuid_BEFORE` value from the ledger

### 3. HTML Formatting in TEXT Blocks
TEXT blocks support rich HTML:
- `<b>bold</b>` or `<strong>bold</strong>`
- `<u>underline</u>`
- `<b><u>bold+underline</u></b>`
- `<br>` for line breaks (use `<br><br>` for paragraph spacing)
- `<p>paragraph</p>` for paragraph blocks
- Tally auto-converts `<b>` to `<span style="font-weight: bold;">` internally

### 4. Block Groups — Questions are Multi-Block
A question is a GROUP of blocks, not a single block:
- `TITLE` + `INPUT_TEXT` = text question
- `TITLE` + `MULTIPLE_CHOICE_OPTION` + `MULTIPLE_CHOICE_OPTION` = radio question
- `TITLE` + `DROPDOWN_OPTION` + ... = dropdown question

When creating questions, include ALL blocks for the group in one `create_blocks` call.

### 5. Conditional Logic — CAN be done via `apply_logic` (the old "UI only" note was WRONG)
The `claude_ai_Tally` server exposes **`apply_logic`**, which creates/updates logic rules from a DSL. (Only the legacy `mcp__tally__*` server lacked this — verify your prefix before claiming it's impossible.)

**DSL shape:** `WHEN <questionUuid> IS <optionBlockUuid> THEN <action>[, <action>...]`
- `operations: [{operation: "insert", dsl: "..."}]` — one rule per operation; batch many in one call.
- **Condition LHS** = the question's `questionUuid` (for a choice question this is the **options' shared groupUuid**, shown in the ledger's `questionUuid` column — NOT the TITLE's group).
- **Condition RHS** for choice fields = the **option's `blockUuid`** (not its text). Text fields: `IS "literal"`. Also: `IS EMPTY`, `IS NOT`, `CONTAINS`, `> 5`, `IS ANY OF (uuid,uuid)`, etc.
- **Chain MULTIPLE actions with COMMAS, not `AND`** (`AND` is only for chaining *conditions*). `THEN SHOW <q>, REQUIRE <q>` ✓ — `THEN SHOW <q> AND REQUIRE <q>` ✗ ("Unexpected content after rule").
- **Actions:** `SHOW <questionUuid>` / `HIDE <questionUuid>` (full question), `REQUIRE <questionUuid>`, `JUMP TO PAGE <n>`. SHOW/HIDE/REQUIRE take a `questionUuid` for a whole question, or a `blockUuid` for a single block (e.g. one option).

**Two-part gotcha for "show field only when X":**
1. The target field must be **hidden by default** — set `configure_blocks` `visibility isHidden:true` on its blocks FIRST. `apply_logic` only creates the rule; it does NOT auto-hide. (A field with a SHOW rule but no default-hide stays always visible.)
2. `REQUIRE` auto-marks the field `isRequired:false` by default and required-only-when-shown — this is correct/expected.

**questionUuid grouping:** A TITLE, an interspersed helper `TEXT` block, and the input all share ONE `questionUuid` even though their internal block `groupUuid`s differ. So a single `SHOW <questionUuid>` reveals the title + helper + input together — you do NOT need separate SHOW actions per block.

**Reference:** a full set of conditional logic rules + default-hidden blocks can be mirrored across two
forms purely via `apply_logic` + `configure_blocks`. Pattern: `WHEN <q> IS <Yes-option> THEN SHOW <followup>, REQUIRE <followup>`.

### 6. Form Title Blocks — Editable via API (OLD "UI-only" note was WRONG)
`FORM_TITLE` blocks **can** be edited via `update_text` like any TITLE/TEXT/HEADING block, **including inserting mentions** — verified June 2026 against current Tally docs (developers.tally.so/documentation/creating-a-mention uses FORM_TITLE as the mention example) and live on real forms. The old `safeHTMLSchema` validation-failure warning is stale. Only fall back to the Tally UI if a *specific* `save_form` actually rejects the title edit.

### 6b. Mentions / Recall — render a hidden field (or answer) inside text
`update_text` supports **mentions** in `TITLE`, `TEXT`, `HEADING`, and `FORM_TITLE` blocks (NOT in input placeholders or option text — those strip to plain text). Use them to display a value dynamically:
- **Syntax:** put `{{Field Title}}` or `{{questionUuid}}` in the `html`. The MCP **auto-corrects a field name to its UUID** and reports it, e.g. `Auto-corrected: "year" → {{aef51653-…}}`. Referencing a **hidden field by name** works (`{{year}}`), but the stored form is UUID-based.
- **Hidden-field use case:** a hidden field populated from a URL query param (`?year=2024`) renders **on first page load**, before any input — so it shows in the form title and the very first question. This lets a form become year-dynamic for any year without per-year duplication.
- **Reconstruct full block HTML:** `update_text` replaces the *entire* block. For multi-run TEXT blocks, rebuild the full HTML (`<b>`, `<u>`, `<br>`) and put the mention token where the dynamic value goes (e.g. `31.12.{{year}}`).
- **No `defaultValue` via MCP:** the `{{}}` shorthand can't set a fallback for a missing param → the mention renders blank if the param is absent. Ensure the URL always supplies it, or set the default once in the Tally UI.
- **Verify after save:** reload (or read the returned ledger) and confirm the block shows a `mentions=…` entry / `{{uuid}}` placeholder, NOT a literal `{{year}}` string.

### 7. Groups Auto-Chain
When passing multiple groups with the same `insertAfterBlockUuid` to `create_blocks`, only the first group uses it — subsequent groups auto-chain after the previous one.

## Block Types Reference

| Type | Description | Requires TITLE? |
|------|-------------|-----------------|
| `TEXT` | Static text / paragraph | No |
| `HEADING_1` | Main heading | No |
| `HEADING_2` | Section heading | No |
| `HEADING_3` | Sub-section heading | No |
| `DIVIDER` | Horizontal rule | No |
| `PAGE_BREAK` | New page | No |
| `IMAGE` | Image block | No |
| `INPUT_TEXT` | Short text input | Yes |
| `TEXTAREA` | Long text input | Yes |
| `INPUT_EMAIL` | Email input | Yes |
| `INPUT_NUMBER` | Number input | Yes |
| `INPUT_PHONE_NUMBER` | Phone input | Yes |
| `INPUT_DATE` | Date picker | Yes |
| `MULTIPLE_CHOICE_OPTION` | Radio button option | Yes (+ multiple options) |
| `DROPDOWN_OPTION` | Dropdown option | Yes (+ multiple options) |
| `CHECKBOX` | Checkbox option | Yes (+ multiple options) |
| `FILE_UPLOAD` | File upload | Yes |
| `LINEAR_SCALE` | Numeric scale | Yes |
| `RATING` | Star rating | Yes |
| `HIDDEN_FIELDS` | URL query params | No |
| `CAPTCHA` | Bot protection | No |

## Common Operations

| User says... | Action |
|--------------|--------|
| "Add a paragraph to form X" | load_form > create_blocks (TEXT) > save_form |
| "Add a question to form X" | load_form > create_blocks (TITLE + INPUT) > save_form |
| "Change text in form X" | load_form > update_text > save_form |
| "Remove a question" | load_form > remove_questions > save_form |
| "Reorder questions" | load_form > reposition_questions > save_form |
| "Make a field optional" | load_form > configure_blocks (isRequired: false) > save_form |
| "Hide a field" | load_form > configure_blocks (visibility, isHidden: true) > save_form |
| "Show field Y only when X = Yes" | load_form > configure_blocks (visibility isHidden:true on Y's blocks) > apply_logic (`WHEN <Xq> IS <YesOpt> THEN SHOW <Yq>, REQUIRE <Yq>`) > save_form |
| "Sync English form to Hebrew" | load both (read-only diff) > replicate structure, options, **and conditional logic** via apply_logic > save_form. Translate wording; don't just copy text. |

## Localization / RTL Guidelines

- Use `<br>` for line breaks inside block HTML, not `\n`.
- Bold (or bold+underline) the key terms a respondent must not miss — option qualifiers, definitions,
  required-vs-optional markers — and keep that styling consistent across the whole form.
- Include any privacy/consent notice in a `TEXT` block right after the intro paragraph.
- Phone fields: set `defaultCountryCode` to the form's primary country (e.g. `"US"`, `"IL"`, `"GB"`).
- For RTL languages (Hebrew, Arabic, …), author the form in that language as the source of truth and
  mirror other languages from it (see the "Sync … form" row above) — replicate structure + logic, not
  just translated text.

## Reference

- [Tally MCP Tools](https://api.tally.so/mcp) — the MCP endpoint
- [api-reference.md](api-reference.md) — detailed tool patterns and examples

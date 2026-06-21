# Tally MCP — API Reference

## Tool Inventory

Tool prefix depends on how the server is registered — `mcp__claude_ai_Tally__*` for the claude.ai-connected server (the one currently configured) or `mcp__tally__*` for a legacy/CLI-registered server. Examples below use the bare `mcp__tally__` form for brevity; substitute your actual prefix. See SKILL.md for the prefix-detection note.

### Session Management
| Tool | Description |
|------|-------------|
| `load_form(formId)` | Start editing session, returns full block ledger |
| `save_form(formId, status)` | Persist changes. Status: `PUBLISHED`, `DRAFT`, `BLANK`, `DELETED` |
| `list_blocks()` | Get current ledger (form must be loaded first) |

### Block Creation
| Tool | Description |
|------|-------------|
| `create_blocks(groups)` | Add blocks. Each group has `insertAfterBlockUuid` + `blocks[]` |
| `create_new_form(title, workspaceId?)` | Create a brand new form |

### Block Modification
| Tool | Description |
|------|-------------|
| `update_text(updates)` | Change text/HTML of existing blocks |
| `configure_blocks(updates)` | Change properties (visibility, required, settings) |
| `set_form_title(...)` | Update form title via configure_blocks |
| `set_column_layout(...)` | Set column layout for blocks |

### Block Removal
| Tool | Description |
|------|-------------|
| `remove_blocks(blockUuids)` | Remove specific blocks |
| `remove_questions(...)` | Remove entire question groups |
| `remove_pages(...)` | Remove entire pages |

### Reordering
| Tool | Description |
|------|-------------|
| `reposition_questions(...)` | Move/swap/reorder questions |
| `reposition_pages(...)` | Move/swap/reorder pages |
| `move_blocks(...)` | Move blocks between positions |

### Data
| Tool | Description |
|------|-------------|
| `fetch_submissions(formId, page?, limit?, filter?)` | Get form responses |
| `list_forms()` | List all forms in workspace |
| `list_workspaces()` | List available workspaces |

### Settings
| Tool | Description |
|------|-------------|
| `update_settings(...)` | Update form-level settings |

## create_blocks — Detailed Pattern

```
mcp__tally__create_blocks({
  groups: [{
    insertAfterBlockUuid: "uuid-from-ledger",
    blocks: [
      { type: "TEXT", html: "Hello <b>world</b>" },
      { type: "HEADING_2", html: "Section Title" },
      { type: "TITLE", html: "Question text?" },
      { type: "MULTIPLE_CHOICE_OPTION", text: "Option A" },
      { type: "MULTIPLE_CHOICE_OPTION", text: "Option B" }
    ]
  }]
})
```

### Block Type Schemas

**Text/Heading blocks:** `{ type, html }` — html supports rich formatting
**Input blocks:** `{ type, placeholder? }` — INPUT_TEXT, TEXTAREA, INPUT_EMAIL, etc.
**Option blocks:** `{ type, text }` — MULTIPLE_CHOICE_OPTION, DROPDOWN_OPTION, CHECKBOX, etc.
**Image blocks:** `{ type, name, url, altText?, caption?, link? }`
**Hidden fields:** `{ type: "HIDDEN_FIELDS", hiddenFields: [{ name: "field_name" }] }`
**Page break:** `{ type: "PAGE_BREAK", isThankYouPage? }`
**Divider:** `{ type: "DIVIDER" }`

## configure_blocks — Operations

| Operation | Key Fields |
|-----------|------------|
| `visibility` | `blockUuid, isHidden` |
| `input_settings` | `blockUuid, isRequired?, defaultAnswer?` |
| `form_title_settings` | `blockUuid, logo?, cover?, button?` |
| `page_break_settings` | `blockUuid, name?, button?` |
| `choice_behavior` | `blockUuid, allowMultiple?, randomize?, badgeType?` |
| `phone_settings` | `blockUuid, defaultCountryCode?` |
| `date_display` | `blockUuid, format?, startWeekOn?` |
| `file_settings` | `blockUuid, hasMultipleFiles` |
| `hidden_fields_settings` | `blockUuid, hiddenFields[]` |
| `change_type` | `blockUuid, type` — change block type |
| `scale_range` | `blockUuid, start, end, step?` |
| `scale_labels` | `blockUuid, leftLabel?, rightLabel?, centerLabel?` |

## update_text — Pattern

```
mcp__tally__update_text({
  updates: [
    { blockUuid: "uuid", html: "New <b>content</b>" }
  ]
})
```

Supports batch updates — multiple blocks in one call.

**Field references (mentions):** Use `{{questionUuid}}` or `{{Field Title}}` in html to show a field's answer dynamically.

## fetch_submissions — Pattern

```
mcp__tally__fetch_submissions({
  formId: "FORM_ID",
  page: 1,
  limit: 50,
  filter: {
    status: "completed",     // "all", "completed", "partial"
    startDate: "2025-01-01", // ISO 8601
    endDate: "2025-12-31"
  }
})
```

Returns paginated results with `hasMore` flag for pagination.

## Ledger Format

After every mutation, the tool returns a ledger table:

```
|#|text/html|blockUuid|type|questionUuid|page|insertAfterBlockUuid_BEFORE|properties|
```

Key columns:
- `#` — sequential block number
- `blockUuid` — unique ID, use for positioning and updates
- `type` — block type (TEXT, TITLE, INPUT_TEXT, etc.)
- `questionUuid` — group UUID (shared by TITLE + its input blocks)
- `page` — page number (1-based)
- `insertAfterBlockUuid_BEFORE` — use this to insert BEFORE this block
- `properties` — isRequired, isHidden, conditional logic, etc.

## Error Handling

### Transient MCP Response Errors
```
MCP error -32602: Invalid tools/call result: content[1]...
```
This means the operation may have succeeded but the response format is invalid. **Retry the call** — it usually works on the second attempt. If persistent, try: load_form > operation > save_form (save_form is most reliable).

### Large Form Responses
`load_form` may return results exceeding token limits, saved to a temp file. Read the file to extract block UUIDs and structure.

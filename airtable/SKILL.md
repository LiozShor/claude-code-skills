---
name: airtable
description: 'Read or write Airtable records — bases, tbl/rec/fld IDs, filterByFormula, pyairtable. Not for n8n workflows or Google Sheets/Excel.'
allowed-tools: Bash, Read
---

# Airtable Client

You are an Airtable client that helps users access their bases, tables, and records using curl for reads and Python `pyairtable` for writes.

## When this triggers

- User mentions Airtable, a base, table, record, `filterByFormula`, `pyairtable`, or a `tbl…`/`rec…`/`fld…` ID.
- User asks to query, list, find, count, create, update, upsert, or delete records.
- User asks about schema/fields of an Airtable table.
- A 422 came back from an Airtable request and the user wants help debugging.

## When this does not trigger

- n8n Airtable nodes inside a workflow JSON — use the n8n skill (this skill is for direct API access only).
- Google Sheets, Excel, CSV, or any non-Airtable tabular data.
- Editing the `.env` file or rotating tokens — out of scope.

## Configuration (no hardcoded IDs)

This skill keeps every base/table ID out of `SKILL.md` so it works against **any** Airtable base by
editing config only:

- **API key** lives in your project's `.env` (or shell env) as `AIRTABLE_API_KEY` — never in this repo.
- **Base + table IDs** live in `config.env` (gitignored). Copy `config.example.env` → `config.env` and
  fill in your real `app…`/`tbl…` values, exposed as shell vars (e.g. `$BASE_ID`, `$<TABLE>_TID`).
- To redeploy against a different base, edit `config.env` only — never hardcode raw `app…`/`tbl…` IDs
  in commands or docs.

Adapt the `source` paths below to wherever your `.env` and `config.env` live.

## Required inputs

Before running anything, confirm you have:

- `AIRTABLE_API_KEY` in env (e.g. `source <your-project>/.env`).
- **Base + table IDs** loaded from config: `source <path-to>/airtable/config.env` sets `$BASE_ID` and
  your table-ID vars. Template: `config.example.env`.
- The **table ID** (`tblXXX`) or table name — prefer the ID var.
- For writes/deletes: the user's explicit go-ahead and the exact record IDs or filter.
- For filtered reads: confirmed field names (satisfy the HARD GATE below).

## Workflow

1. Source your `.env` (API key) and `config.env` (base + table IDs); verify `AIRTABLE_API_KEY` and `$BASE_ID` are set.
2. Identify the operation type — read, write, delete, schema introspect.
3. **Satisfy the HARD GATE** (below) — confirm field names before any `filterByFormula`/`sort`.
4. For reads: build a curl request using `--data-urlencode` per parameter.
5. For writes: ask the user's permission (privacy rule), then use the curl PATCH/POST templates or `pyairtable`.
6. On 422: STOP, run the recovery sequence in "If you get a 422" — do not retry the same query with tweaks.
7. Format results as a clean table or summary, never as raw JSON dumps.

## HARD GATE — Schema check before ANY query

**Do not write a `filterByFormula` or `sort` until you have confirmed the actual field names of the target table.** Field-name guessing is the #1 cause of 422s in this skill. This gate fires even when the skill is invoked from inside another skill / sub-agent context.

Pick ONE of these to satisfy the gate:

1. The table is in a **Quick Reference** you maintain (see below) and you are using ONLY fields listed there.
2. You have just read your project's schema doc for the target table in this conversation.
3. You ran a no-filter probe and saw the actual field names:
   ```bash
   curl -s -G "https://api.airtable.com/v0/$BASE_ID/$TABLE_ID" \
     -H "Authorization: Bearer $AIRTABLE_API_KEY" \
     --data-urlencode "maxRecords=1" | python3 -m json.tool
   ```

If none of the three are true, run the probe FIRST. Do not skip this step to "save a tool call" — every guessed query that 422s costs more than the probe.

Also: **lookup / formula / rollup fields cannot be matched with `=`.** Use `SEARCH('value', {field})` or `FIND('value', ARRAYJOIN({field}))`. A linked-record field returns an array, so `{linked_field}='value'` will never match — use `FIND('value', ARRAYJOIN({linked_field}))`.

## Build your own Quick Reference (optional but recommended)

For a base you query often, keep a short reference of the exact field names + enum values per table so
you can satisfy the schema gate without a probe every time. Generate it once from the base schema:

```bash
python3 -c "
import os
from pyairtable import Api
api = Api(os.environ['AIRTABLE_API_KEY'])
base = api.base(os.environ['BASE_ID'])
for table in base.tables():
    print(f'\n{table.name}:')
    for field in table.schema().fields:
        print(f'  - {field.name} ({field.type})')
"
```

Note for each table which fields are **lookup/formula/rollup/linked** (they need `SEARCH`/`FIND`/`ARRAYJOIN`, not `=`) and which timestamp field is sortable, so future queries are correct on the first try.

## First: Check Prerequisites

Before ANY Airtable operation, run these checks in order:

### Step 1: Check Python

```bash
python3 --version 2>/dev/null || echo "NOT_INSTALLED"
```

**If NOT installed**, guide based on OS:

For **macOS**:
```bash
brew install python3
```

For **Windows**:
Download from https://python.org (add to PATH during install)

For **Linux**:
```bash
sudo apt-get install python3 python3-pip
```

### Step 2: Check pyairtable

```bash
python3 -c "import pyairtable; print(pyairtable.__version__)" 2>/dev/null || echo "NOT_INSTALLED"
```

**If NOT installed**:
```bash
pip3 install pyairtable
```

### Step 3: Check Airtable API Key

```bash
echo "AIRTABLE_API_KEY=${AIRTABLE_API_KEY:+SET}"
```

**If NOT configured**, guide the user:

**Airtable is not configured yet. Let me help you set it up.**

**Step 1: Get your Airtable Personal Access Token**
1. Go to https://airtable.com/create/tokens
2. Click **"Create new token"**
3. Name it "Claude Assistant"
4. Add scopes:
   - `data.records:read` (to read records)
   - `data.records:write` (optional - to create/update)
   - `schema.bases:read` (to see base structure)
5. Add access to the bases you want
6. Click **"Create token"** and copy it (starts with `pat...`)

**Step 2: Set the environment variable**
```bash
echo 'export AIRTABLE_API_KEY="patXXXXXXXX.XXXXXXX"' >> ~/.zshrc
source ~/.zshrc
```

**Step 3: Restart Claude Code** and come back.

Then STOP and wait for the user to complete setup.

## Python Code Patterns (writes / schema introspection only — NOT for filtered reads)

Use these Python patterns for write operations and schema introspection. **Do not use Python `urllib` for filtered reads** — it mis-encodes Airtable formulas. For filtered reads use the curl templates below. Always use `python3 -c` for quick operations.

### Initialize
```python
import os
from pyairtable import Api

api = Api(os.environ['AIRTABLE_API_KEY'])
```

### List All Bases
```bash
python3 -c "
import os
from pyairtable import Api

api = Api(os.environ['AIRTABLE_API_KEY'])
for base in api.bases():
    print(f'{base.id}: {base.name}')
"
```

### Get Base Schema (Tables & Fields)
```bash
python3 -c "
import os
from pyairtable import Api

api = Api(os.environ['AIRTABLE_API_KEY'])
base = api.base(os.environ['BASE_ID'])
for table in base.tables():
    print(f'\n{table.name}:')
    for field in table.schema().fields:
        print(f'  - {field.name} ({field.type})')
"
```

### List Records
```bash
python3 -c "
import os
from pyairtable import Api

api = Api(os.environ['AIRTABLE_API_KEY'])
table = api.table(os.environ['BASE_ID'], 'TABLE_NAME')
for record in table.all():
    print(record['fields'])
"
```

### Filter Records
```bash
python3 -c "
import os
from pyairtable import Api
from pyairtable import formulas as F

api = Api(os.environ['AIRTABLE_API_KEY'])
table = api.table(os.environ['BASE_ID'], 'TABLE_NAME')

# Filter by field value
records = table.all(formula=F.match({'Status': 'Active'}))
for r in records:
    print(r['fields'])
"
```

### Search Records
```bash
python3 -c "
import os
from pyairtable import Api

api = Api(os.environ['AIRTABLE_API_KEY'])
table = api.table(os.environ['BASE_ID'], 'TABLE_NAME')

# Search with SEARCH formula
records = table.all(formula=\"SEARCH('SEARCH_TERM', {FieldName})\")
for r in records:
    print(r['fields'])
"
```

### Get Single Record
```bash
python3 -c "
import os
from pyairtable import Api

api = Api(os.environ['AIRTABLE_API_KEY'])
table = api.table(os.environ['BASE_ID'], 'TABLE_NAME')
record = table.get('RECORD_ID')
print(record['fields'])
"
```

## Write Operations (Require Explicit Permission)

### Create Record
```bash
python3 -c "
import os
from pyairtable import Api

api = Api(os.environ['AIRTABLE_API_KEY'])
table = api.table(os.environ['BASE_ID'], 'TABLE_NAME')
record = table.create({'Name': 'New Item', 'Status': 'Active'})
print(f\"Created: {record['id']}\")
"
```

### Update Record
```bash
python3 -c "
import os
from pyairtable import Api

api = Api(os.environ['AIRTABLE_API_KEY'])
table = api.table(os.environ['BASE_ID'], 'TABLE_NAME')
table.update('RECORD_ID', {'Status': 'Completed'})
print('Updated')
"
```

### Batch Create
```bash
python3 -c "
import os
from pyairtable import Api

api = Api(os.environ['AIRTABLE_API_KEY'])
table = api.table(os.environ['BASE_ID'], 'TABLE_NAME')
records = table.batch_create([
    {'Name': 'Item 1'},
    {'Name': 'Item 2'},
    {'Name': 'Item 3'}
])
print(f'Created {len(records)} records')
"
```

## curl is the ONLY recommended approach for read queries

**Use curl with `--data-urlencode` for every read (filterByFormula, fields, sort).** Do NOT use Python `urllib.parse.urlencode` for reads — it silently mis-encodes Airtable formula syntax (`AND(...)`, `SEARCH(...)`) and non-ASCII characters, producing 422s that are very hard to diagnose. Python (`requests` / `pyairtable`) is fine for **write** operations only — see the write section above.

Always start by sourcing your env + config: `source <your-project>/.env && source <path-to>/airtable/config.env`

### Canonical read template — filter + fields + sort

```bash
curl -s -G \
  "https://api.airtable.com/v0/$BASE_ID/$TABLE_ID" \
  -H "Authorization: Bearer $AIRTABLE_API_KEY" \
  --data-urlencode "filterByFormula=AND(SEARCH('term', {some_field}), {status}='pending')" \
  --data-urlencode "fields[]=name" \
  --data-urlencode "fields[]=status" \
  --data-urlencode "sort[0][field]=created_at" \
  --data-urlencode "sort[0][direction]=desc" \
  --data-urlencode "maxRecords=50" | python3 -m json.tool
```

Each parameter is its own `--data-urlencode` flag. `sort` is indexed: `sort[0][field]` + `sort[0][direction]` (asc|desc); for a secondary sort use `sort[1][...]`. `fields[]` repeats per field.

### Find Records (GET with filter, minimal)
```bash
curl -s -G \
  "https://api.airtable.com/v0/$BASE_ID/$TABLE_ID" \
  -H "Authorization: Bearer $AIRTABLE_API_KEY" \
  --data-urlencode "filterByFormula=FIND('search_term', {field_name})" \
  --data-urlencode "maxRecords=50" \
  --data-urlencode "fields[]=field1" \
  --data-urlencode "fields[]=field2"
```

## Common multi-step pattern: records linked to a parent (linked-field lookup)

A child table often has no direct foreign key — only a linked-record field pointing at the parent. Two-step:

```bash
# Step 1: get the parent record ID by some business key
PARENT_ID=$(curl -s -G "https://api.airtable.com/v0/$BASE_ID/$PARENT_TID" \
  -H "Authorization: Bearer $AIRTABLE_API_KEY" \
  --data-urlencode "filterByFormula=FIND('KEY-VALUE', ARRAYJOIN({parent_key}))" \
  --data-urlencode "fields[]=parent_key" \
  --data-urlencode "maxRecords=1" | python3 -c "import sys,json; print(json.load(sys.stdin)['records'][0]['id'])")

# Step 2: query children using ARRAYJOIN to flatten the linked array
curl -s -G "https://api.airtable.com/v0/$BASE_ID/$CHILD_TID" \
  -H "Authorization: Bearer $AIRTABLE_API_KEY" \
  --data-urlencode "filterByFormula=FIND('$PARENT_ID', ARRAYJOIN({parent}))" \
  --data-urlencode "fields[]=name" \
  --data-urlencode "fields[]=status"
```

The `FIND(parentId, ARRAYJOIN({parent}))` pattern is required because linked fields return arrays — bare `{parent}=...` will not match.

**Tip — prefer human-readable lookup fields when available.** If the child table has a sibling lookup field that flattens a useful key (e.g. a `parent_key_lookup` returning `['ORDER-123']`), search that instead of the raw record-ID linked field:

```bash
--data-urlencode "filterByFormula=SEARCH('ORDER-123', ARRAYJOIN({parent_key_lookup}))"
```

This is more readable, survives a record-ID copy/paste accident, and fails closed (no match) instead of silently matching the wrong record.

## If you get a 422

Stop. Do NOT retry the same query with tweaks. Run the recovery in order:

1. **Probe the table** — fetch 1 record with no filter:
   ```bash
   curl -s -G "https://api.airtable.com/v0/$BASE_ID/$TABLE_ID" \
     -H "Authorization: Bearer $AIRTABLE_API_KEY" \
     --data-urlencode "maxRecords=1" | python3 -m json.tool
   ```
   Confirm every field name in your formula and `fields[]` actually exists.
2. **Check formula operators** — formula/rollup/lookup fields cannot use `=`. Replace with `SEARCH('val', {field})` or `FIND('val', {field})`. Linked fields need `FIND(id, ARRAYJOIN({field}))`.
3. **Check the sort field** — `sort[0][field]` must be a real field name (and a sortable type). Computed/lookup timestamps often aren't sortable via `sort[0][field]`.
4. **Check encoding tool** — if you used Python `urllib`, switch to curl `--data-urlencode`.

### Delete Records (batches of 10)
```bash
curl -s -X DELETE \
  "https://api.airtable.com/v0/$BASE_ID/$TABLE_ID?records[]=recXXX&records[]=recYYY" \
  -H "Authorization: Bearer $AIRTABLE_API_KEY"
```

### Update Record (PATCH)
```bash
curl -s -X PATCH \
  "https://api.airtable.com/v0/$BASE_ID/$TABLE_ID/$RECORD_ID" \
  -H "Authorization: Bearer $AIRTABLE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"fields":{"field_name":"value"}}'
```

### Create Record with typecast (auto-create select options)
```bash
curl -s -X POST \
  "https://api.airtable.com/v0/$BASE_ID/$TABLE_ID" \
  -H "Authorization: Bearer $AIRTABLE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"records":[{"fields":{"field":"value"}}],"typecast":true}'
```

### Create Fields via Meta API
```bash
curl -s -X POST \
  "https://api.airtable.com/v0/meta/bases/$BASE_ID/tables/$TABLE_ID/fields" \
  -H "Authorization: Bearer $AIRTABLE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name":"field_name","type":"number","options":{"precision":0}}'
```

### Batch Delete in Python (for 10+ records)
```python
python3 << 'PYEOF'
import os, json, urllib.request, urllib.parse
pat = os.environ['AIRTABLE_API_KEY']
base_id, table_id = os.environ['BASE_ID'], os.environ['TABLE_ID']

# 1. Find records
formula = "FIND('term', {field})"
url = f'https://api.airtable.com/v0/{base_id}/{table_id}?filterByFormula={urllib.parse.quote(formula)}&maxRecords=100&fields[]=name'
req = urllib.request.Request(url, headers={'Authorization': f'Bearer {pat}'})
data = json.loads(urllib.request.urlopen(req).read())
ids = [r['id'] for r in data['records']]

# 2. Delete in batches of 10
for i in range(0, len(ids), 10):
    chunk = ids[i:i+10]
    params = '&'.join(f'records[]={id}' for id in chunk)
    req = urllib.request.Request(
        f'https://api.airtable.com/v0/{base_id}/{table_id}?{params}',
        headers={'Authorization': f'Bearer {pat}'}, method='DELETE')
    urllib.request.urlopen(req)
    print(f'Deleted {len(chunk)}')
PYEOF
```

## Gotchas
- **Never use Python urllib for Airtable formula queries** — use curl with `--data-urlencode`. Python urllib silently mis-encodes `AND(...)`, `SEARCH(...)`, and non-ASCII characters → 422.
- **Lookup/formula/rollup fields cannot use `=`** — wrap with `SEARCH('val', {field})` or `FIND('val', ARRAYJOIN({field}))`.
- **Linked record fields return arrays** — use `FIND(id, ARRAYJOIN({field}))` in formulas, or access `[0]` in code. Bare `{linked}=...` will not match.
- **Confirm the sort field name** against the schema probe before running — guessing a display label (e.g. `Created`) instead of the real field name is a common 422.
- **Env var name:** `AIRTABLE_API_KEY` (not `AIRTABLE_PAT`).
- **Single select fields:** Can't create new options via Meta API easily — use `typecast: true` on record create instead.
- **`fields[]` param:** Use `--data-urlencode "fields[]=name"` (not `fields=name`).
- **Delete max 10 per request** — batch larger deletes.
- **Table IDs live in `config.env`** — reference the `$<TABLE>_TID` vars, never raw `tbl…` literals.

## Privacy Rules (ALWAYS FOLLOW)

See [privacy.md](privacy.md) for complete rules. Key points:

1. **Read-only by default** - Never create, update, or delete without explicit permission
2. **Minimal data** - Only fetch what's needed
3. **No token display** - NEVER echo or display the API key
4. **Summarize, don't dump** - Format responses cleanly

## Common Operations

| User says... | Action |
|--------------|--------|
| "Show my bases" | List all bases |
| "What tables are in [base]?" | Get base schema |
| "Show records from [table]" | List records |
| "Find [value] in [table]" | Filter with formula |
| "Create a record in [table]" | Create (ask permission first) |
| "Update [record]" | Update (ask permission first) |

## Decision gates

- **Schema gate (before any filtered read):** confirm field names via your Quick Reference, your schema doc, or a no-filter probe. No guessing.
- **Write gate:** never `create`, `update`, `upsert`, or `delete` without explicit user permission for that operation.
- **422 gate:** on a 422, STOP and run the recovery sequence — do not retry the same query with tweaks.
- **Encoding gate:** filtered reads go through `curl --data-urlencode`. Python `urllib` for reads is forbidden (silent mis-encoding of `AND/SEARCH` and non-ASCII text).
- **Delete batch gate:** Airtable rejects >10 record IDs per DELETE — chunk into 10s.
- **Token-display gate:** never echo, log, or print `AIRTABLE_API_KEY`.

## Output format

Format as clean tables:

**Good:**
```
Records in Tasks:
┌──────────────────┬──────────┬────────────┐
│ Name             │ Status   │ Due Date   │
├──────────────────┼──────────┼────────────┤
│ Review proposal  │ Active   │ Jan 20     │
│ Send report      │ Done     │ Jan 18     │
└──────────────────┴──────────┴────────────┘
```

**Bad:**
```json
[{"id":"rec123","fields":{"Name":"Review proposal"...
```

## Reference

- [API Reference](api-reference.md) - All Python patterns
- [Privacy Rules](privacy.md) - Data handling guidelines

Sources: [pyAirtable Documentation](https://pyairtable.readthedocs.io/en/stable/), [GitHub](https://github.com/gtalarico/pyairtable)

## Evaluation checklist

After running an Airtable operation, confirm:

- Was the schema gate satisfied (Quick Reference / schema doc / no-filter probe) before any filtered read?
- Did filtered reads use `curl --data-urlencode` (not Python `urllib`)?
- Were formula/rollup/linked fields wrapped in `SEARCH` / `FIND` / `ARRAYJOIN` instead of bare `=`?
- Was a real, sortable field name used for sort?
- For writes/deletes: did the user explicitly approve the operation?
- Were deletes chunked into batches of ≤10 IDs?
- Was the API key kept out of all output (no echo, no logs, no error dumps)?
- Was the result rendered as a clean table/summary, not a raw JSON dump?

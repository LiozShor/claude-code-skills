# Query Patterns, Templates & Setup

Load when actually building requests: curl read templates, write/delete/Meta-API templates, multi-step linked-field patterns, the 422 recovery sequence, pyairtable patterns, and first-time environment setup.

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

> **Airtable is not configured yet. Let me help you set it up.**
>
> **Step 1: Get your Airtable Personal Access Token**
> 1. Go to https://airtable.com/create/tokens
> 2. Click **"Create new token"**
> 3. Name it "Claude Assistant"
> 4. Add scopes:
>    - `data.records:read` (to read records)
>    - `data.records:write` (optional - to create/update)
>    - `schema.bases:read` (to see base structure)
> 5. Add access to the bases you want
> 6. Click **"Create token"** and copy it (starts with `pat...`)
>
> **Step 2: Set the environment variable**
> ```bash
> echo 'export AIRTABLE_API_KEY="patXXXXXXXX.XXXXXXX"' >> ~/.zshrc
> source ~/.zshrc
> ```
>
> **Step 3: Restart Claude Code** and come back

Then STOP and wait for user to complete setup.

## Python Code Patterns (writes / schema introspection only — NOT for filtered reads)

Use these Python patterns for write operations and schema introspection. **Do not use Python `urllib` for filtered reads** — it mis-encodes Airtable formulas. For filtered reads use the curl templates above. Always use `python3 -c` for quick operations.

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
base = api.base('BASE_ID')
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
table = api.table('BASE_ID', 'TABLE_NAME')
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
table = api.table('BASE_ID', 'TABLE_NAME')

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
table = api.table('BASE_ID', 'TABLE_NAME')

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
table = api.table('BASE_ID', 'TABLE_NAME')
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
table = api.table('BASE_ID', 'TABLE_NAME')
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
table = api.table('BASE_ID', 'TABLE_NAME')
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
table = api.table('BASE_ID', 'TABLE_NAME')
records = table.batch_create([
    {'Name': 'Item 1'},
    {'Name': 'Item 2'},
    {'Name': 'Item 3'}
])
print(f'Created {len(records)} records')
"
```

## curl is the ONLY recommended approach for read queries

**Use curl with `--data-urlencode` for every read (filterByFormula, fields, sort).** Do NOT use Python `urllib.parse.urlencode` for reads — it silently mis-encodes Airtable formula syntax (`AND(...)`, `SEARCH(...)`) and Hebrew characters, producing 422s that are very hard to diagnose. Python (`requests` / `pyairtable`) is fine for **write** operations only — see the write section below.

Always start with: `source <project-root>/.env && source ~/.claude/skills/airtable/config.env`

### Canonical read template — filter + fields + sort

```bash
curl -s -G \
  "https://api.airtable.com/v0/$BASE_ID/$TABLE_ID" \
  -H "Authorization: Bearer $AIRTABLE_API_KEY" \
  --data-urlencode "filterByFormula=AND(SEARCH('210', {client_id}), {review_status}='pending')" \
  --data-urlencode "fields[]=classification_key" \
  --data-urlencode "fields[]=attachment_name" \
  --data-urlencode "fields[]=review_status" \
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

## Common multi-step patterns

### Documents-for-a-client (linked-field lookup)
`documents` has no direct `client_id` — only a `report` linked field. Two-step:

```bash
# Step 1: get the report record ID for the client + year
REPORT_ID=$(curl -s -G "https://api.airtable.com/v0/$BASE_ID/$REPORTS_TID" \
  -H "Authorization: Bearer $AIRTABLE_API_KEY" \
  --data-urlencode "filterByFormula=AND(FIND('CPA-210', ARRAYJOIN({client_id})), {year}=2025)" \
  --data-urlencode "fields[]=report_uid" \
  --data-urlencode "maxRecords=1" | python3 -c "import sys,json; print(json.load(sys.stdin)['records'][0]['id'])")

# Step 2: query documents using ARRAYJOIN to flatten the linked array
curl -s -G "https://api.airtable.com/v0/$BASE_ID/$DOCUMENTS_TID" \
  -H "Authorization: Bearer $AIRTABLE_API_KEY" \
  --data-urlencode "filterByFormula=FIND('$REPORT_ID', ARRAYJOIN({report}))" \
  --data-urlencode "fields[]=document_uid" \
  --data-urlencode "fields[]=type" \
  --data-urlencode "fields[]=status"
```

The `FIND(reportId, ARRAYJOIN({report}))` pattern is required because linked fields return arrays — bare `{report}=...` will not match.

**Tip — prefer human-readable lookup fields when available.** If the table has a sibling lookup field that flattens a useful key (e.g. documents has `report_key_lookup` returning `['CPA-210_2025_annual_report']`), search that instead of the raw record-ID linked field. Example for "all docs of report CPA-210 2025":

```bash
--data-urlencode "filterByFormula=SEARCH('CPA-210_2025_annual_report', ARRAYJOIN({report_key_lookup}))"
```

This is more readable, survives a record-ID copy/paste casing accident, and fails closed (no match) instead of silently matching the wrong record. Real run 2026-05-02: `FIND('rec8jOE…', ARRAYJOIN({report}))` returned 0 unexpectedly; switching to `SEARCH(...{report_key_lookup})` returned the correct 15 records on the first try.

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
3. **Check the sort field** — `sort[0][field]` must be a real field name. In this base it is `created_at`, not `Created`.
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
source .env && python3 << 'PYEOF'
import os, json, urllib.request
pat = os.environ['AIRTABLE_API_KEY']
base_id, table_id = 'appXXX', 'tblXXX'

# 1. Find records
formula = "FIND('term', {field})"
url = f'https://api.airtable.com/v0/{base_id}/{table_id}?filterByFormula={urllib.request.quote(formula)}&maxRecords=100&fields[]=type'
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


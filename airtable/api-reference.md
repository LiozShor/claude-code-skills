# Airtable API Reference - Python (pyairtable)

Clean Python patterns using the pyairtable library. No raw curl needed.

## Setup

```bash
pip3 install pyairtable
```

## Initialization

```python
import os
from pyairtable import Api

api = Api(os.environ['AIRTABLE_API_KEY'])
```

---

## Bases

### List All Bases
```python
for base in api.bases():
    print(f'{base.id}: {base.name}')
```

### Get Specific Base
```python
base = api.base('appXXXXXXXXXXXXXX')
```

### Get Base Schema (All Tables & Fields)
```python
base = api.base('appXXXXXXXXXXXXXX')
for table in base.tables():
    print(f'\nTable: {table.name}')
    schema = table.schema()
    for field in schema.fields:
        print(f'  {field.name} ({field.type})')
```

---

## Tables

### Get Table Reference
```python
table = api.table('appXXXXXXXXXXXXXX', 'Table Name')
# or
table = base.table('Table Name')
```

---

## Records - Reading

### List All Records
```python
records = table.all()
for record in records:
    print(record['id'], record['fields'])
```

### With Pagination Control
```python
# Iterate in batches
for page in table.iterate(page_size=100):
    for record in page:
        print(record['fields'])
```

### Limit Results
```python
records = table.all(max_records=10)
```

### Select Specific Fields
```python
records = table.all(fields=['Name', 'Status', 'Email'])
```

### Sort Results
```python
# Ascending
records = table.all(sort=['Name'])

# Descending (prefix with -)
records = table.all(sort=['-Created'])

# Multiple fields
records = table.all(sort=['Status', '-Name'])
```

### Use a View
```python
records = table.all(view='Active Items')
```

### Get First Match
```python
record = table.first(formula="{Status}='Active'")
```

### Get by Record ID
```python
record = table.get('recXXXXXXXXXXXXXX')
```

---

## Records - Filtering

### Simple Match
```python
from pyairtable.formulas import match

records = table.all(formula=match({'Status': 'Active'}))
```

### Multiple Conditions
```python
from pyairtable.formulas import match

records = table.all(formula=match({
    'Status': 'Active',
    'Priority': 'High'
}))
```

### Using Formula Builders
```python
from pyairtable import formulas as F

# Equals
formula = F.EQ(F.Field('Status'), 'Active')

# Greater than
formula = F.GT(F.Field('Amount'), 100)

# Contains text
formula = F.FIND('search term', F.Field('Name'))

# Combine with AND/OR
formula = F.AND(
    F.EQ(F.Field('Status'), 'Active'),
    F.GT(F.Field('Amount'), 100)
)

records = table.all(formula=formula)
```

### Raw Formula String
```python
records = table.all(formula="{Status}='Active' AND {Amount}>100")
```

---

## Records - Writing (Require Permission)

### Create Single Record
```python
record = table.create({
    'Name': 'New Item',
    'Status': 'Active',
    'Email': 'user@example.com'
})
print(f"Created: {record['id']}")
```

### Create Multiple Records (Batch)
```python
records = table.batch_create([
    {'Name': 'Item 1', 'Status': 'Active'},
    {'Name': 'Item 2', 'Status': 'Pending'},
    {'Name': 'Item 3', 'Status': 'Active'}
])
print(f"Created {len(records)} records")
```

### Update Single Record
```python
table.update('recXXXXXXXXXXXXXX', {
    'Status': 'Completed'
})
```

### Update Multiple Records (Batch)
```python
table.batch_update([
    {'id': 'rec111', 'fields': {'Status': 'Done'}},
    {'id': 'rec222', 'fields': {'Status': 'Done'}},
])
```

### Upsert (Create or Update)
```python
# Creates if not exists, updates if exists
# key_fields determines matching
table.batch_upsert(
    [{'Name': 'Item 1', 'Status': 'Active'}],
    key_fields=['Name']
)
```

### Delete Single Record
```python
table.delete('recXXXXXXXXXXXXXX')
```

### Delete Multiple Records (Batch)
```python
table.batch_delete(['rec111', 'rec222', 'rec333'])
```

---

## Comments

### List Comments on Record
```python
comments = table.comments('recXXXXXXXXXXXXXX')
for c in comments:
    print(f"{c.author.name}: {c.text}")
```

### Add Comment
```python
comment = table.add_comment('recXXXXXXXXXXXXXX', 'This looks good!')
```

---

## Error Handling

```python
from pyairtable.api.types import AirtableError

try:
    record = table.get('invalid_id')
except AirtableError as e:
    print(f"Error: {e}")
```

---

## Rate Limits

- Airtable: 5 requests/second per base
- pyairtable automatically retries on 429 errors (up to 5 times)
- No manual handling needed

---

## Full Example

```python
import os
from pyairtable import Api
from pyairtable.formulas import match

# Initialize
api = Api(os.environ['AIRTABLE_API_KEY'])

# Get table
table = api.table('appXXXXXXXX', 'Tasks')

# List active tasks, sorted by due date
tasks = table.all(
    formula=match({'Status': 'Active'}),
    sort=['Due Date'],
    fields=['Name', 'Status', 'Due Date', 'Assignee']
)

# Display nicely
print("Active Tasks:")
print("-" * 50)
for task in tasks:
    fields = task['fields']
    print(f"• {fields.get('Name', 'Untitled')}")
    print(f"  Due: {fields.get('Due Date', 'No date')}")
    print(f"  Assignee: {fields.get('Assignee', 'Unassigned')}")
    print()
```

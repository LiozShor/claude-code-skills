# Privacy Guidelines

## Core Principles

### 1. Read-Only by Default
- NEVER use create, update, or delete operations without explicit user permission
- If user asks to modify something, confirm first: "This will change [X]. Should I proceed?"
- Write operations (POST, PATCH, DELETE) require explicit consent

### 2. Minimal Data Fetching
- Only request fields needed for the current task
- Use `fields[]` parameter to limit returned data
- Don't fetch "everything just in case"

### 3. No Credential Exposure
- NEVER display or echo `AIRTABLE_API_KEY`
- NEVER include tokens in output or logs
- If a command fails, don't show the full curl command with token

### 4. Sensitive Data Protection
When displaying records:
- Be aware that Airtable may contain PII (emails, phone numbers, addresses)
- Ask before displaying potentially sensitive fields
- Summarize large datasets rather than dumping all records

### 5. Response Formatting
- Summarize large responses (don't dump raw JSON)
- Format as clean tables when showing records
- Truncate long content with "[...more]" indicator
- Offer to show details rather than overwhelming with data

## What NOT To Do

| Don't | Instead |
|-------|---------|
| Show raw API responses | Format as clean tables/lists |
| Display the API key | Say "using configured credentials" |
| Fetch all records without asking | Ask how many/which records needed |
| Modify without confirmation | Always confirm writes |
| Show full record dump | Summarize key fields |

## Handling Errors

When API calls fail:
- Don't show full error with token/URL
- Summarize: "Couldn't access [resource]. Check permissions."
- Suggest: "Make sure your token has access to this base."

## Data Retention

- Don't store Airtable data between sessions
- Don't cache record information
- Each request should be fresh from the API

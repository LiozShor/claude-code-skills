# Project Quick Reference — CRM schema (example)

Reading this file in the current conversation satisfies option 1 of the HARD GATE in SKILL.md, for the fields listed here. Field lists and enum values were verified against the live base via the Meta API (2026-06); re-verify with a probe if something looks off.

## Project Quick Reference (base `$BASE_ID`)

Use these field names verbatim. If you need a field NOT listed here, satisfy the schema gate first. Table IDs resolve from `config.env` (see Project Context) — the `$*_TID` vars below.

> Table names below are the **real** base names (lowercase; the templates table is `documents_templates`). Field lists and enum values are verified against the live base via the Meta API.

**clients** — `$CLIENTS_TID`
- `client_id` (formula, e.g. `"CPA-210"` — string, NOT bare number), `client_counter` (210 as int), `name`, `email`, `phone`, `VAT`, `is_active`, `annual_reports` (linked → reports), `created_at`, `updated_at`
- ⚠ `spouse_name` is NOT on clients — lives on reports.

**reports** — `$REPORTS_TID`
- `report_uid`, `report_key`, `client_id` (**lookup array**, e.g. `["CPA-210"]` — match with `FIND('CPA-210', ARRAYJOIN({client_id}))`, NOT `=`), `client_name` (lookup, array), `year` (int, NOT `filing_year`), `stage`, `filing_type`, `client_is_active` (lookup, array), `spouse_name`, `record_id`, `questionnaire_token`, `documents` / `email_events` / `pending_classifications` (linked), reminder fields
- `stage` ∈ `Send_Questionnaire`, `Waiting_For_Answers`, `Pending_Approval`, `Collecting_Docs`, `Review`, `Moshe_Review`, `Before_Signing`, `Completed`, `Partner_Review` · `filing_type` ∈ `annual_report`, `capital_statement`
- ⚠ No `created_at` field — use Airtable's implicit `createdTime` (cannot sort by it via `sort[0][field]`).

**documents** — `$DOCUMENTS_TID`
- `document_uid`, `document_key`, `type`, `issuer_name`, `issuer_name_en`, `category`, `status`, `is_received`, `is_missing`, `is_required`, `person`, `report` (linked → reports), `report_key_lookup` (lookup, prefer for filters), `report_record_id`, `internal_pdf_note`, `created_at`, `updated_at`
- `status` ∈ `Required_Missing`, `Received`, `Requires_Fix`, `Waived`, `Not Required` · `person` ∈ `client`, `spouse`
- ⚠ No direct `client_id` — see "Documents-for-a-client" pattern below.

**pending_classifications** — `$PENDING_TID`
- `classification_key`, `attachment_name`, `attachment_content_type`, `attachment_size`, `review_status`, `ai_reason`, `ai_confidence`, `onedrive_item_id`, `file_url`, `file_hash`, `client_id` (plain text, e.g. `CPA-210` — `=` works), `client_name`, `sender_email`, `sender_name`, `received_at` (sort field), `report` (linked), `document` (linked), `email_event` (linked), `matched_template_id`, `matched_doc_name`, `issuer_match_quality`, `contract_period`, `expected_filename`, `year`, `email_body_text`, `page_count`
- `review_status` ∈ `pending`, `approved`, `rejected`, `reassigned`, `splitting`, `on_hold` · `issuer_match_quality` ∈ `exact`, `fuzzy`, `mismatch`, `single`

**email_events** — `$EMAIL_EVENTS_TID`
- `event_key`, `source_message_id`, `source_internet_message_id`, `received_at` (sort field), `sender_email`, `subject`, `attachment_name`, `processing_status`, `error_message`, `workflow_run_id`, `retry_count`, `next_retry_at`, `last_error_step`, `match_method`, `report` / `document` / `pending_classifications` (linked), `created_at`

**documents_templates** — `$TEMPLATES_TID`
- `template_id`, `name_he`, `name_en`, `short_name_he`, `category`, `scope` (`CLIENT` / `SPOUSE` / `PERSON` / `GLOBAL_SINGLE`, or blank), `filing_type`, `variables`, `needs_issuer_suggestion`, `help_he`, `help_en`, `emoji`
- No `created_at` — Airtable implicit `createdTime` only.

**Other tables** (IDs in `config.env`; confirm fields via the schema gate before querying): `question_mappings` (`$QUESTION_MAPPINGS_TID`), `categories` (`$CATEGORIES_TID`), `system_config` (`$SYSTEM_CONFIG_TID`), `company_links` (`$COMPANY_LINKS_TID`), `system_logs` (`$SYSTEM_LOGS_TID`), `security_logs` (`$SECURITY_LOGS_TID`), questionnaire answers «תשובות שאלון שנתי» (`$QUESTIONNAIRE_TID`).

**Sort fields by table:** documents → `created_at`/`updated_at`; pending_classifications & email_events → `received_at` (or `created_at`); clients → `created_at`/`updated_at`; reports & documents_templates → no sortable timestamp field (omit `sort[]`, or sort by `year`/`stage`).


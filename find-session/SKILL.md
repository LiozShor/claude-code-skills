---
name: find-session
description: 'Find a past Claude Code session to resume — I closed my session, find the session where we…, which session discussed X.'
---

# Find Session

Search Claude Code's local session logs (`~/.claude/projects/**/*.jsonl`) for a past conversation matching the user's description, and return resume instructions.

## Inputs

Ask the user for a search hint if not provided: a distinctive phrase, error message, feature name, file path, or topic discussed. Shorter and more distinctive is better ("preview load failed", "auth token refresh bug", "csv parser crash") than vague ("that bug we fixed").

## Where sessions live

Claude Code stores one project dir per working directory under `~/.claude/projects/`. The dir name is
the absolute `cwd` with `/` (and other separators) replaced by `-` — e.g. cwd `/Users/alex/code/api`
becomes `~/.claude/projects/-Users-alex-code-api/`. Inside each is one `.jsonl` file per session.

- **Search across ALL project dirs**, not just the one matching the current `cwd`.
- **Git worktrees get their own project dir** (the worktree path encodes to its own dashed name) —
  a freshly-closed session is often inside a worktree's project dir, not the main repo's. Always
  include them.

Each `.jsonl` file is one session. Filename (minus extension) is the session ID. File mtime ≈ last active time.

## Search procedure

### 1. Narrow to recent sessions first
If the user says "just now" / "accidentally closed" / "today", start with the 10 most recently modified `.jsonl` files across **all** project dirs — not just the main one. The active session's own file is usually the freshest — skip it.

```bash
ls -lt ~/.claude/projects/*/*.jsonl | head -20
```

### 2. Match on the user's hint
Use Python over the jsonl (faster than grep for structured match). For each file, read lines as JSON, check `type == "user"` content for the hint. Literal error text (`"Preview load failed"`) almost always appears verbatim — try exact substring first, then loosen.

Helpful match heuristics:
- **Verbatim error strings** pasted from browser console are gold — they appear in user messages (not just code), and are highly distinctive.
- **Unique IDs / ticket numbers** (e.g. `PROJ-1234`, an issue number) match uniquely.
- **Non-Latin-script terms** (Hebrew, accented text, etc.) match exactly — don't transliterate.
- If a file has many matches (≥3), that's a stronger signal than a single grep hit.

### 3. Rank candidates
Sort by mtime descending. For the top 3–5, extract:
- First substantive user message (skip `<command-message>`, `<bash-stdout>`, `<persisted-output>`, `<task-notification>` wrappers — those aren't real user input).
- A snippet of the matching content with ±200 chars of context.
- Mtime as "last active" time.

### 4. Disambiguate
If multiple candidates look plausible, show the top 2–3 with their first-user-message and match context, and ask the user which one. Don't guess silently.

### 5. Return resume instructions
For the confirmed match, print:

```
Session: <uuid>
Project dir: <dirname under ~/.claude/projects/>
Last active: <mtime>
Topic: <one-line summary from first user message or match context>

To resume:
  cd <actual-worktree-or-repo-path>
  claude --resume <uuid>
```

**Critical:** if the session is in a worktree (or any non-main) project dir, translate the dashed dir
name back to the real filesystem path (reverse the `/`→`-` encoding) and tell the user to `cd` there
first — `claude --resume` won't find the session if run from the wrong project directory.

## Pitfalls

- **Don't match on tool-call content alone.** A file containing "preview load failed" in an assistant's Grep output is a false positive — the user may never have discussed it. Require a hit in a `type: "user"` message OR count many hits across the file.
- **Skip the current session.** It will always match any phrase the user just typed. Identify it by checking which project dir matches `cwd` in the current conversation, and its file will be the freshest.
- **Don't read whole files into memory for huge sessions (>5MB).** Stream line-by-line.
- **File mtime can lag** a few seconds behind the actual last message — don't rely on it for exact ordering within a 1-min window; use the last message's `timestamp` field instead.
- **"Resume cancelled" marker.** If the last entry is `<local-command-stdout>Resume cancelled</local-command-stdout>`, that session is a stub — the real session is its parent. Check the user message that said `resume` and find the session they tried to resume.

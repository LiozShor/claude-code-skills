---
name: git-ship
description: 'Commit and optionally push. MANDATORY before any git write — commit, push, merge, rebase, reset, branch -d. Triggers: ship it, commit, push.'
---
# Git Ship

A single, safe entry point for git **write** operations: commit, push, and merge-to-main, with
multi-tab/worktree safety baked in. Read-only commands (`status`, `diff`, `log`, `show`,
`branch --show-current`) never need this skill.

## Mandatory Invocation
Treat this skill as the ONLY entry point for git write operations. Before running `git commit`,
`git push`, `git merge`, `git rebase`, `git reset`, `git branch -d`, or `git checkout main` — you MUST
be inside this skill.

## Pre-Ship Validation (Multi-Tab Safety)
1. **Branch guard:** Run `git branch --show-current`. If on `main`/`master`, **REFUSE** and error:
   "You're on main. A feature branch should have been created at session start." Do NOT commit.
   (Skip this guard only if the project deliberately commits to a trunk — then say so explicitly.)
2. Run `git diff` and review ALL hunks. Check whether any changes don't belong to the current
   task/ticket (e.g. changes left by another parallel Claude Code tab/session).
3. If suspicious mixed changes are detected: **warn the user**, list the foreign hunks, and suggest
   `git add -p` to selectively stage only the relevant changes.
4. Verify the commit will only include files relevant to the current task.

## Ship
1. Run `git status` to see all changes.
2. Run `git diff --staged` (if nothing staged, run `git add -A` first — but only after pre-ship validation passes).
3. Generate a conventional commit message: `type(scope): description`.
4. Commit with the generated message.
5. Ask the user: "Push to remote?" — only push if they confirm.

## Post-Push Housekeeping (Before Merge)
After a successful push, if there are pending status/index files to update (e.g. a project status file
or a design-log index), do them NOW — while still on the feature branch — then commit and push again.
This avoids editing them on `main` later.

## Merge to Main
Only after ALL file edits are committed and pushed, ask: "Merge to main and delete branch?"

### Default (single-checkout repos)
```bash
git checkout main && git merge <branch> && git branch -d <branch> && git push
```

### Worktree-safe merge (when the repo uses git worktrees)
If `main` is checked out in another worktree, `git checkout main` fails with
`fatal: 'main' is already used by worktree at '...'`. Two safe options:

Fast-forward-only push — no checkout, leaves every worktree untouched:
```bash
git push origin <branch>:main
```

Or merge from the canonical (main) clone, never from a session worktree:
```bash
cd <your-canonical-clone>
git fetch origin main
git checkout main && git pull --ff-only origin main
git merge --no-ff <branch> -m "Merge <branch>: ..."
git push origin main
```

**Tip:** if your project wraps this sequence in a script (e.g. a `merge-and-push.sh` under
`.claude/workflows/`), prefer it — it encodes the worktree-safe order so you don't hand-roll it.

**Do NOT edit any files after merging to main** if a branch-guard hook is active — it will block the edit.

## Conflict-prone append-only files
Files that every parallel session appends to (a shared status file, a design-log `INDEX.md`, a
changelog) conflict on nearly every merge. Resolve by keeping ALL entries from both sides (order by
whatever key the file uses — e.g. highest number on top). Declaring `merge=union` for these paths in
`.gitattributes` makes such conflicts auto-resolve.

## Project-specific hooks (optional)
Real projects often bolt extra steps onto ship/merge — a post-merge deploy (Workers/Pages, a server
restart), a "close the design log" script, a CI trigger. Keep those in project scripts (e.g. under
`.claude/workflows/`) and invoke them here after the merge, rather than hardcoding deploy commands into
this skill. That keeps `git-ship` portable across projects.

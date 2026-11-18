---
name: wrap
description: End-of-session wrap-up. Updates the project's existing docs to match this session's work, then proposes improvements to skills, agents and CLAUDE.md. Run manually with /wrap.
disable-model-invocation: true
allowed-tools: Bash(git status *) Bash(git diff *) Bash(git ls-files *) Bash(head *)
---

## Session state
- Changed files: !`git status --short 2>/dev/null || true`
- Diff summary: !`git diff --stat HEAD 2>/dev/null || true`
- Docs in repo: !`git ls-files -- '*.md' '*.mdx' '*.rst' 2>/dev/null | head -100 || true`

## Step 1: Update existing docs
1. From this conversation and the diff, list what this session changed or established: behavior, commands, setup steps, architecture, decisions, gotchas.
2. From the doc list above (plus CLAUDE.md and AGENTS.md at any level), pick only the docs that are now stale or missing one of those facts. Read them.
3. For each affected doc, draft the smallest edit that brings it up to date, in that doc's existing style and structure.
4. Never create new doc files. Never restructure a doc. Leave unaffected docs alone.
5. Show all proposed edits as diffs grouped by file, and apply them only after I approve. If no doc needs a change, say so in one line.

## Step 2: Reflect
1. List what went wrong or took too long this session: failed checks, worker retries, wrong assumptions, my corrections, wasted exploration.
2. For each item with a clear fix, propose the smallest edit to a skill, an agent file, the Omega orchestrator prompt, or CLAUDE.md that would have prevented it, with one line of evidence from this session. Keep CLAUDE.md under 200 lines: prefer tightening a line over adding one.
3. Apply edits only after I approve. If nothing is worth changing, say so in one line.

Keep the whole wrap-up concise.

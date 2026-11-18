# Omega setup

Instructions for an AI coding agent installing Omega for its user. The user's prompt points you here from a clone of https://github.com/bakirgdev/omega. In this file, `<clone>` is that clone's root and "I" is the user. Follow the steps in order.

## Rules
- Write only the files listed in step 3 and, if I confirm in step 4, one line in my shell rc file. Do not edit any `settings.json` and do not commit anything.
- Before overwriting a file (the rc file included), compare it with the new content. If it differs, copy it to `<file>.bak` first, or to `<file>.bak.<YYYYmmddHHMMSS>` if a `.bak` already exists, so no backup is ever overwritten. If it is identical, leave it.
- Copy files byte for byte, changing only what my answers in step 2 change. Do not add agents, skills, hooks or docs.
- If a step fails, stop and tell me what failed; do not work around it.

## 1. Preflight (read-only)
1. Run `claude --version` and compare the version number numerically. Omega needs Claude Code 2.1.271 or later (for the `omitClaudeMd` agent field). If it is older, stop and tell me to update.
2. Take the directory this session started in, before you cloned or changed directory, and note whether it is inside a git repository (`git -C <that directory> rev-parse --show-toplevel`). That path is the project root for a project install. Never treat the clone as the project.
3. Detect my shell from `$SHELL`. zsh uses `${ZDOTDIR:-$HOME}/.zshrc`. bash uses `~/.bashrc`; on macOS, use `~/.bash_profile` instead unless `grep -q bashrc ~/.bash_profile` succeeds. Other shells are not supported by the launchers; note it.
4. Look for settings that silently override Omega, in `~/.claude/settings.json` and `~/.claude/settings.local.json` (under `env`), `.claude/settings*.json` under the project root, my rc file, and the current environment (`env | grep CLAUDE_CODE_`):
   - `CLAUDE_CODE_SUBAGENT_MODEL_FORCE`: every subagent ignores its own `model` field.
   - `CLAUDE_CODE_EFFORT_LEVEL`: overrides the launchers' `--effort` flag.
   - `CLAUDE_CODE_DISABLE_EXPLORE_PLAN_AGENTS`: removes Explore.
   Do not change them. Mention any you find in step 2 and in the final report.
5. Note which step 3 target files already exist, and whether the rc file already defines `claude-omega` or `claude-omega-dsp` or sources `omega.sh`.

## 2. Ask me
Ask these four in one round with your question tool (`AskUserQuestion` in Claude Code; otherwise one plain message), recommended option first. Mention anything preflight found that affects an answer.

1. **Scope:** where should the agents and the `/wrap` skill go?
   - User level, `~/.claude/` (recommended): available in every project.
   - Project level, `<project root>/.claude/`: only this repo, and teammates get them when it is committed. Offer this only if preflight found a git repository.
   Either way, the orchestrator rules and launchers go to `~/.claude/omega/`, because the launchers only read the user-level rules: a repo's own copy would reach the system prompt before Claude Code's workspace trust check.
2. **Orchestrator:** which model and effort should the launchers start?
   - Opus, xhigh (recommended): strongest planning and verification.
   - Opus, high: cheaper and faster.
   - Sonnet, high: cheapest, for lighter work.
3. **Workers:** which models should `builder` and `reviewer` use?
   - Sonnet for both (recommended): Anthropic recommends Sonnet or Opus over Haiku for complex agentic coding.
   - Haiku builder, Sonnet reviewer: cheapest; Haiku suits only narrow, mechanical edits where the brief spells out the change.
   - Opus for both: highest quality and cost.
4. **Optional parts** (multi-select, both recommended):
   - Explore on Haiku: replaces the built-in Explore agent, which otherwise runs on the session's model. At user scope this applies to every Claude Code session.
   - `/wrap`: a manual end-of-session skill that updates stale docs and proposes fixes to the agents and CLAUDE.md.

## 3. Copy the files
`<target>` is `~/.claude` for user scope, or `<project root>/.claude` for project scope. Create directories as needed.

| Source in `<clone>` | Destination | When |
|---|---|---|
| `.claude/omega/orchestrator.md` | `~/.claude/omega/orchestrator.md` | always |
| `.claude/omega/omega.sh` | `~/.claude/omega/omega.sh` | always |
| `.claude/agents/builder.md` | `<target>/agents/builder.md` | always |
| `.claude/agents/reviewer.md` | `<target>/agents/reviewer.md` | always |
| `.claude/agents/Explore.md` | `<target>/agents/Explore.md` | if selected |
| `.claude/skills/wrap/SKILL.md` | `<target>/skills/wrap/SKILL.md` | if selected |

Then apply my answers to the copies:
- Orchestrator: set `--model` and `--effort` in `~/.claude/omega/omega.sh`.
- Workers: set the `model:` line in `builder.md` and `reviewer.md`.

## 4. Launchers
`~/.claude/omega/omega.sh` defines two shell functions:
- `claude-omega`: starts the orchestrator in auto mode, where a classifier reviews each action instead of prompting. Claude Code falls back to Manual mode when auto mode is unavailable.
- `claude-omega-dsp`: the same, with `--dangerously-skip-permissions`. Nothing reviews any action. Claude Code's docs recommend this only in sandboxes without internet access.

If my shell is zsh or bash, show me this exact line and the rc file it goes into, and ask whether to add it:

```sh
source "$HOME/.claude/omega/omega.sh"
```

Add it only if I say yes, and only if the rc file doesn't already source `omega.sh`; make sure the file ends with a newline first. If the rc file already defines a function or alias with either name, show it and ask before adding. If I say no, or my shell isn't zsh or bash, tell me how to start Omega by hand: `claude --model <model> --effort <effort> --append-system-prompt-file ~/.claude/omega/orchestrator.md`.

## 5. Verify
1. Each agent and skill file you wrote starts with `---` on line 1, has a closing `---`, and has `name` and `description` in its frontmatter.
2. From the project root (project scope) or my home directory (user scope), run in my shell: `source ~/.claude/omega/omega.sh && claude-omega -p "Reply OK" --output-format stream-json --verbose --debug-file "$(mktemp)" < /dev/null`. It must print a reply. In the JSON line with `"subtype":"init"`, confirm `model` matches my orchestrator answer, `agents` contains `builder` and `reviewer` (and `Explore` if installed), and `slash_commands` contains `wrap` if installed.
3. Search that debug file for `does not recognize or apply`. A match means a frontmatter field was ignored; report it.
4. If you added the rc line, confirm it appears exactly once.

## 6. Report and clean up
Delete the temporary directory you cloned into, by its exact path, and only if it is neither the project root, nor inside it, nor inside `~/.claude`. Then tell me:
- The files you created or changed, and every backup you made.
- Any override variable from preflight and what it does to Omega.
- For project scope: that the new `.claude/` files are uncommitted, and that committing them shares the agents with my team (each teammate still runs this setup once for the launchers).
- How to use it: open a new terminal and run `claude-omega` (or the manual command). Use plain `claude` for quick tasks; Omega pays off on multi-part work. Run `/wrap` at the end of a session if installed.
- How to update or undo: run the setup prompt again to update; to undo, delete the files you wrote, restore any backups, and remove the rc line.

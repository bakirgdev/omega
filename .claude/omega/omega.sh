# shellcheck shell=bash
# Omega launchers for zsh and bash. Source this file from your shell rc.

# Reads only the user-level rules: a repo's own copy would reach the system
# prompt before Claude Code's workspace trust check.
_claude_omega() {
	claude --model opus --effort xhigh \
		--append-system-prompt-file "$HOME/.claude/omega/orchestrator.md" "$@"
}

claude-omega() { _claude_omega --permission-mode auto "$@"; }

claude-omega-dsp() { _claude_omega --dangerously-skip-permissions "$@"; }

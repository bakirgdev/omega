#!/usr/bin/env bash
# Sources omega.sh in zsh and bash with a stub `claude` and checks the exact
# arguments each launcher passes. Usage: tests/launchers.test.sh
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
launchers="$root/.claude/omega/omega.sh"
fail=0

check() {
	local shell=$1 cmd=$2 want=$3 got
	# shellcheck disable=SC2016 # $* and $1 must expand inside the child shell.
	got="$(HOME=/home/test "$shell" -c 'claude() { printf "%s|" "$@"; }; . "$1"; '"$cmd" _ "$launchers")"
	if [[ "$got" == "$want" ]]; then
		echo "ok   $shell: $cmd"
	else
		echo "FAIL $shell: $cmd"
		echo "     want: $want"
		echo "     got:  $got"
		fail=1
	fi
}

base='--model|opus|--effort|xhigh|--append-system-prompt-file|/home/test/.claude/omega/orchestrator.md|'

for shell in zsh bash; do
	if ! command -v "$shell" >/dev/null; then
		echo "FAIL $shell: not installed"
		fail=1
		continue
	fi
	check "$shell" 'claude-omega' "${base}--permission-mode|auto|"
	check "$shell" 'claude-omega-dsp' "${base}--dangerously-skip-permissions|"
	check "$shell" 'claude-omega -c "fix the bug"' "${base}--permission-mode|auto|-c|fix the bug|"
done

exit "$fail"

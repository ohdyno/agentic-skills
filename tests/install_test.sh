#!/bin/sh

set -eu

REPO_ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
INSTALLER="$REPO_ROOT/install.sh"
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/agentic-skills-install-test.XXXXXX")
CODEX_HOME="$TMP_DIR/codex-home"
CLAUDE_HOME="$TMP_DIR/claude-home"

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT INT TERM

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_file_exists() {
  [ -f "$1" ] || fail "expected file to exist: $1"
}

assert_not_exists() {
  [ ! -e "$1" ] || fail "expected path not to exist: $1"
}

assert_contains() {
  haystack=$1
  needle=$2
  printf '%s' "$haystack" | grep -F "$needle" >/dev/null || fail "expected output to contain: $needle"
}

assert_files_equal() {
  cmp -s "$1" "$2" || fail "expected files to match: $1 $2"
}

run_installer() {
  "$INSTALLER" "$@"
}

list_output=$(run_installer list --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME")
assert_contains "$list_output" "git-commit"
assert_contains "$list_output" "socratic-tutor"
assert_contains "$list_output" "tighten-skill"
assert_contains "$list_output" "$CODEX_HOME/skills/git-commit"
assert_contains "$list_output" "$CLAUDE_HOME/skills/git-commit"

run_installer install git-commit --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" >/dev/null
assert_file_exists "$CODEX_HOME/skills/git-commit/SKILL.md"
assert_file_exists "$CODEX_HOME/skills/git-commit/agents/openai.yaml"
assert_file_exists "$CLAUDE_HOME/skills/git-commit/SKILL.md"
assert_file_exists "$CLAUDE_HOME/skills/git-commit/agents/openai.yaml"
assert_files_equal "$REPO_ROOT/git-commit/SKILL.md" "$CODEX_HOME/skills/git-commit/SKILL.md"
assert_files_equal "$REPO_ROOT/git-commit/SKILL.md" "$CLAUDE_HOME/skills/git-commit/SKILL.md"
assert_files_equal "$REPO_ROOT/git-commit/agents/openai.yaml" "$CODEX_HOME/skills/git-commit/agents/openai.yaml"
assert_files_equal "$REPO_ROOT/git-commit/agents/openai.yaml" "$CLAUDE_HOME/skills/git-commit/agents/openai.yaml"

if run_installer install git-commit --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" >/dev/null 2>"$TMP_DIR/reinstall.stderr"; then
  fail "expected reinstall without --force to fail"
fi
assert_contains "$(cat "$TMP_DIR/reinstall.stderr")" "already exists"

run_installer install git-commit --force --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" >/dev/null

run_installer install socratic-tutor --agent codex --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" >/dev/null
assert_file_exists "$CODEX_HOME/skills/socratic-tutor/SKILL.md"
assert_file_exists "$CODEX_HOME/skills/socratic-tutor/agents/openai.yaml"
assert_not_exists "$CLAUDE_HOME/skills/socratic-tutor"

ALL_CODEX_HOME="$TMP_DIR/all-codex-home"
run_installer install --all --agent codex --codex-home "$ALL_CODEX_HOME" >/dev/null
assert_file_exists "$ALL_CODEX_HOME/skills/git-commit/SKILL.md"
assert_file_exists "$ALL_CODEX_HOME/skills/socratic-tutor/SKILL.md"
assert_file_exists "$ALL_CODEX_HOME/skills/tighten-skill/SKILL.md"
assert_file_exists "$ALL_CODEX_HOME/skills/git-commit/agents/openai.yaml"
assert_file_exists "$ALL_CODEX_HOME/skills/socratic-tutor/agents/openai.yaml"
assert_file_exists "$ALL_CODEX_HOME/skills/tighten-skill/agents/openai.yaml"

ALL_CLAUDE_HOME="$TMP_DIR/all-claude-home"
run_installer install --all --agent claude --claude-home "$ALL_CLAUDE_HOME" >/dev/null
assert_file_exists "$ALL_CLAUDE_HOME/skills/git-commit/SKILL.md"
assert_file_exists "$ALL_CLAUDE_HOME/skills/socratic-tutor/SKILL.md"
assert_file_exists "$ALL_CLAUDE_HOME/skills/tighten-skill/SKILL.md"
assert_file_exists "$ALL_CLAUDE_HOME/skills/git-commit/agents/openai.yaml"
assert_file_exists "$ALL_CLAUDE_HOME/skills/socratic-tutor/agents/openai.yaml"
assert_file_exists "$ALL_CLAUDE_HOME/skills/tighten-skill/agents/openai.yaml"

printf 'install.sh tests passed\n'

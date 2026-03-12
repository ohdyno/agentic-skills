#!/bin/sh

set -eu

REPO_ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
INSTALLER="$REPO_ROOT/install.sh"
TEST_LIB="$REPO_ROOT/tests/test_lib.sh"
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/agentic-skills-install-test.XXXXXX")
CODEX_HOME="$TMP_DIR/codex-home"
CLAUDE_HOME="$TMP_DIR/claude-home"

# shellcheck source=tests/test_lib.sh
. "$TEST_LIB"

teardown_suite() {
  rm -rf "$TMP_DIR"
}

trap teardown_suite EXIT INT TERM

run_installer() {
  "$INSTALLER" "$@"
}

setup_test() {
  rm -rf "$CODEX_HOME" "$CLAUDE_HOME"
  mkdir -p "$CODEX_HOME" "$CLAUDE_HOME"
}

teardown_test() {
  rm -rf "$CODEX_HOME" "$CLAUDE_HOME"
}

test_list_displays_available_skills() {
  # Arrange: use the temporary agent homes declared at the top of the script.

  # Act
  list_output=$(run_installer list --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME")

  # Assert
  assert_contains "$list_output" "git-commit"
  assert_contains "$list_output" "socratic-tutor"
  assert_contains "$list_output" "tighten-skill"
  assert_contains "$list_output" "$CODEX_HOME/skills/git-commit"
  assert_contains "$list_output" "$CLAUDE_HOME/skills/git-commit"
}

test_install_copies_skill_for_both_agents() {
  # Act
  run_installer install git-commit --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" >/dev/null

  # Assert
  assert_directory_files_match "$REPO_ROOT/git-commit" "$CODEX_HOME/skills/git-commit"
  assert_directory_files_match "$REPO_ROOT/git-commit" "$CLAUDE_HOME/skills/git-commit"
}

test_install_copies_test_review_skill_metadata() {
  for skill_name in test-narrative-clarity test-structural-legibility; do
    # Act
    run_installer install "$skill_name" --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" >/dev/null

    # Assert
    assert_directory_files_match "$REPO_ROOT/$skill_name" "$CODEX_HOME/skills/$skill_name"
    assert_directory_files_match "$REPO_ROOT/$skill_name" "$CLAUDE_HOME/skills/$skill_name"
  done
}

test_install_can_overwrite_existing_skill_after_confirmation() {
  # Arrange
  codex_skill_dir="$CODEX_HOME/skills/git-commit"
  run_installer install git-commit --agent codex --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" >/dev/null
  printf 'legacy installed skill\n' >"$codex_skill_dir/SKILL.md"

  # Act
  install_output=$(
    printf 'y\n' |
      "$INSTALLER" install git-commit --agent codex --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" 2>&1
  )

  # Assert
  assert_contains "$install_output" "found existing installed skill git-commit at $codex_skill_dir"
  assert_file_exists "$codex_skill_dir/SKILL.md"
  assert_files_equal "$REPO_ROOT/git-commit/SKILL.md" "$codex_skill_dir/SKILL.md"
}

test_install_can_keep_existing_skill_after_declined_overwrite() {
  # Arrange
  codex_skill_dir="$CODEX_HOME/skills/git-commit"
  run_installer install git-commit --agent codex --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" >/dev/null
  printf 'legacy installed skill\n' >"$codex_skill_dir/SKILL.md"

  # Act
  install_output=$(
    printf 'n\n' |
      "$INSTALLER" install git-commit --agent codex --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" 2>&1
  )

  # Assert
  assert_contains "$install_output" "found existing installed skill git-commit at $codex_skill_dir"
  assert_contains "$install_output" "keeping $codex_skill_dir in place"
  assert_contains "$install_output" "skipped codex git-commit; keeping existing install at $codex_skill_dir"
  assert_contains "$(cat "$codex_skill_dir/SKILL.md")" "legacy installed skill"
}

test_force_reinstall_overwrites_existing_skill_without_prompt() {
  # Arrange
  codex_skill_dir="$CODEX_HOME/skills/git-commit"
  run_installer install git-commit --agent codex --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" >/dev/null
  printf 'legacy installed skill\n' >"$codex_skill_dir/SKILL.md"

  # Act
  install_output=$(
    "$INSTALLER" install --force git-commit --agent codex --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" 2>&1
  )

  # Assert
  assert_contains "$install_output" "found existing installed skill git-commit at $codex_skill_dir"
  assert_contains "$install_output" "force enabled; overwriting the installed copy"
  assert_files_equal "$REPO_ROOT/git-commit/SKILL.md" "$codex_skill_dir/SKILL.md"
}

test_install_can_remove_previously_installed_renamed_skill() {
  # Arrange
  old_codex_skill_dir="$CODEX_HOME/skills/project-agent-setup"
  old_claude_skill_dir="$CLAUDE_HOME/skills/project-agent-setup"
  new_codex_skill_dir="$CODEX_HOME/skills/bootstrap-agent-setup"
  new_claude_skill_dir="$CLAUDE_HOME/skills/bootstrap-agent-setup"
  mkdir -p "$old_codex_skill_dir" "$old_claude_skill_dir"
  printf 'legacy codex skill\n' >"$old_codex_skill_dir/SKILL.md"
  printf 'legacy claude skill\n' >"$old_claude_skill_dir/SKILL.md"

  # Act
  install_output=$(
    printf 'y\ny\n' |
      "$INSTALLER" install bootstrap-agent-setup --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" 2>&1
  )

  # Assert
  assert_contains "$install_output" "found previously installed renamed skill project-agent-setup for bootstrap-agent-setup"
  assert_contains "$install_output" "removed renamed skill project-agent-setup <- $old_codex_skill_dir"
  assert_contains "$install_output" "removed renamed skill project-agent-setup <- $old_claude_skill_dir"
  assert_not_exists "$old_codex_skill_dir"
  assert_not_exists "$old_claude_skill_dir"
  assert_directory_files_match "$REPO_ROOT/bootstrap-agent-setup" "$new_codex_skill_dir"
  assert_directory_files_match "$REPO_ROOT/bootstrap-agent-setup" "$new_claude_skill_dir"
}

test_install_can_keep_previously_installed_renamed_skill() {
  # Arrange
  old_codex_skill_dir="$CODEX_HOME/skills/measure-test-metrics"
  new_codex_skill_dir="$CODEX_HOME/skills/setup-test-metrics"
  mkdir -p "$old_codex_skill_dir"
  printf 'legacy codex skill\n' >"$old_codex_skill_dir/SKILL.md"

  # Act
  install_output=$(
    printf 'n\n' |
      "$INSTALLER" install setup-test-metrics --agent codex --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" 2>&1
  )

  # Assert
  assert_contains "$install_output" "found previously installed renamed skill measure-test-metrics for setup-test-metrics"
  assert_contains "$install_output" "keeping $old_codex_skill_dir in place"
  assert_dir_exists "$old_codex_skill_dir"
  assert_directory_files_match "$REPO_ROOT/setup-test-metrics" "$new_codex_skill_dir"
}

test_force_install_removes_previously_installed_renamed_skill_without_prompt() {
  # Arrange
  old_codex_skill_dir="$CODEX_HOME/skills/measure-test-metrics"
  old_claude_skill_dir="$CLAUDE_HOME/skills/measure-test-metrics"
  new_codex_skill_dir="$CODEX_HOME/skills/setup-test-metrics"
  new_claude_skill_dir="$CLAUDE_HOME/skills/setup-test-metrics"
  mkdir -p "$old_codex_skill_dir" "$old_claude_skill_dir"
  printf 'legacy codex skill\n' >"$old_codex_skill_dir/SKILL.md"
  printf 'legacy claude skill\n' >"$old_claude_skill_dir/SKILL.md"

  # Act
  install_output=$(
    "$INSTALLER" install --force setup-test-metrics --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" 2>&1
  )

  # Assert
  assert_contains "$install_output" "force enabled; removing the old installed copy"
  assert_contains "$install_output" "removed renamed skill measure-test-metrics <- $old_codex_skill_dir"
  assert_contains "$install_output" "removed renamed skill measure-test-metrics <- $old_claude_skill_dir"
  assert_not_exists "$old_codex_skill_dir"
  assert_not_exists "$old_claude_skill_dir"
  assert_directory_files_match "$REPO_ROOT/setup-test-metrics" "$new_codex_skill_dir"
  assert_directory_files_match "$REPO_ROOT/setup-test-metrics" "$new_claude_skill_dir"
}

test_declined_overwrite_skips_renamed_skill_cleanup() {
  # Arrange
  old_codex_skill_dir="$CODEX_HOME/skills/measure-test-metrics"
  new_codex_skill_dir="$CODEX_HOME/skills/setup-test-metrics"
  mkdir -p "$old_codex_skill_dir" "$new_codex_skill_dir"
  printf 'legacy renamed skill\n' >"$old_codex_skill_dir/SKILL.md"
  printf 'existing installed skill\n' >"$new_codex_skill_dir/SKILL.md"

  # Act
  install_output=$(
    printf 'n\n' |
      "$INSTALLER" install setup-test-metrics --agent codex --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" 2>&1
  )

  # Assert
  assert_contains "$install_output" "skipped codex setup-test-metrics; keeping existing install at $new_codex_skill_dir"
  assert_contains "$(cat "$new_codex_skill_dir/SKILL.md")" "existing installed skill"
  assert_file_exists "$old_codex_skill_dir/SKILL.md"
}

test_agent_specific_install_only_targets_requested_agent() {
  # Act
  run_installer install socratic-tutor --agent codex --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" >/dev/null

  # Assert
  assert_directory_files_match "$REPO_ROOT/socratic-tutor" "$CODEX_HOME/skills/socratic-tutor"
  assert_not_exists "$CLAUDE_HOME/skills/socratic-tutor"
}

test_uninstall_removes_installed_skill_for_both_agents() {
  # Arrange
  codex_skill_dir="$CODEX_HOME/skills/git-commit"
  claude_skill_dir="$CLAUDE_HOME/skills/git-commit"
  run_installer install git-commit --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" >/dev/null

  # Act
  uninstall_output=$(run_installer uninstall git-commit --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" 2>&1)

  # Assert
  assert_contains "$uninstall_output" "any local modifications will be lost"
  assert_not_exists "$codex_skill_dir"
  assert_not_exists "$claude_skill_dir"
}

test_agent_specific_uninstall_removes_only_requested_agent() {
  # Arrange
  stderr_file="$TMP_DIR/uninstall-codex.stderr"
  run_installer install socratic-tutor --agent codex --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" >/dev/null
  run_installer install git-commit --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" >/dev/null

  # Act
  run_installer uninstall socratic-tutor --agent codex --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" >/dev/null 2>"$stderr_file"

  # Assert
  assert_contains "$(cat "$stderr_file")" "any local modifications will be lost"
  assert_not_exists "$CODEX_HOME/skills/socratic-tutor"
  assert_not_exists "$CLAUDE_HOME/skills/socratic-tutor"
  assert_dir_exists "$CODEX_HOME/skills/git-commit"
  assert_dir_exists "$CLAUDE_HOME/skills/git-commit"
}

test_uninstall_missing_install_fails() {
  # Arrange
  stderr_file="$TMP_DIR/uninstall-missing.stderr"

  # Act
  if run_installer uninstall socratic-tutor --agent codex --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" >/dev/null 2>"$stderr_file"; then
    fail "expected uninstall of missing installed skill to fail"
  fi

  # Assert
  assert_contains "$(cat "$stderr_file")" "is not installed"
}

test_install_all_and_uninstall_all_for_specific_agent() {
  # Arrange
  all_codex_home="$TMP_DIR/all-codex-home"
  all_claude_home="$TMP_DIR/all-claude-home"
  stderr_file="$TMP_DIR/uninstall-all.stderr"

  # Act
  run_installer install --all --agent codex --codex-home "$all_codex_home" >/dev/null
  run_installer install --all --agent claude --claude-home "$all_claude_home" >/dev/null
  run_installer uninstall --all --agent codex --codex-home "$all_codex_home" >/dev/null 2>"$stderr_file"

  # Assert
  assert_directory_files_match "$REPO_ROOT/git-commit" "$all_claude_home/skills/git-commit"
  assert_directory_files_match "$REPO_ROOT/socratic-tutor" "$all_claude_home/skills/socratic-tutor"
  assert_directory_files_match "$REPO_ROOT/tighten-skill" "$all_claude_home/skills/tighten-skill"
  assert_contains "$(cat "$stderr_file")" "any local modifications will be lost"
  assert_not_exists "$all_codex_home/skills/git-commit"
  assert_not_exists "$all_codex_home/skills/socratic-tutor"
  assert_not_exists "$all_codex_home/skills/tighten-skill"
}

test_uninstall_unknown_skill_fails() {
  # Arrange
  stderr_file="$TMP_DIR/uninstall-unknown.stderr"

  # Act
  if run_installer uninstall not-a-skill --codex-home "$CODEX_HOME" --claude-home "$CLAUDE_HOME" >/dev/null 2>"$stderr_file"; then
    fail "expected uninstall of unknown skill to fail"
  fi

  # Assert
  assert_contains "$(cat "$stderr_file")" "Unknown skill: not-a-skill"
}

run_test test_list_displays_available_skills
run_test test_install_copies_skill_for_both_agents
run_test test_install_copies_test_review_skill_metadata
run_test test_install_can_overwrite_existing_skill_after_confirmation
run_test test_install_can_keep_existing_skill_after_declined_overwrite
run_test test_force_reinstall_overwrites_existing_skill_without_prompt
run_test test_install_can_remove_previously_installed_renamed_skill
run_test test_install_can_keep_previously_installed_renamed_skill
run_test test_force_install_removes_previously_installed_renamed_skill_without_prompt
run_test test_declined_overwrite_skips_renamed_skill_cleanup
run_test test_agent_specific_install_only_targets_requested_agent
run_test test_uninstall_removes_installed_skill_for_both_agents
run_test test_agent_specific_uninstall_removes_only_requested_agent
run_test test_uninstall_missing_install_fails
run_test test_install_all_and_uninstall_all_for_specific_agent
run_test test_uninstall_unknown_skill_fails

printf 'install.sh tests passed\n'

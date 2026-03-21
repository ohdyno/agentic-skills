#!/bin/sh

set -eu

REPO_ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
INSTALLER="$REPO_ROOT/install.sh"
TEST_LIB="$REPO_ROOT/tests/test_lib.sh"
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/agentic-skills-install-test.XXXXXX")
AGENTS_HOME="$TMP_DIR/agents-home"
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
  rm -rf "$AGENTS_HOME" "$CLAUDE_HOME"
  mkdir -p "$AGENTS_HOME" "$CLAUDE_HOME"
}

teardown_test() {
  rm -rf "$AGENTS_HOME" "$CLAUDE_HOME"
}

test_list_displays_available_skills() {
  list_output=$(run_installer list --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME")

  assert_contains "$list_output" "git-commit"
  assert_contains "$list_output" "socratic-tutor"
  assert_contains "$list_output" "tighten-skill"
  assert_contains "$list_output" "$AGENTS_HOME/skills/git-commit"
  assert_contains "$list_output" "$CLAUDE_HOME/skills/git-commit"
}

test_install_copies_skill_for_all_targets() {
  install_output=$(
    run_installer install git-commit --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME"
  )

  assert_contains "$install_output" "[install] agents git-commit -> $AGENTS_HOME/skills/git-commit"
  assert_contains "$install_output" "[install] claude git-commit -> $CLAUDE_HOME/skills/git-commit"
  assert_directory_files_match "$REPO_ROOT/git-commit" "$AGENTS_HOME/skills/git-commit"
  assert_directory_files_match "$REPO_ROOT/git-commit" "$CLAUDE_HOME/skills/git-commit"
}

test_force_color_highlights_action_tags_and_skill_names_in_install_output() {
  colored_action=$(printf '\033[1;34m[install]\033[0m')
  colored_skill=$(printf '\033[1;36mgit-commit\033[0m')

  install_output=$(
    env -u NO_COLOR FORCE_COLOR=1 "$INSTALLER" install git-commit --agent agents --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME"
  )

  assert_contains "$install_output" "$colored_action agents $colored_skill -> $AGENTS_HOME/skills/git-commit"
}

test_no_color_flag_disables_forced_skill_name_highlighting() {
  colored_action=$(printf '\033[1;34m[install]\033[0m')
  colored_skill=$(printf '\033[1;36mgit-commit\033[0m')

  install_output=$(
    env -u NO_COLOR FORCE_COLOR=1 "$INSTALLER" install --no-color git-commit --agent agents --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME"
  )

  assert_contains "$install_output" "[install] agents git-commit -> $AGENTS_HOME/skills/git-commit"
  assert_not_contains "$install_output" "$colored_action"
  assert_not_contains "$install_output" "$colored_skill"
}

test_install_can_overwrite_existing_skill_after_confirmation() {
  agents_skill_dir="$AGENTS_HOME/skills/git-commit"
  run_installer install git-commit --agent agents --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" >/dev/null
  printf 'legacy installed skill\n' >"$agents_skill_dir/SKILL.md"

  install_output=$(
    printf 'y\n' |
      "$INSTALLER" install git-commit --agent agents --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" 2>&1
  )

  assert_contains "$install_output" "[found] existing installed skill git-commit at $agents_skill_dir"
  assert_contains "$install_output" "[prompt] overwrite the installed copy? [y/N]"
  assert_contains "$install_output" "[install] agents git-commit -> $agents_skill_dir"
  assert_file_exists "$agents_skill_dir/SKILL.md"
  assert_files_equal "$REPO_ROOT/git-commit/SKILL.md" "$agents_skill_dir/SKILL.md"
}

test_install_can_keep_existing_skill_after_declined_overwrite() {
  agents_skill_dir="$AGENTS_HOME/skills/git-commit"
  run_installer install git-commit --agent agents --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" >/dev/null
  printf 'legacy installed skill\n' >"$agents_skill_dir/SKILL.md"

  install_output=$(
    printf 'n\n' |
      "$INSTALLER" install git-commit --agent agents --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" 2>&1
  )

  assert_contains "$install_output" "[found] existing installed skill git-commit at $agents_skill_dir"
  assert_contains "$install_output" "[prompt] overwrite the installed copy? [y/N]"
  assert_contains "$install_output" "[keep] keeping $agents_skill_dir in place"
  assert_contains "$install_output" "[skip] agents git-commit; keeping existing install at $agents_skill_dir"
  assert_contains "$(cat "$agents_skill_dir/SKILL.md")" "legacy installed skill"
}

test_force_reinstall_overwrites_existing_skill_without_prompt() {
  agents_skill_dir="$AGENTS_HOME/skills/git-commit"
  run_installer install git-commit --agent agents --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" >/dev/null
  printf 'legacy installed skill\n' >"$agents_skill_dir/SKILL.md"

  install_output=$(
    "$INSTALLER" install --force git-commit --agent agents --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" 2>&1
  )

  assert_contains "$install_output" "[found] existing installed skill git-commit at $agents_skill_dir"
  assert_contains "$install_output" "[force] overwriting the installed copy"
  assert_contains "$install_output" "[install] agents git-commit -> $agents_skill_dir"
  assert_files_equal "$REPO_ROOT/git-commit/SKILL.md" "$agents_skill_dir/SKILL.md"
}

test_install_can_remove_previously_installed_renamed_skill() {
  old_agents_skill_dir="$AGENTS_HOME/skills/project-agent-setup"
  old_claude_skill_dir="$CLAUDE_HOME/skills/project-agent-setup"
  new_agents_skill_dir="$AGENTS_HOME/skills/bootstrap-agent-setup"
  new_claude_skill_dir="$CLAUDE_HOME/skills/bootstrap-agent-setup"
  mkdir -p "$old_agents_skill_dir" "$old_claude_skill_dir"
  printf 'legacy agents skill\n' >"$old_agents_skill_dir/SKILL.md"
  printf 'legacy claude skill\n' >"$old_claude_skill_dir/SKILL.md"

  install_output=$(
    printf 'y\ny\n' |
      "$INSTALLER" install bootstrap-agent-setup --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" 2>&1
  )

  assert_contains "$install_output" "[found] previously installed renamed skill project-agent-setup for bootstrap-agent-setup at $old_agents_skill_dir"
  assert_contains "$install_output" "[found] previously installed renamed skill project-agent-setup for bootstrap-agent-setup at $old_claude_skill_dir"
  assert_contains "$install_output" "[remove] renamed skill project-agent-setup <- $old_agents_skill_dir"
  assert_contains "$install_output" "[remove] renamed skill project-agent-setup <- $old_claude_skill_dir"
  assert_not_exists "$old_agents_skill_dir"
  assert_not_exists "$old_claude_skill_dir"
  assert_directory_files_match "$REPO_ROOT/bootstrap-agent-setup" "$new_agents_skill_dir"
  assert_directory_files_match "$REPO_ROOT/bootstrap-agent-setup" "$new_claude_skill_dir"
}

test_install_can_keep_previously_installed_renamed_skill() {
  old_agents_skill_dir="$AGENTS_HOME/skills/measure-test-metrics"
  new_agents_skill_dir="$AGENTS_HOME/skills/setup-test-metrics"
  mkdir -p "$old_agents_skill_dir"
  printf 'legacy agents skill\n' >"$old_agents_skill_dir/SKILL.md"

  install_output=$(
    printf 'n\n' |
      "$INSTALLER" install setup-test-metrics --agent agents --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" 2>&1
  )

  assert_contains "$install_output" "[found] previously installed renamed skill measure-test-metrics for setup-test-metrics at $old_agents_skill_dir"
  assert_contains "$install_output" "[prompt] remove the old installed copy? [y/N]"
  assert_contains "$install_output" "[keep] keeping $old_agents_skill_dir in place"
  assert_dir_exists "$old_agents_skill_dir"
  assert_directory_files_match "$REPO_ROOT/setup-test-metrics" "$new_agents_skill_dir"
}

test_force_install_removes_previously_installed_renamed_skill_without_prompt() {
  old_agents_skill_dir="$AGENTS_HOME/skills/measure-test-metrics"
  old_claude_skill_dir="$CLAUDE_HOME/skills/measure-test-metrics"
  new_agents_skill_dir="$AGENTS_HOME/skills/setup-test-metrics"
  new_claude_skill_dir="$CLAUDE_HOME/skills/setup-test-metrics"
  mkdir -p "$old_agents_skill_dir" "$old_claude_skill_dir"
  printf 'legacy agents skill\n' >"$old_agents_skill_dir/SKILL.md"
  printf 'legacy claude skill\n' >"$old_claude_skill_dir/SKILL.md"

  install_output=$(
    "$INSTALLER" install --force setup-test-metrics --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" 2>&1
  )

  assert_contains "$install_output" "[force] removing the old installed copy"
  assert_contains "$install_output" "[remove] renamed skill measure-test-metrics <- $old_agents_skill_dir"
  assert_contains "$install_output" "[remove] renamed skill measure-test-metrics <- $old_claude_skill_dir"
  assert_not_exists "$old_agents_skill_dir"
  assert_not_exists "$old_claude_skill_dir"
  assert_directory_files_match "$REPO_ROOT/setup-test-metrics" "$new_agents_skill_dir"
  assert_directory_files_match "$REPO_ROOT/setup-test-metrics" "$new_claude_skill_dir"
}

test_declined_overwrite_skips_renamed_skill_cleanup() {
  old_agents_skill_dir="$AGENTS_HOME/skills/measure-test-metrics"
  new_agents_skill_dir="$AGENTS_HOME/skills/setup-test-metrics"
  mkdir -p "$old_agents_skill_dir" "$new_agents_skill_dir"
  printf 'legacy renamed skill\n' >"$old_agents_skill_dir/SKILL.md"
  printf 'existing installed skill\n' >"$new_agents_skill_dir/SKILL.md"

  install_output=$(
    printf 'n\n' |
      "$INSTALLER" install setup-test-metrics --agent agents --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" 2>&1
  )

  assert_contains "$install_output" "[skip] agents setup-test-metrics; keeping existing install at $new_agents_skill_dir"
  assert_contains "$(cat "$new_agents_skill_dir/SKILL.md")" "existing installed skill"
  assert_file_exists "$old_agents_skill_dir/SKILL.md"
}

test_target_specific_install_only_targets_agents() {
  install_output=$(
    run_installer install socratic-tutor --agent agents --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME"
  )

  assert_contains "$install_output" "[install] agents socratic-tutor -> $AGENTS_HOME/skills/socratic-tutor"
  assert_directory_files_match "$REPO_ROOT/socratic-tutor" "$AGENTS_HOME/skills/socratic-tutor"
  assert_not_exists "$CLAUDE_HOME/skills/socratic-tutor"
}

test_target_specific_install_only_targets_claude() {
  install_output=$(
    run_installer install socratic-tutor --agent claude --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME"
  )

  assert_contains "$install_output" "[install] claude socratic-tutor -> $CLAUDE_HOME/skills/socratic-tutor"
  assert_directory_files_match "$REPO_ROOT/socratic-tutor" "$CLAUDE_HOME/skills/socratic-tutor"
  assert_not_exists "$AGENTS_HOME/skills/socratic-tutor"
}

test_uninstall_removes_installed_skill_for_all_targets() {
  agents_skill_dir="$AGENTS_HOME/skills/git-commit"
  claude_skill_dir="$CLAUDE_HOME/skills/git-commit"
  run_installer install git-commit --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" >/dev/null

  uninstall_output=$(run_installer uninstall git-commit --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" 2>&1)

  assert_contains "$uninstall_output" "[warn] uninstalling $agents_skill_dir will remove the installed skill directory; any local modifications will be lost"
  assert_contains "$uninstall_output" "[warn] uninstalling $claude_skill_dir will remove the installed skill directory; any local modifications will be lost"
  assert_contains "$uninstall_output" "[uninstall] agents git-commit <- $agents_skill_dir"
  assert_contains "$uninstall_output" "[uninstall] claude git-commit <- $claude_skill_dir"
  assert_not_exists "$agents_skill_dir"
  assert_not_exists "$claude_skill_dir"
}

test_target_specific_uninstall_removes_only_requested_target() {
  stderr_file="$TMP_DIR/uninstall-agents.stderr"
  run_installer install socratic-tutor --agent agents --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" >/dev/null
  run_installer install git-commit --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" >/dev/null

  run_installer uninstall socratic-tutor --agent agents --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" >/dev/null 2>"$stderr_file"

  assert_contains "$(cat "$stderr_file")" "[warn] uninstalling $AGENTS_HOME/skills/socratic-tutor will remove the installed skill directory; any local modifications will be lost"
  assert_not_exists "$AGENTS_HOME/skills/socratic-tutor"
  assert_not_exists "$CLAUDE_HOME/skills/socratic-tutor"
  assert_dir_exists "$AGENTS_HOME/skills/git-commit"
  assert_dir_exists "$CLAUDE_HOME/skills/git-commit"
}

test_install_all_for_specific_target_only_targets_agents() {
  run_installer install --all --agent agents --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" >/dev/null

  assert_directory_files_match "$REPO_ROOT/git-commit" "$AGENTS_HOME/skills/git-commit"
  assert_directory_files_match "$REPO_ROOT/socratic-tutor" "$AGENTS_HOME/skills/socratic-tutor"
  assert_directory_files_match "$REPO_ROOT/tighten-skill" "$AGENTS_HOME/skills/tighten-skill"
  assert_not_exists "$CLAUDE_HOME/skills/git-commit"
  assert_not_exists "$CLAUDE_HOME/skills/socratic-tutor"
  assert_not_exists "$CLAUDE_HOME/skills/tighten-skill"
}

test_uninstall_all_for_specific_target_removes_only_requested_target() {
  stderr_file="$TMP_DIR/uninstall-all.stderr"
  run_installer install --all --agent agents --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" >/dev/null
  run_installer install --all --agent claude --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" >/dev/null

  run_installer uninstall --all --agent agents --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" >/dev/null 2>"$stderr_file"

  assert_directory_files_match "$REPO_ROOT/git-commit" "$CLAUDE_HOME/skills/git-commit"
  assert_directory_files_match "$REPO_ROOT/socratic-tutor" "$CLAUDE_HOME/skills/socratic-tutor"
  assert_directory_files_match "$REPO_ROOT/tighten-skill" "$CLAUDE_HOME/skills/tighten-skill"
  assert_contains "$(cat "$stderr_file")" "[warn] uninstalling $AGENTS_HOME/skills/git-commit will remove the installed skill directory; any local modifications will be lost"
  assert_not_exists "$AGENTS_HOME/skills/git-commit"
  assert_not_exists "$AGENTS_HOME/skills/socratic-tutor"
  assert_not_exists "$AGENTS_HOME/skills/tighten-skill"
}

test_uninstall_missing_install_fails() {
  stderr_file="$TMP_DIR/uninstall-missing.stderr"

  if run_installer uninstall socratic-tutor --agent agents --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" >/dev/null 2>"$stderr_file"; then
    fail "expected uninstall of missing installed skill to fail"
  fi

  assert_contains "$(cat "$stderr_file")" "is not installed"
}

test_uninstall_unknown_skill_fails() {
  stderr_file="$TMP_DIR/uninstall-unknown.stderr"

  if run_installer uninstall not-a-skill --agents-home "$AGENTS_HOME" --claude-home "$CLAUDE_HOME" >/dev/null 2>"$stderr_file"; then
    fail "expected uninstall of unknown skill to fail"
  fi

  assert_contains "$(cat "$stderr_file")" "Unknown skill: not-a-skill"
}

run_test test_list_displays_available_skills
run_test test_install_copies_skill_for_all_targets
run_test test_force_color_highlights_action_tags_and_skill_names_in_install_output
run_test test_no_color_flag_disables_forced_skill_name_highlighting
run_test test_install_can_overwrite_existing_skill_after_confirmation
run_test test_install_can_keep_existing_skill_after_declined_overwrite
run_test test_force_reinstall_overwrites_existing_skill_without_prompt
run_test test_install_can_remove_previously_installed_renamed_skill
run_test test_install_can_keep_previously_installed_renamed_skill
run_test test_force_install_removes_previously_installed_renamed_skill_without_prompt
run_test test_declined_overwrite_skips_renamed_skill_cleanup
run_test test_target_specific_install_only_targets_agents
run_test test_target_specific_install_only_targets_claude
run_test test_uninstall_removes_installed_skill_for_all_targets
run_test test_target_specific_uninstall_removes_only_requested_target
run_test test_install_all_for_specific_target_only_targets_agents
run_test test_uninstall_all_for_specific_target_removes_only_requested_target
run_test test_uninstall_missing_install_fails
run_test test_uninstall_unknown_skill_fails

printf 'install.sh tests passed\n'

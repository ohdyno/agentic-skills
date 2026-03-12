#!/bin/sh

set -eu

usage() {
  cat <<'EOF'
Usage:
  ./install.sh list [--agent codex|claude|all] [--codex-home PATH] [--claude-home PATH] [--no-color]
  ./install.sh install [--agent codex|claude|all] [--codex-home PATH] [--claude-home PATH] [--force] [--no-color] SKILL...
  ./install.sh install --all [--agent codex|claude|all] [--codex-home PATH] [--claude-home PATH] [--force] [--no-color]
  ./install.sh uninstall [--agent codex|claude|all] [--codex-home PATH] [--claude-home PATH] [--no-color] SKILL...
  ./install.sh uninstall --all [--agent codex|claude|all] [--codex-home PATH] [--claude-home PATH] [--no-color]

Commands:
  list       List available skills and their install targets
  install    Install one or more skills, or use --all
  uninstall  Uninstall one or more skills, or use --all
EOF
}

die() {
  printf '%s\n' "$1" >&2
  exit 2
}

should_force_color() {
  case ${FORCE_COLOR:-${CLICOLOR_FORCE:-}} in
    ''|0) return 1 ;;
    *) return 0 ;;
  esac
}

fd_supports_color() {
  fd=$1

  [ "${TERM:-}" != "dumb" ] || return 1
  [ -t "$fd" ]
}

init_colors() {
  stdout_action_prefix=
  stdout_action_suffix=
  stdout_skill_prefix=
  stdout_skill_suffix=
  stderr_action_prefix=
  stderr_action_suffix=
  stderr_skill_prefix=
  stderr_skill_suffix=

  if [ "$COLOR_MODE" = "never" ] || [ -n "${NO_COLOR:-}" ]; then
    return
  fi

  action_prefix=$(printf '\033[1;34m')
  action_suffix=$(printf '\033[0m')
  skill_prefix=$(printf '\033[1;36m')
  skill_suffix=$(printf '\033[0m')

  if should_force_color || fd_supports_color 1; then
    stdout_action_prefix=$action_prefix
    stdout_action_suffix=$action_suffix
    stdout_skill_prefix=$skill_prefix
    stdout_skill_suffix=$skill_suffix
  fi

  if should_force_color || fd_supports_color 2; then
    stderr_action_prefix=$action_prefix
    stderr_action_suffix=$action_suffix
    stderr_skill_prefix=$skill_prefix
    stderr_skill_suffix=$skill_suffix
  fi
}

stdout_action_tag() {
  action=$1

  printf '%s[%s]%s' "$stdout_action_prefix" "$action" "$stdout_action_suffix"
}

stdout_skill_name() {
  skill_name=$1

  printf '%s%s%s' "$stdout_skill_prefix" "$skill_name" "$stdout_skill_suffix"
}

stderr_action_tag() {
  action=$1

  printf '%s[%s]%s' "$stderr_action_prefix" "$action" "$stderr_action_suffix"
}

stderr_skill_name() {
  skill_name=$1

  printf '%s%s%s' "$stderr_skill_prefix" "$skill_name" "$stderr_skill_suffix"
}

log_stdout() {
  action=$1
  message=$2

  printf '%s %s\n' "$(stdout_action_tag "$action")" "$message"
}

log_stderr() {
  action=$1
  message=$2

  printf '%s %s\n' "$(stderr_action_tag "$action")" "$message" >&2
}

prompt_stderr() {
  action=$1
  message=$2

  printf '%s %s' "$(stderr_action_tag "$action")" "$message" >&2
}

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
RENAMES_FILE=$SCRIPT_DIR/skill-renames.txt
CODEX_HOME=${HOME}/.codex
CLAUDE_HOME=${HOME}/.claude
AGENT=all
FORCE=0
INSTALL_ALL=0
COLOR_MODE=auto

COMMAND=${1:-}
[ -n "$COMMAND" ] || {
  usage >&2
  exit 2
}
shift

SKILLS=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --agent)
      [ "$#" -ge 2 ] || die "Missing value for --agent"
      AGENT=$2
      case "$AGENT" in
        codex|claude|all) ;;
        *) die "Invalid --agent value: $AGENT" ;;
      esac
      shift 2
      ;;
    --codex-home)
      [ "$#" -ge 2 ] || die "Missing value for --codex-home"
      CODEX_HOME=$2
      shift 2
      ;;
    --claude-home)
      [ "$#" -ge 2 ] || die "Missing value for --claude-home"
      CLAUDE_HOME=$2
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --no-color)
      COLOR_MODE=never
      shift
      ;;
    --all)
      INSTALL_ALL=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --*)
      die "Unknown option: $1"
      ;;
    *)
      if [ -z "$SKILLS" ]; then
        SKILLS=$1
      else
        SKILLS="$SKILLS
$1"
      fi
      shift
      ;;
  esac
done

init_colors

list_skill_names() {
  find "$SCRIPT_DIR" -mindepth 2 -maxdepth 2 -name SKILL.md -type f \
    ! -path "$SCRIPT_DIR/.codex/*" \
    ! -path "$SCRIPT_DIR/.claude/*" \
    | sed "s|$SCRIPT_DIR/||" \
    | sed 's|/SKILL.md$||' \
    | sort
}

codex_target() {
  skill_name=$1
  printf '%s\n' "$CODEX_HOME/skills/$skill_name"
}

claude_target() {
  skill_name=$1
  printf '%s\n' "$CLAUDE_HOME/skills/$skill_name"
}

copy_directory() {
  source_dir=$1
  target_dir=$2

  rm -rf "$target_dir"
  mkdir -p "$(dirname "$target_dir")"
  cp -R "$source_dir" "$target_dir"
}

agent_target() {
  agent_name=$1
  skill_name=$2

  case "$agent_name" in
    codex) codex_target "$skill_name" ;;
    claude) claude_target "$skill_name" ;;
    *) die "Unknown agent: $agent_name" ;;
  esac
}

agent_root() {
  agent_name=$1

  case "$agent_name" in
    codex) printf '%s\n' "$CODEX_HOME/skills" ;;
    claude) printf '%s\n' "$CLAUDE_HOME/skills" ;;
    *) die "Unknown agent: $agent_name" ;;
  esac
}

print_install_message() {
  agent_name=$1
  skill_name=$2
  target_dir=$3

  case "$agent_name" in
    codex) log_stdout install "codex $(stdout_skill_name "$skill_name") -> $target_dir" ;;
    claude) log_stdout install "claude $(stdout_skill_name "$skill_name") -> $target_dir" ;;
    *) die "Unknown agent: $agent_name" ;;
  esac
}

validate_target_dir() {
  target_dir=$1
  expected_root=$2

  case "$target_dir" in
    "$expected_root"/*) ;;
    *) die "Refusing to remove path outside expected root: $target_dir" ;;
  esac
}

remove_directory() {
  target_dir=$1
  expected_root=$2

  validate_target_dir "$target_dir" "$expected_root"

  if [ ! -e "$target_dir" ]; then
    die "$target_dir is not installed"
  fi

  log_stderr warn \
    "uninstalling $target_dir will remove the installed skill directory; any local modifications will be lost"
  rm -rf "$target_dir"
}

list_command() {
  found=0
  for skill_name in $(list_skill_names); do
    found=1
    printf '%s\n' "$skill_name"
    if [ "$AGENT" = "codex" ] || [ "$AGENT" = "all" ]; then
      printf '  codex  -> %s\n' "$(codex_target "$skill_name")"
    fi
    if [ "$AGENT" = "claude" ] || [ "$AGENT" = "all" ]; then
      printf '  claude -> %s\n' "$(claude_target "$skill_name")"
    fi
  done

  [ "$found" -eq 1 ] || die "No skills found."
}

has_skill() {
  wanted=$1
  for listed_skill in $(list_skill_names); do
    if [ "$listed_skill" = "$wanted" ]; then
      return 0
    fi
  done
  return 1
}

confirm_overwrite_installed_skill() {
  skill_name=$1
  target_dir=$2

  if [ ! -e "$target_dir" ]; then
    return 0
  fi

  if [ "$FORCE" -eq 1 ]; then
    log_stderr found "existing installed skill $(stderr_skill_name "$skill_name") at $target_dir"
    log_stderr force "overwriting the installed copy"
    return 0
  fi

  if [ ! -r /dev/stdin ]; then
    die "$target_dir already exists (use --force to overwrite)"
  fi

  log_stderr found "existing installed skill $(stderr_skill_name "$skill_name") at $target_dir"
  prompt_stderr prompt "overwrite the installed copy? [y/N] "

  if ! IFS= read -r reply; then
    printf '\n' >&2
    log_stderr warn "no response received; keeping $target_dir in place"
    return 1
  fi

  case $reply in
    y|Y|yes|YES|Yes)
      return 0
      ;;
    *)
      log_stderr keep "keeping $target_dir in place"
      return 1
      ;;
  esac
}

list_previous_skill_names() {
  skill_name=$1

  [ -f "$RENAMES_FILE" ] || return 0

  while IFS=' ' read -r old_name new_name; do
    case "$old_name" in
      ''|'#'*) continue ;;
    esac

    [ -n "$new_name" ] || continue

    if [ "$new_name" = "$skill_name" ]; then
      printf '%s\n' "$old_name"
    fi
  done < "$RENAMES_FILE"
}

confirm_remove_renamed_skill() {
  old_skill_name=$1
  new_skill_name=$2
  target_dir=$3

  if [ ! -e "$target_dir" ]; then
    return 1
  fi

  if [ "$FORCE" -eq 1 ]; then
    log_stderr found \
      "previously installed renamed skill $(stderr_skill_name "$old_skill_name") for $(stderr_skill_name "$new_skill_name") at $target_dir"
    log_stderr force "removing the old installed copy"
    return 0
  fi

  if [ ! -r /dev/stdin ]; then
    log_stderr warn \
      "found previously installed renamed skill $(stderr_skill_name "$old_skill_name") for $(stderr_skill_name "$new_skill_name") at $target_dir, but no interactive input is available; leaving it in place"
    return 1
  fi

  log_stderr found \
    "previously installed renamed skill $(stderr_skill_name "$old_skill_name") for $(stderr_skill_name "$new_skill_name") at $target_dir"
  prompt_stderr prompt "remove the old installed copy? [y/N] "

  if ! IFS= read -r reply; then
    printf '\n' >&2
    log_stderr warn "no response received; leaving $target_dir in place"
    return 1
  fi

  case $reply in
    y|Y|yes|YES|Yes)
      return 0
      ;;
    *)
      log_stderr keep "keeping $target_dir in place"
      return 1
      ;;
  esac
}

remove_renamed_skill_if_requested() {
  old_skill_name=$1
  new_skill_name=$2
  target_dir=$3
  expected_root=$4

  if confirm_remove_renamed_skill "$old_skill_name" "$new_skill_name" "$target_dir"; then
    remove_directory "$target_dir" "$expected_root"
    log_stdout remove "renamed skill $(stdout_skill_name "$old_skill_name") <- $target_dir"
  fi
}

cleanup_renamed_installs() {
  new_skill_name=$1
  agent_name=$2

  for old_skill_name in $(list_previous_skill_names "$new_skill_name"); do
    remove_renamed_skill_if_requested \
      "$old_skill_name" \
      "$new_skill_name" \
      "$(agent_target "$agent_name" "$old_skill_name")" \
      "$(agent_root "$agent_name")"
  done
}

install_for_agent() {
  skill_name=$1
  source_dir=$2
  agent_name=$3

  target_dir=$(agent_target "$agent_name" "$skill_name")

  if ! confirm_overwrite_installed_skill "$skill_name" "$target_dir"; then
    log_stderr skip "$agent_name $(stderr_skill_name "$skill_name"); keeping existing install at $target_dir"
    return 0
  fi

  copy_directory "$source_dir" "$target_dir"
  print_install_message "$agent_name" "$skill_name" "$target_dir"
  cleanup_renamed_installs "$skill_name" "$agent_name"
}

install_one() {
  skill_name=$1
  source_dir=$SCRIPT_DIR/$skill_name
  source_file=$source_dir/SKILL.md

  [ -f "$source_file" ] || die "Unknown skill: $skill_name"

  if [ "$AGENT" = "codex" ] || [ "$AGENT" = "all" ]; then
    install_for_agent "$skill_name" "$source_dir" codex
  fi

  if [ "$AGENT" = "claude" ] || [ "$AGENT" = "all" ]; then
    install_for_agent "$skill_name" "$source_dir" claude
  fi
}

install_command() {
  if [ "$INSTALL_ALL" -eq 1 ]; then
    set -- $(list_skill_names)
    [ "$#" -gt 0 ] || die "No skills found."
  else
    [ -n "$SKILLS" ] || die "Pass one or more skill names, or use --all."
    set -- $SKILLS
    for requested_skill in "$@"; do
      has_skill "$requested_skill" || die "Unknown skill: $requested_skill"
    done
  fi

  for skill_name in "$@"; do
    install_one "$skill_name"
  done
}

uninstall_one() {
  skill_name=$1

  [ -d "$SCRIPT_DIR/$skill_name" ] || die "Unknown skill: $skill_name"

  if [ "$AGENT" = "codex" ] || [ "$AGENT" = "all" ]; then
    target_dir=$(codex_target "$skill_name")
    remove_directory "$target_dir" "$CODEX_HOME/skills"
    log_stdout uninstall "codex $(stdout_skill_name "$skill_name") <- $target_dir"
  fi

  if [ "$AGENT" = "claude" ] || [ "$AGENT" = "all" ]; then
    target_dir=$(claude_target "$skill_name")
    remove_directory "$target_dir" "$CLAUDE_HOME/skills"
    log_stdout uninstall "claude $(stdout_skill_name "$skill_name") <- $target_dir"
  fi
}

uninstall_command() {
  if [ "$INSTALL_ALL" -eq 1 ]; then
    set -- $(list_skill_names)
    [ "$#" -gt 0 ] || die "No skills found."
  else
    [ -n "$SKILLS" ] || die "Pass one or more skill names, or use --all."
    set -- $SKILLS
    for requested_skill in "$@"; do
      has_skill "$requested_skill" || die "Unknown skill: $requested_skill"
    done
  fi

  for skill_name in "$@"; do
    uninstall_one "$skill_name"
  done
}

case "$COMMAND" in
  list)
    [ -z "$SKILLS" ] || die "Unexpected arguments for list: $SKILLS"
    list_command
    ;;
  install)
    install_command
    ;;
  uninstall)
    uninstall_command
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

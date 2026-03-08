#!/bin/sh

set -eu

usage() {
  cat <<'EOF'
Usage:
  ./install.sh list [--agent codex|claude|all] [--codex-home PATH] [--claude-home PATH]
  ./install.sh install [--agent codex|claude|all] [--codex-home PATH] [--claude-home PATH] [--force] SKILL...
  ./install.sh install --all [--agent codex|claude|all] [--codex-home PATH] [--claude-home PATH] [--force]
  ./install.sh uninstall [--agent codex|claude|all] [--codex-home PATH] [--claude-home PATH] SKILL...
  ./install.sh uninstall --all [--agent codex|claude|all] [--codex-home PATH] [--claude-home PATH]

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

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
CODEX_HOME=${HOME}/.codex
CLAUDE_HOME=${HOME}/.claude
AGENT=all
FORCE=0
INSTALL_ALL=0

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

  if [ -e "$target_dir" ] && [ "$FORCE" -ne 1 ]; then
    die "$target_dir already exists (use --force to overwrite)"
  fi

  rm -rf "$target_dir"
  mkdir -p "$(dirname "$target_dir")"
  cp -R "$source_dir" "$target_dir"
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

  printf 'warning: uninstalling %s will remove the installed skill directory; any local modifications will be lost\n' "$target_dir" >&2
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

install_one() {
  skill_name=$1
  source_dir=$SCRIPT_DIR/$skill_name
  source_file=$source_dir/SKILL.md

  [ -f "$source_file" ] || die "Unknown skill: $skill_name"

  if [ "$AGENT" = "codex" ] || [ "$AGENT" = "all" ]; then
    target_dir=$(codex_target "$skill_name")
    copy_directory "$source_dir" "$target_dir"
    printf 'installed codex  %s -> %s\n' "$skill_name" "$target_dir"
  fi

  if [ "$AGENT" = "claude" ] || [ "$AGENT" = "all" ]; then
    target_dir=$(claude_target "$skill_name")
    copy_directory "$source_dir" "$target_dir"
    printf 'installed claude %s -> %s\n' "$skill_name" "$target_dir"
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
    printf 'uninstalled codex  %s <- %s\n' "$skill_name" "$target_dir"
  fi

  if [ "$AGENT" = "claude" ] || [ "$AGENT" = "all" ]; then
    target_dir=$(claude_target "$skill_name")
    remove_directory "$target_dir" "$CLAUDE_HOME/skills"
    printf 'uninstalled claude %s <- %s\n' "$skill_name" "$target_dir"
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

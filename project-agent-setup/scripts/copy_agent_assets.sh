#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: copy_agent_assets.sh [--target DIR] [--dry-run] [--force]

Copy this skill's project template assets into a target repository.

Options:
  --target DIR  Destination directory. Defaults to the current working directory.
  --dry-run     Show planned actions without copying files.
  --force       Overwrite existing files that conflict.
  --help        Show this help text.
EOF
}

target_dir="$PWD"
dry_run=0
force=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      if [[ $# -lt 2 ]]; then
        echo "error: --target requires a directory" >&2
        exit 1
      fi
      target_dir="$2"
      shift 2
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --force)
      force=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
asset_dir="${script_dir%/scripts}/assets/project-template"

if [[ ! -d "$asset_dir" ]]; then
  echo "error: asset directory not found: $asset_dir" >&2
  exit 1
fi

mkdir -p "$target_dir"
target_dir="$(cd "$target_dir" && pwd)"

source_files=()
while IFS= read -r -d '' source_file; do
  source_files+=("$source_file")
done < <(find "$asset_dir" -type f -print0 | sort -z)

conflicts=()
copied=0

for source_file in "${source_files[@]}"; do
  rel_path="${source_file#$asset_dir/}"
  dest_file="$target_dir/$rel_path"

  if [[ -e "$dest_file" && $force -ne 1 ]]; then
    conflicts+=("$rel_path")
  fi
done

if [[ ${#conflicts[@]} -gt 0 ]]; then
  echo "conflicts detected:" >&2
  printf '  %s\n' "${conflicts[@]}" >&2
  echo "re-run with --force to overwrite conflicting files" >&2
  exit 2
fi

for source_file in "${source_files[@]}"; do
  rel_path="${source_file#$asset_dir/}"
  dest_file="$target_dir/$rel_path"
  dest_dir="$(dirname "$dest_file")"

  if [[ $dry_run -eq 1 ]]; then
    if [[ -e "$dest_file" ]]; then
      echo "overwrite $rel_path"
    else
      echo "copy $rel_path"
    fi
    copied=$((copied + 1))
    continue
  fi

  mkdir -p "$dest_dir"
  cp "$source_file" "$dest_file"
  echo "copied $rel_path"
  copied=$((copied + 1))
done

if [[ $dry_run -eq 1 ]]; then
  echo "dry run complete: $copied file(s) would be copied"
else
  echo "copy complete: $copied file(s) copied"
fi

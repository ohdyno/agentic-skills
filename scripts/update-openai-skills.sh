#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
vendor_dir="$repo_root/vendor/openai-skills"
skills_dir="$repo_root/.agents/skills"
upstream_url="https://github.com/openai/skills.git"
system_skills=(
  openai-docs
  skill-creator
  skill-installer
)

mkdir -p "$repo_root/vendor" "$skills_dir"

if [[ -d "$vendor_dir/.git" ]]; then
  git -C "$vendor_dir" pull --ff-only
else
  rm -rf "$vendor_dir"
  git clone --filter=blob:none --depth 1 "$upstream_url" "$vendor_dir"
fi

for skill in "${system_skills[@]}"; do
  target="../../vendor/openai-skills/skills/.system/$skill"
  ln -sfn "$target" "$skills_dir/$skill"
done

printf 'Updated OpenAI system skills in %s\n' "$skills_dir"

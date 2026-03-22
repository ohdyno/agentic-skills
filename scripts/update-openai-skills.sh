#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
vendor_dir="$repo_root/vendor/openai-skills"
skills_dir="$repo_root/.agents/skills"
system_skills=(
  openai-docs
  skill-creator
  skill-installer
)

mkdir -p "$skills_dir"

git -C "$repo_root" submodule update --init --remote vendor/openai-skills

for skill in "${system_skills[@]}"; do
  target="../../vendor/openai-skills/skills/.system/$skill"
  ln -sfn "$target" "$skills_dir/$skill"
done

printf 'Updated OpenAI system skills in %s\n' "$skills_dir"

---
name: bootstrap-agent-setup
description: Bootstrap a repository for agent use by copying a reusable local asset bundle into the current project. Use when the user wants to bootstrap a consistent agent setup, install repo-local agent instructions, or add a starter agent scaffold in the directory where the agent is working.
---

# Bootstrap Agent Setup

Install this skill's repo-local scaffold into the target repository with `scripts/copy_agent_assets.sh`.

## Workflow

### 1. Confirm the Target

Treat the current working directory as the default target unless the user names another path.
- Prefer a dry run first when the repo state is unclear.

### 2. Use the Script

Run `scripts/copy_agent_assets.sh` from this skill instead of manually recreating files.

Default command:

```bash
scripts/copy_agent_assets.sh --target "$PWD"
```

- `--dry-run` to preview what would be copied
- `--force` to overwrite conflicting files only after the user explicitly chooses replacement instead of merge

### 3. Handle Conflicts Explicitly

If the script reports conflicts:
- Do not overwrite by default
- Show the conflicting paths briefly
- Ask whether the existing file and the skill asset should be merged

If the user wants a merge:
- Read the existing file and the matching asset file
- Preserve the intent of both versions, not just the wording
- If they conflict in meaning, ask the user how to resolve it before drafting
- Show the proposed merged content before writing
- Wait for explicit approval before applying it

If the user does not want a merge:
- Leave the existing file unchanged unless the user explicitly asks to overwrite it

### 4. Adapt the Scaffold

After copying:
- Fill in `README.md` with the project's purpose
- Fill in `CONTRIBUTING.md` with the repository's contribution guidelines
- Keep `AGENTS.md` focused on directing agents to read those files first
- Add any extra tool-specific files only when the repository actually needs them
- Keep the repo-local setup lean and actionable

### 5. Offer Commit-time Quality Checks

Ask whether the user wants local checks for formatting, linting, and quick validation before code is committed.

If the user agrees:
- Inspect the repository's existing formatter, linter, and test tooling
- Propose a minimal commit-time check setup that fits the project
- Show the planned files and commands before making changes
- Ask for explicit approval before writing hook files, adding config, or installing dependencies

## Guardrails

- Never replace conflicting setup files silently.
- Never merge and write a file in one step; preview first, then wait for approval.
- When intent differs between the repo and the asset, surface the contradiction explicitly instead of guessing.
- Never set up local commit-time checks without explicit user consent.
- Never add hook-related dependencies, configs, or docs without explicit user approval.

---
name: project-agent-setup
description: Bootstrap a repository for agent use by copying a reusable local asset bundle into the current project. Use when the user wants a consistent agent setup, repo-local agent instructions, or a starter agent scaffold installed into the directory where the agent is working.
---

# Project Agent Setup

Install this skill's repo-local scaffold into the target repository by invoking `scripts/copy_agent_assets.sh` directly.

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
- Preserve the intent of both, not just the wording
- If the two versions conflict in meaning or instruction, ask the user how that contradiction should be resolved before drafting the merge
- Show the proposed merged content before writing anything
- Ask for explicit approval
- Only write the merged version after the user approves it

If the user does not want a merge:
- Leave the existing file unchanged unless the user explicitly asks to overwrite it

### 4. Adapt the Scaffold

After copying:
- Fill in `README.md` with the project's purpose
- Fill in `CONTRIBUTING.md` with the repository's contribution guidelines
- Keep `AGENTS.md` focused on directing agents to read those files first
- Add any extra tool-specific files only when the repository actually needs them
- Keep the repo-local setup lean and actionable

## Guardrails

- Never replace conflicting setup files silently.
- Never merge and write a file in one step; preview first, then wait for approval.
- When intent differs between the repo and the asset, surface the contradiction explicitly instead of guessing.

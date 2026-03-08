---
name: project-agent-setup
description: Bootstrap a repository for agent use by copying a reusable local asset bundle into the current project. Use when the user wants a consistent agent setup, repo-local agent instructions, or a starter agent scaffold installed into the directory where the agent is working.
---

# Project Agent Setup

Install a reusable agent scaffold into the current repository by copying this skill's bundled assets with the provided script.

## Workflow

### 1. Confirm the Target

Treat the current working directory as the default target repository unless the user names another path.

Before copying:
- Check whether the target already contains files that would conflict with the asset bundle.
- Prefer a dry run first when the repo state is unclear.

### 2. Use the Script

Run `scripts/copy_agent_assets.sh` from this skill instead of manually recreating files.

Default command:

```bash
bash scripts/copy_agent_assets.sh --target "$PWD"
```

Useful flags:
- `--dry-run` to preview what would be copied
- `--force` to overwrite conflicting files only after the user explicitly chooses replacement instead of merge

The script copies everything under `assets/project-template/` into the target repository while preserving relative paths.

### 3. Handle Conflicts Explicitly

If the script reports conflicts:
- Do not overwrite by default
- Show the conflicting paths briefly
- Ask whether the existing file and the skill asset should be merged

If the user wants a merge:
- Read the existing file and the matching asset file
- Preserve the intent of both, not just the wording
- If the two versions conflict in meaning or instruction, ask the user how that contradiction should be resolved before drafting the merge
- Show the proposed merged content to the user before writing anything
- Ask for explicit approval of the merged content
- Only write the merged version after the user approves it

If the user does not want a merge:
- Leave the existing file unchanged unless the user explicitly asks to overwrite it

### 4. Adapt the Scaffold

After copying:
- Fill in project-specific guidance in `AGENTS.md`
- Add any extra tool-specific files only when the repository actually needs them
- Keep the repo-local setup lean and actionable

## Bundled Resources

- `scripts/copy_agent_assets.sh`: deterministic asset copier for the current repo
- `assets/project-template/`: starter files copied into the target repo

## Example Triggers

Use this skill for requests like:
- "Set this repo up for agent use."
- "Copy my standard agent files into this project."
- "Bootstrap a consistent agent scaffold here."

## Guardrails

- Never replace conflicting setup files silently.
- Never merge and write a file in one step; preview first, then wait for approval.
- When intent differs between the repo and the asset, surface the contradiction explicitly instead of guessing.

---
name: setup-pre-commit-hooks
description: Set up or update repository-local pre-commit hooks and other commit-time checks. Use when the user wants local checks before commit for formatting, linting, tests, or similar quality gates.
---

# Setup Pre-commit Hooks

Configure or update repository-local commit-time checks for the current repository, typically through git pre-commit hooks.

## Workflow

### 1. Confirm Scope

Treat the current working directory as the target repository unless the user names another path.

Clarify whether the user wants:
- A simple `.git/hooks/pre-commit` script
- A `pre-commit` framework setup
- Updates to an existing hook setup

If the repository already has hook-related files or scripts:
- Inspect them first
- Preserve the existing approach unless the user asks to replace it

### 2. Inspect Current Tooling

Determine the project's formatter, linter, and test commands from repository files before proposing hook contents.

Check only the files needed, such as:
- `package.json`
- `pyproject.toml`
- `mise.toml`
- `justfile`
- `Makefile`
- Existing `.pre-commit-config.yaml`
- Existing files under `.git/hooks/`

If the correct commands are still unclear:
- Ask the user whether to use the discovered defaults or provide custom commands

### 3. Propose the Hook Plan

Default to a small, fast hook plan.

Prefer commands that are:
- Already used by the repository
- Fast enough for commit-time execution
- Auto-fixing where appropriate

Typical order:
1. formatter or autofix step
2. lint step
3. targeted fast tests only if they are quick enough

Do not add slow or flaky checks to pre-commit by default.

Show the exact planned commands and which files will be created or modified before making changes.

### 4. Get Explicit Approval

Ask for explicit approval before:
- Writing or editing hook files
- Installing hook frameworks or dependencies
- Adding config files
- Updating documentation

If the user wants changes to an existing hook setup:
- Summarize the delta clearly before editing

### 5. Implement

After approval:
- Create or update the hook files
- Keep the implementation minimal and readable
- Avoid introducing new tooling unless the user approved it

If using a shell hook:
- Make the script executable
- Fail fast on command errors
- Print concise failure output

If using the `pre-commit` framework:
- Add only the necessary config and commands
- Keep hook stages scoped to `pre-commit` unless the user asks otherwise

### 6. Verify

After setup:
- Show the final files changed
- Run a safe verification step when possible, such as config validation or a non-destructive hook invocation
- Tell the user how to run the hook manually

## Guardrails

- Never overwrite an existing hook setup without explicit approval.
- Never invent formatter, linter, or test commands when the repo does not make them clear.
- Never add dependencies or config files without explicit user approval.
- Never default to slow full test suites for pre-commit hooks.
- Prefer the repository's current tooling over introducing a new framework.

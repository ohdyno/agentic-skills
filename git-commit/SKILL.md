---
name: git-commit
description: Draft succinct Conventional Commits for the current repository state. Use when the user asks the agent to commit changes, write a commit message, or summarize work for commit. Analyze staged, unstaged, and untracked changes, and implicitly use the conversation history since the last commit to produce a message that captures the purpose of the full change set rather than only the latest prompt.
---

# Git Commit

Draft one Conventional Commit for the full current change set by using repository state for what changed and conversation history for why it changed.

## Workflow

### 1. Inspect the Full Commit Scope

Review all changes that would be included if the user committed now:
- Check tracked and untracked files.
- Read staged and unstaged diffs.
- Skim the latest commit only when needed to understand what changed since `HEAD`.

Treat the scope as the full working tree delta since the last commit, not merely the files touched by the latest prompt.

### 2. Reconstruct the Goal

Read the conversation context that led to the current state. Do this implicitly whenever the user asks to commit changes.

Identify:
- The user-visible goal
- The problem being solved
- The behavior or workflow being enabled, fixed, refined, or documented

Prefer the unifying reason across all changes. If several edits exist, look for the single intention that best explains why they belong in one commit.

### 3. Choose the Conventional Commit Type

Pick the type that matches the intent, not the implementation detail.

Use these defaults:
- `feat` for new user-facing capability or newly supported workflow
- `fix` for correcting broken behavior or wrong results
- `refactor` for structural improvement without behavior change
- `docs` for documentation-only changes
- `chore` for maintenance work that does not fit better elsewhere

Add a scope only when it clarifies the message and remains short.

### 4. Write for Intent

Write a short subject line in Conventional Commits form: `type(scope): summary`

Optimize the summary for why the change exists:
- Describe the outcome or purpose
- Omit file lists and low-level edit details
- Avoid repeating obvious diff mechanics such as "update files" or "change code"
- Keep it concise and specific

Good patterns:
- `feat(skills): add a reusable git-commit skill`

Weak patterns:
- `feat: update multiple files`

### 5. Resolve Ambiguity

If the changes support more than one plausible message:
- Prefer the message that best explains the user-requested outcome
- Prefer broader intent over narrow implementation detail
- Mention uncertainty briefly only if the user asked for explanation or alternatives

If the repository contains unrelated edits, do not invent a false unifying story. Instead, state that the working tree appears to mix multiple concerns and give the best message for the dominant theme.

## Output

Default to returning exactly one commit message line and nothing else.

If the user asks for options, provide a small set of alternatives ordered from strongest to weaker.

If the user asks for rationale, add one short explanation after the primary message describing the inferred goal.

## Examples

Trigger this skill for requests like:
- "Commit the current changes."
- "Write a commit message for the current changes."
- "Summarize everything we changed since the last commit as one commit message."

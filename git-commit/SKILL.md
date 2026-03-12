---
name: git-commit
description: Create succinct Conventional Commits for the current repository state and, when the user asks to commit, actually make the git commit. Analyze staged, unstaged, and untracked changes, and implicitly use the conversation history since the last commit to produce a message that captures the purpose of the full change set rather than only the latest prompt.
---

# Git Commit

When the user asks to commit changes, inspect the full change set, write a Conventional Commit subject that matches the intent, add a short body when it helps, and execute the commit.

## Workflow

### 1. Inspect the Full Commit Scope

Review all changes that would be included if the user committed now:
- Check tracked and untracked files.
- Read staged and unstaged diffs.
- Skim the latest commit only when needed to understand what changed since `HEAD`.

Treat the scope as the full working tree delta since the last commit, not merely the files touched by the latest prompt.

### 2. Reconstruct the Goal

Use the conversation context to identify:

- The user-visible goal
- The problem being solved
- The behavior or workflow being enabled, fixed, refined, or documented

Prefer the single intention that best explains why the changes belong in one commit.

### 3. Choose the Conventional Commit Type

Pick the type that matches the intent, not the implementation detail.

Use these defaults:
- `build` for build system or dependency changes
- `chore` for maintenance work that does not fit better elsewhere
- `ci` for CI configuration or automation changes
- `docs` for documentation-only changes
- `feat` for new user-facing capability or newly supported workflow
- `fix` for correcting broken behavior or wrong results
- `perf` for performance improvements
- `refactor` for structural improvement without behavior change
- `style` for formatting or stylistic changes without behavior impact
- `test` for adding or updating tests

Add a scope only when it clarifies the message and remains short.

### 4. Write for Intent

Use this template:

```text
<type>(<scope>): <summary>

<body, optional>
```

Formatting rules:
- Omit `(<scope>)` when it does not help.
- Add a body only when one or two short sentences materially improve clarity.
- Wrap body lines at roughly 72 characters.

Summary:
- Describe the outcome or purpose
- Omit file lists and low-level edit details
- Avoid repeating obvious diff mechanics such as "update files" or "change code"
- Keep it concise and specific

Body:
- State the user-visible effect or behavioral change
- Mention the key sequencing or tradeoff only when it clarifies intent
- Omit file inventories, test lists, and low-level patch narration
- Keep it to 1-2 short sentences

### 5. Resolve Ambiguity

If the changes support more than one plausible message:
- Prefer the message that best explains the user-requested outcome
- Prefer broader intent over narrow implementation detail
- Mention uncertainty briefly only if the user asked for explanation or alternatives

If the repository contains unrelated edits, do not invent a false unifying story. State that the working tree mixes concerns and give the best message for the dominant theme.

### 6. Execute the Commit When Requested

If the user asked to commit:
- Stage the intended files when appropriate for the request. If the request is broad, treat it as the full current change set.
- Commit using the template above.
- If the message has a body, pass it as a separate paragraph, for example `git commit -m "<subject>" -m "<body>"`.
- If the commit fails because there is nothing to commit, hooks reject it, or Git reports another actionable problem, report the real failure briefly.
- After committing, return the commit hash and subject line, and mention the body briefly if one was included.

If the user asked only for a message, options, or rationale, do not commit.

## Output

- If the user asked to commit, default to committing and then report the result briefly.
- If the user asked only for a message, return the subject line only unless they explicitly ask for a full commit message.
- If the user asks for options, provide a small set ordered from strongest to weaker.
- If the user asks for rationale, add one short explanation after the subject. Include a body only if it materially helps.

## Examples

Trigger this skill for requests like:
- "Commit the current changes."
- "Write a commit message for the current changes."
- "Summarize everything we changed since the last commit as one commit message."

---
name: git-commit
description: Create succinct Conventional Commits for the current repository state and, when the user asks to commit, actually make the git commit. Analyze staged, unstaged, and untracked changes, and implicitly use the conversation history since the last commit to produce a message that captures the purpose of the full change set rather than only the latest prompt.
---

# Git Commit

When the user asks to commit changes, inspect the full current change set, write a Conventional Commit subject that matches the real intent, add a short body when it helps, and execute the commit.

## Workflow

### 1. Inspect the Full Commit Scope

Review all changes that would be included if the user committed now:
- Check tracked and untracked files.
- Read staged and unstaged diffs.
- Skim the latest commit only when needed to understand what changed since `HEAD`.

Treat the scope as the full working tree delta since the last commit, not merely the files touched by the latest prompt.

If the user asked to commit changes, use the scope that would actually be committed now.

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

Add a brief body only when one or two short sentences materially improve clarity.

Optimize the summary for why the change exists:
- Describe the outcome or purpose
- Omit file lists and low-level edit details
- Avoid repeating obvious diff mechanics such as "update files" or "change code"
- Keep it concise and specific

Optimize the body for the extra context that would help a reviewer scanning history:
- State the user-visible effect or behavioral change
- Mention the key sequencing or tradeoff only when it clarifies intent
- Omit file inventories, test lists, and low-level patch narration
- Keep it to 1-2 short sentences

Good patterns:
- `feat(skills): add a reusable git-commit skill`

Weak patterns:
- `feat: update multiple files`

Good subject + body pattern:
- Subject: `fix(installer): prompt before overwriting skills`
- Body: `Reorders install flow so overwrite confirmation happens before install. Renamed-skill cleanup now runs only after a successful per-agent install.`

### 5. Resolve Ambiguity

If the changes support more than one plausible message:
- Prefer the message that best explains the user-requested outcome
- Prefer broader intent over narrow implementation detail
- Mention uncertainty briefly only if the user asked for explanation or alternatives

If the repository contains unrelated edits, do not invent a false unifying story. Instead, state that the working tree appears to mix multiple concerns and give the best message for the dominant theme.

### 6. Execute the Commit When Requested

If the user asked to commit:
- Stage the intended files when appropriate for the request. If the request is broad, treat it as the full current change set.
- Commit with the derived subject line.
- If a body is warranted, pass it as a separate paragraph, for example `git commit -m "<subject>" -m "<body>"`.
- If the commit fails because there is nothing to commit, hooks reject it, or Git reports another actionable problem, report the real failure briefly.
- After committing, return the commit hash and subject line, and mention the body briefly if one was included.

If the user asked only for a message, options, or rationale, do not commit.

## Output

If the user asked to commit, default to actually committing and then report the resulting commit briefly.

If the user asked only for a message, default to returning the subject line only unless the user explicitly asks for a full commit message.

If the user asks for options, provide a small set of alternatives ordered from strongest to weaker.

If the user asks for rationale, add one short explanation after the primary message describing the inferred goal. If a body would clearly help, include it after the subject.

## Examples

Trigger this skill for requests like:
- "Commit the current changes."
- "Write a commit message for the current changes."
- "Summarize everything we changed since the last commit as one commit message."

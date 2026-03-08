---
name: tighten-skill
description: Tighten an existing skill's SKILL.md without changing what the skill is for. Use when the user asks the agent to review a skill that was just discussed, created, or edited and make its instructions more succinct while preserving triggers, workflow, and intent.
---

# Tighten Skill

Review a skill's `SKILL.md` and compress it without weakening the skill.

## Workflow

### 1. Read the Skill Before Editing

Inspect the current `SKILL.md` and identify:
- The trigger behavior in frontmatter
- The core workflow or guardrails that must survive
- The distinctive instructions that make the skill useful

Treat the existing file as the source of truth for intent.

### 2. Find Safe Compression Targets

Look for:
- Repeated ideas across the description, overview, workflow, and examples
- Long examples that restate the rule instead of sharpening it
- Sections that can be merged without losing decision-making value
- Lists that can be shortened to the most important cases

Prefer removing repetition over rewriting the whole skill.

### 3. Preserve the Important Parts

Do not tighten away:
- What should trigger the skill
- The main operating loop or workflow
- Key guardrails, exceptions, or escalation rules
- Instructions that encode non-obvious behavior

If a section is verbose but carries unique behavior, compress it rather than deleting it.

### 4. Edit for Density

Rewrite instructions to be:
- Shorter
- More direct
- Less repetitive
- Easier to scan

Prefer one strong sentence over several weak ones. Keep examples only when they clarify behavior that would otherwise be ambiguous.

### 5. Verify the Result

After editing, confirm that:
- The shortened version still supports the same trigger conditions
- The workflow still tells the agent what to do
- No distinctive constraint was removed by accident

If validation tooling exists, run it.

## Output

When asked for analysis, identify the best compression opportunities before editing.

When asked to make the change, edit the `SKILL.md` directly and keep the final result lean.

## Examples

Trigger this skill for requests like:
- "Tighten this skill without losing intent."
- "Make the skill instructions more succinct."
- "Review the skill we just created and trim the SKILL.md."

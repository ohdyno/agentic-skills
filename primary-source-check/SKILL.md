---
name: primary-source-check
description: Verify changing or source-sensitive claims against primary sources before answering. Use when the user asks for the latest information, official behavior, product capabilities, APIs, install paths, packaging formats, policies, rules, or anything else that may have changed and should not be answered from memory.
---

# Primary Source Check

Verify changing or source-sensitive claims against primary sources before answering.

## Workflow

### 1. Decide Whether Verification Is Required

Use this skill when the answer may have changed or the user asks for verification.

Common triggers:
- Product behavior or feature support
- Official install paths or packaging formats
- APIs, SDKs, and current documentation
- Policies, rules, pricing, or limits
- Requests using words like "latest", "current", "official", "verify", or "check first"

Skip it for stable, non-source-sensitive facts.

### 2. Prefer Primary Sources

Look for the most authoritative source first:
- Official product documentation
- Vendor documentation
- Standards bodies
- Maintainer documentation
- Original papers or specifications

Do not rely on secondary summaries when a primary source is available.

### 3. Verify Before Concluding

Read enough to answer the real question, not just to match keywords.

When needed:
- Check more than one official page
- Confirm the exact path, feature name, or packaging model
- Compare older assumptions against the current docs

Treat memory as provisional until the source confirms it.

### 4. Separate Facts From Inference

In the answer:
- State the verified fact plainly
- Link the source used
- Mark any inference as an inference

If the source is ambiguous or incomplete, say so directly.

### 5. Correct Earlier Assumptions Cleanly

If a previous answer in the conversation was wrong or outdated:
- Say so briefly
- Replace it with the verified answer
- Avoid defending the earlier assumption

## Output

Default to a concise answer with source attribution.

If the user asked specifically for verification, say that you checked the official or primary source.

## Guardrails

- Do not answer changing product questions from memory when primary sources are available.
- Do not present secondary commentary as authoritative when official docs exist.
- Do not hide uncertainty behind confident wording.
- Do not overquote sources; summarize the relevant point and link the source.

## Example Triggers

This skill should activate for requests like:
- "Check the official docs first and then answer."
- "Verify this against the latest docs."
- "Does Claude support directory-based skills now?"
- "What is the official install path for this tool?"

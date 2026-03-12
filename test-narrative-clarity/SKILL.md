---
name: test-narrative-clarity
description: Review whether tests communicate clear domain stories with coherent language. Use when the user wants to assess scenario meaning, name/body semantic alignment, terminology consistency, ubiquitous language, or whether tests read like understandable business narratives.
---

# Test Narrative Clarity

Review tests for narrative clarity: meaning and language, not mechanical code shape.

## Workflow

### 1. Discover Test Formats

Identify the build tool, test runner, and test formats first. Prefer:
1. project management or test tooling commands that can enumerate or dry-run tests without executing them
2. test runner and build configuration
3. repository conventions and file heuristics

Look for:
- code-based tests such as `*.spec.*`, `*.test.*`, `*_test.*`, `tests/`, `test/`
- Gherkin tests such as `*.feature`
- related step-definition or glue configuration when Gherkin is in use

If Gherkin `.feature` files are present, verify the current Gherkin syntax and supported constructs against the official Cucumber Gherkin reference before reviewing them. Adapt the review to the constructs and language actually used in the project.

If the repository uses multiple test formats, adapt the review to each format instead of assuming unit tests.

### 2. Identify the Story the Test Claims to Tell

Read only what is needed:
- the test itself
- nearby helpers or production code when needed to resolve domain terms
- domain docs or glossary files when present
- step definitions only when feature wording is ambiguous or overloaded

For each test, identify:
- the scenario being described
- the business concept being exercised
- the outcome the test appears to care about

For Gherkin tests, treat the feature file text as the primary narrative source.

### 3. Evaluate Narrative Clarity

Look for:
- meaningful scenario description
- clear name/body or scenario/step semantic alignment
- explicit business-relevant outcome
- coherent use of domain terms
- consistent terminology across related tests

Flag issues such as:
- vague names like `works`, `handles`, or `success`
- scenario text that does not match the implemented behavior
- multiple terms for the same concept
- the same term used with different meanings
- business meaning hidden behind generic helper or step names

### 4. Ground Terminology in Evidence

When commenting on language:
- cite the relevant test code or feature text
- cite nearby production identifiers when helpful
- cite project docs or glossary files when available

Distinguish clearly between:
- observed wording in the repo
- your inference about intended domain meaning

### 5. Report Findings as Review Notes

For each issue, state:
- what is unclear or inconsistent
- why it weakens the test's narrative
- what wording or terminology would make it clearer

If the user wants a structured review, use:
- scenario summary
- terminology issues
- semantic alignment notes
- suggested glossary entries

## Guardrails

- Do not judge indentation, fixture layout, branching, or assertion count unless they directly affect meaning.
- Do not treat setup/action/assertion shape as the primary signal; this skill is about narrative meaning.
- Do not invent domain terminology without grounding it in repo evidence.
- Do not present subjective judgments as deterministic metrics.

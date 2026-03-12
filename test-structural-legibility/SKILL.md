---
name: test-structural-legibility
description: Review the mechanical readability of tests. Use when the user wants to assess setup/action/assertion flow, hidden fixture indirection, branching, assertion focus, or whether a test is easy to scan and follow.
---

# Test Structural Legibility

Review tests for structural legibility: mechanical readability, not domain language.

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

### 2. Inspect the Test Shape

Read only what is needed:
- the test file
- helper or fixture files when they hide important setup
- test framework config only when it affects readability
- step definitions when a Gherkin scenario hides important mechanics behind steps

Identify the visible structure of each test:
- setup
- triggering action
- assertions or expected outcomes
- helper, fixture, or step-definition usage

For Gherkin tests, review both the feature file text and the amount of indirection hidden in step definitions when needed.

### 3. Evaluate Mechanical Readability

Look for:
- clear setup/action/assertion or equivalent scenario flow
- one main action per test or scenario
- focused assertions or outcomes
- low branching and looping
- low hidden fixture or step-definition indirection
- readable helper boundaries

Flag issues such as:
- setup buried in distant fixtures
- multiple unrelated actions in one test
- assertion blocks that mix many concerns
- heavy control flow that obscures the path
- helpers or step definitions that hide critical state transitions

### 4. Report Findings as Review Notes

For each issue, state:
- where the structure becomes hard to follow
- what part of the test is obscured
- what simplification would improve scanability

When labeling findings, use readability-impact labels such as `important`, `moderate`, or `minor` rather than bug-style severity terms.

If the user wants a structured review, use:
- structure summary
- hidden setup notes
- action clarity notes
- assertion or outcome focus notes

## Guardrails

- Do not critique domain wording or ubiquitous language unless it blocks mechanical readability.
- Do not treat business meaning as the main focus; this skill is about code shape.
- Do not enforce a single style unless the repository already has one.
- Prefer practical readability improvements over stylistic preferences.

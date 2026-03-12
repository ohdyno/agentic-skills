---
name: setup-test-metrics
description: Set up deterministic tooling to collect software testing metrics such as coverage, test fan-out, and mutation score. Use when the user wants help choosing, installing, configuring, or automating battle-tested test-metric tools in a project.
---

# Setup Test Metrics

Set up deterministic tooling to collect coverage, test fan-out, and mutation score.

Read [references/metrics.md](references/metrics.md) for metric definitions and [references/sources.md](references/sources.md) for the source set behind them.

## Workflow

### 1. Confirm the Setup Goal

Clarify whether the user wants to:
- choose tools to collect the metrics
- add or configure tooling in the repository
- automate metric collection locally or in CI
- run the configured tools and review the outputs

Treat the current working directory as the default target repository unless the user names another path.

### 2. Inspect the Project First

Identify the language, build tool, test framework, and any existing quality tooling before proposing changes.

Check only the files needed, such as:
- build manifests
- test runner configuration
- CI configuration
- coverage or mutation-testing config

Prefer the repository's existing tooling over introducing a new stack.

### 3. Discover Existing Tools First

Look for battle-tested deterministic tools before proposing any custom implementation.

Prefer tools that are:
- well established in the language ecosystem
- deterministic and scriptable
- already used by the repository or its build stack
- able to report the metric directly rather than through an LLM-derived estimate

If multiple viable tools exist:
- prefer the simplest toolchain that covers the needed metrics
- call out any gaps in granularity, runtime, or language support

Only propose a bespoke tool if no suitable existing tool is available.

### 4. Use the Canonical Metric Set

Default to these metrics unless the user asks otherwise:
1. coverage
2. test fan-out
3. mutation score

Use these meanings:
- coverage: how much production code the tests execute
- fan-out: how many distinct production units a test unit depends on
- mutation score: how many injected faults are caught by the tests

Measure fan-out at the smallest meaningful dependency unit supported by the language and tooling:
- class-level for class-centric languages such as Java
- function-level when function dependencies are explicit and analyzable
- module or package level when finer-grained analysis is not reliable

Prefer static fan-out first. Use dynamic fan-out only if the user asks for runtime measurement.

### 5. Propose a Minimal Collection Setup

Before making changes, show:
- which tools you plan to use
- which metrics each tool will produce
- which files or configs you will add or edit
- any assumptions, limitations, or language-specific fallbacks

If no single tool covers all three metrics, combine small purpose-built tools instead of forcing one framework to do everything.

Ask for explicit approval before:
- integrating any tool into the repository
- adding or editing config files
- adding dependencies
- adding CI or automation steps

If no suitable existing tool was found and you want to propose a bespoke tool:
- say clearly why existing tools were insufficient
- show the proposed scope and limitations
- wait for explicit approval before building it

### 6. Implement Carefully

After approval:
- add or update the minimal config needed
- keep commands reproducible and scriptable
- prefer repo-local commands over ad hoc shell steps
- document any language-specific mapping for fan-out
- state any metric approximation explicitly

### 7. Verify the Setup

When possible:
- run the configured metric commands
- report the outputs in a comparable format
- distinguish measured facts from setup guidance or interpretation

Do not treat coverage alone as test quality; use mutation score and fan-out to add context.

## Guardrails

- Never present coverage as a complete proxy for test quality.
- Never claim function-level or method-level fan-out if the chosen tool only supports coarser units.
- Never hide when fan-out is based on a static approximation.
- Never infer any metric through an LLM.
- Never build a bespoke metric tool when a suitable existing deterministic tool is available.
- Never build a bespoke metric tool without explicit user approval.
- Never add heavy or slow tooling without explicit user approval.
- Prefer primary or official tool documentation for setup details.

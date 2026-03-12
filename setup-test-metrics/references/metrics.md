# Test Metrics

This skill uses three primary metrics.

## Coverage

Coverage measures how much production code is executed by the test suite.

Common forms:
- line or statement coverage
- branch coverage
- function or method coverage

Use coverage to find untested areas, not as a complete quality metric.

## Test Fan-out

Fan-out measures how many distinct production units a test unit depends on.

Generic definition:
- fan-out = count of distinct production units depended on by a test unit

Choose the production unit at the smallest meaningful dependency boundary that the language and tooling support reliably.

Examples:
- Java: class-level fan-out
- JavaScript or TypeScript: function-level when imports or exports make function boundaries analyzable, otherwise module-level
- Python: function-level when reliable, otherwise module or class-level

Prefer static fan-out first:
- static fan-out: dependencies inferred from source, bytecode, imports, or other static structure
- dynamic fan-out: dependencies observed while running tests

Use dynamic fan-out only when the user explicitly wants runtime measurement.

## Mutation Score

Mutation testing changes the production code in small ways and reruns the tests.

Mutation score measures how many injected faults are detected by the test suite.

Generic definition:
- mutation score = killed mutants / total non-equivalent mutants

Use mutation score as a stronger signal of test effectiveness than coverage alone.

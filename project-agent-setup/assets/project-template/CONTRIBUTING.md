# Contributing

## Guidelines

Contributors should keep changes scoped, explain the intent of the change clearly, and follow the repository's review and safety expectations.

Before submitting work, run the required validation for the affected code and confirm the change is ready for review.

## Testing

Prefer tests that exercise the code more holistically across clear production boundaries.

When adding tests, default toward sociable tests unless isolated tests are the better fit for the behavior being verified.

Write tests to be expressive and easy to read.

When it fits the test stack and style of the repository, prefer Gherkin-style structure for test scenarios.

## Commit Style

Commits to development branches such as `main` must follow Conventional Commits style and have passing tests.

## Branching And Merging

Branches merging into development branches such as `main` must use merge, not rebase.

Rebase may be used on local branches to squash commits or clean up branch history before merging.

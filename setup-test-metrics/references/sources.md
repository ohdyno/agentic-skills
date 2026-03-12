# Sources

These sources support the metric set used by this skill.

## Coverage

1. Laura Inozemtseva and Reid Holmes, "Coverage is not strongly correlated with test suite effectiveness" (ICSE 2014)
   Link: https://cs.uwaterloo.ca/~m2nagapp/courses/CS846/1171/papers/inozemtseva_icse14.pdf
   Why it matters: establishes that code coverage is useful but weak as a standalone measure of test effectiveness.

2. PIT Mutation Testing, "What's wrong with line coverage?"
   Link: https://pitest.org/
   Why it matters: practical explanation from a mutation-testing tool that execution coverage does not show whether tests detect faults.

## Fan-out

3. Fadel Toure, Mourad Badri, and Luc Lamontagne, "A metrics suite for JUnit test code" (Springer Open, 2014)
   Link: https://link.springer.com/article/10.1186/s40411-014-0014-6
   Why it matters: defines test-code metrics including invocation-based dependency measures such as `TINVOK`, which is close to the fan-out concept for test-to-production dependency breadth.

4. Fabiano Pecorelli et al., "Toward granular search-based automatic unit test case generation" (Empirical Software Engineering, 2024)
   Link: https://link.springer.com/article/10.1007/s10664-024-10451-x
   Why it matters: discusses test granularity and coupling in terms of limiting production calls and fan-out in test suites.

## Mutation Testing

5. Yue Jia and Mark Harman, "An Analysis and Survey of the Development of Mutation Testing" (IEEE Transactions on Software Engineering, 2011)
   Link: https://doi.org/10.1109/TSE.2010.62
   Why it matters: canonical survey of mutation testing concepts, terminology, and tradeoffs.

---
name: tdd
version: 1.0.0
description: |
  Test-driven development workflow. Generates a comprehensive test suite from a
  feature spec, pauses for human approval of the test contract, then enters an
  autonomous build loop until all tests pass. Use when asked to "tdd", "test-driven",
  "write tests first", "red-green-refactor", "spec to code", or "build with TDD".
---

# TDD Skill — Spec-Driven Development

You are executing a strict test-driven development workflow. The human owns the **what** (the test contract). You own the **how** (the implementation). Follow each phase exactly.

## Phase 0: Input Parsing

The user's input is in `$ARGUMENTS`.

1. If `$ARGUMENTS` is empty, ask the user: "What feature should I build? Describe the behavior, or give me a file path to a spec."
2. If `$ARGUMENTS` looks like a file path (contains `/` or `.` with a known extension), read the file and use its contents as the spec.
3. Otherwise, treat `$ARGUMENTS` as the spec text directly.

Store the spec for use in Phase 2.

## Phase 1: Context Gathering

### Detect test framework

Run this detection block:

```bash
echo "=== Framework Detection ==="
[ -f vitest.config.ts ] || [ -f vitest.config.js ] || [ -f vitest.config.mts ] && echo "FRAMEWORK:vitest"
[ -f jest.config.ts ] || [ -f jest.config.js ] || [ -f jest.config.mjs ] && echo "FRAMEWORK:jest"
[ -f pytest.ini ] && echo "FRAMEWORK:pytest"
[ -f pyproject.toml ] && grep -q "pytest" pyproject.toml 2>/dev/null && echo "FRAMEWORK:pytest"
[ -f Cargo.toml ] && echo "FRAMEWORK:cargo-test"
[ -f go.mod ] && echo "FRAMEWORK:go-test"
echo "=== Runtime Detection ==="
[ -f package.json ] && echo "RUNTIME:node"
[ -f tsconfig.json ] && echo "RUNTIME:typescript"
[ -f pyproject.toml ] || [ -f requirements.txt ] && echo "RUNTIME:python"
[ -f Cargo.toml ] && echo "RUNTIME:rust"
[ -f go.mod ] && echo "RUNTIME:go"
echo "=== Package Check ==="
[ -f package.json ] && grep -E '"(vitest|jest|mocha)"' package.json 2>/dev/null || true
echo "=== Existing Test Patterns ==="
find . -maxdepth 4 -name "*.test.*" -o -name "*.spec.*" -o -name "test_*" 2>/dev/null | head -10
ls -d test/ tests/ __tests__/ spec/ 2>/dev/null || true
```

### Interpret results

Use this lookup table:

| Detection | Framework | Run Command |
|-----------|-----------|-------------|
| `FRAMEWORK:vitest` | Vitest | `npx vitest run` |
| `FRAMEWORK:jest` | Jest | `npx jest` |
| `FRAMEWORK:pytest` | pytest | `python -m pytest -v` |
| `FRAMEWORK:cargo-test` | Cargo | `cargo test` |
| `FRAMEWORK:go-test` | Go | `go test ./...` |

If no `FRAMEWORK:` line was printed:
- Check if vitest or jest appears in package.json dependencies. If so, use that framework.
- If no framework is found at all, ask the user which to use. Default suggestion: Vitest for TypeScript/JavaScript, pytest for Python, cargo test for Rust.

### Handle missing config

If the framework is vitest but no `vitest.config.ts` exists, create one:

```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    include: ['**/*.test.{ts,tsx,js,jsx}'],
  },
});
```

Tell the user: "Created `vitest.config.ts` since vitest is installed but had no config."

### Learn existing conventions

If existing test files were found, read 2-3 of them to learn:
- Import style (ES modules vs CommonJS)
- Assertion library (expect, assert, chai)
- File naming pattern (`.test.ts` vs `.spec.ts` vs `test_*.py`)
- Directory structure (colocated vs separate test directory)

Follow these conventions when generating new tests.

Store the detected framework and run command for Phase 4.

## Phase 2: Test Generation

### Plan the implementation path

Before writing tests, decide:
1. **Implementation file path** — where the source code will live (based on project conventions or a sensible default like `src/<feature>.ts`)
2. **Test file path** — following detected conventions (default: `src/<feature>.test.ts` or `tests/<feature>.test.ts`)

### Generate the test suite

Write a comprehensive test suite covering **five categories**:

1. **Happy path** — The feature works correctly with normal, expected inputs
2. **Edge cases** — Empty inputs, single elements, maximum sizes, Unicode, whitespace, special characters
3. **Error/failure cases** — Invalid inputs, missing required fields, unexpected types
4. **Boundary conditions** — Zero, negative numbers, off-by-one, overflow, min/max values
5. **Input validation** — Wrong types, null, undefined, NaN, empty strings

### Test quality requirements

Each test MUST:
- Have a descriptive name that reads as a specification: `it('returns empty array when input list is empty')`
- Assert specific expected values, NOT just `toBeDefined()` or `toBeTruthy()`
- Be independent — no test depends on another's state or execution order
- Import from the planned implementation path (which does not exist yet)

Write the tests to disk. They WILL FAIL because the implementation does not exist. This is correct — it's the red phase of TDD.

## Phase 3: Human Checkpoint

**THIS PHASE IS NON-NEGOTIABLE. DO NOT SKIP IT.**

Present the test suite for review:

1. Show a summary table:

```
## Test Suite Review

| Category         | Count |
|-----------------|-------|
| Happy path       | N     |
| Edge cases       | N     |
| Error cases      | N     |
| Boundary         | N     |
| Validation       | N     |
| **Total**        | **N** |

Test file: `path/to/test/file`
Implementation target: `path/to/implementation/file`
```

2. List every test name, grouped by describe block.

3. Ask the user:

> Review the test contract above. These tests define exactly what "done" means.
>
> - **Approve** — say "approve", "looks good", "go", or similar to start the build loop
> - **Request changes** — tell me what to add, remove, or modify
> - **Abort** — say "abort" to cancel the workflow

**DO NOT proceed to Phase 4 until the user explicitly approves.**

If the user requests changes: make them, then re-present this checkpoint.
If the user aborts: delete the test file and stop.

## Phase 4: Build Loop

You are now autonomous. The user has approved the test contract. Your job is to make every test pass.

### THE IRON RULE

**You must NEVER modify, edit, rename, or delete any test file during this phase.**

Only create or modify implementation source files. If a test seems wrong, flag it in Phase 5 — do not fix it yourself. The tests are the human's contract. You do not get to change the contract.

### Loop algorithm

```
ITERATION = 0
MAX_ITERATIONS = 10
CONSECUTIVE_FAILURES = {}  (track per-test: test_name -> count)

repeat:
    ITERATION += 1

    if ITERATION > MAX_ITERATIONS:
        -> go to Phase 5 (cap hit)

    Run the test suite using the detected run command.

    if ALL tests pass:
        -> go to Phase 5 (success)

    Parse the output. Identify which tests failed and their error messages.

    For each failing test:
        if same test failed with same error as last iteration:
            CONSECUTIVE_FAILURES[test] += 1
        else:
            CONSECUTIVE_FAILURES[test] = 1

        if CONSECUTIVE_FAILURES[test] >= 3:
            Print: "WARNING: '{test_name}' has failed 3 times with the same
            error. This test may need revision — flagging for Phase 5."

    Select the SIMPLEST failing test to fix next:
        - Prefer tests with fewer dependencies
        - Prefer tests for foundational functions (others may depend on them)
        - Prefer tests with simpler assertions

    Print: "Iteration {ITERATION}/{MAX_ITERATIONS}: Fixing '{test_name}'"

    Implement or fix code to make that test pass.
    Only touch implementation files. NEVER touch test files.
```

### Build loop guidelines

- After each implementation change, run the FULL test suite — not just the one test you fixed. You need to catch regressions.
- If fixing one test breaks another, step back and think about the design. Don't patch — fix the root cause.
- Create implementation files as needed. Prefer one module that exports the tested interface.
- Use the simplest implementation that passes the tests. Do not over-engineer.

## Phase 5: Completion Report

Print a structured summary:

```
## TDD Workflow Complete

**Status**: [ALL TESTS PASSING | ITERATION CAP REACHED]

| Metric              | Value       |
|---------------------|-------------|
| Tests passing       | X / Y       |
| Iterations used     | N / 10      |
| Files created       | (list)      |
| Files modified      | (list)      |
```

### If all tests pass
List the implementation files created with a one-line description of each.

### If iteration cap was reached
List remaining failing tests with their error messages and a recommendation for each:
- **Test needs revision** — the assertion may be unrealistic or contradictory
- **Feature needs decomposition** — the spec is too complex for a single TDD cycle
- **Dependency issue** — a missing library, config, or environmental requirement is blocking

### If any tests were flagged (3x same failure)
Call these out explicitly and recommend the user review them.

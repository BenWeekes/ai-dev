---
description: Implement a task using test-driven development
---

Implement the following task using strict TDD. Follow the 6-step cycle exactly.

**Task:** $ARGUMENTS

## The TDD cycle

### Step 1: Read acceptance criteria

Find the acceptance criteria for this task. Check:

- The plan in `docs/plans/` (if one exists)
- The task description above
- Any linked issues or PRs

If no acceptance criteria exist, define them before writing any code.

### Step 2: Write tests

Write test(s) that encode the acceptance criteria. Each criterion becomes at least one test case.

### Step 3: Verify red

Run the tests. They **MUST fail**. A test that passes before implementation tests nothing.

If any test passes at this step, either:

- The feature already exists (verify and skip)
- The test is wrong (fix the test)

Do not proceed to step 4 until all new tests fail.

### Step 4: Implement

Write the minimum code to make the tests pass. No more, no less.

### Step 5: Verify green

Run the tests. All tests **MUST pass** — both the new tests and all existing tests.

If a test fails: **fix the code, not the test.** Weakening a test to match broken code defeats the purpose.

### Step 6: Commit

Stage and commit the implementation with passing tests.

## Rules

- **Never skip verify-red** (step 3). This is the most important step.
- **Fix the code, not the test.** When tests fail after implementation, the code is wrong.
- **Task is not done until zero failures.** No skipped tests, no ignored assertions.
- **One cycle per behavior.** If the task has multiple acceptance criteria, run the full 6-step cycle for each one.

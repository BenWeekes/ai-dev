---
description: Implement a task using test-driven development
---

Implement the following task using strict TDD. Follow the 6-step cycle exactly.

**Task:** $ARGUMENTS

## The TDD cycle

### Step 1: Read acceptance criteria

Find the acceptance criteria for this task. Check:

- The spec in `docs/plans/` (if one exists)
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

## Anti-rationalization table

When tempted to skip or weaken tests, find your excuse below. The rebuttal is the correct action.

| Excuse                                                     | Rebuttal                                                                    |
| ---------------------------------------------------------- | --------------------------------------------------------------------------- |
| "This is too simple to need a test."                       | Simple code breaks too. Write the test — it takes 30 seconds.               |
| "I'll add tests after I get it working."                   | That's not TDD. The test comes first or it doesn't come at all.             |
| "The test is wrong, not the code."                         | Re-read the spec. If the test matches the requirement, fix the code.        |
| "Testing this would require too much setup."               | Complex setup means the code needs better boundaries. Refactor, then test.  |
| "I just need to make this one small change without tests." | Small untested changes compound into large untested systems. No exceptions. |

> **NEVER weaken a test to make it pass.** If the test matches the requirement and the code doesn't pass, the code is wrong. Changing the test to match broken code is the single most common way agents introduce bugs.

## Rules

- **Never skip verify-red** (step 3). This is the most important step.
- **Fix the code, not the test.** When tests fail after implementation, the code is wrong.
- **Task is not done until zero failures.** No skipped tests, no ignored assertions.
- **One cycle per behavior.** If the task has multiple acceptance criteria, run the full 6-step cycle for each one.
- **NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.** Before declaring a task complete, run the full test suite and include the passing output. Stale or remembered results do not count.

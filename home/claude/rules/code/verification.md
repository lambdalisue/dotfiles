# Done Means Verified by Running the Change

A change is done when you have **run it** and can show what happened. Passing
unit tests are evidence, not proof: they can pass while the feature is broken,
because the test was written with the same misunderstanding as the code.

## Verify

1. Run the project's cheap deterministic checks first — format, lint, type
   check, tests (the `just` / `make` / `npm` targets the project defines).
2. Then exercise the change the way a user would: run the CLI, start the app
   and drive it (the `run` skill, Claude in Chrome), call the endpoint, apply
   the config and observe it take effect. Prefer a project's `verify` skill
   when one exists.
3. Report what you ran and what it showed. When something was not verified,
   say so and say why — "not verified: needs a device" is a valid report;
   implying it was checked is not.

## Fixing a failing check

- **Three rounds, then ask.** If the same check still fails after three fix
  attempts, stop and bring the user the failure and what you tried.
- **Never weaken the judge.** Do not skip, delete or loosen a test, add
  `sleep` / retries, widen a lint `allow`, or edit CI and hook config to get a
  change through. If the check itself is wrong, say so and ask first.
- **A flaky test is a bug.** Re-running until green is not a fix. Find the
  cause; if you cannot, report it rather than retrying.

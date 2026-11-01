---
description: Fix the project's build/compile/lint errors until it's clean, without papering over them.
argument-hint: [optional context, e.g. "after the dependency bump"]
---

Fix the current build/compile/lint errors for this project. $ARGUMENTS

1. Detect how this project builds (check `package.json` scripts, a `Makefile`, or ask if neither
   exists) and run it to capture the actual error output — don't guess at errors from reading code.
2. Fix errors one root cause at a time, re-running the build after each fix. Don't silence a type
   error, lint rule, or warning just to make the build pass — fix the actual cause, or tell the user
   plainly if a fix needs their input (e.g. a genuine breaking API change upstream).
3. Re-run the full build/lint/typecheck once more at the end to confirm everything is clean, not
   just the error you were chasing.
4. If the project has the `tdd-workflow` skill and tests exist, run them too before declaring done —
   a clean build with broken tests isn't a fixed build.

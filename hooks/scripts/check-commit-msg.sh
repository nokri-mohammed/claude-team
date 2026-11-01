#!/usr/bin/env bash
# PostToolUse hook (after `git commit`): warn, never block, if the just-made commit's
# subject doesn't follow Conventional Commits. Reads the message back from git itself
# (git log), not the raw bash command, so it's correct regardless of how the commit was
# authored — -m, a heredoc body, or an editor.
msg=$(git log -1 --format=%s 2>/dev/null)
pattern='^(feat|fix|chore|docs|refactor|perf|test|build|ci|revert)(\([a-z0-9_.-]+\))?!?: '

if [ -z "$msg" ] || echo "$msg" | grep -qE "$pattern"; then
  echo '{}'
else
  jq -n --arg m "$msg" \
    '{systemMessage: ("Commit message \"" + $m + "\" does not follow Conventional Commits (feat/fix/chore/docs/refactor/perf/test/build/ci/revert) — release tooling in HUB.md depends on this.")}'
fi

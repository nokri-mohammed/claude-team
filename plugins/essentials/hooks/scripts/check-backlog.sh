#!/usr/bin/env bash
# Stop hook: block finishing a task unless docs/backlog.md has an entry dated today.
# Only checks that today's date appears somewhere in the file, not that the specific
# line is new: a stateless, good-enough check without tracking session snapshots.
TODAY=$(date +%Y-%m-%d)

if [ -f docs/backlog.md ] && ! grep -q "$TODAY" docs/backlog.md; then
  jq -n --arg today "$TODAY" \
    '{decision: "block", reason: ("docs/backlog.md has no entry dated " + $today + ", add one before finishing.")}'
else
  echo '{}'
fi

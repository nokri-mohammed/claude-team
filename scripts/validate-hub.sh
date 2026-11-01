#!/usr/bin/env bash
# Checks the hub against the rules established during its own audit:
# - every SKILL.md stays under Anthropic's 500-line guidance
# - every agent declares an explicit `tools:` allowlist (no silent "inherit everything")
# - no skill points at a references/*.md file that doesn't exist
# - every plugin.json, marketplace.json, .mcp.json, .versionrc.json, package.json, and
#   hooks.json parses as valid JSON
# - every plugin folder passes `claude plugin validate`
set -u
cd "$(dirname "$0")/.."
fail=0

echo "== SKILL.md line limit (500) =="
for f in plugins/*/skills/*/SKILL.md; do
  lines=$(wc -l < "$f")
  if [ "$lines" -gt 500 ]; then
    echo "FAIL: $f has $lines lines (limit 500)"
    fail=1
  fi
done

echo "== agent tools: field present =="
for f in plugins/*/agents/*.md; do
  if ! grep -q "^tools:" "$f"; then
    echo "FAIL: $f has no explicit tools: field"
    fail=1
  fi
done

echo "== dangling references/*.md pointers =="
for f in plugins/*/skills/*/SKILL.md; do
  dir=$(dirname "$f")
  grep -o 'references/[a-zA-Z0-9_.-]*\.md' "$f" 2>/dev/null | while read -r ref; do
    if [ ! -f "$dir/$ref" ]; then
      echo "FAIL: $f -> $ref (missing)"
      exit 1
    fi
  done || fail=1
done

echo "== JSON validity =="
for f in package.json .versionrc.json \
         .claude-plugin/marketplace.json \
         plugins/*/.claude-plugin/plugin.json \
         plugins/*/.mcp.json \
         plugins/*/hooks/hooks.json; do
  if [ -f "$f" ] && ! jq empty "$f" >/dev/null 2>&1; then
    echo "FAIL: $f is not valid JSON"
    fail=1
  fi
done

echo "== claude plugin validate (each plugin) =="
if command -v claude >/dev/null 2>&1; then
  for d in plugins/*/; do
    if ! claude plugin validate "$d" >/tmp/validate-hub-plugin.out 2>&1; then
      echo "FAIL: claude plugin validate $d"
      cat /tmp/validate-hub-plugin.out
      fail=1
    fi
  done
  rm -f /tmp/validate-hub-plugin.out
else
  echo "SKIP: claude CLI not on PATH"
fi

if [ "$fail" -eq 0 ]; then
  echo "== all checks passed =="
else
  echo "== one or more checks failed =="
fi
exit $fail

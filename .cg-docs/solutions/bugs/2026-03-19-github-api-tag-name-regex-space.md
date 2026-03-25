---
date: 2026-03-19
title: "GitHub API: tag_name JSON field has a space after the colon"
category: "bugs"
language: "Stata"
tags: [github-api, regexm, json-parsing, tag_name, pip_githubquery, silent-failure]
root-cause: "Regex 'tag_name\":\"' never matches real GitHub API responses because the actual format is 'tag_name\": \"' (space after colon)"
severity: "P1"
test-written: "yes"
fix-confirmed: "yes"
---

# GitHub API: `tag_name` JSON Field Has a Space After the Colon

## Problem

`pip_githubquery` always returned an empty `latestversion` even when the GitHub API was reachable. No error was thrown — the program exited silently as if the API were down.

## Root Cause

The regex used to extract the tag from the JSON response assumed no space between the colon and the value:

```stata
// BROKEN — never matches real GitHub API
if regexm(scalar(`gh_json'), `""tag_name":"([^"]+)""') {
    local latestversion = regexs(1)
}
```

The actual GitHub API returns JSON with a **space after the colon**:

```json
{"tag_name": "v0.11.0", "prerelease": false, ...}
```

Because the regex required `"tag_name":"` (no space), it never matched, `latestversion` remained empty, and the program exited on the next guard:

```stata
if ("`latestversion'" == "") exit 1   // API unreachable - skip silently
```

This made every version check silently fail, so users never saw update notifications.

## Confirmation Test

```stata
// tests/test_pip_gh_returns.do — Tests 8 & 9
// Test 8: new regex handles space
local json `"{"tag_name": "v0.11.0","prerelease":false}"'
assert regexm(`"`json'"', `""tag_name": *"([^"]+)""')
assert regexs(1) == "v0.11.0"

// Test 9: old regex (no space) does NOT match — documents the bug
local json `"{"tag_name": "v0.11.0","prerelease":false}"'
assert !regexm(`"`json'"', `""tag_name":"([^"]+)""')
```

## Fix

Use `*` in the regex to allow zero or more spaces between `:` and `"`:

```stata
// FIXED — matches with or without space
if regexm(scalar(`gh_json'), `""tag_name": *"([^"]+)""') {
    local latestversion = regexs(1)
}
```

The `*` quantifier applies to the space character, so `: *"` matches `:"` (no space) and `": "` (one space), making the regex robust to minor formatting variations in the API response.

## Prevention

- When parsing JSON with `regexm`, always check whether the key-value separator format is exact. HTTP APIs routinely include spaces for readability; RFC 8259 explicitly permits whitespace around structural characters.
- Use `: *` (not `:`) between a JSON key and its quoted value in all `regexm` patterns.
- Write a test that parses a literal JSON string matching the real API format, distinct from a test that verifies the logic after extraction. This would have caught this immediately.
- The same issue applies to any JSON field: `"prerelease": false` not `"prerelease":false`.

## Related

- `.cg-docs/solutions/performance-issues/2026-03-19-github-api-releases-latest.md` — the `pip_githubquery` rewrite where this regex was first introduced (code example in that doc had the old broken regex; updated separately)
- `.cg-docs/solutions/bugs/2026-03-19-stata-exit-vs-exit1-stale-rclass.md` — the companion issue: even with the regex fixed, bare `exit` masked the failure

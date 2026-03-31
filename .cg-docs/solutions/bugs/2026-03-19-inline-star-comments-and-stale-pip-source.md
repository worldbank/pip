---
date: 2026-03-19
title: "Inline * comments and stale pip_source global cause runtime errors"
category: "bugs"
type: "bug"
language: "Stata"
tags: [stata-comments, inline-comment, pip_gh, pip_utils, pip_source, refactor-leftover]
root-cause: "Bulk // → * comment replacement broke inline comments; deleted program left orphan global reference"
severity: "P1"
test-written: "yes"
fix-confirmed: "yes"
---

# Inline * comments and stale pip_source global cause runtime errors

## Symptom

Two errors after the refactor session (commits 676ae7f–bafac61):

1. **pip_gh.ado** — Lines like `if (_rc) exit   * pip not found` threw `r(198)` (`*this invalid name`) because Stata treated `*` as multiplication, not a comment.

2. **pip_utils finalmsg** — `noi pip_${pip_source} msg` in `pip_utils_final_msg` threw `r(199)` (`command pip_NotInstalled is unrecognized`) because `pip_source` was a stale global from the deleted `pip_update.ado`, and `pip_gh.ado` no longer has a `msg` subcommand.

## Root Cause

**Bug 1**: A prior session globally standardized comments from `//` to `*` in `pip_gh.ado`. In Stata, `*` is only a comment when it is the **first non-whitespace character on a line**. When `*` appears after code (e.g. `exit   * text`), Stata parses it as a multiplication operator or variable name, producing a syntax error.

**Bug 2**: The refactor deleted `pip_update.ado` (which set `$pip_source`) and removed the `msg` subcommand from `pip_gh.ado`. But `pip_utils_final_msg` in `pip_utils.ado` still called `noi pip_${pip_source} msg`. The user's `pip_setup.do` retained the stale value `"NotInstalled"`, resolving to `pip_NotInstalled msg` → unrecognized command.

## Reproduction Test

**Test 1** — `tests/test_bug_inline_star_comment.do`:
Confirms that `local _x = 1   * text` fails with `_rc != 0` (inline `*` is not a comment), while `local _x = 1   // text` succeeds with `_rc == 0`.

**Test 2** — `tests/test_bug_pip_source_stale.do`:
Reads `pip_utils.ado` line by line and asserts no line contains the string `pip_source`.

## Fix

**pip_gh.ado** — Replaced 4 inline `*` comments with `//`:
```stata
// Before (broken):
if (_rc) exit   * pip not found - skip silently
if (_rc) exit   * can't read file - skip silently
if ("`latestversion'" == "") exit   * API unreachable - skip silently
else exit   * tag is not a valid semver - skip silently

// After (fixed):
if (_rc) exit   // pip not found - skip silently
if (_rc) exit   // can't read file - skip silently
if ("`latestversion'" == "") exit   // API unreachable - skip silently
else exit   // tag is not a valid semver - skip silently
```

**pip_utils.ado** — Removed the dead `pip_source` block from `pip_utils_final_msg`:
```stata
// Removed:
	* Install alternative version
	if ("${pip_old_session}" == "") {
		noi pip_${pip_source} msg
	}
```

## Lessons Learned

1. **Never use `*` for inline comments in Stata.** The `*` comment token is only valid as the first non-whitespace character on a line. Always use `//` for inline (end-of-line) comments. This is a fundamental Stata syntax rule that automated find-and-replace must respect.

2. **When deleting a program, grep for all references to it and its side effects.** Deleting `pip_update.ado` orphaned the `$pip_source` global and the `pip_${pip_source} msg` call. A search for `pip_source` across all `.ado` files would have caught this immediately.

3. **Anti-pattern: bulk comment-style normalization without syntax awareness.** Regex-based `// → *` replacement across Stata files is inherently unsafe. If comment normalization is desired, it must distinguish start-of-line positions from inline positions.

## Related

- `.cg-docs/solutions/bugs/2026-03-19-stata-exit-vs-exit1-stale-rclass.md` — the thorough review of `pip_gh.ado` that followed this bug fix revealed that bare `exit` (used in the fixed code) returns `_rc=0`, causing the caller to consume stale `r()` values
- `.cg-docs/solutions/bugs/2026-03-19-github-api-tag-name-regex-space.md` — another silent failure found in the same review: the regex never matched real GitHub API responses

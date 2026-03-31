---
date: 2026-03-19
title: "Stata: bare exit in a program returns _rc=0, causing callers to consume stale r() values"
category: "bugs"
language: "Stata"
tags: [exit, rclass, capture, _rc, r-class, stale-results, pip_gh, pip_new_session, silent-failure]
root-cause: "exit (no argument) returns _rc=0 like a successful completion; callers using 'if (_rc == 0)' cannot distinguish a real success from a silent skip, so they read r() values set by whatever ran before"
severity: "P1"
test-written: "yes"
fix-confirmed: "yes"
---

# Stata: Bare `exit` Returns `_rc=0`, Causing Callers to Consume Stale `r()` Values

## Problem

`pip_gh` had multiple "skip silently" paths that used bare `exit`:

```stata
if (_rc) exit          // pip not found — skip silently
if (_rc) exit          // can't read file — skip silently  
if ("`latestversion'" == "") exit   // API unreachable — skip silently
```

`pip_new_session` called `pip_gh` under `capture` and then checked `_rc`:

```stata
capture pip_gh
local update_available "`r(update_available)'"
local latest_version   "`r(latest_version)'"
if (_rc == 0 & "`update_available'" == "1") {
    di as result "Update available: `latest_version'"
    // ...
}
```

When `pip_gh` skipped silently via `exit`, the user saw a **false update notification** (or read wrong version strings) from a completely unrelated previous command.

## Root Cause

`exit` with no argument is equivalent to `exit 0`. When a program is invoked via `capture prog`, `_rc` is set to the exit code, so `exit 0` returns `_rc=0` — identical to a **successful completion**.

The caller `pip_new_session` had no way to distinguish "pip_gh ran successfully and filled r()" from "pip_gh decided to skip and left r() untouched". In the skip case, `r(update_available)` (and friends) contained whatever `r()` was set by the previous command in that Stata session — completely unrelated values.

## Fix

**In `pip_gh.ado`**: Use `exit 1` on every "skip silently" path:

```stata
if (_rc) exit 1          // pip not found — skip silently (exit 1 ≠ success)
if (_rc) exit 1          // can't read file — skip silently
if ("`latestversion'" == "") exit 1   // API unreachable — skip silently
else exit 1              // pre-release or non-semver tag — skip silently
```

Exit code `1` is a non-zero, non-error code that means "intentionally skipped". It propagates as `_rc=1` through `capture`.

**In `pip_new_session.ado`**: Guard the `r()` reads with both a return-code check AND emptiness checks:

```stata
capture pip_gh
local update_available "`r(update_available)'"
local latest_version   "`r(latest_version)'"
local install_cmd      "`r(install_cmd)'"

* exit 1 from pip_gh means 'skipped silently' (not an error)
if (_rc == 0 & "`update_available'" == "1" ///
     & "`latest_version'" != ""            ///
     & "`install_cmd'" != "") {
    di as result "Update available: `latest_version'"
    di as result "Run: `install_cmd'"
}
```

The emptiness checks (`!= ""`) catch the case where `_rc` returned 0 unexpectedly but `r()` was not properly populated.

## The Contract for Skip-vs-Success Exit Codes

| `exit N` | `_rc` seen by caller | Meaning |
|----------|---------------------|---------|
| `exit` or `exit 0` | `0` | **Successful completion** — `r()` is valid |
| `exit 1` | `1` | **Intentionally skipped** — `r()` may be stale |
| `exit 198` | `198` | Syntax error |
| `error N` | `N` | Error — message displayed (unless `capture` used) |

Use exit codes 1–9 for intentional skips that the caller should handle gracefully. Reserve `error N` for genuine failures that should propagate to the user.

## Confirmation Test

```stata
// tests/test_pip_gh_silent_failures.do — Test 1
// After pip_gh skips (due to no network/no version file), _rc should be 1

capture pip_gh
local rc_gh = _rc

if (`rc_gh' == 0) {
    // If it returned 0, r(update_available) MUST be non-empty
    assert "`r(update_available)'" != ""
    assert "`r(update_available)'" == "0" | "`r(update_available)'" == "1"
}
else {
    // _rc != 0 means silently skipped — acceptable
    di as result "pip_gh skipped silently (_rc=`rc_gh')"
}
```

## Prevention

- In any rclass program that has "skip silently" paths invoked via `capture`, use **`exit 1`** (not bare `exit`) to signal skip.
- Always guard `r()` macro reads with **both** a return-code check **and** emptiness checks on the critical macros. Never rely on `_rc == 0` alone.
- Document the skip exit code in a comment: `// exit 1 = intentionally skipped, not an error`.
- Anti-pattern: reading `r()` after `capture prog` without checking `_rc` — the `r()` stack is **global** and contains whatever was last set by any command.

## Related

- `.cg-docs/solutions/bugs/2026-03-19-github-api-tag-name-regex-space.md` — companion P1 bug in the same function (regex never matched, so pip_gh always skipped)
- `.cg-docs/solutions/bugs/2026-03-19-inline-star-comments-and-stale-pip-source.md` — original bug session that led to this thorough review

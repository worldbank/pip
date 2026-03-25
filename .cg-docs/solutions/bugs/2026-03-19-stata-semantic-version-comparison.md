---
date: 2026-03-19
title: "Stata Semantic Version Comparison: String Concatenation Fails with Multi-Digit Components"
category: "bugs"
language: "Stata"
tags: [semver, version-comparison, string-concatenation, numeric, pip_gh]
root-cause: "Concatenating version components as strings produces numerically wrong comparisons when any component is >= 10"
severity: "P1"
---

# Stata Semantic Version Comparison: String Concatenation Fails with Multi-Digit Components

## Problem

Version comparison logic of the form:

```stata
local current = `crrMajor'`crrMinor'`crrPatch'
local last    = `lastMajor'`lastMinor'`lastPatch'
local update_available = (`last' > `current')
```

silently produces wrong results when minor or patch numbers reach 10+.

**Example failure**:
- v0.10.0 → `0100` (numeric value: 100)
- v0.9.10 → `0910` (numeric value: 910)
- Result: `910 > 100` → code concludes v0.9.10 is *newer* than v0.10.0 ✗

The code appears to work for years because most packages stay below minor/patch 10. The failure is completely silent — no error, just wrong update notifications (or suppressed ones).

## Root Cause

Stata macro concatenation (`\`a'\`b'\`c'`) is string concatenation, not arithmetic. The resulting string is then coerced to a number, but without zero-padding, the positional weight of each component is not preserved. A 2-digit minor (10–99) shifts all lower components left by one digit, making the resulting integer larger than any 1-digit minor version regardless of actual version ordering.

The same failure occurs when major reaches 10, or whenever any component crosses a digit boundary.

## Solution

Use weighted arithmetic so each component occupies a fixed positional range:

```stata
* In pip_gh.ado (and anywhere version comparison is needed)
local current_cmp = `crrMajor' * 1000000 + `crrMinor' * 1000 + `crrPatch'
local last_cmp    = `lastMajor' * 1000000 + `lastMinor' * 1000 + `lastPatch'
local update_available = cond(`last_cmp' > `current_cmp', "1", "0")
```

This supports major up to 999, minor up to 999, and patch up to 999 — safely beyond any realistic version range.

Return `update_available` as an explicit string `"1"`/`"0"` and document the contract at the call site:

```stata
* r(update_available) is returned as string "1"/"0" (r-class macros are always strings)
return local update_available "`update_available'"
```

## Prevention

- **Never** concatenate version parts as raw strings for numeric comparison in Stata.
- Use `Major * 1000000 + Minor * 1000 + Patch` as the canonical pattern for semver comparison.
- Always test version comparison with at least one component >= 10 (e.g., minor = 10 or 11).
- Suggested test cases to include in `tests/`:

```stata
* tests/test_version_compare.do
* Verify weighted comparison is correct for double-digit components

* Case 1: 0.10.0 should be newer than 0.9.9
assert (0 * 1000000 + 10 * 1000 + 0) > (0 * 1000000 + 9 * 1000 + 9)

* Case 2: 0.9.10 should be older than 0.10.0
assert (0 * 1000000 + 9 * 1000 + 10) < (0 * 1000000 + 10 * 1000 + 0)

* Case 3: 1.0.0 should be newer than 0.99.99
assert (1 * 1000000 + 0 * 1000 + 0) > (0 * 1000000 + 99 * 1000 + 99)
```

## Related

- `.cg-docs/solutions/bugs/2026-03-19-stata-scalar-drop-outside-capture.md` — another silent-failure pattern in `pip_gh.ado`
- `.cg-docs/solutions/performance-issues/2026-03-19-github-api-releases-latest.md` — the API rewrite that accompanied this fix

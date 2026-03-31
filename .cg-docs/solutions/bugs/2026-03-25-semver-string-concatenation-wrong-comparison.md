---
date: 2026-03-25
title: "Semver string concatenation gives wrong comparison for multi-digit version components"
category: "bugs"
language: "Stata"
tags: [stata, semver, version-comparison, regex, numeric]
root-cause: "Concatenating Major, Minor, Patch into a single string (e.g. '0910') produces lexicographic ordering that is wrong when any component has more than one digit (0.9.10 > 0.10.0 is false but '0910' > '0100' is true)"
severity: "P1"
---

# Semver string concatenation gives wrong comparison for multi-digit version components

## Problem

`pip_gh.ado` compared installed vs. latest GitHub versions by concatenating the
three semver components into a single string and comparing with `>`:

```stata
// BUGGY — wrong for multi-digit components
local current = "`crrMajor'`crrMinor'`crrPatch'"   // e.g. "0910"
local latest  = "`lastMajor'`lastMinor'`lastPatch'" // e.g. "0100"
if ("`latest'" > "`current'") { ... }               // "0910" > "0100" → true (WRONG)
```

With version `0.9.10` installed and `0.10.0` on GitHub, the comparison
incorrectly concluded that `0.10.0` was **older** than `0.9.10`, suppressing
update notifications.

## Root Cause

String comparison is lexicographic: `"0910"` sorts after `"0100"` because `'9'`
> `'1'` at character position 2. For single-digit components this coincidentally
matches numeric order, but breaks as soon as any component reaches 10 or more.

## Solution

Use **weighted numeric arithmetic** to convert the three-part version into a
single comparable integer:

```stata
// CORRECT — weighted comparison
local current_cmp = `crrMajor' * 1000000 + `crrMinor' * 1000 + `crrPatch'
local last_cmp    = `lastMajor' * 1000000 + `lastMinor' * 1000 + `lastPatch'
if (`last_cmp' > `current_cmp') { ... }
```

The weight `1000000 / 1000 / 1` means each component may range 0–999 before
overflow. Document the constraint:

```stata
* Constraint: each semver component must be < 1000 for weighting to hold.
```

Alternatively, use a three-level lexicographic compare (Major first, then Minor,
then Patch) if components could exceed 999, but that requires more branching.

## Prevention

- Never compare version strings by raw concatenation or string `>` / `<`.
- Always convert semver to a weighted integer before numeric comparison.
- When parsing semver from a regex, validate the result with
  `^([0-9]+)\.([0-9]+)\.([0-9]+)$` anchored at both ends (`^` and `$`) to
  reject pre-release tags (e.g. `1.0.0-beta`) that would silently produce
  wrong component values.
- Regression test: covered in [tests/unit/test_pip_gh_returns.do](../../../../tests/unit/test_pip_gh_returns.do)

## Related

- [2026-03-25-github-api-regex-space.md](./2026-03-25-github-api-regex-space.md) — related GitHub API parsing bug in the same function

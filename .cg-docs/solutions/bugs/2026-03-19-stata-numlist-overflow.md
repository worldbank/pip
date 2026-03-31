---
date: 2026-03-19
title: "Stata numlist overflow silently truncates iteration at ~4100 items"
category: "bugs"
language: "Stata"
tags: [numlist, forvalues, foreach, loop, truncation, silent-failure, pip_utils, frame2locals]
root-cause: "numlist '1/N' overflows Stata's numlist limit when N > ~4100, silently generating a shorter list than requested and causing foreach to iterate over fewer rows than exist in the frame"
severity: "P2"
test-written: "no"
fix-confirmed: "yes"
---

# Stata `numlist` Overflow Silently Truncates Iteration at ~4100 Items

## Problem

`pip_utils_frame2locals` iterated over frame rows using:

```stata
numlist "1/`c(N)'"
foreach ob of numlist `r(numlist)' {
    local val`ob' = var[`ob']
}
```

For frames with more than ~4100 rows, this produced **wrong output without an error** — only the first ~4100 locals were populated. The frame had more rows, but the loop silently stopped early.

## Root Cause

Stata's `numlist` command has an internal limit on the number of elements it can generate. When `c(N)` exceeds this limit (approximately 4,100 items, though the exact threshold depends on Stata version and element size), `numlist "1/N"` either errors or — worse — silently generates a truncated list.

Using `foreach ob of numlist \`r(numlist)''` then iterates only over the truncated list, so `local val_N` for rows beyond the limit are never set. The calling code receives no warning.

This is particularly dangerous in utility functions that convert frame contents to locals, because callers assume all rows are represented.

## Fix

Replace `numlist` + `foreach` with `forvalues`, which has no such limit:

```stata
// Before (broken for N > ~4100):
numlist "1/`c(N)'"
foreach ob of numlist `r(numlist)' {
    local val`ob' = var[`ob']
}

// After (no limit):
forvalues ob = 1/`c(N)' {
    local val`ob' = var[`ob']
}
```

`forvalues` is a native loop construct handled by Stata's parser, not a macro-expansion step. It handles any valid integer range regardless of size.

## Prevention

- **Never use `numlist` to generate large integer sequences for iteration.** `numlist` is designed for user-facing number lists (e.g., option parsing, display). Use `forvalues` for any programmatic integer loop.
- As a rule: if the loop variable is a simple integer counter (1, 2, 3, ..., N), always prefer `forvalues i = 1/N`.
- Reserve `foreach ... of numlist` for cases where the numlist is externally provided (e.g., parsed from user input) and is known to be small.
- The failure is **silent** — always prefer constructs that error loudly over ones that truncate silently.

## Related

- `.cg-docs/solutions/testing-patterns/2026-03-19-stata-test-suite-patterns.md` — how to write regression tests that would catch silent truncation

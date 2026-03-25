---
date: 2026-03-19
title: "Stata: extract helper programs to eliminate duplicated boilerplate patterns"
category: "testing-patterns"
language: "Stata"
tags: [DRY, helper-program, pip_setup, findfile, boilerplate, refactoring, pip_setup_ensure]
root-cause: "Multi-step boilerplate sequences (find file, create if missing, use result) repeated verbatim at multiple call sites; a future fix to one copy silently leaves the others broken"
severity: "P2"
---

# Stata: Extract Helper Programs to Eliminate Duplicated Boilerplate Patterns

## Problem

`pip_setup.ado` contained the following three-line pattern in **three separate places**:

```stata
cap findfile "pip_setup.do"
if (_rc)  pip_setup_create   // create if not found
<use r(fn) from findfile>
```

The pattern also appeared inline within the larger `qui { ... }` block, making it easy to miss. Any future fix to the creation or lookup logic (e.g. changing the filename, adding a path hint, handling a permission error) required identifying and updating all three sites.

## Root Cause

Classic DRY (Don't Repeat Yourself) violation. The boilerplate was short enough that copy-pasting felt acceptable at each site, but the three copies diverged over time: one used `cap`, another used `capture`, and the `return` handling after each was slightly different.

## Solution

Extract into a dedicated helper program that encapsulates the pattern once:

```stata
program define pip_setup_ensure, rclass
    // Ensures pip_setup.do exists; creates it if not found.
    // Returns r(fn) with the absolute path to pip_setup.do.
    cap findfile "pip_setup.do"
    if (_rc) pip_setup_create
    return local fn = "`r(fn)'"
end
```

Then replace every call site:

```stata
// Before (3 copies of the same pattern):
cap findfile "pip_setup.do"
if (_rc)  pip_setup_create
<use r(fn)>

// After (single call at each site):
pip_setup_ensure
<use r(fn)>
```

## When to Extract a Helper Program in Stata

Extract when **all three** of the following are true:

1. **The pattern appears 2+ times** — even if they look identical today, divergence is guaranteed over time.
2. **The pattern has a single clear responsibility** — "ensure X exists and return its path" is one responsibility.
3. **The pattern has a meaningful name** — if you can name it with a verb (`pip_setup_ensure`, `pip_utils_frame2locals`), it should be a program.

Stata `program define` is cheap. There is no overhead to small helper programs beyond the one-time parse on `run`. Use them freely.

## Naming Conventions for Helper Programs in pip

Follow the existing `pip_<module>_<action>` convention:

| Pattern | Name |
|---------|------|
| Ensure/create a setup file | `pip_setup_ensure` |
| Check frame existence | `pip_utils_frameexists` |
| Convert frame to locals | `pip_utils_frame2locals` |
| Drop missing variables | `pip_utils_dropvars` |

Keep the helper program in the same `.ado` file as its caller unless it is used by more than one `.ado` file, in which case it belongs in `pip_utils.ado`.

## Anti-Patterns to Avoid

```stata
// Anti-pattern 1: copy-paste with slight variations
cap findfile "pip_setup.do"      // site A uses cap
if (_rc)  pip_setup_create

capture findfile "pip_setup.do"  // site B uses capture (inconsistent)
if _rc  pip_setup_create         // site B drops parentheses

// Anti-pattern 2: inline multi-step logic in a qui {} block
qui {
    ...
    cap findfile "pip_setup.do"
    if (_rc)  pip_setup_create    // buried, easy to miss
    pip_setup replace, ...
    ...
}
```

## Related

- `.cg-docs/solutions/testing-patterns/2026-03-19-stata-test-suite-patterns.md` — related DRY pattern for test infrastructure: capture program drop before run
- `.cg-docs/solutions/bugs/2026-03-19-stata-file-handle-leak-in-capture-block.md` — another code-quality finding from the same light review session

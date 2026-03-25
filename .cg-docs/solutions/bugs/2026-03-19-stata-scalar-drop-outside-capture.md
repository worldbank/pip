---
date: 2026-03-19
title: "Stata: scalar drop Outside capture Block Causes User-Visible Error When Scalar Was Never Created"
category: "bugs"
language: "Stata"
tags: [scalar, capture, error-handling, silent-failure, offline, pip_gh]
root-cause: "scalar drop errors if the named scalar does not exist; when scalar creation is inside a capture block that fails, the drop runs unconditionally outside capture and produces a visible error"
severity: "P2"
---

# Stata: `scalar drop` Outside `capture` Block Causes User-Visible Error When Scalar Was Never Created

## Problem

A common pattern for large-string processing in Stata:

```stata
capture {
    scalar mydata = fileread("https://api.example.com/data")
    * ... processing ...
}
scalar drop mydata    // <-- BUG: runs unconditionally
```

When the `capture` block fails (e.g., network unavailable, URL 404, `fileread` errors), the scalar `mydata` is never created. The `scalar drop mydata` line then throws:

```
scalar mydata not found
r(111);
```

If the calling program uses `capture noi`, the `noi` causes this error message to be **displayed to the user** even though the failure was intentional (silent degradation). In `pip`, this meant every offline user saw a confusing Stata error on every first `pip` call per session.

## Root Cause

`scalar drop` is not capture-safe — it errors on missing scalars. The developer assumed the cleanup line was "outside" the failure path, but when the `capture` block itself errors, program execution continues at the line after `end` of the `capture` block, reaching `scalar drop` regardless of whether the scalar was created.

## Solution

Use `capture scalar drop` instead:

```stata
capture {
    scalar mydata = fileread("https://api.example.com/data")
    * ... processing ...
}
capture scalar drop mydata    // safe: no-op if scalar doesn't exist
```

`capture scalar drop` suppresses the "not found" error, making cleanup unconditionally safe. The scalar is dropped if it exists, silently skipped if it doesn't.

## Prevention

- **Always** use `capture scalar drop <name>` (never plain `scalar drop`) when the scalar may not have been created due to a preceding `capture` block.
- This applies to any cleanup after a `capture` block: `capture macro drop`, `capture matrix drop`, `capture frame drop`, etc.
- Code review checklist: any `scalar drop` that appears after or outside a `capture` block should be flagged for this pattern.
- The same issue applies in Mata: `mata: mata drop mymat` should be wrapped in `capture mata: mata drop mymat` if creation was conditional.

## Related

- `.cg-docs/solutions/performance-issues/2026-03-19-github-api-releases-latest.md` — the broader `pip_githubquery` rewrite where this bug was found
- `.cg-docs/solutions/bugs/2026-03-19-stata-file-handle-leak-in-capture-block.md` — file-handle version of the same root cause: cleanup inside `capture` is skipped when an earlier statement errors

---
date: 2026-03-25
title: "Stata ado auto-loader silently discards sub-programs defined after the first `end`"
category: "bugs"
language: "Stata"
tags: [stata, ado, auto-loader, program-define, r(199), sub-programs]
root-cause: "Stata's ado auto-loader retains only the first program block (the one whose name matches the filename) from an .ado file; any program defined after the first `end` is silently discarded, causing r(199) on every call"
severity: "P1"
---

# Stata ado auto-loader silently discards sub-programs after the first `end`

## Problem

`pip_split_options` was defined as a second `program define` block at the
bottom of `pip_parseopts.ado` (after the first `end`). Every call to
`pip_split_options` produced:

```
r(199): command pip_split_options is unrecognized
```

The program appeared to be present in the file and was never explicitly
dropped, so the error was confusing.

## Root Cause

Stata's ado auto-loader works by filename: when Stata first sees an unknown
command, it looks for `<commandname>.ado` on the `adopath` and **executes
only the first `program define` block** — the one whose name matches the
filename. Any additional `program define` blocks that appear after the first
`end` in the same file are **silently discarded** at auto-load time.

This means helper programs bundled inside a parent `.ado` file are invisible
to Stata's auto-discovery mechanism unless they have been explicitly `run` or
`do`'d first.

```stata
// pip_parseopts.ado  ← Stata auto-loads THIS block only
program define pip_parseopts
    ...
end

// THIS BLOCK IS SILENTLY DROPPED on auto-load:
program define pip_split_options
    ...
end
```

## Solution

Give every helper program its **own `.ado` file** whose filename exactly
matches the program name. Stata will then auto-discover it independently:

```
pip_parseopts.ado      ← defines program pip_parseopts
pip_split_options.ado  ← defines program pip_split_options  (new file)
```

The extracted file needs only the standard header and a single
`program define <name> ... end` block.

## Prevention

- **One `.ado` file, one public program.** If a helper needs to be callable
  by name (e.g. from other `.ado` files), it must live in its own file.
- Sub-programs that are only ever called *within the same program* (using
  `capture program call` after an explicit `run` or inline as Mata) are safe
  to co-locate, but they will **not** be auto-loadable.
- Add a comment at the top of any extracted helper noting why it lives in
  its own file:
  ```stata
  // INTERNAL HELPER — extracted from pip_parseopts.ado so Stata's
  // ado auto-loader can discover it independently.
  ```
- Regression test: [tests/unit/test_pip_split_options.do](../../../../tests/unit/test_pip_split_options.do)

## Related

- [2026-03-25-undefined-program-r199.md](./2026-03-25-undefined-program-r199.md) — related r(199) from a missing `program define` body

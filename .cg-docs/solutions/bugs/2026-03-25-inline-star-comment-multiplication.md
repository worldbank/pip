---
date: 2026-03-25
title: "Inline * comment after code is parsed as multiplication in Stata"
category: "bugs"
language: "Stata"
tags: [stata, comments, syntax, r(198), parsing]
root-cause: "In Stata, * is only a comment character at the start of a line; mid-line it is the multiplication operator, causing r(198) on any line like `exit * optional text`"
severity: "P1"
---

# Inline * comment after code is parsed as multiplication in Stata

## Problem

Several lines in `pip_gh.ado` used `*` for inline comments after code:

```stata
exit * text describing why we exit
scalar drop myval * clean up
```

These produced `r(198): invalid syntax` at runtime. The lines looked like
innocent documentation but silently broke the program.

## Root Cause

In Stata, `*` is **only** a comment character when it appears at the **start of
a line** (optionally preceded by whitespace). Mid-line, `*` is the arithmetic
multiplication operator. So:

```stata
exit * some text
```

is parsed as `exit` (a command) followed by the expression `* some text`, which
is invalid syntax — `r(198)`.

This is a common mistake when migrating code from languages (R, Python, shell)
where `#` or `//` work anywhere on a line.

## Solution

Replace all inline `*` comments after code with `//`, which **is** valid
mid-line:

```stata
// WRONG
exit * text
capture scalar drop myval * clean up scalar

// CORRECT
exit // text
capture scalar drop myval // clean up scalar
```

For standalone comment lines, `*` at the start of the line remains valid and
idiomatic Stata:

```stata
* This is a valid full-line comment
// This is also valid
```

## Prevention

- Never use `*` after code on the same line in Stata. Use `//` for inline
  comments.
- `*` is safe only as the **first non-whitespace character** on a line.
- Linting rule: search for `^\s*[^*].*\*\s+[a-zA-Z]` in `.ado` / `.do` files
  to catch most occurrences (not foolproof, but catches the common case).
- Regression test: [tests/unit/test_bug_inline_star_comment.do](../../../../tests/unit/test_bug_inline_star_comment.do)

## Related

- [2026-03-25-utf8-bom-stata-parse-error.md](./2026-03-25-utf8-bom-stata-parse-error.md) — another silent parsing bug from the same revamp

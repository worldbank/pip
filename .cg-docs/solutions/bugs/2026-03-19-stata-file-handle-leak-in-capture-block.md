---
date: 2026-03-19
title: "Stata: file handle leaks when file open/read/close share a single capture block"
category: "bugs"
language: "Stata"
tags: [file-handle, capture, file-open, file-read, file-close, resource-leak, pip_gh]
root-cause: "Grouping file open, file read, and file close inside one capture block means file close is skipped whenever file read errors, permanently leaking the handle for the remainder of the session"
severity: "P1"
test-written: "no"
fix-confirmed: "yes"
---

# Stata: File Handle Leaks When `file open`/`file read`/`file close` Share a Single `capture` Block

## Problem

A common Stata pattern for reading a single line from a file:

```stata
tempname fh
capture {
    file open `fh' using "`myfile'", read text
    file read `fh' line
    file close `fh'
}
if (_rc) exit 1
```

When `file read` fails (empty file, binary content, OS lock, etc.), execution jumps to the end of the `capture` block — **skipping `file close`**. The handle `fh` remains open for the rest of the Stata session. Stata has a hard per-session limit on open file handles; each leaked handle consumes one slot permanently. After enough leaks (e.g. repeated calls to an API-check function in an interactive session), subsequent `file open` calls fail with an unhelpful system error.

## Root Cause

`capture { ... }` suppresses errors and continues after the `end` of the block — but program flow within the block stops at the first error. Statements after the failing one (here: `file close`) are never reached. The programmer's assumption that cleanup code at the end of a `capture` block will always run is **wrong** — it only runs if every preceding statement in the block succeeds.

This is the file-handle analogue of the scalar-drop problem (see related doc). Both stem from the same false assumption.

## Solution

Split `file open`, `file read`, and `file close` into **separate** `capture` steps so each has a deterministic execution path:

```stata
tempname fh
capture file open `fh' using `"`whichout'"', read text
if (_rc) exit 1            // open failed — nothing to close, exit immediately

capture file read `fh' line
local rc_fh = _rc          // save BEFORE file close resets _rc

capture file close `fh'    // always runs: open succeeded above
                           // capture is safe: close errors (already closed) are suppressed

if (`rc_fh') exit 1        // read failed — handle was closed above, now exit
```

**Why each decision matters**:

| Line | Reasoning |
|------|-----------|
| `capture file open` + `if (_rc) exit 1` | If open fails, there is no handle — exit immediately, nothing to close |
| `capture file read` | Isolates the read's `_rc` |
| `local rc_fh = _rc` | Must be captured **before** `file close` runs, because `file close` resets `_rc` to 0 on success |
| `capture file close` | `capture` here is belt-and-suspenders: if `file read` exited via some edge case that already closed the handle, the plain `file close` would error; `capture` makes it a no-op |
| `if (\`rc_fh') exit 1` | Uses the saved code, not the post-cleanup `_rc` |

## Wrong Fixes

**Wrong fix 1**: Move `file close` outside the `capture` block without a `capture` prefix:
```stata
capture {
    file open `fh' using ..., read text
    file read `fh' line
}
file close `fh'    // BUG: errors if open failed (no handle) AND doesn't save _rc
```
`file close` errors if the handle was never opened (open failed), and it resets `_rc` before the caller can check it.

**Wrong fix 2**: `capture file close` after a single `capture` block but before the exit check:
```stata
capture { file open; file read; file close }
local rc_fh = _rc
capture file close `fh'    // harmless if close already ran inside block;
                           // but errors if open FAILED (handle was never created)
                           // and resets _rc to 0, masking the original failure
if (`rc_fh') exit 1        // rc_fh correctly saved, but the double-close attempt
                           // leaves a confusing "_rc=0" state as a side effect
```
This is subtly wrong when open failed: `capture file close` on a never-opened handle produces `_rc` from the close attempt (which capture suppresses to 0), not from the original open failure. The check `if (\`rc_fh')` still works because `rc_fh` was saved before the cleanup — but the overall pattern is fragile and confusing.

## Prevention

- **Never put `file open`, `file read`, and `file close` in the same `capture` block** when you need `file close` to run unconditionally.
- Treat file handles like memory: open and close are a matched pair that must not both be inside a single capture scope.
- Pattern to follow: **open → check → read → save rc → close → check saved rc**.
- The same principle applies to any Stata resource that must be explicitly released: `file`, `frame`, `mata` objects, `postfile`/`postclose` handles.
- Code review checklist: any `file close` inside a `capture { }` block should be flagged.

## Related

- `.cg-docs/solutions/bugs/2026-03-19-stata-scalar-drop-outside-capture.md` — same root cause: cleanup inside `capture` is skipped when an earlier statement errors. Scalar version of this bug.
- `.cg-docs/solutions/bugs/2026-03-19-stata-exit-vs-exit1-stale-rclass.md` — the broader `pip_gh` cleanup session where this was found

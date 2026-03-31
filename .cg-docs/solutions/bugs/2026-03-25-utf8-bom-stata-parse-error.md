---
date: 2026-03-25
title: "UTF-8 BOM in .ado files causes Stata parse error on load"
category: "bugs"
language: "Stata"
tags: [stata, encoding, bom, utf-8, vscode, editorconfig]
root-cause: "VS Code silently prepends a UTF-8 BOM (0xEF 0xBB 0xBF) to files saved as UTF-8; Stata does not strip the BOM and tries to execute the 3-byte sequence as a command name"
severity: "P1"
---

# UTF-8 BOM in .ado files causes Stata parse error on load

## Problem

After editing `pip.ado` or `pip_gh.ado` in VS Code, every attempt to call `pip`
produced the error:

```
ï is not a valid command name
(error occurred while loading pip.ado)
```

The file appeared correct when opened in VS Code and when read via PowerShell
`Get-Content` (which strips BOMs automatically). The error was invisible to
normal inspection.

## Root Cause

VS Code can silently write a UTF-8 BOM (`0xEF 0xBB 0xBF`) to the start of a
file when saving in UTF-8 mode. PowerShell's `Get-Content` automatically strips
BOMs on read, hiding the issue from shell-based inspection. Stata does **not**
strip BOMs; it attempts to execute the 3-byte sequence as a Stata command name,
which manifests as the cryptic `ï is not a valid command name` error (the UTF-8
BOM decodes to the Latin-1 character `ï` followed by two non-printable bytes).

## Solution

### 1. Strip existing BOMs

Use Python's `utf-8-sig` codec (which reads and discards the BOM) then write
back as plain `utf-8`:

```python
import pathlib

def strip_bom(path: str) -> None:
    p = pathlib.Path(path)
    text = p.read_text(encoding="utf-8-sig")   # reads and discards BOM
    p.write_text(text, encoding="utf-8")        # writes without BOM

strip_bom("pip.ado")
strip_bom("pip_gh.ado")
```

### 2. Prevent recurrence with `.editorconfig`

Add a `.editorconfig` at the project root that sets `charset = utf-8` (no BOM)
for all Stata file types:

```ini
root = true

[*]
end_of_line = crlf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{ado,do,mata,sthlp}]
charset = utf-8
indent_style = tab
indent_size = 4
```

VS Code respects `.editorconfig` via the built-in EditorConfig extension and
will no longer write BOMs to Stata files.

## Prevention

- Always add `.editorconfig` with `charset = utf-8` to any project that
  includes Stata `.ado` / `.do` files edited in VS Code.
- If a Stata file suddenly produces `ï is not a valid command name`, check for
  a BOM first (PowerShell: `Format-Hex file.ado | Select-Object -First 1`).
- Do **not** use `charset = utf-8-bom` for Stata files.

## Related

- [2026-03-25-inline-star-comment-multiplication.md](./2026-03-25-inline-star-comment-multiplication.md) — another silent Stata parsing bug from the same revamp

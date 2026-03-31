---
date: 2026-03-19
title: "Stata Test Suite Patterns: runner, file structure, and common pitfalls"
category: "testing-patterns"
language: "Stata"
tags: [testing, test-runner, stata-syntax, program-drop, adopath, capture, r198, r110]
root-cause: "Stata has several non-obvious syntax and scoping rules that break test files written with intuitions from other languages"
severity: "P2"
---

# Stata Test Suite Patterns: Runner, File Structure, and Common Pitfalls

## Overview

This document captures the patterns and anti-patterns discovered while building `tests/run_all_tests.do` and the associated test files for the `pip` package.

---

## Pattern: Test Runner

```stata
// tests/run_all_tests.do
version 16.1
set more off

* Resolve tests directory regardless of working directory
capture findfile "run_all_tests.do"
if (_rc == 0) local tests_dir "`c(pwd)'"     // running from tests/
else          local tests_dir "`c(pwd)'/tests"  // running from project root

local tests : dir "`tests_dir'" files "test_*.do", respectcase
local n_total : list sizeof tests
local n_pass  = 0
local n_fail  = 0
local failures ""

foreach test of local tests {
    di as text _n "Running: `test' ..."
    capture noisily do "`tests_dir'/`test'"
    if (_rc == 0) {
        local n_pass = `n_pass' + 1
        di as result "  -> PASSED"
    }
    else {
        local n_fail = `n_fail' + 1
        local failures "`failures' `test'"
        di as error "  -> FAILED (_rc = " _rc ")"
    }
}

di as result _n _dup(60) "="
di as result "RESULTS: `n_pass'/`n_total' passed"
if (`n_fail' > 0) {
    di as error "FAILED (`n_fail'):"
    foreach f of local failures { di as error "  - `f'" }
    error 9
}
else di as result "All tests passed."
di as result _dup(60) "="
```

Key choices:
- `capture noisily do` — captures the return code while still showing output for debugging
- `error 9` at the end — makes batch mode exit with non-zero status, so CI/make scripts can detect failure
- `dir ... files "test_*.do"` — auto-discovers test files; no manual registration required

---

## Pattern: Individual Test File Structure

```stata
// tests/test_<feature>.do
version 16.1
set more off

* Make project ado files findable without being installed
adopath ++ ".."

* Drop any previously-loaded versions of the program under test
* (prevents r(110) when multiple test files load the same ado)
capture program drop pip_gh
capture program drop pip_githubquery
run "../pip_gh.ado"

* ---- Test 1: <description> -----
<setup>
if !(<assertion>) {
    di as error "FAIL Test 1: <what was expected>"
    error 9    // non-zero _rc causes run_all_tests to mark FAILED
}
di as result "  PASS Test 1: <what was verified>"
```

---

## Anti-Patterns (and Fixes)

### 1. Using `;` as a statement separator

**Symptom**: `r(198): ';' invalid`

**Wrong**:
```stata
local maj1 0 ; local min1 10 ; local pat1 0   // NOT valid Stata
```

**Correct**: Stata does not support `;` as a statement separator. Each statement must be on its own line (or use `///` continuation for long single statements):
```stata
local maj1 0
local min1 10
local pat1 0
```

Note: `#delimit ;` changes the delimiter to `;` for the remainder of the do-file (or until `#delimit cr`), but this is a global file-scope change and should not be used inside test files.

---

### 2. `program already defined` when multiple test files load the same ado

**Symptom**: `r(110): program pip_gh already defined`

**Cause**: `run "file.ado"` defines programs into the **global** Stata program namespace. If `test_a.do` runs `pip_gh.ado` and the runner then runs `test_b.do` which also runs `pip_gh.ado`, Stata sees `pip_gh` already defined and errors.

**Fix**: Always `capture program drop` before `run`-ing an ado file in a test:
```stata
capture program drop pip_gh
capture program drop pip_githubquery
run "../pip_gh.ado"
```

`capture` makes the drop a no-op if the program doesn't exist yet (first test file in the session).

---

### 3. `adopath` pollution across test files

**Cause**: `adopath ++ ".."` in one test file adds `..` to the **global** adopath for all subsequent test files in the same Stata session (since the runner uses one session).

**Mitigation**: This is generally harmless — adding the project root once is idempotent in effect. But be aware that `adopath ++ ".."` from the `tests/` directory adds the project root, so programs in both `../` and anywhere in the adopath are available to all tests after the first one sets this up.

If strict isolation is needed, use `adopath - ".."` at the end of each test, but this is rarely necessary.

---

### 4. Checking `_rc` after an `if` block

Stata resets `_rc` after every successfully-parsed statement, including `if`/`else` compound blocks. Capture `_rc` into a local **immediately** after the command of interest:

```stata
capture pip_gh
local rc_after = _rc    // capture IMMEDIATELY before any other statement
if (`rc_after' == 0) {
    // ...
}
```

Do NOT rely on `_rc` after `if (_rc == 0) { ... }` — the `if` block itself sets `_rc = 0` on success.

---

### 5. Leaving temporary programs defined at end of test

If a test creates a helper program (`program define _pip_test_helper`), drop it explicitly at the end:
```stata
program define _pip_test_helper, rclass
    return local val "test"
end

// ... tests ...

program drop _pip_test_helper    // clean up
```

This prevents namespace collisions with other tests.

---

## Running Tests in Batch Mode

```powershell
# From project root
Push-Location tests
Remove-Item *.log -ErrorAction SilentlyContinue
& "C:\Program Files\StataNow19\StataMP-64.exe" /b do run_all_tests.do
Start-Sleep 30   # wait for batch completion
Get-Content run_all_tests.log | Select-String "RESULTS|PASSED|FAILED"
Pop-Location
```

The `/b` flag runs in batch (no GUI). Log is written to `run_all_tests.log` alongside the do-file. Exit code of the Stata process reflects whether `error 9` was hit.

---

## Related

- `.cg-docs/solutions/bugs/2026-03-19-stata-exit-vs-exit1-stale-rclass.md` — when capture + _rc checking can be fooled by stale r() values
- `.cg-docs/solutions/bugs/2026-03-19-stata-semantic-version-comparison.md` — includes suggested test assertions for semver arithmetic

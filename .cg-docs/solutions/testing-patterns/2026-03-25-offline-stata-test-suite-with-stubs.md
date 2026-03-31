---
date: 2026-03-25
title: "Offline Stata test suite using stub programs and shared assertion helpers"
category: "testing-patterns"
language: "Stata"
tags: [stata, testing, stubs, offline, assertions, unit-tests, integration-tests]
root-cause: "pip's network-dependent sub-programs make automated testing impossible without internet; stub programs replace them with deterministic synthetic data so the full test suite can run in CI or air-gapped environments"
severity: "P2"
---

# Offline Stata test suite using stub programs and shared assertion helpers

## Problem

`pip` calls several network-dependent sub-programs (`pip_cl`, `pip_wb`,
`pip_gh`, `pip_versions`, `pip_set_server`, `pip_new_session`) that require
a live API. This made it impossible to:

- Run a fast smoke test in CI
- Test logic offline or on restricted networks
- Write unit tests for non-network code without accidentally hitting the API

## Solution

The solution has three layers:

### 1. `tests/stubs.do` — stub harness

Redefines every network-dependent program as a minimal `program define` that
returns synthetic data and sets the same globals / `r()` macros as the real
program:

```stata
// stubs.do snippet

// Pre-set globals that short-circuit network gates
global pip_version_checked "1"
global pip_host   "https://api.worldbank.org/pip/v1"
global pip_server "prod"
global pip_version "20230601_2017_01_02_PROD"

// Stub: pip_cl returns a 2-row synthetic dataset
cap program drop pip_cl
program define pip_cl
    syntax [, clear fillgaps noNOWcasts *]
    clear
    qui set obs 2
    gen str3  country_code = cond(_n == 1, "CHN", "IND")
    gen       headcount    = 0.01 * _n
    // ... other required variables
end

// Stub: pip_gh returns "no update available" silently
cap program drop pip_gh
program define pip_gh, rclass
    return local update_available = "0"
end
```

Key design rules:
- Accept `*` (passthrough) in `syntax` so callers can pass estimation options without error.
- Set the same **globals** the real program would set (e.g. `pip_version_checked`, `pip_host`) so downstream gates are satisfied.
- Return the same **`r()` macros** the real program returns.
- Use `cap program drop` before each `program define` so the file is safe to `run` multiple times.

### 2. `tests/test_helpers.do` — shared assertion library

Defines reusable `program define` helpers that print `PASS <test>` or
`FAIL <test>` with a descriptive message and `error 9` on failure:

```stata
// assert_rc_zero — caller captures rc and passes it in
program define assert_rc_zero
    syntax, test(string) [rc(integer 0)]
    if (`rc' != 0) {
        pip_test_fail, test("`test'") msg("_rc = `rc' (expected 0)")
    }
    pip_test_pass, test("`test'")
end

// assert_var_exists — checks that a variable is present in current data
program define assert_var_exists
    syntax, test(string) var(string)
    cap confirm variable `var'
    if (_rc != 0) pip_test_fail, test("`test'") msg("variable `var' not found")
    pip_test_pass, test("`test'")
end

// assert_return_equal — checks r(name) immediately after rclass call
program define assert_return_equal
    syntax, test(string) name(string) expected(string)
    local actual = "`r(`name')'"
    if ("`actual'" != "`expected'") {
        pip_test_fail, test("`test'") msg("r(`name') = '`actual'' (expected '`expected'')")
    }
    pip_test_pass, test("`test'")
end
```

Full list of helpers: `assert_rc_zero`, `assert_rc_nonzero`, `assert_var_exists`,
`assert_var_not_exists`, `assert_var_type`, `assert_nobs_positive`,
`assert_nobs_equal`, `assert_global_set`, `assert_global_empty`,
`assert_local_equal`, `assert_frame_exists`, `assert_frame_not_exists`,
`assert_return_equal`.

### 3. `tests/run_unit_tests.do` — offline runner

Loads stubs, then `run`s each unit test file. Each test file follows a
consistent template:

```stata
// tests/unit/test_pip_smoke.do
version 16.1
set more off
adopath ++ "../.."                  // make pip findable
run "../../pip_fun.mata"            // load mata functions
run "../test_helpers.do"            // load assertion helpers
run "../stubs.do"                   // activate offline stubs

di as result "=== Smoke tests (offline) ==="

// Test 1: pip cl returns observations
capture pip cl, clear
assert_rc_zero, test("pip cl returns rc=0") rc(`=_rc')
assert_nobs_positive, test("pip cl returns observations")
assert_var_exists, test("pip cl has headcount") var(headcount)
```

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Stubs use `syntax [, *]` passthrough | Callers can pass any estimation option without the stub erroring |
| Stub variables use heterogeneous values (e.g. `welfare_type = _n`) | Catches code that incorrectly assumes homogeneous data |
| `cap program drop` before every stub | Safe to `run stubs.do` multiple times without "already defined" errors |
| `_rc` saved to a local *before* calling assert helpers | `_rc` is reset the moment any new program is called |
| `adopath ++` in runner, not in individual test files | Prevents duplicate path entries; test files keep their own call for standalone robustness |
| Stubs file renamed from `test_stubs.do` to `stubs.do` | Prevents glob matchers in test runners from executing it as a test |

## Prevention / How to Add New Tests

1. Create `tests/unit/test_<feature>.do` following the template above.
2. Source `test_helpers.do` and `stubs.do` at the top.
3. Name each test case with a unique string passed to `test()`.
4. Add the new file to `run_unit_tests.do`.

## Related

- [2026-03-25-ado-autoloader-discards-sub-programs.md](../bugs/2026-03-25-ado-autoloader-discards-sub-programs.md) — a bug this test suite helped catch
- [tests/stubs.do](../../../../tests/stubs.do)
- [tests/test_helpers.do](../../../../tests/test_helpers.do)
- [tests/run_unit_tests.do](../../../../tests/run_unit_tests.do)

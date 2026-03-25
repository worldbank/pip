---
date: 2026-03-19
title: "Comprehensive test suite for the pip Stata package"
status: decided
chosen-approach: "Subdirectories + lightweight assertion helpers"
tags: [testing, stata, regression-tests, integration-tests]
---

# Comprehensive Test Suite for pip Stata Package

## Context

The `pip` Stata package (v0.11.0) wraps the World Bank PIP API. A major refactor was just completed and there is no confidence that the rest of the package is bug-free. The existing test suite (7 files) covers only a small fraction of the package surface — semver arithmetic, regex patterns, dropvars, frame prefix matching, and bug reproductions. A comprehensive test suite is needed to catch regressions before each release.

## Requirements

Gathered through Q&A:

1. **Purpose**: Local regression tests, run manually before releases. No CI/GitHub Actions.
2. **Network**: Two categories — offline unit tests (fast, no network) and live API integration tests (require internet).
3. **Validation**: Structural checks are the priority (expected variables exist, types correct, N > 0, no errors). Known-value/missingness checks are roadmap items (informational warnings, not hard stops).
4. **Scope**: All layers of the package:
   - Option parsing (`pip_parseopts`, `pip_split_options`, `pip_pov_check_args`)
   - Session/setup (`pip_new_session`, `pip_setup`, `pip_set_server`, `pip_versions`)
   - Caching (`pip_cache` — hash, save, load, inventory, iscache)
   - API subcommands (`cl`, `wb`, `agg`, `cp`, `gd`, `tables`)
   - Utilities (`pip_utils` — dropvars, keepframes, finalmsg, etc.), `pip_cleanup`, `pip_drop`
   - GitHub/version check (`pip_gh`)
   - Mata functions (`pip_fun.mata`)
5. **Error handling / edge cases**: Deferred to roadmap. Focus on happy-path first.
6. **Runner**: Single runner is fine. Clear test names and messages are the priority — no need for separate unit/integration runners.

### Roadmap items (out of scope for initial implementation)

- Error handling / edge case tests (invalid inputs, conflicting options, graceful failure)
- Known-value checks on API data (informational warnings, not hard stops)
- Missingness checks on specific API variables (informational)

## Approaches Considered

### Approach 1: Flat files, naming convention (minimal infrastructure)

Keep current pattern — all `test_*.do` files in `tests/`. Use naming prefix (`test_unit_*`, `test_api_*`). Existing `run_all_tests.do` globs everything.

- **Pros**: No structural change. Easy to add tests. Already working.
- **Cons**: Flat directory gets crowded at 30+ files. No shared helpers — repeated boilerplate in every file.
- **Effort**: Small
- **Recommended?** No — doesn't scale.

### Approach 2: Subdirectories + lightweight assertion helpers

Organize into `tests/unit/` and `tests/integration/`. Create `tests/test_helpers.do` with reusable assertion programs (`assert_rc_zero`, `assert_var_exists`, `assert_nobs_positive`, `assert_var_type`, etc.). Update `run_all_tests.do` to recurse into both directories.

- **Pros**: Clean separation. Assertion helpers reduce boilerplate and standardize output. Each test file is shorter. Scales to 40+ files.
- **Cons**: Slightly more upfront work. Two-directory convention to learn.
- **Effort**: Medium
- **Recommended?** **Yes**

### Approach 3: Full test framework with manifest and tagging

Like Approach 2, plus a `test_manifest.do` with metadata per test (layer, priority, requires_network). Runner filters by tag, produces timing report. Mini `testthat` for Stata.

- **Pros**: Maximum flexibility. Rich reporting.
- **Cons**: Overengineered for local manual runs. Manifest must be maintained.
- **Effort**: Large
- **Recommended?** No

## Decision

**Approach 2: Subdirectories + lightweight assertion helpers.**

Best balance of structure and simplicity. Scales well for all-layer coverage without overengineering.

## Next Steps

1. **Create `tests/test_helpers.do`** — reusable assertion programs for standardized PASS/FAIL output.
2. **Create `tests/unit/` directory** — move existing offline tests here, add new unit tests for:
   - `pip_parseopts` (option parsing, subcommand extraction)
   - `pip_split_options` (general vs estimation option classification)
   - `pip_cache` (hash generation, save/load round-trip, iscache logic)
   - `pip_setup` (globals set correctly)
   - `pip_versions` (version string parsing)
   - `pip_drop` (frame dropping, global dropping)
   - `pip_cleanup` (cleanup behavior)
   - `pip_timer` (on/off/print)
   - `pip_fun.mata` (mata utility functions)
   - Existing: `pip_gh` arithmetic, `pip_utils_dropvars`, `pip_utils_keep_frame`, deprecated subcommands, bug reproductions
3. **Create `tests/integration/` directory** — add live API tests for:
   - `pip cl` (default, with country, with region, with year, with povline, with fillgaps, with popshare)
   - `pip wb` (default, with region, with year, with povline)
   - `pip agg` (default, with aggregate options)
   - `pip cp` (country profiles)
   - `pip gd` (grouped data)
   - `pip tables` (auxiliary tables)
   - `pip print` (versions, tables, info)
   - `pip info` (availability)
   - Structural checks: expected vars exist, correct types, N > 0, no _rc errors
4. **Update `run_all_tests.do`** — recurse into `unit/` and `integration/` subdirectories, preserve cleanup logic between tests.
5. **Migrate existing tests** — move current `test_*.do` files from `tests/` into appropriate subdirectory.

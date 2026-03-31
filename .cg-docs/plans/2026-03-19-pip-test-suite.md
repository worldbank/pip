---
date: 2026-03-19
title: "Comprehensive test suite for the pip Stata package"
status: active
brainstorm: ".cg-docs/brainstorms/2026-03-19-pip-test-suite-design.md"
language: "Stata"
estimated-effort: "large"
tags: [testing, stata, regression-tests, integration-tests, pip]
---

# Plan: Comprehensive Test Suite for pip Stata Package

## Objective

Build a complete regression test suite for the `pip` Stata package (v0.11.0) that covers all layers — option parsing, session management, caching, API subcommands, utilities, GitHub version checking, and Mata functions. The suite must be runnable locally before each release to catch bugs that could have been prevented by testing. Tests are split into offline unit tests (no network) and live integration tests (API calls), with structural validation as the primary assertion strategy.

## Context

**What exists today:** 7 test files in `tests/` covering semver arithmetic (`pip_gh`), regex patterns, `pip_utils_dropvars`, `pip_utils_keep_frame`, deprecated subcommands, and two bug reproduction tests. A `run_all_tests.do` runner globs `test_*.do` and reports pass/fail.

**What the brainstorm decided:** Approach 2 — reorganize into `tests/unit/` and `tests/integration/` subdirectories, create shared `test_helpers.do` with reusable assertion programs, cover all package layers. Focus on happy-path structural checks. Error handling / edge case tests and known-value checks are deferred to the roadmap.

**Conventions in existing tests:**
- `version 16.1` / `set more off` at top
- `adopath ++ ".."` to find package `.ado` files
- `capture program drop` + `run` to force-reload
- `error 9` as the standard test-failure exit code
- Manual `di as result "  PASS ..."` / `di as error "FAIL ..."` messages
- Cleanup of frames and data between tests

**Package layers to cover:**

| # | Layer | Key files | Type |
|---|-------|-----------|------|
| 1 | Option parsing | `pip_parseopts.ado`, `pip_split_options` (in `pip.ado`), `pip_pov_check_args.ado` | Unit |
| 2 | Session/setup | `pip_new_session.ado`, `pip_setup.ado`, `pip_set_server.ado`, `pip_versions.ado` | Unit + Integration |
| 3 | Caching | `pip_cache.ado` (gethash, save, load, iscache, delete, inventory) | Unit |
| 4 | API subcommands | `pip_cl.ado`, `pip_wb.ado`, `pip_agg.ado`, `pip_cp.ado`, `pip_gd.ado` | Integration |
| 5 | Tables/aux | `pip_tables.ado`, `pip_auxframes.ado` | Integration |
| 6 | Utilities | `pip_utils.ado` (dropvars, keepframes, frameexists, finalmsg, output, clicktable, frame2locals, dispquery), `pip_cleanup.ado`, `pip_drop.ado` | Unit |
| 7 | GitHub/version | `pip_gh.ado`, `pip_githubquery` | Unit (existing) |
| 8 | Mata functions | `pip_fun.mata` (pip_retlist2locals, pip_locals2call, pip_abb_regex, pip_replace_in_pattern, pip_check_folder, pip_mkdir_recursive, pip_reverse_macro, timer structs) | Unit |
| 9 | Timer | `pip_timer.ado` + mata timer struct | Unit |
| 10 | Info/cite | `pip_info.ado`, `pip_cite.ado` | Integration |
| 11 | Dispatcher | `pip.ado` (subcommand routing, early returns, deprecated commands) | Integration |

---

## Implementation Steps

### Step 0: Create test infrastructure

- **Files to create:**
  - `tests/test_helpers.do` — shared assertion programs
  - `tests/unit/` directory
  - `tests/integration/` directory

- **Details:** Build reusable assertion programs that standardize PASS/FAIL output and reduce boilerplate. Each program takes a test label and fails with `error 9` on assertion failure.

  Programs to create:

  | Program | Purpose | Signature |
  |---------|---------|-----------|
  | `assert_rc_zero` | Last command succeeded | `assert_rc_zero, test(string) [rc(integer 0)]` |
  | `assert_rc_nonzero` | Last command failed | `assert_rc_nonzero, test(string) rc(integer)` |
  | `assert_var_exists` | Variable exists in dataset | `assert_var_exists, test(string) var(string)` |
  | `assert_var_not_exists` | Variable was dropped | `assert_var_not_exists, test(string) var(string)` |
  | `assert_var_type` | Variable has expected type | `assert_var_type, test(string) var(string) type(string)` |
  | `assert_nobs_positive` | Dataset has N > 0 | `assert_nobs_positive, test(string)` |
  | `assert_nobs_equal` | Dataset has exactly N obs | `assert_nobs_equal, test(string) expected(integer)` |
  | `assert_global_set` | Global macro is non-empty | `assert_global_set, test(string) global(string)` |
  | `assert_global_empty` | Global macro is empty | `assert_global_empty, test(string) global(string)` |
  | `assert_local_equal` | Local equals expected value | `assert_local_equal, test(string) got(string) expected(string)` |
  | `assert_frame_exists` | Named frame exists | `assert_frame_exists, test(string) frame(string)` |
  | `assert_frame_not_exists` | Named frame was dropped | `assert_frame_not_exists, test(string) frame(string)` |
  | `assert_return_equal` | r(name) equals expected | `assert_return_equal, test(string) name(string) expected(string)` |

- **Acceptance criteria:** `do tests/test_helpers.do` loads without error; each helper can be called and produces correct PASS/FAIL output.

---

### Step 1: Migrate existing tests into subdirectories

- **Files to move:**
  - `tests/test_pip_gh_returns.do` → `tests/unit/test_pip_gh_returns.do`
  - `tests/test_pip_gh_silent_failures.do` → `tests/unit/test_pip_gh_silent_failures.do`
  - `tests/test_pip_utils_dropvars.do` → `tests/unit/test_pip_utils_dropvars.do`
  - `tests/test_pip_utils_keep_frame.do` → `tests/unit/test_pip_utils_keep_frame.do`
  - `tests/test_pip_deprecated_subcommands.do` → `tests/unit/test_pip_deprecated_subcommands.do`
  - `tests/test_bug_inline_star_comment.do` → `tests/unit/test_bug_inline_star_comment.do`
  - `tests/test_bug_pip_source_stale.do` → `tests/unit/test_bug_pip_source_stale.do`

- **Details:** Move files. Update `adopath` references — existing tests use `adopath ++ ".."` which must become `adopath ++ "../.."` since they're one directory deeper. Verify all 7 existing tests still pass after the move.

- **Acceptance criteria:** `run_all_tests.do` (updated) finds and runs all 7 tests, all pass.

---

### Step 2: Update `run_all_tests.do`

- **Files to modify:** `tests/run_all_tests.do`

- **Details:** Update the runner to:
  1. Load `test_helpers.do` at startup.
  2. Glob `test_*.do` from both `unit/` and `integration/` subdirectories.
  3. Report separate counts for unit vs integration tests.
  4. Preserve the existing cleanup logic between tests (clear data, drop extra frames).
  5. Also accept `test_*.do` files in the `tests/` root for backward compatibility during migration.

- **Acceptance criteria:** Runner discovers and executes tests in both subdirectories. Output clearly shows which directory each test belongs to.

---

### Step 3: Unit tests — Option parsing

- **Files to create:**
  - `tests/unit/test_pip_parseopts.do`
  - `tests/unit/test_pip_split_options.do`

- **Details:**

  **`test_pip_parseopts.do`** — test `pip_parseopts` in isolation:
  - Test 1: Subcommand extraction — `pip_parseopts cl, country(CHN)` returns `r(subcmd)=="cl"`, `r(country)=="country(CHN)"`
  - Test 2: No subcommand — `pip_parseopts , country(CHN)` returns empty `r(subcmd)`
  - Test 3: Multiple options — verify all option names appear in `r(optnames)` and each option is returned as a named local
  - Test 4: Options with parenthesized values — `povline(1.9)`, `year(2015)`
  - Test 5: Boolean options — `fillgaps`, `clear`, `nofillgaps`
  - Test 6: `r(returnnames)` contains all returned macro names

  **`test_pip_split_options.do`** — test `pip_split_options` in isolation:
  - Test 1: General options (`version`, `ppp_year`, `release`, `identity`, `server`, `n2disp`, `cachedir`) correctly classified into `r(gen_opts)`
  - Test 2: Estimation options (`country`, `povline`, `fillgaps`) correctly classified into `r(est_opts)`
  - Test 3: Abbreviated options (`ver`, `ppp`, `rel`) matched correctly (3-char abbreviation)
  - Test 4: Empty optnames produces empty returns
  - Test 5: Mixed general + estimation options split correctly

- **Acceptance criteria:** Both test files pass. Each test uses helpers from `test_helpers.do`.

---

### Step 4: Unit tests — Caching

- **Files to create:** `tests/unit/test_pip_cache.do`

- **Details:** Test `pip_cache` subprograms in isolation (no network):

  - Test 1: `pip_cache_gethash` — same query produces same hash; different queries produce different hashes
  - Test 2: `pip_cache_gethash` — hash format is `_pip` followed by digits
  - Test 3: `pip_cache_gethash` — empty query does not crash
  - Test 4: `pip_cache save` / `pip_cache load` round-trip — save a dataset to a temp cachedir, load it back, verify contents match
  - Test 5: `pip_cache load` with `cacheforce` — returns `pc_exists==0` even when cache file exists
  - Test 6: `pip_cache load` for missing file — returns `pc_exists==0`
  - Test 7: `pip_cache_iscache` — after loading cached data, `iscache` returns the hash; on non-cached data, returns empty
  - Test 8: Caching disabled (`pip_cachedir=="0"`) — `pip_cache load` returns `piphash=="0"`, `pc_exists==0`

  **Setup:** Use a `tempfile`-based cachedir so tests don't pollute the real cache. Set `$pip_cachedir` to a temp directory, clean up after.

- **Acceptance criteria:** All 8 tests pass. No files left in real cache after test run.

---

### Step 5: Unit tests — Utilities (new tests)

- **Files to create:**
  - `tests/unit/test_pip_utils_frameexists.do`
  - `tests/unit/test_pip_utils_frame2locals.do`
  - `tests/unit/test_pip_drop.do`
  - `tests/unit/test_pip_cleanup.do`

- **Details:**

  **`test_pip_utils_frameexists.do`:**
  - Test 1: Existing frame returns `r(fexists)==1`
  - Test 2: Non-existing frame returns `r(fexists)==0`
  - Test 3: Default frame returns `r(fexists)==1`

  **`test_pip_utils_frame2locals.do`:**
  - Test 1: Single-row dataset — each variable becomes `r(varname_1)`
  - Test 2: Multi-row dataset — returns `r(varname_1)`, `r(varname_2)`, etc.
  - Test 3: String and numeric variables both returned

  **`test_pip_drop.do`:**
  - Test 1: `pip_drop frame` drops frames matching prefix
  - Test 2: `pip_drop frame` does not drop frames with different prefix
  - Test 3: `pip_drop frame, frame_prefix(custom_)` uses custom prefix
  - Test 4: `pip_drop global` clears all `pip_*` globals
  - Test 5: `pip_drop global` does not clear non-pip globals

  **`test_pip_cleanup.do`:**
  - Test 1: After creating `_pip_*` frames and `pip_*` globals, `pip_cleanup` removes both
  - Test 2: Non-pip frames and globals survive cleanup

- **Acceptance criteria:** All tests pass. Proper cleanup between tests (no leaked frames/globals).

---

### Step 6: Unit tests — Mata functions

- **Files to create:** `tests/unit/test_pip_fun_mata.do`

- **Details:** Load `pip_fun.mata` and test key Mata functions:

  - Test 1: `pip_retlist2locals` — after an rclass program sets `r(foo)`, calling `pip_retlist2locals` creates local `foo` with the value
  - Test 2: `pip_locals2call` — given optnames `"country year"`, produces string `` "`country' `year'" ``
  - Test 3: `pip_abb_regex` — for `("version" "ppp_year")` with length 3, produces regex patterns that match `ver`, `vers`, `version`, `ppp`, `ppp_`, `ppp_year` but not `ve`, `pp`
  - Test 4: `pip_replace_in_pattern` — creates a temp file, replaces a line matching a pattern, verifies the output file has the new line
  - Test 5: `pip_check_folder` — returns 1 for an existing writable directory, creates it if needed
  - Test 6: `pip_reverse_macro` — reverses `"a b c"` to `"c b a"`
  - Test 7: `pip_mkdir_recursive` — creates a nested directory structure in a temp location

- **Acceptance criteria:** All Mata function tests pass. No temp files/dirs left behind.

---

### Step 7: Unit tests — Timer

- **Files to create:** `tests/unit/test_pip_timer.do`

- **Details:**
  - Test 1: `pip_timer` (no args) initializes without error
  - Test 2: `pip_timer label, on` followed by `pip_timer label, off` completes without error
  - Test 3: Multiple timers can be started and stopped
  - Test 4: `pip_timer, printtimer` produces output without error
  - Test 5: Stopping a non-existent timer produces an error (expected `_rc != 0`)

- **Acceptance criteria:** All timer tests pass.

---

### Step 8: Integration tests — Server and versions

- **Files to create:**
  - `tests/integration/test_pip_set_server.do`
  - `tests/integration/test_pip_versions.do`

- **Details:**

  **`test_pip_set_server.do`:**
  - Test 1: `pip_set_server` (default) sets `$pip_host` to production URL, `$pip_server` to `"prod"`
  - Test 2: `pip_set_server, server(prod)` — same as default
  - Test 3: `r(server)`, `r(url)`, `r(base)` all non-empty
  - Test 4: Health check passed (implicit — no error thrown)

  **`test_pip_versions.do`:**
  - Test 1: `pip_versions` sets `$pip_version` to a non-empty string matching the vintage pattern `[0-9]{8}_[0-9]{4}_[0-9]{2}_[0-9]{2}_(PROD|INT|TEST)`
  - Test 2: `r(release)`, `r(ppp_year)`, `r(identity)` all non-empty
  - Test 3: `pip_versions, availability` lists versions without error
  - Test 4: Frame `_pip_versions_*` created and has expected variables (`version`, `release`, `ppp_year`, `identity`)

- **Acceptance criteria:** All tests pass with a live API connection.

---

### Step 9: Integration tests — API subcommands (structural)

- **Files to create:**
  - `tests/integration/test_pip_cl.do`
  - `tests/integration/test_pip_wb.do`
  - `tests/integration/test_pip_agg.do`
  - `tests/integration/test_pip_cp.do`
  - `tests/integration/test_pip_gd.do`

- **Details:** Each file follows the same pattern: call the subcommand, then verify structural properties of the returned dataset (variables exist, types correct, N > 0). No value assertions.

  **`test_pip_cl.do`:**
  - Test 1: `pip cl, clear` — returns data with N > 0
  - Test 2: Expected variables exist: `country_code`, `year`, `headcount`, `poverty_gap`, `poverty_severity`, `watts`, `mean`, `median`, `reporting_level`
  - Test 3: `country_code` is string type; `headcount` is numeric
  - Test 4: `pip cl, country(CHN) clear` — returns data filtered to CHN only
  - Test 5: `pip cl, country(CHN) year(2018) clear` — returns data for specific year
  - Test 6: `pip cl, country(CHN) fillgaps clear` — returns data (fillgaps variant)
  - Test 7: `pip cl, povline(3.20) clear` — returns data with custom poverty line
  - Test 8: `pip cl, popshare(0.5) clear` — returns data with popshare

  **`test_pip_wb.do`:**
  - Test 1: `pip wb, clear` — returns data with N > 0
  - Test 2: Expected variables: `region_code`, `year`, `headcount`, `poverty_gap`, `poverty_severity`, `watts`, `mean`
  - Test 3: `region_code` is string; `headcount` is numeric
  - Test 4: `pip wb, region(SSA) clear` — filters to region
  - Test 5: `pip wb, povline(3.20) clear` — custom poverty line

  **`test_pip_agg.do`:**
  - Test 1: `pip agg, clear` — returns data with N > 0
  - Test 2: Expected variables present (check what the API returns)
  - Test 3: `pip agg, povline(3.20) clear` — custom poverty line

  **`test_pip_cp.do`:**
  - Test 1: `pip cp, clear` — returns data with N > 0
  - Test 2: Expected variables present
  - Test 3: `pip cp, country(CHN) clear` — filtered to country

  **`test_pip_gd.do`:**
  - Test 1: `pip gd, cum_welfare(0.1 0.2 0.5 0.9 1.0) cum_population(0.2 0.4 0.6 0.8 1.0) clear` — returns data with N > 0
  - Test 2: Expected variables present
  - Test 3: Key numeric variables are numeric type

  **Note:** The exact variable lists will be confirmed by running each command once and inspecting the output during implementation. The tests should be resilient to added variables across API versions — check for a minimum set, not an exact match.

- **Acceptance criteria:** All integration tests pass with a live API connection. Each test takes < 30 seconds.

---

### Step 10: Integration tests — Tables and auxiliary frames

- **Files to create:**
  - `tests/integration/test_pip_tables.do`
  - `tests/integration/test_pip_auxframes.do`

- **Details:**

  **`test_pip_tables.do`:**
  - Test 1: `pip tables, clear` — loads table list without error, N > 0
  - Test 2: `pip tables, table(countries) clear` — loads specific table, expected variables present (`country_code`, `country_name`)
  - Test 3: `pip tables, table(regions) clear` — `region_code` variable exists
  - Test 4: `pip tables, table(framework) clear` — `country_code`, `year` exist

  **`test_pip_auxframes.do`:**
  - Test 1: After `pip_auxframes`, frames `_pip_cts*`, `_pip_regions*`, `_pip_fw*`, `_pip_cl*` exist
  - Test 2: Countries frame has `country_code` variable
  - Test 3: Regions frame has `region_code` variable
  - Test 4: Framework frame has `country_code`, `year`, `welfare_type` variables

- **Acceptance criteria:** All tests pass with live API.

---

### Step 11: Integration tests — Info, cite, and full dispatcher

- **Files to create:**
  - `tests/integration/test_pip_info.do`
  - `tests/integration/test_pip_cite.do`
  - `tests/integration/test_pip_dispatcher.do`

- **Details:**

  **`test_pip_info.do`:**
  - Test 1: `pip info, clear` — completes without error
  - Test 2: `pip print, info clear` — same behavior via print subcommand

  **`test_pip_cite.do`:**
  - Test 1: `pip_cite, reg_cite` — returns `r(cite_ado)` and `r(cite_data)` non-empty
  - Test 2: Citation strings contain expected fragments ("World Bank", "pip", version number)

  **`test_pip_dispatcher.do`** — test the main `pip.ado` routing:
  - Test 1: `pip, clear` — default subcommand (cl) works, data returned
  - Test 2: `pip cl, clear` — explicit country-level
  - Test 3: `pip wb, clear` — aggregate
  - Test 4: `pip tables, clear` — tables
  - Test 5: `pip cleanup` — runs without error, clears internal state
  - Test 6: `pip print, versions` — displays versions
  - Test 7: `pip drop frame` — drops pip frames
  - Test 8: `pip drop global` — drops pip globals

- **Acceptance criteria:** All tests pass. This is the "end-to-end" smoke test that the dispatcher routes correctly.

---

### Step 12: Integration test — Cache round-trip with live data

- **Files to create:** `tests/integration/test_pip_cache_live.do`

- **Details:**
  - Test 1: Run `pip cl, country(COL) clear` — data is fetched and cached
  - Test 2: Run same query again — verify it loads from cache (check `_dta[piphash]` characteristic)
  - Test 3: `pip_cache iscache` returns the hash
  - Test 4: `pip_cache info` displays without error

  **Setup:** Use the default cachedir. Tests are non-destructive (read + write cache, don't delete).

- **Acceptance criteria:** Cache hit confirmed on second call.

---

## Testing Strategy

**Test categories:**
- **Unit tests** (`tests/unit/`): ~15 files, no network needed. Tests option parsing, caching logic, utility programs, Mata functions, timer, frame operations, regex patterns.
- **Integration tests** (`tests/integration/`): ~10 files, require live PIP API. Tests all subcommands, tables, server setup, version checking, info/cite, full dispatcher routing, live cache round-trip.

**Assertion strategy:**
- Primary: structural (variables exist, types correct, N > 0, no `_rc` errors, globals/locals set correctly).
- Deferred: known-value checks, missingness warnings, error-handling tests.

**Test isolation:**
- Each test file is self-contained: sets up its own state, cleans up after.
- `run_all_tests.do` runner performs additional cleanup between tests (clear data, drop non-default frames).
- Unit tests use `adopath ++ "../.."` to find package `.ado` files.
- Integration tests call `pip` directly (full stack).

**Naming convention:**
- Unit: `tests/unit/test_<module_name>.do`
- Integration: `tests/integration/test_pip_<subcommand>.do`

## Documentation Checklist

- [x] Standard do-file headers on all test files (project, author, date, purpose)
- [ ] README update: add "Running Tests" section explaining how to run the suite
- [x] Inline comments in `test_helpers.do` explaining each assertion program
- [ ] Each test file documents what it tests and what layer it covers

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| API changes variable names | Integration tests break | Test for a **minimum** set of variables, not exact. Use `cap confirm var` pattern. |
| API is down during test run | Integration tests fail | Runner distinguishes network errors from logic errors in output. |
| Cache tests leave artifacts | Pollute user's cache | Unit cache tests use temp directories. Integration cache tests are non-destructive (write-only). |
| Mata library not compiled | Mata tests fail | `test_pip_fun_mata.do` runs `pip_fun.mata` directly at start. |
| `adopath` conflicts | Tests pick up wrong `.ado` version | Each test file explicitly sets `adopath` to project root. |

## Out of Scope

- **Error handling tests** — invalid inputs, conflicting options, graceful failure (roadmap)
- **Known-value checks** — asserting specific numeric results from API (roadmap)
- **Missingness warnings** — informational checks on API data quality (roadmap)
- **CI/CD integration** — no GitHub Actions, no automated runs
- **Performance benchmarks** — not testing speed, only correctness

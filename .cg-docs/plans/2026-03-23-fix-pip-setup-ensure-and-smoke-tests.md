---
date: 2026-03-23
title: "Fix missing pip_setup_ensure and add offline smoke tests"
status: active
brainstorm: ".cg-docs/brainstorms/2026-03-23-fix-pip-setup-ensure-and-smoke-tests.md"
language: "Stata"
estimated-effort: "medium"
tags: [bugs, testing-patterns, smoke-tests, pip_setup]
---

# Plan: Fix missing pip_setup_ensure and add offline smoke tests

## Objective

Define the missing `pip_setup_ensure` program that is blocking all `pip`
commands on the `revamp` branch, then create a reusable test-stub harness
and a suite of offline smoke tests that verify the top-level dispatch chain
never regresses again.

## Context

The `revamp` branch replaced three inline `cap findfile / pip_setup_create`
blocks in `pip_setup.ado` with calls to `pip_setup_ensure`, but that program
was never defined — producing `r(199)` on every `pip` call.

The existing test suite has 16 unit tests and 13 integration tests, all
targeting individual sub-programs. None tests the top-level `pip` command or
the `pip_setup` entry point. The integration test `test_pip_dispatcher.do`
tests routing but requires a live API, so it would not have been caught by
a fast offline CI run.

### Programs in the call chain (what gets called on `pip, clear`)

```
pip.ado
  └─ pip_setup              ← calls pip_setup_ensure (MISSING)
       ├─ pip_setup_dates
       ├─ pip_setup_ensure   ← findfile pip_setup.do, create if missing
       ├─ pip_setup_create   ← writes pip_setup.do
       ├─ pip_setup_replace  ← replaces lines in pip_setup.do
       └─ pip_setup_gethash  ← hash-based cache
  └─ pip_parseopts          ← pure parsing, no network
  └─ pip_split_options      ← pure parsing, no network
  └─ pip_timer              ← timing, no network
  └─ pip_set_server         ← health-check (NETWORK)
  └─ pip_new_session        ← pip_gh + pip_setup run (NETWORK)
  └─ pip_versions           ← API call (NETWORK)
  └─ pip_cl / pip_wb / ...  ← API calls (NETWORK)
```

For offline smoke tests we need to stub: `pip_new_session`, `pip_set_server`,
`pip_versions`, `pip_cl`, `pip_wb`, and related API-calling programs. The
stubs must set the minimum globals/returns that the `pip.ado` dispatcher
expects so execution completes without error.

## Implementation Steps

### Step 1: Define `pip_setup_ensure` in `pip_setup.ado`

- **Files**: `pip_setup.ado`
- **Details**: Add a new `program define pip_setup_ensure, rclass` block
  after `pip_setup_replace` and before `pip_setup_gethash`. Logic:
  ```
  1. cap findfile "pip_setup.do"
  2. if (_rc) pip_setup_create
  3. if (_rc still) → error with informative message ("could not
     find or create pip_setup.do — check writable directories")
  4. return local fn = "`r(fn)'"   (from findfile or pip_setup_create)
  ```
- **Tests**: Covered in Step 3 (unit tests for pip_setup_ensure).
- **Acceptance criteria**: `pip_setup run` and `pip_setup display` no longer
  produce `r(199)`. Running `which pip_setup_ensure` in Stata resolves the
  program.

### Step 2: Create reusable test-stub harness `tests/test_stubs.do`

- **Files**: `tests/test_stubs.do` (new)
- **Details**: A do-file that, when `run`, redefines network-dependent
  programs as no-ops or minimal stubs. Programs to stub:
  - `pip_new_session` — no-op (sets `$pip_version_checked = "1"`)
  - `pip_set_server` — sets `$pip_host` and `$pip_server` to dummy values,
    returns `r(server)`, `r(url)`, `r(base)`, `r(base_grp)`
  - `pip_versions` — sets `$pip_version` to a synthetic value like
    `"20230601_2017_01_02_PROD"`, returns `r(version)`
  - `pip_cl` — creates a minimal dataset with the expected variables
    (`country_code year headcount poverty_gap poverty_severity mean
    welfare_type`), labels it
  - `pip_wb` — creates a minimal dataset with expected variables
    (`region_code year headcount poverty_gap poverty_severity mean`)
  - `pip_gh` — no-op, returns `r(update_available) = "0"`
  - `pip_auxframes` — creates the minimum expected auxiliary frames
    with dummy data
  - `pip_get` — no-op (data already in memory from cl/wb stubs? or
    stubbed at the cl/wb level)

  Design notes:
  - Each stub is wrapped in `cap program drop ... / program define ...`
  - A header comment explains that this file is for **offline testing only**
  - A local `_stubs_loaded` is set so tests can verify stubs are active

- **Tests**: The stubs themselves don't need tests; they are validated by
  the smoke tests in Step 4.
- **Acceptance criteria**: After `run "tests/test_stubs.do"`, calling
  `pip, clear` completes without error and without network access.

### Step 3: Create unit tests for `pip_setup_ensure` — `tests/unit/test_pip_setup_ensure.do`

- **Files**: `tests/unit/test_pip_setup_ensure.do` (new)
- **Details**: Tests (offline, fast):
  1. `pip_setup_ensure` succeeds when `pip_setup.do` already exists on the
     adopath (normal case) — assert `r(fn)` non-empty and file exists
  2. `pip_setup_ensure` creates `pip_setup.do` when it does not exist —
     temporarily hide the real one (rename), call ensure, verify file
     created, restore original
  3. `pip_setup_ensure` returns `r(fn)` pointing to a valid path
  4. Calling `pip_setup run` no longer errors (`_rc == 0`)
  5. Calling `pip_setup display` no longer errors (`_rc == 0`)
- **Acceptance criteria**: All 5 tests pass; no network calls.

### Step 4: Create offline smoke tests — `tests/unit/test_pip_smoke.do`

- **Files**: `tests/unit/test_pip_smoke.do` (new)
- **Details**: Uses the stub harness from Step 2. Tests:
  1. `pip, clear` — completes without error, dataset has observations,
     `country_code` variable exists
  2. `pip cl, clear` — same checks
  3. `pip wb, clear` — completes without error, `region_code` exists
  4. `pip cl, clear fillgaps` — completes without error
  5. `pip_setup` (no args, raw call) — completes without error
  6. Verify stubs are active (no real API calls made) —
     check `$pip_host` == stub value

  Structure:
  ```stata
  adopath ++ "../.."
  run "../../pip_fun.mata"
  run "../test_helpers.do"
  run "../test_stubs.do"    // <-- activate stubs
  // ... tests ...
  ```
- **Acceptance criteria**: All 6 tests pass offline.

### Step 5: Create integration smoke tests — `tests/integration/test_pip_smoke_live.do`

- **Files**: `tests/integration/test_pip_smoke_live.do` (new)
- **Details**: Live API tests (complement to the offline smoke tests).
  These call the real API and verify end-to-end:
  1. `pip, clear` — N > 0, `country_code` exists
  2. `pip cl, clear` — N > 0, expected vars present
  3. `pip wb, clear` — N > 0, expected vars present
  4. `pip cl, clear fillgaps` — N > 0
  5. `pip cl, country(CHN) fillgaps clear` — N > 0, all rows CHN

  Note: The existing `test_pip_dispatcher.do` already tests some of this,
  but not `fillgaps` and not with the new `pip_setup_ensure` fix in place.
  This new file focuses specifically on the smoke-test surface agreed in the
  brainstorm.
- **Acceptance criteria**: All 5 tests pass with live internet.

### Step 6: Verify existing tests still pass

- **Files**: none (validation only)
- **Details**: Run `tests/run_unit_tests.do` and visually confirm
  all existing unit tests pass (integration tests require network
  and are run separately).
- **Acceptance criteria**: 0 failures in the unit suite.

## Testing Strategy

Two-layer approach:

| Layer | Location | Network | Purpose |
|-------|----------|---------|---------|
| Unit — setup | `tests/unit/test_pip_setup_ensure.do` | No | Guards the `pip_setup_ensure` fix directly |
| Unit — smoke | `tests/unit/test_pip_smoke.do` | No | Guards top-level dispatch chain offline |
| Integration — smoke | `tests/integration/test_pip_smoke_live.do` | Yes | End-to-end validation with real API |

Edge cases covered:
- `pip_setup.do` missing on disk (ensure creates it)
- No writable directory (ensure errors gracefully)
- fillgaps variant (different code path in `pip_cl`)
- Default subcommand routing (`pip, clear` → `pip cl`)

## Documentation Checklist

- [x] Function documentation: `pip_setup_ensure` gets a header comment
      explaining purpose, return values, and relationship to
      `pip_setup_create`
- [ ] README updates: not needed (internal plumbing, test infra)
- [x] Inline comments: stub harness and smoke tests get clear comments
- [x] Usage examples: test files serve as examples

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Stubs drift from real program signatures | Each stub has a comment referencing the real `.ado` file; stubs are minimal (no arg parsing beyond what's needed) |
| `pip_setup_ensure` masks deeper setup failures | The program includes an explicit error path with a diagnostic message when both findfile and create fail |
| Offline smoke tests pass but real commands fail | That's what the integration smoke tests are for — they test the same surface with the real API |
| Mata library rebuild triggers during tests | The stub for `pip_setup` (no args) avoids the Mata rebuild path by pre-setting `$pip_pipmata_hash` |

## Out of Scope

- `pip drop frame`, `pip drop global`, `pip print` tests (later iteration)
- `pip agg`, `pip cp`, `pip gd` smoke tests (later iteration)
- CI/CD pipeline integration (later)
- Refactoring `pip_setup.ado` beyond the `pip_setup_ensure` addition

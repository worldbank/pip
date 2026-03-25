---
date: 2026-03-23
title: "Fix missing pip_setup_ensure and add offline smoke tests"
status: decided
chosen-approach: "Fix + Reusable Test Harness"
tags: [bugs, testing-patterns, stata]
---

# Fix missing pip_setup_ensure and add offline smoke tests

## Context

The `revamp` branch refactored `pip_setup.ado` to replace three inline
`cap findfile / pip_setup_create` patterns with calls to `pip_setup_ensure`,
but that program was never defined. This causes `r(199)` on every invocation
of `pip`, making the package completely broken.

The existing test suite (16 unit + 13 integration tests) tests individual
sub-programs but has **no smoke test** for the top-level `pip` command or
`pip_setup` entry point, so the regression was not caught.

## Requirements

1. **Define `pip_setup_ensure`**: find `pip_setup.do`, create it if missing
   via `pip_setup_create`, return `r(fn)`. Include a guard for when no
   writable directory is available.
2. **Offline unit tests** (mock-based, no network):
   - `pip_setup` (no args) — the plumbing that broke
   - `pip_setup run` / `pip_setup display` — exercise `pip_setup_ensure`
   - `pip, clear` — top-level dispatch through setup → new_session
   - `pip wb, clear` — subcmd routing
   - `pip cl, clear` — subcmd routing
   - `pip, clear fillgaps` — fillgaps variant
3. **Integration tests** (live API): confirm the above commands work end-to-end.
4. **Reusable harness**: `tests/test_stubs.do` with stub definitions that can
   be extended when `pip drop`, `pip print`, etc. are tested later.
5. Mocks should be minimal — stub only `pip_new_session` (and any network
   programs it calls) for the offline smoke tests.

## Approaches Considered

### Approach 1: Minimal Fix + Lightweight Stub Smoke Tests

Define `pip_setup_ensure`, stub only `pip_new_session`, write a few smoke
tests.

- **Pros**: Simple, low maintenance, catches the exact class of bug.
- **Cons**: No reusable harness, harder to extend later.
- **Effort**: Small

### Approach 2: Full Mock Chain

Stub every network-dependent program (`pip_new_session`, `pip_get`,
`pip_auxframes`, `pip_versions`) for deep offline testing.

- **Pros**: Deep offline coverage.
- **Cons**: Heavy maintenance burden, fragile stubs.
- **Effort**: Large

### Approach 3: Fix + Reusable Test Harness (CHOSEN)

Define `pip_setup_ensure` with a writable-directory guard. Create a reusable
`tests/test_stubs.do` harness. Unit tests for `pip_setup_ensure` in isolation.
Smoke tests using the harness for top-level dispatch.

- **Pros**: Clean separation, reusable when adding more tests later, medium
  effort.
- **Cons**: Slightly more upfront work than Approach 1.
- **Effort**: Medium

## Decision

Approach 3 selected. The reusable harness provides a foundation for expanding
test coverage incrementally (e.g., `pip drop`, `pip print` later).

## Next Steps

1. Define `program define pip_setup_ensure` in `pip_setup.ado` — wraps
   `findfile` + `pip_setup_create` with a guard.
2. Create `tests/test_stubs.do` — reusable stub definitions for
   `pip_new_session`, `pip_versions`, and other network programs.
3. Create `tests/unit/test_pip_setup_ensure.do` — unit tests for the new
   program.
4. Create `tests/unit/test_pip_smoke.do` — offline smoke tests for
   `pip, clear`, `pip wb, clear`, `pip cl, clear`, `pip, clear fillgaps`.
5. Create `tests/integration/test_pip_smoke_live.do` — live API smoke tests.
6. Verify all existing tests still pass.

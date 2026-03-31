---
date: 2026-03-19
title: "Remove SSC support and simplify GitHub version checking"
status: decided
chosen-approach: "Clean Sweep + Lightweight Session Check"
tags: [ssc-removal, version-check, install, simplification]
---

# Remove SSC Support and Simplify GitHub Version Checking

## Context

The `pip` Stata package is no longer distributed via SSC — only via GitHub. The codebase still contains extensive SSC-related logic across multiple files (`pip_ssc.ado`, `pip_install.ado`, `pip_update.ado`, `pip_find_src.ado`, `pip_gh.ado`, `pip.ado`, and several `.sthlp` files). The GitHub version-checking mechanism in `pip_gh.ado` is also broken, relying on fragile parsing of `github.dta` and the GitHub API.

## Requirements

1. **Remove all SSC references** from `.ado` files, `.sthlp` files, and `README.md`.
2. **Delete `pip_ssc.ado`** entirely.
3. **Remove `pip install`, `pip uninstall`, and `pip update` subcommands** from `pip.ado`.
4. **Delete or gut** `pip_install.ado`, `pip_update.ado`, `pip_find_src.ado`.
5. **Implement a lightweight once-per-session version check** in `pip_new_session.ado`:
   - Hit the GitHub API releases endpoint once per Stata session (gated by a global like `$pip_version_checked`).
   - Get installed version from `which pip` (requires standardized `*!version` line at top of `pip.ado`).
   - If API call fails (firewall, no internet), silently skip.
   - If up to date, say nothing.
   - If outdated, display a single-line note with a clickable `{stata}` link.
6. **Install suggestion**: prefer `github install worldbank/pip, replace` if Haghish's `github` package is available (`cap which github`); fall back to `net install pip, from("https://raw.githubusercontent.com/worldbank/pip/main/") replace`.
7. **Standardize version in `pip.ado`**: move `*!version X.Y.Z` to the first line; remove the long version history at the bottom.
8. **Simplify `pip_gh.ado`**: keep only the version-check logic (refactored `_tmp_githubquery`); remove install/message subcommands.
9. **Update all `.sthlp` help files and `README.md`** to reflect GitHub-only distribution.

## Approaches Considered

### Approach 1: Clean Sweep + Lightweight Session Check (CHOSEN)

Remove all SSC code and install/update subcommands. Replace with a single once-per-session version check in `pip_new_session.ado`.

- **Delete**: `pip_ssc.ado`
- **Delete or gut**: `pip_install.ado`, `pip_update.ado`, `pip_find_src.ado`
- **Simplify**: `pip_gh.ado` — keep only version-check logic, remove install/message subcommands
- **Simplify**: `pip.ado` — remove `install`, `uninstall`, `update` subcommands and `ssc`/`gh` options; standardize `*!version` at top; delete version history at bottom
- **Simplify**: `pip_new_session.ado` — call new lightweight check; display one-liner with `{stata github install worldbank/pip, replace}` or `{stata net install ...}` fallback
- **Update**: all `.sthlp` files and `README.md` — remove SSC references

**Pros**: Maximum simplification; single code path; no more source-detection logic.
**Cons**: Larger diff; removes install convenience (users run `github install` themselves).
**Effort**: Medium.

### Approach 2: Keep `pip install` as a Thin Wrapper

Same cleanup but keep `pip install` as a convenience that runs `github install worldbank/pip` for the user.

**Pros**: Users can still type `pip install`.
**Cons**: Extra code surface; redundant with `github install`.
**Effort**: Medium.

### Approach 3: Incremental — Remove SSC First, Refactor Later

Only strip SSC references and delete `pip_ssc.ado`. Keep install/update pipeline hardcoded to GitHub.

**Pros**: Smaller diff.
**Cons**: Leaves broken version check; kicks the can.
**Effort**: Small.

## Decision

**Approach 1: Clean Sweep + Lightweight Session Check**. This fully removes dead SSC code, fixes the broken version check, and simplifies the codebase in one pass. Users are directed to use `github install worldbank/pip` (or `net install` fallback) directly.

## Next Steps

1. Create an implementation plan with `/cg-plan` covering:
   - File-by-file changes (deletions, edits)
   - New version-check logic in `pip_new_session.ado` / `pip_gh.ado`
   - Help file and README updates
   - Testing strategy
2. Implement step by step with `/cg-work`

---
date: 2026-03-19
title: "Remove SSC support, simplify install/update, fix version check"
status: active
brainstorm: ".cg-docs/brainstorms/2026-03-19-remove-ssc-simplify-version-check.md"
language: "Stata"
estimated-effort: "medium"
tags: [ssc-removal, version-check, install, simplification, cleanup]
---

# Plan: Remove SSC Support, Simplify Install/Update, Fix Version Check

## Objective

Remove all SSC-related code from the `pip` Stata package, eliminate the `install`/`uninstall`/`update` subcommands, and replace them with a lightweight once-per-session GitHub version check that notifies users when a newer version is available.

## Context

The `pip` package is no longer distributed via SSC — only via GitHub. The codebase still contains extensive dual-source (SSC/GitHub) install logic spread across `pip_ssc.ado`, `pip_install.ado`, `pip_update.ado`, `pip_find_src.ado`, and `pip_gh.ado`. The GitHub version-checking mechanism in `pip_gh.ado` is broken due to fragile dependency on `github.dta` and raw API parsing. The brainstorm decided on **Approach 1: Clean Sweep + Lightweight Session Check**.

## Implementation Steps

### Step 1: Standardize version in `pip.ado`

- **Files**: `pip.ado`
- **Details**:
  - Add `*!version 0.11.0` as the **first line** of `pip.ado` (above the header comment block). This enables `which pip` to reliably return the installed version. Bump to 0.11.0 since this is a breaking change (subcommands removed).
  - Delete the entire version history block at the bottom of the file (everything after the `exit` and `end` statements, from `*! version 0.0.1` through `*! version 0.10.17`).
- **Tests**: Run `which pip` in Stata and verify it returns `*!version 0.11.0`.
- **Acceptance criteria**: `which pip` returns the correct version string.

### Step 2: Remove install/uninstall/update subcommands from `pip.ado`

- **Files**: `pip.ado`
- **Details**:
  - Remove the `//------------Install and Uninstall` block (~lines 126–156) that handles `install`, `uninstall`, and `update` subcommands.
  - Replace with a friendly deprecation message for each: if user types `pip install`, `pip uninstall`, or `pip update`, display an informational message directing them to `github install worldbank/pip, replace` (or `net install` fallback), then exit.
  - The `ssc` and `gh` options parsed by `pip_parseopts` will no longer be consumed; they become harmless dead options. No change needed in `pip_parseopts.ado` — it's a generic parser.
- **Tests**: Verify `pip install`, `pip uninstall`, `pip update` each display the deprecation message and do not error.
- **Acceptance criteria**: Old subcommands produce helpful messages; no runtime errors.

### Step 3: Rewrite `pip_gh.ado` as a pure version-check utility

- **Files**: `pip_gh.ado`
- **Details**:
  - Gut the file. Remove the `update`, `msg`/`message`, and `install` subcommand blocks.
  - Keep and improve `_tmp_githubquery` (the auxiliary program that hits the GitHub API).
  - Rename the main program to a single-purpose design: `pip_gh` takes no subcommands. It:
    1. Gets the installed version via `which pip` (parse the `*!version X.Y.Z` line).
    2. Calls `_tmp_githubquery worldbank/pip` to get the latest release tag.
    3. Compares versions numerically.
    4. Returns `r(update_available)` (0/1), `r(latest_version)`, `r(current_version)`.
  - Make `_tmp_githubquery` more robust:
    - Wrap `fileread` in `capture` so network failures are silent.
    - If the API call fails, return empty `r(latestversion)` and exit cleanly.
    - Add `preserve`/`restore` to avoid corrupting user data.
  - Build the install command string with fallback logic:
    - `cap which github` — if available, suggest `github install worldbank/pip, replace`.
    - Otherwise, suggest `net install pip, from("https://raw.githubusercontent.com/worldbank/pip/main/") replace`.
  - Return the suggested command as `r(install_cmd)`.
- **Tests**: 
  - Call `pip_gh` when version is current → verify `r(update_available)` == 0.
  - Simulate outdated version → verify `r(update_available)` == 1 and `r(install_cmd)` is populated.
  - Disconnect network → verify silent exit, no error.
- **Acceptance criteria**: `pip_gh` reliably checks version, handles failures silently, returns structured results.

### Step 4: Rewrite `pip_new_session.ado` to use the new version check

- **Files**: `pip_new_session.ado`
- **Details**:
  - Remove the call to `pip_update` and `pip_find_src`.
  - Remove all references to `pip_source` global/local.
  - Remove the commented-out SSC dependency-check block (`ssc_cmds missings`).
  - Replace with:
    1. Check if `"${pip_version_checked}"` is non-empty → if so, skip (already checked this session).
    2. Call `pip_gh` (the rewritten version-check utility).
    3. If `r(update_available)` == 1, display a single-line notification:
       `noi disp as text "A new version of {cmd:pip} is available (" r(latest_version) "). To update, type: {stata `r(install_cmd)'}"`
    4. Set `global pip_version_checked "1"`.
  - Keep the `pip_setup` calls for globals that are still needed.
  - Remove the `local bye` / `` `bye' `` pattern (no more forced exits after install).
- **Tests**: 
  - First call in session displays check (or notification). Second call skips.
  - Network failure → no message, no error.
- **Acceptance criteria**: Version check runs once per session, notification is non-intrusive, failures are silent.

### Step 5: Delete obsolete files

- **Files to delete**: 
  - `pip_ssc.ado` — entirely SSC-specific, no longer needed.
  - `pip_install.ado` — install logic replaced by user running `github install` directly.
  - `pip_update.ado` — update logic replaced by version check in `pip_new_session.ado`.
  - `pip_find_src.ado` — source detection (SSC vs GitHub) no longer needed.
  - `pip_install.sthlp` — help file for removed subcommands.
- **Details**: Verify no other `.ado` file calls these programs (besides the ones we've already edited). Search for `pip_ssc`, `pip_install`, `pip_update`, `pip_find_src` across all `.ado` files.
- **Tests**: `pip` runs without errors after deletion. `help pip install` no longer works (expected).
- **Acceptance criteria**: No dangling references to deleted files.

### Step 6: Update `pip.sthlp` (main help file)

- **Files**: `pip.sthlp`
- **Details**:
  - Remove the `[un]install` row from the subcommand table (line ~43-44).
  - Update the "General Troubleshooting" section:
    - Replace `pip uninstall` with `github uninstall pip` (or manual deletion instructions).
    - Keep the `github install worldbank/pip` instruction.
    - Add `net install` as a fallback option.
    - Remove all SSC references.
  - Remove any mention of `pip install ssc`, `pip install gh`, `pip update`.
- **Tests**: `help pip` displays correctly in Stata viewer with no broken links.
- **Acceptance criteria**: No SSC references remain; troubleshooting steps are accurate.

### Step 7: Update `pip_intro.sthlp`

- **Files**: `pip_intro.sthlp`
- **Details**: Scan for SSC/install references. Currently this file appears clean (no SSC mentions), but verify and update if needed.
- **Acceptance criteria**: No SSC references.

### Step 8: Update `pip_misc.sthlp`

- **Files**: `pip_misc.sthlp`
- **Details**: Verify no SSC/install references. Currently appears clean.
- **Acceptance criteria**: No SSC references.

### Step 9: Update `pip_countries.sthlp`

- **Files**: `pip_countries.sthlp`
- **Details**: Remove the `{vieweralsosee "Install wbopendata" "ssc install wbopendata"}` line — this is an SSC install reference for a different package, but it's fine to keep if `wbopendata` is still on SSC. Review and decide.
- **Acceptance criteria**: Reviewed; SSC reference for `pip` specifically is gone.

### Step 10: Update `README.md`

- **Files**: `README.md`
- **Details**:
  - Remove the "From SSC" installation section entirely (including the "(Current version is out of date)" note).
  - Keep the "From GitHub" section as the primary install method.
  - Add `net install` as a secondary option for users who can't install the `github` package.
  - Update the troubleshooting section:
    - Replace `github uninstall pip` with both options (with/without `github` package).
    - Remove any SSC references.
  - Update the version badge if needed.
- **Tests**: README renders correctly on GitHub.
- **Acceptance criteria**: No SSC references; clear GitHub-only installation instructions.

### Step 11: Bump version via `make.do` and update `stata.toc`

- **Files**: `make.do`, `stata.toc` (auto-generated by `make`)
- **Details**:
  - In `make.do`, update the `version()` argument from `version(0.10.17)` to `version(0.11.0)`.
  - Run `make.do` in Stata (via the Stata MCP / `rundo` task). This regenerates `stata.toc` and the `.pkg` file with the new version number. This is the standard version-bump workflow for this project.
  - Verify `stata.toc` now says `v 0.11.0`.
- **Acceptance criteria**: `make.do` runs without errors; `stata.toc` version matches `pip.ado` version (0.11.0).

### Step 12: End-to-end smoke test

- **Files**: All modified files.
- **Details**: 
  - Fresh Stata session: run `pip, clear` — verify version check runs, data loads.
  - Second call: `pip, country(col) year(last) clear` — verify no repeat version check.
  - `pip install` → deprecation message.
  - `pip update` → deprecation message.
  - `pip uninstall` → deprecation message.
  - `help pip` → no broken links, no SSC references.
  - Disconnect network, fresh session: `pip, clear` → no error from version check.
- **Acceptance criteria**: All smoke tests pass.

## Testing Strategy

- **Unit-level**: Each rewritten `.ado` is tested in isolation (Steps 1–4).
- **Integration**: End-to-end smoke test after all changes (Step 12).
- **Edge cases**:
  - No internet / firewall blocks GitHub API → silent skip.
  - `github` package not installed → falls back to `net install` suggestion.
  - User types old subcommands → helpful deprecation message, not a cryptic error.
  - `which pip` returns unexpected format → handle gracefully.

## Documentation Checklist

- [ ] `pip.ado` header block updated with new version
- [ ] `pip.sthlp` — remove install/SSC sections, update troubleshooting
- [ ] `pip_install.sthlp` — deleted (subcommands removed)
- [ ] `pip_intro.sthlp` — verified clean
- [ ] `README.md` — GitHub-only install instructions
- [ ] `stata.toc` — version bumped
- [ ] Inline comments in `pip_gh.ado` and `pip_new_session.ado` explaining the version-check logic

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Users who type `pip install` get confused | Deprecation message with exact install command to copy |
| GitHub API rate limit (60 req/hr unauthenticated) | Once-per-session check; silent failure on HTTP errors |
| `which pip` output format varies across Stata versions | Parse conservatively; fall back to skipping check |
| `fileread` of HTTPS URL may not work behind corporate firewall | `capture` wrapping; silent skip; user can still use pip normally |
| Breaking change for users who scripted `pip install`/`pip update` | Clear deprecation message; document in release notes |

## Out of Scope

- **Automatic installation**: We will NOT auto-install updates. Only notify.
- **`github` package management**: We will NOT install/manage the `github` package itself.
- **Version pinning**: We will NOT add version-pinned installation support (users use `github install worldbank/pip, version(X.Y.Z)` directly).
- **`pip_cache.ado` changes**: Cache logic is unrelated; no changes needed.
- **Test suite creation**: The `tests/` directory is empty; creating a full test suite is a separate effort.

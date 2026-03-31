/*==================================================
project:       pip_setup compatibility test with offline stubs active
Author:        DECDG Team
Creation Date: 23 Mar 2026
Purpose:       Verify that pip_setup (no args) completes without error
               when the offline stub layer is active.  Tests the plumbing
               entry point in a fully offline environment.

               Extracted from test_pip_smoke.do (was Test 6) to keep each
               file focused on a single concern: this file tests pip_setup
               itself; test_pip_smoke.do tests the top-level dispatcher.

Layer:         Setup / offline compatibility
==================================================*/
version 16.1
set more off

adopath ++ "../.."
run "../../pip_fun.mata"

// Load shared assertion helpers and stubs.
run "../test_helpers.do"
run "../stubs.do"

di as result "=== pip_setup stub-compat tests ==="

// ---- Drop and reload pip_setup to ensure the fixed version is used -------
foreach _prog in pip_setup pip_setup_ensure pip_setup_create ///
    pip_setup_replace pip_setup_gethash pip_setup_dates pip_get_version {
    capture program drop `_prog'
}
run "../../pip_setup.ado"

// =========================================================
// Test 1: pip_setup (no args) — the plumbing entry point
// Confirms pip_setup completes without network calls when
// stubs have already set pip_host, pip_version, and
// pip_version_checked, short-circuiting all network gates.
// =========================================================
capture noisily pip_setup
local _rc1 = _rc
assert_rc_zero, test("1: pip_setup (no args) completes without error") rc(`_rc1')
assert_global_set, test("1: pip_host still set after pip_setup") global(pip_host)

// =========================================================
// Test 2: pip_setup run — explicitly exercises the run path
// pip_pipmata_hash is cleared to bypass the hash gate so
// pip_setup is forced to call pip_setup_ensure.  This is
// the call site that previously caused r(199).
// =========================================================
local _saved_hash "${pip_pipmata_hash}"
global pip_pipmata_hash ""   // force run path

capture noisily pip_setup run
local _rc2 = _rc

// Restore BEFORE asserting so a failing assert leaves state clean.
global pip_pipmata_hash "`_saved_hash'"

assert_rc_zero, test("2: pip_setup run succeeds with stubs active") rc(`_rc2')

clear
di as result _n "All pip_setup stub-compat tests passed."

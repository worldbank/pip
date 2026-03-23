/*==================================================
project:       Unit tests for pip_setup_ensure
Author:        DECDG Team
Creation Date: 23 Mar 2026
Purpose:       Verify that pip_setup_ensure correctly finds or creates
               pip_setup.do and returns r(fn) with the file path.
               Also validates the two call sites (pip_setup run and
               pip_setup display) that were broken by the missing program.
               Tests are fully offline — no API calls.
Layer:         Setup / file management
==================================================*/
version 16.1
set more off

adopath ++ "../.."
run "../../pip_fun.mata"

// Drop programs to ensure we load the fixed version from disk.
foreach _prog in                ///
    pip_setup                   ///
    pip_setup_ensure            ///
    pip_setup_create            ///
    pip_setup_replace           ///
    pip_setup_gethash           ///
    pip_setup_dates             ///
    pip_get_version             {
    capture program drop `_prog'
}
run "../../pip_setup.ado"

// Pre-set pip_host so the pip_set_server call inside pip_setup (no-args)
// is skipped.  We are not testing server connectivity here.
global pip_host "https://api.worldbank.org/pip/v1"

// Load shared assertion helpers.
run "../test_helpers.do"

di as result "=== pip_setup_ensure: find / create pip_setup.do ==="

// ---- Test 0: precondition — pip_setup.do is reachable on the ado path ----
// All subsequent tests depend on findfile locating pip_setup.do.  Failing
// here gives a clear diagnosis instead of cryptic errors downstream.
capture findfile "pip_setup.do"
if (_rc) {
    pip_test_fail, test("0: precondition: pip_setup.do on ado path") ///
        msg("pip_setup.do not found — check that adopath includes project root")
}
pip_test_pass, test("0: precondition: pip_setup.do on ado path")

// ---- Test 1: pip_setup_ensure succeeds when pip_setup.do already exists --
// This is the normal case on any machine that has run pip before.
capture pip_setup_ensure
local _rc1 = _rc
assert_rc_zero, test("1: pip_setup_ensure succeeds with existing pip_setup.do") ///
    rc(`_rc1')

// ---- Test 2: r(fn) is non-empty ------------------------------------------
local fn2 = "`r(fn)'"
if (`"`fn2'"' == `""') {
    pip_test_fail, test("2: r(fn) is non-empty") msg("r(fn) returned empty string")
}
pip_test_pass, test("2: r(fn) is non-empty")

// ---- Test 3: r(fn) path ends with pip_setup.do ---------------------------
if !regexm(lower("`fn2'"), "pip_setup\.do$") {
    pip_test_fail, test("3: r(fn) ends with pip_setup.do") ///
        msg(`"got: `fn2'"')
}
pip_test_pass, test("3: r(fn) path ends with pip_setup.do")

// ---- Test 4: the file returned by r(fn) actually exists on disk ----------
cap confirm file "`fn2'"
local _rc4 = _rc
assert_rc_zero, test("4: file returned by r(fn) exists on disk") rc(`_rc4')

// ---- Test 5: pip_setup run no longer errors (validates the r(199) fix) ---
// This was the EXACT failure mode before pip_setup_ensure was defined:
//   pip_setup called pip_setup_ensure which did not exist → r(199) abort.
// We clear pip_pipmata_hash so pip_setup cannot skip the run path via the
// hash gate.  The hash is RESTORED BEFORE asserting so a failing assert
// (which calls error) leaves the session in a clean state.
local _saved_hash "${pip_pipmata_hash}"
global pip_pipmata_hash ""   // force run path: hash mismatch triggers it

capture noisily pip_setup run
local _rc5 = _rc

global pip_pipmata_hash "`_saved_hash'"   // restore

assert_rc_zero, test("5: pip_setup run no longer produces r(199)") rc(`_rc5')

// ---- Test 6: pip_setup display no longer errors --------------------------
capture noisily pip_setup display
local _rc6 = _rc
assert_rc_zero, test("6: pip_setup display no longer produces r(199)") rc(`_rc6')

// ---- Test 7: pip_setup_ensure is idempotent (safe to call twice) ---------
capture pip_setup_ensure
local _rc7a = _rc
capture pip_setup_ensure
local _rc7b = _rc
assert_rc_zero, test("7a: pip_setup_ensure first call succeeds") rc(`_rc7a')
assert_rc_zero, test("7b: pip_setup_ensure second call succeeds") rc(`_rc7b')

clear
di as result _n "All pip_setup_ensure unit tests passed."

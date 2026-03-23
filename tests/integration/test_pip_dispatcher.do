/*==================================================
project:       Integration tests for pip dispatcher (pip.ado routing)
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Smoke-test the main pip.ado dispatcher: verify that each
               subcommand is correctly routed and returns data or completes
               without error. REQUIRES: live internet connection.
Layer:         Dispatcher (pip.ado)
==================================================*/
version 16.1
set more off

adopath ++ "../.."
run "../../pip_fun.mata"

* Load shared assertion helpers
run "../test_helpers.do"

di as result "=== pip dispatcher: subcommand routing ==="

// ---- Test 1: pip, clear (default = cl) returns country-level data -----
pip, clear
assert_nobs_positive, test("1: pip (default) returns N > 0")
assert_var_exists, test("1: country_code present in default output") var(country_code)
di as result "  PASS Test 1: default subcommand routes to cl"

// ---- Test 2: pip cl, clear — explicit country-level -----
pip cl, clear
assert_nobs_positive, test("2: pip cl returns N > 0")
assert_var_exists, test("2: country_code present") var(country_code)

// ---- Test 3: pip wb, clear — World Bank aggregate -----
pip wb, clear
assert_nobs_positive, test("3: pip wb returns N > 0")
assert_var_exists, test("3: region_code present") var(region_code)

// ---- Test 4: pip tables, clear — auxiliary tables list -----
capture noi pip tables, clear
assert_rc_zero, test("4: pip tables clears without error") rc(`=_rc')
assert_nobs_positive, test("4: pip tables returns N > 0")

// ---- Test 5: pip print, versions — displays versions without error -----
capture noi pip print, versions
assert_rc_zero, test("5: pip print versions runs without error") rc(`=_rc')

// ---- Test 6: pip cleanup — removes internal frames and globals -----
// First create some state
pip cl, clear
capture noi pip cleanup
assert_rc_zero, test("6: pip cleanup runs without error") rc(`=_rc')

// ---- Test 7: pip drop frame — drops pip_ frames -----
// Create a pip_ frame to drop
frame create pip_test_dispatcher_drop
capture noi pip drop frame
assert_rc_zero, test("7: pip drop frame runs without error") rc(`=_rc')
assert_frame_not_exists, test("7b: pip_test_dispatcher_drop was dropped") ///
    frame("pip_test_dispatcher_drop")

// ---- Test 8: pip drop global — clears pip_ globals -----
global pip_dispatcher_test_global "test_value"
capture noi pip drop global
assert_rc_zero, test("8: pip drop global runs without error") rc(`=_rc')
assert_global_empty, test("8b: pip_dispatcher_test_global cleared") ///
    global(pip_dispatcher_test_global)

// ---- Test 9: pip test — displays last query metadata without error -----
// First run a query to set pip_last_queries
pip cl, country(CHN) year(2018) clear
capture noi pip test
assert_rc_zero, test("9: pip test (show last query) runs without error") rc(`=_rc')

clear
di as result _n "All pip dispatcher integration tests passed."

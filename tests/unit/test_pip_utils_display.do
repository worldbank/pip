/*==================================================
project:       Smoke tests for pip_utils display/IO sub-programs
Author:        DECDG Team
Creation Date: 23 Mar 2026
Purpose:       Verify that the display-only utility programs (pip_utils_final_msg,
               pip_utils_output, pip_utils_disp_query, pip_utils_clicktable)
               do not crash on edge cases: empty data, missing globals,
               zero observations, and empty variable lists.
               All tests are fully offline.
Layer:         Utilities / display
==================================================*/
version 16.1
set more off

adopath ++ "../.."
run "../../pip_fun.mata"

foreach _p in pip_utils pip_utils_disp_query pip_utils_dropvars ///
    pip_utils_frameexists pip_utils_final_msg pip_utils_keep_frame ///
    pip_utils_clicktable pip_utils_output pip_utils_frame2locals {
    capture program drop `_p'
}
run "../../pip_utils.ado"

// Helpers: pip_cite is called by pip_utils_final_msg; provide a stub.
capture program drop pip_cite
program define pip_cite, rclass
    syntax [, reg_cite]
    return local cite_data "World Bank (stub citation)"
end

// Load shared assertion helpers.
run "../test_helpers.do"

di as result "=== pip_utils display/IO smoke tests ==="

// =========================================================
// Test 1: pip_utils_disp_query — no crash when queries are empty
// =========================================================
global pip_last_queries ""
capture noisily pip_utils_disp_query
local _rc1 = _rc
assert_rc_zero, test("1: pip_utils_disp_query with empty pip_last_queries") rc(`_rc1')

// =========================================================
// Test 2: pip_utils_disp_query — no crash with a well-formed query
// =========================================================
global pip_last_queries "https://api.worldbank.org/pip/v1/pip?country=all&year=all"
global pip_host         "https://api.worldbank.org/pip/v1"
capture noisily pip_utils_disp_query
local _rc2 = _rc
assert_rc_zero, test("2: pip_utils_disp_query with a valid query URL") rc(`_rc2')
global pip_last_queries ""

// =========================================================
// Test 3: pip_utils_output — no crash with 0 observations
// =========================================================
clear
set obs 0
capture noisily pip_utils_output, n2disp(1)
local _rc3 = _rc
assert_rc_zero, test("3: pip_utils_output with 0 observations") rc(`_rc3')

// =========================================================
// Test 4: pip_utils_output — no crash with n2disp=1 and 2 rows
// =========================================================
clear
set obs 2
gen str3 country_code = cond(_n == 1, "CHN", "IND")
gen year = 2018
gen headcount = 0.01 * _n
capture noisily pip_utils_output, n2disp(1) dispvars(country_code year headcount)
local _rc4 = _rc
assert_rc_zero, test("4: pip_utils_output prints first row without error") rc(`_rc4')

// =========================================================
// Test 5: pip_utils_final_msg — no crash when pip_old_session is unset
// =========================================================
global pip_old_session ""
capture noisily pip_utils_final_msg
local _rc5 = _rc
assert_rc_zero, test("5: pip_utils_final_msg with empty pip_old_session") rc(`_rc5')

// =========================================================
// Test 6: pip_utils_clicktable — no crash when variable has no levels
// =========================================================
clear
set obs 0
gen str3 region = ""
// levelsof on an empty variable returns "" — the program should exit cleanly.
capture noisily pip_utils_clicktable, variable(region) title("test") statacode("noi disp")
local _rc6 = _rc
assert_rc_zero, test("6: pip_utils_clicktable with 0 levels exits cleanly") rc(`_rc6')

// =========================================================
// Test 7: pip_utils_clicktable — no crash with valid levels
// =========================================================
clear
set obs 3
gen str3 country_code = cond(_n == 1, "CHN", cond(_n == 2, "IND", "BRA"))
capture noisily pip_utils_clicktable, variable(country_code) title("Countries:") ///
    statacode(`"noi disp "' )
local _rc7 = _rc
assert_rc_zero, test("7: pip_utils_clicktable with 3 levels prints cleanly") rc(`_rc7')

clear
// Drop the pip_cite stub so real pip_cite loads next time.
capture program drop pip_cite

di as result _n "All pip_utils display/IO smoke tests passed."

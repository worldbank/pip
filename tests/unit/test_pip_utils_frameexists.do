/*==================================================
project:       Unit tests for pip_utils_frameexists
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip_utils_frameexists returns r(fexists)==1 for existing
               frames and r(fexists)==0 for non-existing frames.
               Tests are fully offline — no API calls.
Layer:         Utilities
==================================================*/
version 16.1
set more off

adopath ++ "../.."
foreach _prog in pip_utils pip_utils_frameexists pip_utils_disp_query     ///
    pip_utils_dropvars pip_utils_final_msg pip_utils_keep_frame            ///
    pip_utils_clicktable pip_utils_output pip_utils_frame2locals {
    capture program drop `_prog'
}
run "../../pip_utils.ado"

* Load shared assertion helpers
run "../test_helpers.do"

di as result "=== pip_utils: frameexists ==="

// ---- Test 1: existing frame returns r(fexists)==1 -----
frame create _test_pip_fx_1
pip_utils_frameexists, frame("_test_pip_fx_1")
local fex1 = "`r(fexists)'"
assert_local_equal, test("1: existing frame -> r(fexists)==1") got("`fex1'") expected("1")
frame drop _test_pip_fx_1

// ---- Test 2: non-existing frame returns r(fexists)==0 -----
pip_utils_frameexists, frame("_test_pip_fx_definitely_does_not_exist")
local fex2 = "`r(fexists)'"
assert_local_equal, test("2: non-existing frame -> r(fexists)==0") got("`fex2'") expected("0")

// ---- Test 3: the default frame always exists -----
pip_utils_frameexists, frame("default")
local fex3 = "`r(fexists)'"
assert_local_equal, test("3: default frame always exists") got("`fex3'") expected("1")

di as result _n "All pip_utils_frameexists tests passed."

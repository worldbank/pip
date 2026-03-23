/*==================================================
project:       Unit tests for pip_utils_frame2locals
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip_utils_frame2locals correctly returns each cell
               of the current dataset as r(varname_row) macros.
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

di as result "=== pip_utils: frame2locals ==="

// ---- Test 1: single-row dataset — each variable becomes r(var_1) -----
clear
set obs 1
gen country_code = "CHN"
gen year = 2018
pip_utils_frame2locals
local _cc1 = "`r(country_code_1)'"
local _yr1 = "`r(year_1)'"
assert_local_equal, test("1a: r(country_code_1)==CHN") got("`_cc1'") expected("CHN")
assert_local_equal, test("1b: r(year_1)==2018") got("`_yr1'") expected("2018")

// ---- Test 2: multi-row dataset — returns r(var_1) and r(var_2) -----
clear
set obs 2
gen str3 code = ""
replace code = "IND" in 1
replace code = "COL" in 2
gen n = _n
pip_utils_frame2locals
local _c1 = "`r(code_1)'"
local _c2 = "`r(code_2)'"
local _n1 = "`r(n_1)'"
local _n2 = "`r(n_2)'"
assert_local_equal, test("2a: r(code_1)==IND") got("`_c1'") expected("IND")
assert_local_equal, test("2b: r(code_2)==COL") got("`_c2'") expected("COL")
assert_local_equal, test("2c: r(n_1)==1") got("`_n1'") expected("1")
assert_local_equal, test("2d: r(n_2)==2") got("`_n2'") expected("2")

// ---- Test 3: string and numeric variables both returned correctly -----
clear
set obs 1
gen str10 label = "poverty"
gen double value = 2.15
pip_utils_frame2locals
local _lbl = "`r(label_1)'"
local _val = "`r(value_1)'"
assert_local_equal, test("3a: string var returned") got("`_lbl'") expected("poverty")
// numeric value returned as string representation — check it is non-empty
if ("`_val'" == "") {
    di as error "FAIL Test 3b: r(value_1) is empty for numeric variable"
    error 9
}
di as result "  PASS Test 3b: numeric var returned as non-empty string"

clear
di as result _n "All pip_utils_frame2locals tests passed."

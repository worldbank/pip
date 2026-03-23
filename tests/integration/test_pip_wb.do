/*==================================================
project:       Integration tests for pip wb (World Bank aggregate)
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip wb returns structurally valid data.
               REQUIRES: live internet connection.
Layer:         API subcommands
==================================================*/
version 16.1
set more off

adopath ++ "../.."
run "../../pip_fun.mata"

* Load shared assertion helpers
run "../test_helpers.do"

di as result "=== pip wb: World Bank aggregate API ==="

// ---- Minimum variable set expected from pip wb -----
local wb_min_vars "region_code year headcount poverty_gap poverty_severity mean"

// ---- Test 1: default call returns data -----
pip wb, clear
assert_nobs_positive, test("1: pip wb default returns N > 0")
foreach v of local wb_min_vars {
    assert_var_exists, test("1: var `v' exists (default)") var(`v')
}
di as result "  PASS Test 1: pip wb default — structure OK"

// ---- Test 2: key variable types -----
assert_var_type, test("2a: region_code is string") var(region_code) type(string)
assert_var_type, test("2b: year is numeric") var(year) type(numeric)
assert_var_type, test("2c: headcount is numeric") var(headcount) type(numeric)

// ---- Test 3: pip wb, region(SSA) clear -----
pip wb, region(SSA) clear
assert_nobs_positive, test("3a: pip wb region(SSA) returns N > 0")
// All rows should be SSA
qui count if region_code != "SSA"
if (r(N) > 0) {
    di as error "FAIL Test 3b: non-SSA rows in region(SSA) result"
    error 9
}
di as result "  PASS Test 3b: all rows are SSA"

// ---- Test 4: pip wb, povline(3.20) clear -----
pip wb, povline(3.20) clear
assert_nobs_positive, test("4: pip wb povline(3.20) returns N > 0")
foreach v of local wb_min_vars {
    assert_var_exists, test("4: var `v' exists (povline)") var(`v')
}

// ---- Test 5: pip wb, year(2019) clear -----
pip wb, year(2019) clear
assert_nobs_positive, test("5: pip wb year(2019) returns N > 0")
qui count if year != 2019
if (r(N) > 0) {
    di as error "FAIL Test 5b: non-2019 rows in year(2019) result"
    error 9
}
di as result "  PASS Test 5b: all rows are year 2019"

clear
di as result _n "All pip wb integration tests passed."

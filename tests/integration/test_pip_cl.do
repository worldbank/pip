/*==================================================
project:       Integration tests for pip cl (country-level)
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip cl returns structurally valid data for default and
               parameterised queries. REQUIRES: live internet connection.
               Checks: dataset non-empty, minimum expected variables present,
               correct storage types. No value assertions.
Layer:         API subcommands
==================================================*/
version 16.1
set more off

adopath ++ "../.."
run "../../pip_fun.mata"

* Load shared assertion helpers
run "../test_helpers.do"

di as result "=== pip cl: country-level API ==="

// ---- Minimum variable set expected from pip cl -----
// Tests check for this set; additional vars added by the API are ignored.
local cl_min_vars "country_code year headcount poverty_gap poverty_severity mean"

// ---- Test 1: default call returns data -----
pip cl, clear
assert_nobs_positive, test("1: pip cl default returns N > 0")
foreach v of local cl_min_vars {
    assert_var_exists, test("1: var `v' exists (default)") var(`v')
}
di as result "  PASS Test 1: pip cl default — structure OK"

// ---- Test 2: key variable types -----
assert_var_type, test("2a: country_code is string") var(country_code) type(string)
assert_var_type, test("2b: year is numeric") var(year) type(numeric)
assert_var_type, test("2c: headcount is numeric") var(headcount) type(numeric)
assert_var_type, test("2d: poverty_gap is numeric") var(poverty_gap) type(numeric)
assert_var_type, test("2e: mean is numeric") var(mean) type(numeric)

// ---- Test 3: pip cl, country(CHN) clear -----
pip cl, country(CHN) clear
assert_nobs_positive, test("3a: pip cl country(CHN) returns N > 0")
// All rows should be CHN
qui count if country_code != "CHN"
if (r(N) > 0) {
    di as error "FAIL Test 3b: non-CHN rows in country(CHN) result"
    error 9
}
di as result "  PASS Test 3b: all rows are CHN"
foreach v of local cl_min_vars {
    assert_var_exists, test("3c: var `v' exists (CHN)") var(`v')
}

// ---- Test 4: pip cl, country(CHN) year(2018) clear -----
pip cl, country(CHN) year(2018) clear
assert_nobs_positive, test("4: pip cl CHN 2018 returns N > 0")

// ---- Test 5: pip cl, country(CHN) fillgaps clear -----
capture noi pip cl, country(CHN) fillgaps clear
local _rc5 = _rc
assert_rc_zero, test("5: pip cl fillgaps succeeds") rc(`_rc5')
assert_nobs_positive, test("5: pip cl fillgaps returns N > 0")

// ---- Test 6: pip cl, povline(3.20) clear -----
pip cl, povline(3.20) clear
assert_nobs_positive, test("6: pip cl povline(3.20) returns N > 0")
foreach v of local cl_min_vars {
    assert_var_exists, test("6: var `v' exists (povline)") var(`v')
}

// ---- Test 7: pip cl, popshare(0.5) clear -----
// popshare returns welfare threshold instead of headcount
pip cl, country(CHN) popshare(0.5) clear
assert_nobs_positive, test("7: pip cl popshare(0.5) returns N > 0")

clear
di as result _n "All pip cl integration tests passed."

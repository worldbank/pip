/*==================================================
project:       Integration tests for pip cp (country profile)
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip cp returns structurally valid data.
               REQUIRES: live internet connection.
Layer:         API subcommands
==================================================*/
version 16.1
set more off

adopath ++ "../.."
run "../../pip_fun.mata"

* Load shared assertion helpers
run "../test_helpers.do"

di as result "=== pip cp: country profile API ==="

// ---- Test 1: default call returns data -----
pip cp, clear
assert_nobs_positive, test("1: pip cp default returns N > 0")
di as result "  PASS Test 1: pip cp default returned data"

// ---- Test 2: expected structural variables present -----
// pip cp returns country-level profile data
local cp_min_vars "country_code"
foreach v of local cp_min_vars {
    assert_var_exists, test("2: var `v' exists") var(`v')
}

// ---- Test 3: country_code is string -----
assert_var_type, test("3: country_code is string") var(country_code) type(string)

// ---- Test 4: pip cp, country(CHN) clear -----
pip cp, country(CHN) clear
assert_nobs_positive, test("4a: pip cp country(CHN) returns N > 0")
// All rows should be CHN
qui count if country_code != "CHN"
if (r(N) > 0) {
    di as error "FAIL Test 4b: non-CHN rows in country(CHN) result"
    error 9
}
di as result "  PASS Test 4b: all rows are CHN"

clear
di as result _n "All pip cp integration tests passed."

/*==================================================
project:       Integration tests for pip agg (aggregate)
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip agg returns structurally valid data.
               REQUIRES: live internet connection.
Layer:         API subcommands
==================================================*/
version 16.1
set more off

adopath ++ "../.."
run "../../pip_fun.mata"

* Load shared assertion helpers
run "../test_helpers.do"

di as result "=== pip agg: aggregate API ==="

// ---- Test 1: default call returns data -----
pip agg, clear
assert_nobs_positive, test("1: pip agg default returns N > 0")
di as result "  PASS Test 1: pip agg default returned data"

// ---- Test 2: expected structural variables present -----
// pip agg returns region-year level aggregates — check core vars
local agg_min_vars "region_code year headcount"
foreach v of local agg_min_vars {
    assert_var_exists, test("2: var `v' exists") var(`v')
}

// ---- Test 3: key variable types -----
assert_var_type, test("3a: region_code is string") var(region_code) type(string)
assert_var_type, test("3b: year is numeric") var(year) type(numeric)
assert_var_type, test("3c: headcount is numeric") var(headcount) type(numeric)

// ---- Test 4: pip agg, povline(3.20) clear -----
pip agg, povline(3.20) clear
assert_nobs_positive, test("4: pip agg povline(3.20) returns N > 0")
foreach v of local agg_min_vars {
    assert_var_exists, test("4: var `v' exists (povline)") var(`v')
}

clear
di as result _n "All pip agg integration tests passed."

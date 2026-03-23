/*==================================================
project:       Integration tests for pip gd (grouped data)
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip gd returns structurally valid data given a
               Lorenz curve input. REQUIRES: live internet connection.
Layer:         API subcommands
==================================================*/
version 16.1
set more off

adopath ++ "../.."
run "../../pip_fun.mata"

* Load shared assertion helpers
run "../test_helpers.do"

di as result "=== pip gd: grouped data API ==="

// ---- Lorenz curve input: cumulative welfare and population shares -----
// A valid (though synthetic) Lorenz curve must be monotone and
// start above 0 and end at 1.
local cum_welf "0.04 0.11 0.23 0.41 0.62 0.80 0.91 0.97 1.00"
local cum_pop  "0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 1.00"
local req_mean "300"

// ---- Test 1: pip gd returns data -----
pip gd, cum_welfare(`cum_welf') cum_population(`cum_pop') ///
    requested_mean(`req_mean') clear
assert_nobs_positive, test("1: pip gd returns N > 0")
di as result "  PASS Test 1: pip gd returned data"

// ---- Test 2: expected structural variables present -----
// pip gd returns poverty statistics at the specified poverty line
local gd_min_vars "headcount poverty_gap"
foreach v of local gd_min_vars {
    assert_var_exists, test("2: var `v' exists") var(`v')
}

// ---- Test 3: key variables are numeric -----
assert_var_type, test("3a: headcount is numeric") var(headcount) type(numeric)
assert_var_type, test("3b: poverty_gap is numeric") var(poverty_gap) type(numeric)

// ---- Test 4: pip gd with explicit povline -----
pip gd, cum_welfare(`cum_welf') cum_population(`cum_pop') ///
    requested_mean(`req_mean') povline(2.15) clear
assert_nobs_positive, test("4: pip gd with povline(2.15) returns N > 0")

clear
di as result _n "All pip gd integration tests passed."

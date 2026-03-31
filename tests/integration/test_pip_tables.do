/*==================================================
project:       Integration tests for pip tables
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip tables loads auxiliary tables with the correct
               structure. REQUIRES: live internet connection.
Layer:         Tables/auxiliary
==================================================*/
version 16.1
set more off

adopath ++ "../.."
run "../../pip_fun.mata"

* Load shared assertion helpers
run "../test_helpers.do"

di as result "=== pip tables: auxiliary tables ==="

// ---- Test 1: pip tables (default list) returns data -----
pip tables, clear
assert_nobs_positive, test("1: pip tables default returns N > 0")
di as result "  PASS Test 1: pip tables default returned data"

// ---- Test 2: pip tables, table(countries) -----
pip tables, table(countries) clear
assert_nobs_positive, test("2a: countries table has N > 0")
assert_var_exists, test("2b: country_code exists") var(country_code)
assert_var_exists, test("2c: country_name exists") var(country_name)
assert_var_type, test("2d: country_code is string") var(country_code) type(string)

// ---- Test 3: pip tables, table(regions) -----
pip tables, table(regions) clear
assert_nobs_positive, test("3a: regions table has N > 0")
assert_var_exists, test("3b: region_code exists") var(region_code)
assert_var_type, test("3c: region_code is string") var(region_code) type(string)

// ---- Test 4: pip tables, table(framework) -----
pip tables, table(framework) clear
assert_nobs_positive, test("4a: framework table has N > 0")
assert_var_exists, test("4b: country_code exists in framework") var(country_code)
assert_var_exists, test("4c: year exists in framework") var(year)

// ---- Test 5: pip tables, table(country_list) -----
pip tables, table(country_list) clear
assert_nobs_positive, test("5: country_list table has N > 0")

clear
di as result _n "All pip tables integration tests passed."

/*==================================================
project:       Integration tests for pip_auxframes
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip_auxframes creates auxiliary frames with expected
               structure after a version is set.
               REQUIRES: live internet connection.
Layer:         Tables/auxiliary
==================================================*/
version 16.1
set more off

adopath ++ "../.."
run "../../pip_fun.mata"

* Load shared assertion helpers
run "../test_helpers.do"

di as result "=== pip_auxframes: auxiliary frame creation ==="

// ---- Bootstrap: need pip_version and pip_host -----
// pip cl will call pip_setup and set the version
clear
pip cl, clear

// pip_version is now set by the above call
local _ver = "${pip_version}"
if ("`_ver'" == "") {
    di as error "FAIL setup: pip_version not set after pip cl"
    error 9
}

// Parse version to get the suffix used in frame names
tokenize "${pip_version}", parse("_")
local _version "_`1'_`3'_`9'"

// ---- Test 1: countries frame exists -----
local cts_frame "_pip_cts`_version'"
assert_frame_exists, test("1: countries frame exists") frame("`cts_frame'")

// ---- Test 2: regions frame exists -----
local rgn_frame "_pip_regions`_version'"
assert_frame_exists, test("2: regions frame exists") frame("`rgn_frame'")

// ---- Test 3: framework frame exists -----
local fw_frame "_pip_fw`_version'"
assert_frame_exists, test("3: framework frame exists") frame("`fw_frame'")

// ---- Test 4: countries frame has country_code -----
frame `cts_frame' {
    assert_var_exists, test("4a: country_code in countries frame") var(country_code)
    assert_nobs_positive, test("4b: countries frame non-empty")
}

// ---- Test 5: regions frame has region_code -----
frame `rgn_frame' {
    assert_var_exists, test("5a: region_code in regions frame") var(region_code)
    assert_nobs_positive, test("5b: regions frame non-empty")
}

// ---- Test 6: framework frame has key variables -----
frame `fw_frame' {
    assert_var_exists, test("6a: country_code in framework frame") var(country_code)
    assert_var_exists, test("6b: year in framework frame") var(year)
    assert_var_exists, test("6c: welfare_type in framework frame") var(welfare_type)
    assert_nobs_positive, test("6d: framework frame non-empty")
}

clear
di as result _n "All pip_auxframes integration tests passed."

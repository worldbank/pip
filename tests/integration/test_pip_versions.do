/*==================================================
project:       Integration tests for pip_versions
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip_versions correctly queries the API and sets the
               pip_version global. REQUIRES: live internet connection.
Layer:         Session/setup
==================================================*/
version 16.1
set more off

adopath ++ "../.."

* Load pip and all dependencies needed for pip_versions
foreach _prog in pip_set_server pip_get pip_versions pip_utils_frameexists ///
    pip_utils pip_utils_disp_query pip_utils_dropvars pip_utils_final_msg   ///
    pip_utils_keep_frame pip_utils_clicktable pip_utils_output              ///
    pip_utils_frame2locals pip_timer pip_cache pip_cache_gethash {
    capture program drop `_prog'
}
run "../../pip_fun.mata"
run "../../pip_set_server.ado"
run "../../pip_get.ado"
run "../../pip_utils.ado"
run "../../pip_timer.ado"
run "../../pip_cache.ado"
run "../../pip_versions.ado"

* Load shared assertion helpers
run "../test_helpers.do"

di as result "=== pip_versions: version selection ==="

// Bootstrap: need pip_host set
global pip_host ""
global pip_version ""
global pip_server ""
pip_set_server

// ---- Test 1: pip_versions sets pip_version to a valid vintage string -----
pip_timer   // initialise timer struct
pip_versions
local _ver1 = "${pip_version}"
assert_global_set, test("1: pip_version global is set") global(pip_version)

local _vintage_pattern "[0-9]{8}_[0-9]{4}_[0-9]{2}_[0-9]{2}_(PROD|INT|TEST)"
if !ustrregexm("`_ver1'", "`_vintage_pattern'") {
    di as error "FAIL Test 1b: pip_version '`_ver1'' does not match vintage pattern"
    error 9
}
di as result "  PASS Test 1b: pip_version matches vintage pattern: `_ver1'"

// ---- Test 2: r(release), r(ppp_year), r(identity) all non-empty -----
local _release  = "`r(release)'"
local _ppp_year = "`r(ppp_year)'"
local _identity = "`r(identity)'"
if ("`_release'" == "") {
    di as error "FAIL Test 2a: r(release) is empty"
    error 9
}
if ("`_ppp_year'" == "") {
    di as error "FAIL Test 2b: r(ppp_year) is empty"
    error 9
}
if ("`_identity'" == "") {
    di as error "FAIL Test 2c: r(identity) is empty"
    error 9
}
di as result "  PASS Test 2: r(release)=`_release', r(ppp_year)=`_ppp_year', r(identity)=`_identity'"

// ---- Test 3: pip_versions availability lists versions without error -----
capture noi pip_versions, availability
assert_rc_zero, test("3: pip_versions availability succeeds") rc(`=_rc')

// ---- Test 4: the versions frame exists with expected variables -----
// pip_versions stores its data in _pip_versions_<server>
local _vframe "_pip_versions_${pip_server}"
assert_frame_exists, test("4a: versions frame _pip_versions_* exists") frame("`_vframe'")

frame `_vframe' {
    assert_var_exists, test("4b: version var in versions frame") var(version)
    assert_var_exists, test("4c: release var in versions frame") var(release)
    assert_var_exists, test("4d: ppp_year var in versions frame") var(ppp_year)
    assert_var_exists, test("4e: identity var in versions frame") var(identity)
    assert_nobs_positive, test("4f: versions frame has at least 1 row")
}

di as result _n "All pip_versions integration tests passed."

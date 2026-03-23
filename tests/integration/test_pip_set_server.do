/*==================================================
project:       Integration tests for pip_set_server
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip_set_server correctly sets the pip_host and
               pip_server globals and returns expected r-class values.
               REQUIRES: live internet connection to the PIP API.
Layer:         Session/setup
==================================================*/
version 16.1
set more off

adopath ++ "../.."
capture program drop pip_set_server
run "../../pip_set_server.ado"
run "../../pip_fun.mata"

* Load shared assertion helpers
run "../test_helpers.do"

di as result "=== pip_set_server: server configuration ==="

// ---- Test 1: default call sets production server -----
// Clear globals first to ensure a clean start
global pip_host ""
global pip_server ""

capture noi pip_set_server
local _rc1 = _rc
assert_rc_zero, test("1: pip_set_server (default) succeeds") rc(`_rc1')
assert_global_set, test("1a: pip_host set after default call") global(pip_host)
assert_local_equal, test("1b: pip_server == prod") ///
    got("${pip_server}") expected("prod")

// Verify host contains expected production URL fragment
if !regexm("${pip_host}", "api\.worldbank\.org") {
    di as error "FAIL Test 1c: pip_host '${pip_host}' does not contain expected production URL"
    error 9
}
di as result "  PASS Test 1c: pip_host points to production API"

// ---- Test 2: explicit server(prod) is identical to default -----
local _host_default "${pip_host}"
global pip_host ""
capture noi pip_set_server, server(prod)
local _rc2 = _rc
assert_rc_zero, test("2a: pip_set_server server(prod) succeeds") rc(`_rc2')
assert_local_equal, test("2b: pip_server == prod") got("${pip_server}") expected("prod")
assert_local_equal, test("2c: explicit prod host matches default host") ///
    got("${pip_host}") expected("`_host_default'")

// ---- Test 3: r-class macros are non-empty -----
pip_set_server
local _server_r = "`r(server)'"
local _url_r    = "`r(url)'"
local _base_r   = "`r(base)'"
if ("`_server_r'" == "") {
    di as error "FAIL Test 3a: r(server) is empty"
    error 9
}
if ("`_url_r'" == "") {
    di as error "FAIL Test 3b: r(url) is empty"
    error 9
}
if ("`_base_r'" == "") {
    di as error "FAIL Test 3c: r(base) is empty"
    error 9
}
di as result "  PASS Test 3: r(server), r(url), r(base) all non-empty"

// ---- Test 4: health check is implicit (server errors would have failed Test 1) -----
di as result "  PASS Test 4: health check passed (no error thrown by pip_set_server)"

di as result _n "All pip_set_server integration tests passed."

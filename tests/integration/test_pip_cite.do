/*==================================================
project:       Integration tests for pip_cite
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip_cite returns non-empty citation strings containing
               expected fragments. Requires pip_versions (live API).
               REQUIRES: live internet connection.
Layer:         Info/cite
==================================================*/
version 16.1
set more off

adopath ++ "../.."
run "../../pip_fun.mata"

* Load shared assertion helpers
run "../test_helpers.do"

di as result "=== pip_cite: citation strings ==="

// ---- Bootstrap: need pip_ado_version set -----
// A quick pip cl call will set everything up
pip cl, clear

// ---- Test 1: pip_cite, reg_cite returns non-empty citation macros -----
pip_cite, reg_cite
local _cite_ado  = `"`r(cite_ado)'"'
local _cite_data = `"`r(cite_data)'"'

if (`"`_cite_ado'"' == "") {
    di as error "FAIL Test 1a: r(cite_ado) is empty"
    error 9
}
if (`"`_cite_data'"' == "") {
    di as error "FAIL Test 1b: r(cite_data) is empty"
    error 9
}
di as result "  PASS Test 1: r(cite_ado) and r(cite_data) are non-empty"

// ---- Test 2: citation strings contain expected key fragments -----
// Ado citation should mention "pip", "World Bank", and a version number
foreach frag in "pip" "World Bank" {
    if !strpos(`"`_cite_ado'"', "`frag'") {
        di as error `"FAIL Test 2a: cite_ado does not contain '`frag''"'
        error 9
    }
}
di as result "  PASS Test 2a: cite_ado contains 'pip' and 'World Bank'"

// Data citation should mention "World Bank" and "Poverty"
foreach frag in "World Bank" "Poverty" {
    if !strpos(`"`_cite_data'"', "`frag'") {
        di as error `"FAIL Test 2b: cite_data does not contain '`frag''"'
        error 9
    }
}
di as result "  PASS Test 2b: cite_data contains 'World Bank' and 'Poverty'"

// ---- Test 3: pip_cite, ado_bibtext runs without error -----
capture noi pip_cite, ado_bibtext
assert_rc_zero, test("3: pip_cite ado_bibtext runs without error") rc(`=_rc')

// ---- Test 4: pip_cite, data_bibtext runs without error -----
capture noi pip_cite, data_bibtext
assert_rc_zero, test("4: pip_cite data_bibtext runs without error") rc(`=_rc')

clear
di as result _n "All pip_cite integration tests passed."

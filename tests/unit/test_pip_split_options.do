/*==================================================
project:       Unit tests for pip_split_options
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip_split_options correctly classifies option names
               into general options and estimation options.
               Tests are fully offline — no API calls.
Layer:         Option parsing
==================================================*/
version 16.1
set more off

adopath ++ "../.."

* pip_split_options is defined inside pip.ado — load the full ado
capture program drop pip
capture program drop pip_split_options
capture program drop pip_parseopts
run "../../pip.ado"
run "../../pip_parseopts.ado"

* pip_fun.mata must be compiled for pip_abb_regex (used by pip_split_options)
run "../../pip_fun.mata"

* Load shared assertion helpers (relative path from unit/ to tests/)
run "../test_helpers.do"

di as result "=== pip_split_options: option classification ==="

// ---- Test 1: known general options classified into r(gen_opts) -----
local gen_expected "version ppp_year release identity server n2disp cachedir"
foreach opt of local gen_expected {
    pip_split_options `opt'
    local _gen = "`r(gen_opts)'"
    if !strpos(" `_gen' ", " `opt' ") {
        di as error "FAIL Test 1: general option '`opt'' not in r(gen_opts) = '`_gen''"
        error 9
    }
    local _est = "`r(est_opts)'"
    if strpos(" `_est' ", " `opt' ") {
        di as error "FAIL Test 1: general option '`opt'' incorrectly in r(est_opts)"
        error 9
    }
}
di as result "  PASS Test 1: all general options classified into r(gen_opts)"

// ---- Test 2: estimation options classified into r(est_opts) -----
local est_options "country povline fillgaps clear popshare coverage"
foreach opt of local est_options {
    pip_split_options `opt'
    local _est = "`r(est_opts)'"
    if !strpos(" `_est' ", " `opt' ") {
        di as error "FAIL Test 2: estimation option '`opt'' not in r(est_opts) = '`_est''"
        error 9
    }
}
di as result "  PASS Test 2: estimation options classified into r(est_opts)"

// ---- Test 3: abbreviations of general options recognised -----
// The function uses pip_abb_regex with abblength=3, so 3+ char prefix matches.
// "ver" matches "version", "ppp" matches "ppp_year", "rel" matches "release"
foreach abbpair in "ver version" "rel release" "ide identity" "ser server" "cac cachedir" {
    local abb: word 1 of `abbpair'
    local full: word 2 of `abbpair'
    pip_split_options `abb'
    local _gen = "`r(gen_opts)'"
    if !strpos(" `_gen' ", " `abb' ") {
        di as error "FAIL Test 3: abbreviated '`abb'' (for `full') not in r(gen_opts) = '`_gen''"
        error 9
    }
}
di as result "  PASS Test 3: 3-char abbreviations of general options recognised"

// ---- Test 4: empty optnames produces empty returns -----
pip_split_options
local _gen4 = "`r(gen_opts)'"
local _est4 = "`r(est_opts)'"
assert_local_equal, test("4a: empty optnames -> empty gen_opts") got("`_gen4'") expected("")
assert_local_equal, test("4b: empty optnames -> empty est_opts") got("`_est4'") expected("")

// ---- Test 5: mixed general + estimation options split correctly -----
pip_split_options version country ppp_year povline release fillgaps
local _gen5 = "`r(gen_opts)'"
local _est5 = "`r(est_opts)'"

foreach gopt in version ppp_year release {
    if !strpos(" `_gen5' ", " `gopt' ") {
        di as error "FAIL Test 5: general '`gopt'' not in r(gen_opts)"
        error 9
    }
    if strpos(" `_est5' ", " `gopt' ") {
        di as error "FAIL Test 5: general '`gopt'' incorrectly in r(est_opts)"
        error 9
    }
}
foreach eopt in country povline fillgaps {
    if !strpos(" `_est5' ", " `eopt' ") {
        di as error "FAIL Test 5: estimation '`eopt'' not in r(est_opts)"
        error 9
    }
    if strpos(" `_gen5' ", " `eopt' ") {
        di as error "FAIL Test 5: estimation '`eopt'' incorrectly in r(gen_opts)"
        error 9
    }
}
di as result "  PASS Test 5: mixed options split correctly"

di as result _n "All pip_split_options tests passed."

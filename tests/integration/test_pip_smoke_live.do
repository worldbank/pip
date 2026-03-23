/*==================================================
project:       Integration smoke tests for top-level pip dispatch
Author:        DECDG Team
Creation Date: 23 Mar 2026
Purpose:       Verify that the top-level pip command routes correctly and
               returns structurally valid data from the live PIP API.
               Complements the offline smoke tests (test_pip_smoke.do) by
               confirming the real network path works end-to-end.

               REQUIRES: live internet connection to api.worldbank.org/pip.

               Commands tested
               ---------------
               pip, clear               — default (cl) path
               pip cl, clear            — explicit country-level
               pip wb, clear            — World Bank aggregate
               pip cl, fillgaps clear   — fill-gaps variant
               pip cl, country(CHN) fillgaps clear  — country + fillgaps

Layer:         Top-level dispatcher (live API)
==================================================*/
version 16.1
set more off

adopath ++ "../.."
run "../../pip_fun.mata"

// Load shared assertion helpers.
run "../test_helpers.do"

di as result "=== pip smoke tests (live API) ==="

// ---- Minimum variable sets expected from each subcommand ----------------
local cl_min_vars "country_code year headcount poverty_gap poverty_severity mean welfare_type"
local wb_min_vars "region_code year headcount poverty_gap poverty_severity mean"

// =========================================================
// Test 1: pip, clear  (default subcommand → cl)
// =========================================================
pip, clear
assert_nobs_positive, test("1: pip,clear returns N > 0")
foreach v of local cl_min_vars {
    assert_var_exists, test("1: var `v' present (default)") var(`v')
}
assert_var_type, test("1: country_code is string") var(country_code) type(string)
assert_var_type, test("1: year is numeric")        var(year)         type(numeric)
assert_var_type, test("1: headcount is numeric")   var(headcount)    type(numeric)

// =========================================================
// Test 2: pip cl, clear  (explicit country-level)
// =========================================================
pip cl, clear
assert_nobs_positive, test("2: pip cl,clear returns N > 0")
foreach v of local cl_min_vars {
    assert_var_exists, test("2: var `v' present (cl)") var(`v')
}

// =========================================================
// Test 3: pip wb, clear  (World Bank aggregates)
// =========================================================
pip wb, clear
assert_nobs_positive, test("3: pip wb,clear returns N > 0")
foreach v of local wb_min_vars {
    assert_var_exists, test("3: var `v' present (wb)") var(`v')
}
assert_var_type, test("3: region_code is string") var(region_code) type(string)
assert_var_type, test("3: headcount is numeric")  var(headcount)   type(numeric)

// =========================================================
// Test 4: pip cl, fillgaps clear  (fill-gaps / lined-up)
// =========================================================
capture noisily pip cl, fillgaps clear
local _rc4 = _rc
assert_rc_zero, test("4: pip cl,fillgaps,clear succeeds") rc(`_rc4')
assert_nobs_positive, test("4: pip cl,fillgaps,clear returns N > 0")
foreach v of local cl_min_vars {
    assert_var_exists, test("4: var `v' present (fillgaps)") var(`v')
}

// =========================================================
// Test 5: pip, fillgaps clear  (default subcommand + fillgaps)
// =========================================================
capture noisily pip, fillgaps clear
local _rc5 = _rc
assert_rc_zero, test("5: pip,fillgaps,clear succeeds") rc(`_rc5')
assert_nobs_positive, test("5: pip,fillgaps,clear returns N > 0")

// =========================================================
// Test 6: pip cl, country(CHN) fillgaps clear
// =========================================================
capture noisily pip cl, country(CHN) fillgaps clear
local _rc6 = _rc
assert_rc_zero, test("6: pip cl,country(CHN),fillgaps,clear succeeds") rc(`_rc6')
assert_nobs_positive, test("6: pip cl,country(CHN),fillgaps returns N > 0")
// All rows should be CHN.
qui count if country_code != "CHN"
if (r(N) > 0) {
    pip_test_fail, test("6b: all rows are CHN") ///
        msg(`"`r(N)' non-CHN rows found"')
}
pip_test_pass, test("6b: all rows are CHN")

// =========================================================
// Test 7: Regression guard — pip,clear must not return r(199)
// =========================================================
capture pip, clear
local _rc7 = _rc
if (`_rc7' == 199) {
    pip_test_fail, test("7: pip,clear does not return r(199)") ///
        msg("r(199): pip_setup_ensure still unrecognized — fix not in effect")
}
pip_test_pass, test("7: pip,clear does not return r(199)")

clear
di as result _n "All pip integration smoke tests passed."

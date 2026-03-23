/*==================================================
project:       Offline smoke tests for top-level pip dispatch
Author:        DECDG Team
Creation Date: 23 Mar 2026
Purpose:       Verify that the top-level pip command routes correctly to
               each subcommand and that the entire plumbing chain
               (pip_setup → pip_parseopts → pip_split_options →
               pip_new_session → pip_versions → subcommand) runs without
               error — all without making any network calls.

               Stubs in test_stubs.do replace all network-dependent programs
               (pip_new_session, pip_set_server, pip_versions, pip_cl,
               pip_wb, pip_gh) with offline equivalents that return
               synthetic datasets and macros.

               What these tests guard against
               --------------------------------
               * Missing helper programs (e.g., pip_setup_ensure r(199) bug)
               * Broken parsing / option splitting
               * Mis-routed subcommands (e.g., default not routing to cl)
               * Setup plumbing that fails before any API call is attempted

Layer:         Top-level dispatcher (offline)
==================================================*/
version 16.1
set more off

adopath ++ "../.."
run "../../pip_fun.mata"

// Load shared assertion helpers and stubs.
run "../test_helpers.do"
run "../stubs.do"        // activates offline mode; sets globals and stubs

di as result "=== pip smoke tests (offline, stubs active) ==="

// ---- Confirm stubs are loaded (sanity check) ----------------------------
assert_global_set,  test("pre: pip_host global is set")    global(pip_host)
assert_global_set,  test("pre: pip_version global is set") global(pip_version)

// ---- Minimum variable sets expected from each subcommand ----------------
local cl_min_vars "country_code year headcount poverty_gap poverty_severity mean welfare_type"
local wb_min_vars "region_code year headcount poverty_gap poverty_severity mean"

// =========================================================
// Test 1: pip, clear  (default subcommand → cl)
// =========================================================
capture noisily pip, clear
local _rc1 = _rc
assert_rc_zero, test("1: pip,clear succeeds without error") rc(`_rc1')
assert_nobs_positive, test("1: pip,clear returns N > 0")
foreach v of local cl_min_vars {
    assert_var_exists, test("1: var `v' present (default)") var(`v')
}
assert_var_type, test("1: country_code is string")     var(country_code)     type(string)
assert_var_type, test("1: headcount is numeric")        var(headcount)        type(numeric)
assert_var_type, test("1: poverty_gap is numeric")      var(poverty_gap)      type(numeric)
assert_var_type, test("1: poverty_severity is numeric") var(poverty_severity) type(numeric)
assert_var_type, test("1: welfare_type is numeric")     var(welfare_type)     type(numeric)

// =========================================================
// Test 2: pip cl, clear  (explicit country-level)
// =========================================================
capture noisily pip cl, clear
local _rc2 = _rc
assert_rc_zero, test("2: pip cl,clear succeeds without error") rc(`_rc2')
assert_nobs_positive, test("2: pip cl,clear returns N > 0")
foreach v of local cl_min_vars {
    assert_var_exists, test("2: var `v' present (cl)") var(`v')
}

// =========================================================
// Test 3: pip wb, clear  (World Bank aggregates)
// =========================================================
capture noisily pip wb, clear
local _rc3 = _rc
assert_rc_zero, test("3: pip wb,clear succeeds without error") rc(`_rc3')
assert_nobs_positive, test("3: pip wb,clear returns N > 0")
foreach v of local wb_min_vars {
    assert_var_exists, test("3: var `v' present (wb)") var(`v')
}
assert_var_type, test("3: region_code is string") var(region_code) type(string)

// =========================================================
// Test 4: pip cl, fillgaps clear  (fill-gaps variant)
// =========================================================
capture noisily pip cl, fillgaps clear
local _rc4 = _rc
assert_rc_zero, test("4: pip cl,fillgaps,clear succeeds without error") rc(`_rc4')
assert_nobs_positive, test("4: pip cl,fillgaps,clear returns N > 0")
foreach v of local cl_min_vars {
    assert_var_exists, test("4: var `v' present (fillgaps)") var(`v')
}

// =========================================================
// Test 5: pip, fillgaps clear  (default subcommand + fillgaps)
// =========================================================
capture noisily pip, fillgaps clear
local _rc5 = _rc
assert_rc_zero, test("5: pip,fillgaps,clear succeeds without error") rc(`_rc5')
assert_nobs_positive, test("5: pip,fillgaps,clear returns N > 0")

// =========================================================
// Test 6: see  tests/unit/test_pip_setup_stub_compat.do
// (pip_setup no-args when stubs are active — extracted to
//  keep each file focused on a single concern)
// =========================================================

// =========================================================
// Test 7: Dispatcher does NOT produce r(199) (regression guard)
// Explicitly checks that the specific error code that caused the
// original breakage is not returned.
// =========================================================
capture pip, clear
local _rc7 = _rc
if (`_rc7' == 199) {
    pip_test_fail, test("7: pip,clear does not return r(199)") ///
        msg("r(199): command pip_setup_ensure is unrecognized — fix not applied")
}
pip_test_pass, test("7: pip,clear does not return r(199)")

// =========================================================
// Test 8: invalid subcommand returns an error (negative test)
// The dispatcher must reject unrecognised subcommands; if it
// silently succeeds the entire routing layer is suspect.
// =========================================================
capture pip xyzzy, clear
if (_rc == 0) {
    pip_test_fail, test("8: pip xyzzy errors on unknown subcommand") ///
        msg("expected non-zero rc for unrecognised subcommand, got 0")
}
pip_test_pass, test("8: pip xyzzy returns error for unknown subcommand")

clear
// Stub cleanup is handled unconditionally by the test runner's
// between-test block so that stubs are always dropped, even on failure.
di as result _n "All pip offline smoke tests passed."

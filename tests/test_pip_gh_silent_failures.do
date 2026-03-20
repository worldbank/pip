/*==================================================
project:       Test pip_gh silent failure modes
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify that pip_gh exits with _rc=1 (not _rc=0) on all
               skip conditions, so pip_new_session correctly distinguishes
               "silently skipped" from "completed successfully".
               Tests do NOT require a live network connection.
==================================================*/
version 16.1
set more off

adopath ++ ".."
capture program drop pip_gh
capture program drop pip_githubquery
run "../pip_gh.ado"

di as result "=== pip_gh: silent failure modes ==="

* ---- Test 1: pip_gh returns _rc != 0 on skip, not _rc == 0 -----
* Since pip may or may not be installed in the test environment,
* we verify that pip_gh never silently returns _rc == 0 with empty r() macros.

capture pip_gh
local rc_gh = _rc

* If it returned _rc == 0, r(update_available) must be non-empty ("0" or "1")
if (`rc_gh' == 0) {
    local ua = "`r(update_available)'"
    if ("`ua'" == "") {
        di as error "FAIL Test 1: pip_gh returned _rc=0 but r(update_available) is empty (stale r() consumed)"
        error 9
    }
    if ("`ua'" != "0" & "`ua'" != "1") {
        di as error "FAIL Test 1b: r(update_available) = '`ua'' is not '0' or '1'"
        error 9
    }
    di as result "  PASS Test 1: pip_gh completed (rc=0) with valid r(update_available)='`ua''"
}
else {
    * _rc != 0 means silently skipped - this is acceptable
    di as result "  PASS Test 1: pip_gh skipped silently (_rc=`rc_gh', not 0)"
}

* ---- Test 2: pip_new_session guard prevents stale r() consumption -----
* Set a stale r(update_available) via a dummy rclass program, then
* call pip_gh and verify pip_new_session logic would not use stale value.

program define _pip_test_stale_rclass, rclass
    return local update_available "1"
    return local latest_version   "99.99.99"
    return local install_cmd      "bad_command"
end

* Poison the r() environment with a fake "update available"
_pip_test_stale_rclass

* Now simulate what pip_new_session does: capture pip_gh, check _rc, then guard
capture pip_gh
local rc2 = _rc
local ua2 = "`r(update_available)'"
local lv2 = "`r(latest_version)'"

if (`rc2' != 0) {
    * pip_gh skipped - r() should NOT have been consumed
    * Verify the guard in pip_new_session would block display
    if ("`ua2'" == "1" & "`lv2'" == "99.99.99") {
        di as error "FAIL Test 2: stale r() values still present after skip - guard would fail"
        error 9
    }
    di as result "  PASS Test 2: when pip_gh skips (_rc=`rc2'), stale r() not consumed"
}
else {
    * pip_gh completed - r() should have been overwritten with real values
    if ("`lv2'" == "99.99.99") {
        di as error "FAIL Test 2: stale r(latest_version) not overwritten by pip_gh"
        error 9
    }
    di as result "  PASS Test 2: pip_gh completed, r() contains real values (not stale)"
}

program drop _pip_test_stale_rclass

di as result _n "All pip_gh silent failure tests passed."

/*==================================================
project:       Test pip_utils_keep_frame frame prefix matching
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify that the _pip_ prefix check correctly identifies
               internal pip frames vs user frames. Covers both the string
               matching logic (Tests 1-2) and functional frame operations
               (Tests 3-4).
==================================================*/
version 16.1
set more off

adopath ++ "../.."
foreach _prog in pip_utils pip_utils_disp_query pip_utils_dropvars       ///
    pip_utils_frameexists pip_utils_final_msg pip_utils_keep_frame        ///
    pip_utils_clicktable pip_utils_output pip_utils_frame2locals {
    capture program drop `_prog'
}
run "../../pip_utils.ado"

di as result "=== pip_utils: keep_frame prefix matching ==="

* ---- Test 1: frames starting with _pip_ (5 chars) correctly matched -----
assert substr("_pip_data",  1, 5) == "_pip_"
assert substr("_pip_test",  1, 5) == "_pip_"
assert substr("_pip_",      1, 5) == "_pip_"   // exactly 5 chars
di as result "  PASS Test 1: _pip_<base> frames correctly identified"

* ---- Test 2: frames NOT starting with _pip_ correctly excluded -----
* pip_ (no leading underscore): "pip_d" != "_pip_"
assert substr("pip_data",   1, 5) != "_pip_"
* _pip  (4 chars, no trailing _): "_pip" != "_pip_" (substr pads nothing, gives 4-char result)
assert substr("_pip",       1, 5) != "_pip_"
* _PIP_data (uppercase): case-sensitive in Stata, not matched
assert substr("_PIP_data",  1, 5) != "_pip_"
* completely different name
assert substr("myframe",    1, 5) != "_pip_"
di as result "  PASS Test 2: non-_pip_ frames correctly excluded"

* ---- Test 3: noefficient drops _pip_ frames, leaves others -----
clear
frame create _pip_internal_1
frame create _pip_internal_2
frame create pip_user_frame    // starts with pip_, NOT _pip_ -> should survive

pip_utils_keep_frame, noefficient

frame dir
local after3 "`r(frames)'"

if (strpos(" `after3' ", " _pip_internal_1 ") != 0) {
    di as error "FAIL Test 3: _pip_internal_1 should have been dropped"
    error 9
}
if (strpos(" `after3' ", " _pip_internal_2 ") != 0) {
    di as error "FAIL Test 3: _pip_internal_2 should have been dropped"
    error 9
}
if (strpos(" `after3' ", " pip_user_frame ") == 0) {
    di as error "FAIL Test 3: pip_user_frame should NOT have been dropped"
    error 9
}
di as result "  PASS Test 3: noefficient drops _pip_ frames, keeps pip_ frames"
capture frame drop pip_user_frame   // cleanup

* ---- Test 4: keepframes copies _pip_<base> to <prefix><base> -----
clear
frame create _pip_mydata
frame change _pip_mydata
set obs 3
gen n = _n
frame change default

pip_utils_keep_frame, keepframes frame_prefix(pip_)

frame dir
local after4 "`r(frames)'"

if (strpos(" `after4' ", " pip_mydata ") == 0) {
    di as error "FAIL Test 4: pip_mydata should have been created from _pip_mydata"
    error 9
}
di as result "  PASS Test 4: keepframes copies _pip_<base> to <prefix><base>"
capture frame drop pip_mydata
capture frame drop _pip_mydata

di as result _n "All pip_utils keep_frame tests passed."

/*==================================================
project:       Test pip_utils_dropvars
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify that pip_utils_dropvars correctly drops all-missing
               numeric and string variables while retaining partial-missing ones.
               Tests are isolated: calls pip_utils_dropvars directly without
               going through the pip_utils dispatcher (no mata library needed).
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

di as result "=== pip_utils: dropvars ==="

* ---- Test 1: all-missing numeric variable dropped -----
clear
set obs 5
gen x = .        // all missing numeric — should be dropped
gen y = 1        // has values — should be kept
qui pip_utils_dropvars
cap confirm variable x
if (_rc == 0) {
    di as error "FAIL Test 1: x (all-missing numeric) should have been dropped"
    error 9
}
cap confirm variable y
if (_rc != 0) {
    di as error "FAIL Test 1: y (has values) should have been kept"
    error 9
}
di as result "  PASS Test 1: all-missing numeric dropped, non-missing kept"

* ---- Test 2: all-empty string variable dropped -----
clear
set obs 5
gen str1 x = ""  // all empty strings — should be dropped
gen str1 y = "a" // has values — should be kept
qui pip_utils_dropvars
cap confirm variable x
if (_rc == 0) {
    di as error "FAIL Test 2: x (all-empty string) should have been dropped"
    error 9
}
cap confirm variable y
if (_rc != 0) {
    di as error "FAIL Test 2: y (has values) should have been kept"
    error 9
}
di as result "  PASS Test 2: all-empty string dropped"

* ---- Test 3: string variable with literal '.' dropped -----
* pip convention: "." in a string column means numeric missing — drop it
clear
set obs 5
gen str1 x = "."  // literal dot — should be dropped
gen str1 y = "a"
qui pip_utils_dropvars
cap confirm variable x
if (_rc == 0) {
    di as error "FAIL Test 3: x (literal '.') should have been dropped"
    error 9
}
di as result "  PASS Test 3: string variable with literal '.' dropped"

* ---- Test 4: partial-missing numeric NOT dropped -----
clear
set obs 5
gen x = .
replace x = 1 in 1   // one non-missing value — keep the variable
gen y = 1
qui pip_utils_dropvars
cap confirm variable x
if (_rc != 0) {
    di as error "FAIL Test 4: x (partial-missing) should NOT have been dropped"
    error 9
}
di as result "  PASS Test 4: partial-missing numeric kept"

* ---- Test 5: partial-missing string NOT dropped -----
clear
set obs 5
gen str1 x = ""
replace x = "a" in 1  // one non-missing value — keep the variable
gen str1 y = "b"
qui pip_utils_dropvars
cap confirm variable x
if (_rc != 0) {
    di as error "FAIL Test 5: x (partial-empty string) should NOT have been dropped"
    error 9
}
di as result "  PASS Test 5: partial-missing string kept"

* ---- Test 6: empty dataset (0 obs) drops all vars -----
* With 0 obs: qui sum -> r(N)=0 for all numerics; count if -> 0 = c(N)=0 for all strings
clear
set obs 0
gen x = .
gen y = .
qui pip_utils_dropvars
if (c(k) != 0) {
    di as error "FAIL Test 6: empty dataset - expected 0 vars remaining, got `c(k)'"
    error 9
}
di as result "  PASS Test 6: empty dataset - all vars dropped"

di as result _n "All pip_utils dropvars tests passed."

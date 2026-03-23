/*==================================================
project:       Integration tests for pip info
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip info and pip print, info complete without error.
               REQUIRES: live internet connection.
Layer:         Info
==================================================*/
version 16.1
set more off

adopath ++ "../.."
run "../../pip_fun.mata"

* Load shared assertion helpers
run "../test_helpers.do"

di as result "=== pip info ==="

// ---- Test 1: pip info, clear completes without error -----
capture noi pip info, clear
local _rc1 = _rc
assert_rc_zero, test("1: pip info clear completes without error") rc(`_rc1')

// ---- Test 2: pip print, info clear completes without error -----
capture noi pip print, info clear
local _rc2 = _rc
assert_rc_zero, test("2: pip print info clear completes without error") rc(`_rc2')

// ---- Test 3: pip info, country(CHN) clear completes without error -----
capture noi pip info, country(CHN) clear
local _rc3 = _rc
assert_rc_zero, test("3: pip info country(CHN) clear completes without error") rc(`_rc3')

clear
di as result _n "All pip info integration tests passed."

/*==================================================
project:       Unit tests for pip_cleanup
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip_cleanup removes all _pip_* internal frames and
               pip_* globals, while leaving non-pip frames and globals intact.
               Tests are fully offline — no API calls.
Layer:         Utilities
==================================================*/
version 16.1
set more off

adopath ++ "../.."
capture program drop pip_cleanup
capture program drop pip_drop
run "../../pip_cleanup.ado"
run "../../pip_drop.ado"

* Load shared assertion helpers
run "../test_helpers.do"

di as result "=== pip_cleanup ==="

// ---- Test 1: pip_cleanup removes _pip_ frames and pip_* globals -----
// Set up state to clean up
frame create _pip_internal_frame_1
frame create _pip_internal_frame_2
global pip_cleanup_test_global_a "dirty_value"
global pip_cleanup_test_global_b "another_value"

noi pip_cleanup

// All internal frames should be gone
assert_frame_not_exists, test("1a: _pip_internal_frame_1 dropped by cleanup") ///
    frame("_pip_internal_frame_1")
assert_frame_not_exists, test("1b: _pip_internal_frame_2 dropped by cleanup") ///
    frame("_pip_internal_frame_2")

// All pip_* globals should be empty
assert_global_empty, test("1c: pip_cleanup_test_global_a cleared") ///
    global(pip_cleanup_test_global_a)
assert_global_empty, test("1d: pip_cleanup_test_global_b cleared") ///
    global(pip_cleanup_test_global_b)

// ---- Test 2: non-pip frames and non-pip globals survive cleanup -----
frame create user_frame_survives
global NONPIP_GLOBAL "should_survive"

noi pip_cleanup

assert_frame_exists, test("2a: user_frame_survives survives pip_cleanup") ///
    frame("user_frame_survives")
assert_local_equal, test("2b: NONPIP_GLOBAL survives pip_cleanup") ///
    got("${NONPIP_GLOBAL}") expected("should_survive")

// cleanup test state
capture frame drop user_frame_survives
global NONPIP_GLOBAL ""

di as result _n "All pip_cleanup tests passed."

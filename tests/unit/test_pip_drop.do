/*==================================================
project:       Unit tests for pip_drop
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip_drop correctly drops frames and globals matching
               the pip_ prefix, and leaves non-matching frames/globals intact.
               Tests are fully offline — no API calls.
Layer:         Utilities
==================================================*/
version 16.1
set more off

adopath ++ "../.."
capture program drop pip_drop
run "../../pip_drop.ado"

* Load shared assertion helpers
run "../test_helpers.do"

di as result "=== pip_drop: frames and globals ==="

// ---- Test 1: pip_drop frame drops frames matching the default pip_ prefix -----
frame create pip_test_drop_1
frame create pip_test_drop_2
pip_drop frame, qui
assert_frame_not_exists, test("1a: pip_test_drop_1 dropped") frame("pip_test_drop_1")
assert_frame_not_exists, test("1b: pip_test_drop_2 dropped") frame("pip_test_drop_2")

// ---- Test 2: pip_drop frame does NOT drop frames with different prefix -----
frame create other_frame_stays
frame create pip_test_drop_3   // will be dropped
pip_drop frame, qui
assert_frame_not_exists, test("2a: pip_test_drop_3 dropped") frame("pip_test_drop_3")
assert_frame_exists, test("2b: other_frame_stays survives") frame("other_frame_stays")
capture frame drop other_frame_stays

// ---- Test 3: pip_drop frame with custom prefix -----
frame create custom_frame_a
frame create custom_frame_b
frame create pip_frame_should_stay   // default pip_ frame — should NOT be dropped here
pip_drop frame, frame_prefix(custom_) qui
assert_frame_not_exists, test("3a: custom_frame_a dropped") frame("custom_frame_a")
assert_frame_not_exists, test("3b: custom_frame_b dropped") frame("custom_frame_b")
assert_frame_exists, test("3c: pip_frame_should_stay survives custom prefix") ///
    frame("pip_frame_should_stay")
capture frame drop pip_frame_should_stay

// ---- Test 4: pip_drop global clears all pip_* globals -----
global pip_test_global_a "value_a"
global pip_test_global_b "value_b"
pip_drop global
assert_global_empty, test("4a: pip_test_global_a cleared") global(pip_test_global_a)
assert_global_empty, test("4b: pip_test_global_b cleared") global(pip_test_global_b)

// ---- Test 5: pip_drop global does NOT clear non-pip globals -----
global OTHER_TEST_GLOBAL "should_survive"
global pip_test_global_c "will_be_cleared"
pip_drop global
assert_local_equal, test("5a: non-pip global survives") ///
    got("${OTHER_TEST_GLOBAL}") expected("should_survive")
assert_global_empty, test("5b: pip global cleared") global(pip_test_global_c)
global OTHER_TEST_GLOBAL ""   // cleanup

di as result _n "All pip_drop tests passed."

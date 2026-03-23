/*==================================================
project:       Unit tests for pip_timer
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip_timer correctly initialises, starts, stops, and
               reports timing information via the Mata timer struct.
               Tests are fully offline — no API calls.
Layer:         Timer
==================================================*/
version 16.1
set more off

adopath ++ "../.."
capture program drop pip_timer
run "../../pip_fun.mata"   // timer structs defined here
run "../../pip_timer.ado"

* Load shared assertion helpers
run "../test_helpers.do"

di as result "=== pip_timer ==="

// ---- Test 1: pip_timer with no args initialises the struct -----
capture pip_timer
assert_rc_zero, test("1: pip_timer (no args) initialises without error") rc(`=_rc')

// ---- Test 2: on/off pair completes without error -----
capture pip_timer test_label, on
assert_rc_zero, test("2a: pip_timer label, on succeeds") rc(`=_rc')
capture pip_timer test_label, off
assert_rc_zero, test("2b: pip_timer label, off succeeds") rc(`=_rc')

// ---- Test 3: multiple timers can be started and stopped -----
pip_timer   // re-initialise
capture {
    pip_timer label_a, on
    pip_timer label_b, on
    pip_timer label_a, off
    pip_timer label_b, off
}
assert_rc_zero, test("3: multiple timers start and stop without error") rc(`=_rc')

// ---- Test 4: printtimer produces output without error -----
pip_timer   // re-initialise
pip_timer label_x, on
pip_timer label_x, off
capture pip_timer, printtimer
assert_rc_zero, test("4: pip_timer printtimer runs without error") rc(`=_rc')

// ---- Test 5: on and off are mutually exclusive (should error) -----
capture pip_timer some_label, on off
local _rc5 = _rc
assert_rc_nonzero, test("5: on and off together produce error") rc(`_rc5')

// ---- Test 6: stopping a non-existent timer produces an error -----
pip_timer   // fresh struct
capture pip_timer nonexistent_label, off
local _rc6 = _rc
assert_rc_nonzero, test("6: stopping non-existent timer produces error") rc(`_rc6')

di as result _n "All pip_timer tests passed."

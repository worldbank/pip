/*==================================================
project:       Test runner - executes all test_*.do files
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Run all regression tests and report a pass/fail summary.
               Run from the tests/ directory or the project root.
Usage:         do "tests/run_all_tests.do"
==================================================*/
version 16.1
set more off

* Resolve tests directory regardless of working directory
local script_dir = c(pwd)
capture findfile "run_all_tests.do"
if (_rc == 0) {
    * Running from tests/ dir
    local tests_dir "`c(pwd)'"
}
else {
    * Running from project root
    local tests_dir "`c(pwd)'/tests"
}

di as result _dup(60) "="
di as result "PIP TEST RUNNER"
di as result _dup(60) "="

local tests: dir "`tests_dir'" files "test_*.do", respectcase
local n_total  : list sizeof tests
local n_pass   = 0
local n_fail   = 0
local failures ""

foreach test of local tests {
    di as text _n "Running: `test' ..."
    capture noisily do "`tests_dir'/`test'"
    if (_rc == 0) {
        local n_pass = `n_pass' + 1
        di as result "  -> PASSED"
    }
    else {
        local n_fail = `n_fail' + 1
        local failures "`failures' `test'"
        di as error "  -> FAILED (_rc = " _rc ")"
    }
    * Clean up data and extra frames between tests to prevent state leakage
    capture {
        clear
        frame dir
        local _cln_frames "`r(frames)'"
        foreach _fr of local _cln_frames {
            if ("`_fr'" != "default") capture frame drop `_fr'
        }
        frame change default
    }
}

di as result _n _dup(60) "="
di as result "RESULTS: `n_pass'/`n_total' passed"
if (`n_fail' > 0) {
    di as error "FAILED (`n_fail'):"
    foreach f of local failures {
        di as error "  - `f'"
    }
    error 9
}
else {
    di as result "All tests passed."
}
di as result _dup(60) "="

/*==================================================
Unit-only test runner (no live API needed).
Run from tests/ directory OR project root.
==================================================*/
version 16.1
set more off

* ---- Resolve tests directory -----
capture findfile "run_unit_tests.do"
if (_rc == 0) {
    local tests_dir "`c(pwd)'"
}
else {
    local tests_dir "`c(pwd)'/tests"
}

local unit_dir "`tests_dir'/unit"

* ---- Validate unit directory exists before proceeding -----
cap cd "`unit_dir'"
if (_rc) {
    di as error "FATAL: unit test directory not found or inaccessible: `unit_dir'"
    error 999
}
qui cd "`tests_dir'"   // restore after validation check

* ---- Hoist project root on ado path once — prevents duplicate entries -----
* across test files that each call  adopath ++  individually.
local _save_cwd "`c(pwd)'"
qui cd "`tests_dir'/.."
adopath ++ "`c(pwd)'"
qui cd "`_save_cwd'"

* ---- Load assertion helpers -----
run "`tests_dir'/test_helpers.do"

di as result _dup(60) "="
di as result "PIP UNIT TEST RUNNER"
di as result _dup(60) "="

local n_pass  = 0
local n_fail  = 0
local n_total = 0
local failures ""

local suite_files: dir "`unit_dir'" files "test_*.do", respectcase

* Change to unit directory so that relative paths in each test file
* (e.g. run "../../pip_utils.ado") resolve correctly in batch mode.
cd "`unit_dir'"

foreach test of local suite_files {
    local n_total = `n_total' + 1
    di as text _n "  Running: `test' ..."

    capture noisily do "`test'"
    if (_rc == 0) {
        local n_pass = `n_pass' + 1
        di as result "  -> PASSED"
    }
    else {
        local n_fail    = `n_fail' + 1
        local failures `"`failures' `test'"'
        di as error "  -> FAILED"
    }

    * Clean up between tests
    capture {
        clear
        frame dir
        local _fr "`r(frames)'"
        foreach f of local _fr {
            if ("`f'" != "default") capture frame drop `f'
        }
        frame change default
        local _gl: all globals "pip_*"
        foreach g of local _gl {
            global `g' ""
        }
        * Drop stub programs if loaded during this test.
        foreach _s in pip_new_session pip_set_server pip_versions ///
                      pip_cl pip_wb pip_gh {
            capture program drop `_s'
        }
    }
}

* Restore to tests directory
cd "`tests_dir'"

di as result _n _dup(60) "="
di as result "UNIT RESULTS: `n_pass'/`n_total' passed"
if (`n_fail' > 0) {
    di as error "FAILED:"
    foreach f of local failures {
        di as error "  - `f'"
    }
    error 9
}
else {
    di as result "All `n_total' unit tests passed."
}
di as result _dup(60) "="

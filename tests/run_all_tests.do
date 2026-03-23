/*==================================================
project:       Test runner - executes all test_*.do files
Author:        DECDG Team
Creation Date: 19 Mar 2026
Modification Date: 19 Mar 2026
Purpose:       Run all regression tests and report a pass/fail summary.
               Discovers tests in unit/, integration/, and the tests/ root.
               Run from the tests/ directory or the project root.
Usage:         do "tests/run_all_tests.do"
               do "run_all_tests.do"   (from tests/)
==================================================*/
version 16.1
set more off

* ---- Resolve tests directory regardless of working directory -----
capture findfile "run_all_tests.do"
if (_rc == 0) {
    * Running from tests/ dir
    local tests_dir "`c(pwd)'"
}
else {
    * Running from project root
    local tests_dir "`c(pwd)'/tests"
}

* ---- Hoist project root on ado path once — prevents duplicate entries -----
* across test files that each call  adopath ++  individually.
local _save_cwd "`c(pwd)'"
qui cd "`tests_dir'/.."
adopath ++ "`c(pwd)'"
qui cd "`_save_cwd'"

* ---- Load shared assertion helpers -----
* Helpers define programs: assert_rc_zero, assert_var_exists, etc.
capture do "`tests_dir'/test_helpers.do"
if (_rc != 0) {
    di as error "WARNING: test_helpers.do not found or failed to load. Continuing without helpers."
}

di as result _dup(60) "="
di as result "PIP TEST RUNNER"
di as result _dup(60) "="

local n_pass   = 0
local n_fail   = 0
local n_total  = 0
local failures ""

* ---- Helper macro to run a single test file -----
* (inline — Stata has no nested programs in do-files)

* ---- Collect and run tests from all three locations -----
* Order: unit/ first (offline, fast), then integration/ (live API), then root

foreach suite in "unit" "integration" "." {

    if ("`suite'" == ".") {
        local suite_dir "`tests_dir'"
        local suite_label "root"
    }
    else {
        local suite_dir "`tests_dir'/`suite'"
        local suite_label "`suite'"
    }

    * Check directory exists before globbing
    local suite_files: dir "`suite_dir'" files "test_*.do", respectcase
    if (`"`suite_files'"' == "") continue

    di as result _n _dup(50) "-"
    di as result "Suite: `suite_label' (`suite_dir')"
    di as result _dup(50) "-"

    local suite_pass = 0
    local suite_fail = 0

    * cd into the suite dir so relative paths inside each test resolve correctly
    * (in Stata batch mode, do "file.do" does NOT change the cwd)
    if ("`suite'" == ".") {
        cd "`tests_dir'"
    }
    else {
        cd "`suite_dir'"
    }

    foreach test of local suite_files {
        local n_total = `n_total' + 1
        di as text _n "  Running [`suite_label']: `test' ..."

        capture noisily do "`test'"
        if (_rc == 0) {
            local n_pass     = `n_pass' + 1
            local suite_pass = `suite_pass' + 1
            di as result "    -> PASSED"
        }
        else {
            local n_fail     = `n_fail' + 1
            local suite_fail = `suite_fail' + 1
            local failures   `"`failures' [`suite_label'] `test'"'
            di as error "    -> FAILED (_rc = " _rc ")"
        }

        * ---- Clean up state between tests to prevent leakage -----
        capture {
            clear
            frame dir
            local _cln_frames "`r(frames)'"
            foreach _fr of local _cln_frames {
                if ("`_fr'" != "default") capture frame drop `_fr'
            }
            frame change default
            * Reset pip globals to avoid cross-test contamination
            local _pip_globs: all globals "pip_*"
            foreach _g of local _pip_globs {
                global `_g' ""
            }
            * Drop stub programs if loaded during this test.
            foreach _s in pip_new_session pip_set_server pip_versions ///
                          pip_cl pip_wb pip_gh {
                capture program drop `_s'
            }
        }
    }

    di as result "  Suite `suite_label': `suite_pass' passed, `suite_fail' failed"
}

* ---- Final summary -----
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
    di as result "All `n_total' tests passed."
}
di as result _dup(60) "="

// Minimal test runner for pip package
// Run each test do-file and collect failures
clear all
set more off

local tests "test_pip_get.do test_pip_cl.do"
foreach t of local tests {
    di "\n=== Running test: `t' ==="
    capture noisily do "tests/`t'"
    if (_rc) {
        di as err "Test `t' FAILED with return code = " _rc
    }
    else di as result "Test `t' passed"
}

di "\nAll tests completed."

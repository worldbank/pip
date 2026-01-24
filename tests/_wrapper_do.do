// Wrapper to capture Stata output to a plain text log
capture log close _all
log using "tests/stata_test_output.log", replace text
set more off
di "Starting pip tests wrapper"
do tests/run_tests.do
di "Finished pip tests wrapper"
log close
exit

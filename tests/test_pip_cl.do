// Test pip_cl produces country-level data and required variables
version 16.1
capture program drop test_pip_cl
program define test_pip_cl
    // Check pip version/global settings
    if "${pip_version}" == "" {
        di as err "pip_version not set. Set global `pip_version' before running tests."
        exit 1
    }

    // Run a small, non-destructive country-level query
    capture noisily pip, cl country(USA) year(2017) n2disp(0)
    if (_rc) {
        di as err "pip cl failed with rc=" _rc
        exit _rc
    }

    // Verify dataset has country_code and poverty_line or poverty_line variable
    capture confirm variable country_code
    if (_rc) {
        di as err "Expected variable `country_code' not found"
        exit 2
    }

    capture confirm variable poverty_line
    if (_rc) {
        di as err "Expected variable `poverty_line' not found"
        exit 3
    }

    di as result "pip_cl test succeeded: dataset looks good"
end

test_pip_cl

// Test pip_get downloads a simple endpoint and returns data
// This test requires internet access and that `pip_host` is set
version 16.1
capture program drop test_pip_get
program define test_pip_get
    // Ensure pip host is set (use default if empty)
    if "${pip_host}" == "" {
        di as err "pip_host not set. Set global `pip_host' before running tests."
        exit 1
    }

    // Use the health-check endpoint which should return small CSV/JSON
    capture global pip_last_queries "health-check?format=csv"
    if (_rc) exit 1

    // call pip_get which will import the CSV
    capture noisily pip_get, clear
    if (_rc) {
        di as err "pip_get failed with rc=" _rc
        exit _rc
    }

    // Expect at least one variable in the dataset
    ds
    if (r(N_vars) == 0) {
        di as err "pip_get did not import any variables"
        exit 2
    }

    di as result "pip_get test succeeded: imported `r(N_obs)' obs and `r(N_vars)' vars"
end

test_pip_get

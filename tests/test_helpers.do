/*==================================================
project:       Shared assertion helpers for pip test suite
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Reusable assertion programs called by all test_*.do files.
               Each program prints "PASS <test>" on success, or prints
               "FAIL <test>" and exits with error 9 on failure.
               Load once per test session via: run "path/to/test_helpers.do"
Usage:         run "tests/test_helpers.do"
==================================================*/
version 16.1
set more off

// ---- Drop and reload all helpers to ensure a clean state -----
foreach _prog in                ///
    assert_rc_zero              ///
    assert_rc_nonzero           ///
    assert_var_exists           ///
    assert_var_not_exists       ///
    assert_var_type             ///
    assert_nobs_positive        ///
    assert_nobs_equal           ///
    assert_global_set           ///
    assert_global_empty         ///
    assert_local_equal          ///
    assert_frame_exists         ///
    assert_frame_not_exists     ///
    assert_return_equal         ///
    pip_test_pass               ///
    pip_test_fail               {
    capture program drop `_prog'
}

// ========================================================
// Internal helpers for consistent PASS/FAIL output
// ========================================================

program define pip_test_pass
    syntax, test(string)
    di as result "  PASS `test'"
end

program define pip_test_fail
    syntax, test(string) [msg(string)]
    if (`"`msg'"' != `""') di as error `"  FAIL `test': `msg'"'
    else                   di as error `"  FAIL `test'"'
    error 9
end


// ========================================================
// assert_rc_zero
// Asserts that the immediately preceding capture block set _rc == 0.
// Usage: capture <command>
//        assert_rc_zero, test("my test name")
// ========================================================
program define assert_rc_zero
    syntax, test(string) [rc(integer 0)]
    // caller passes the captured _rc via the rc() option
    // because _rc is reset the moment this program is called.
    if (`rc' != 0) {
        pip_test_fail, test(`"`test'"') msg(`"_rc = `rc' (expected 0)"')
    }
    pip_test_pass, test(`"`test'"')
end


// ========================================================
// assert_rc_nonzero
// Asserts that a capture block set _rc != 0 (expected failure).
// Usage: capture <command>
//        assert_rc_nonzero, test("my test") rc(`=_rc')
// ========================================================
program define assert_rc_nonzero
    syntax, test(string) rc(integer)
    if (`rc' == 0) {
        pip_test_fail, test(`"`test'"') msg("expected nonzero _rc but got 0")
    }
    pip_test_pass, test(`"`test'"')
end


// ========================================================
// assert_var_exists
// Asserts that a variable with the given name exists in the
// current dataset.
// ========================================================
program define assert_var_exists
    syntax, test(string) var(string)
    cap confirm variable `var'
    if (_rc != 0) {
        pip_test_fail, test(`"`test'"') msg(`"variable `var' not found"')
    }
    pip_test_pass, test(`"`test'"')
end


// ========================================================
// assert_var_not_exists
// Asserts that a variable does NOT exist (was dropped).
// ========================================================
program define assert_var_not_exists
    syntax, test(string) var(string)
    cap confirm variable `var'
    if (_rc == 0) {
        pip_test_fail, test(`"`test'"') msg(`"variable `var' still exists (should have been dropped)"')
    }
    pip_test_pass, test(`"`test'"')
end


// ========================================================
// assert_var_type
// Asserts that a variable has a specific storage type.
// type() accepts "numeric" (any numeric), "string" (any str*),
// or an exact Stata type like "float", "double", "str20", etc.
// ========================================================
program define assert_var_type
    syntax, test(string) var(string) type(string)
    cap confirm variable `var'
    if (_rc != 0) {
        pip_test_fail, test(`"`test'"') msg(`"variable `var' not found"')
    }
    local actual_type: type `var'
    if ("`type'" == "numeric") {
        cap confirm numeric variable `var'
        if (_rc != 0) {
            pip_test_fail, test(`"`test'"') msg(`"`var' is `actual_type' (expected numeric)"')
        }
    }
    else if ("`type'" == "string") {
        cap confirm string variable `var'
        if (_rc != 0) {
            pip_test_fail, test(`"`test'"') msg(`"`var' is `actual_type' (expected string)"')
        }
    }
    else {
        if ("`actual_type'" != "`type'") {
            pip_test_fail, test(`"`test'"') msg(`"`var' is `actual_type' (expected `type')"')
        }
    }
    pip_test_pass, test(`"`test'"')
end


// ========================================================
// assert_nobs_positive
// Asserts that the current dataset has at least one observation.
// ========================================================
program define assert_nobs_positive
    syntax, test(string)
    if (c(N) == 0) {
        pip_test_fail, test(`"`test'"') msg("dataset has 0 observations")
    }
    pip_test_pass, test(`"`test'"')
end


// ========================================================
// assert_nobs_equal
// Asserts that the current dataset has exactly N observations.
// ========================================================
program define assert_nobs_equal
    syntax, test(string) expected(integer)
    if (c(N) != `expected') {
        pip_test_fail, test(`"`test'"') msg(`"N = `c(N)' (expected `expected')"')
    }
    pip_test_pass, test(`"`test'"')
end


// ========================================================
// assert_global_set
// Asserts that the named global macro is non-empty.
// ========================================================
program define assert_global_set
    syntax, test(string) global(string)
    if (`"${`global'}"' == "") {
        pip_test_fail, test(`"`test'"') msg(`"global `global' is empty"')
    }
    pip_test_pass, test(`"`test'"')
end


// ========================================================
// assert_global_empty
// Asserts that the named global macro is empty.
// ========================================================
program define assert_global_empty
    syntax, test(string) global(string)
    if (`"${`global'}"' != "") {
        pip_test_fail, test(`"`test'"') msg(`"global `global' = '${`global'}' (expected empty)"')
    }
    pip_test_pass, test(`"`test'"')
end


// ========================================================
// assert_local_equal
// Asserts that two string values are equal.
// Usage: assert_local_equal, test("...") got("`mylocal'") expected("foo")
// NOTE: got() and expected() are optional so that Stata does not abort
//       when an empty string is passed (a known Stata limitation with
//       required string options and empty values).
// ========================================================
program define assert_local_equal
    syntax, test(string) [got(string)] [expected(string)]
    // Use simple-quote comparison — safe for empty strings.
    if "`got'" != "`expected'" {
        pip_test_fail, test(`"`test'"') msg("got '`got'' (expected '`expected'')")
    }
    pip_test_pass, test(`"`test'"')
end


// ========================================================
// assert_frame_exists
// Asserts that the named frame exists.
// ========================================================
program define assert_frame_exists
    syntax, test(string) frame(string)
    mata: st_local("_fex", strofreal(st_frameexists("`frame'")))
    if (`_fex' == 0) {
        pip_test_fail, test(`"`test'"') msg(`"frame `frame' does not exist"')
    }
    pip_test_pass, test(`"`test'"')
end


// ========================================================
// assert_frame_not_exists
// Asserts that the named frame does NOT exist (was dropped).
// ========================================================
program define assert_frame_not_exists
    syntax, test(string) frame(string)
    mata: st_local("_fex", strofreal(st_frameexists("`frame'")))
    if (`_fex' != 0) {
        pip_test_fail, test(`"`test'"') msg(`"frame `frame' still exists (should have been dropped)"')
    }
    pip_test_pass, test(`"`test'"')
end


// ========================================================
// assert_return_equal
// Asserts that r(name) equals the expected string.
// Must be called immediately after the rclass command
// (before any other rclass command wipes r()).
// ========================================================
program define assert_return_equal
    syntax, test(string) name(string) expected(string)
    local actual = `"`r(`name')'"'
    if (`"`actual'"' != `"`expected'"') {
        pip_test_fail, test(`"`test'"') msg(`"r(`name') = '`actual'' (expected '`expected'')"')
    }
    pip_test_pass, test(`"`test'"')
end


di as result "(test_helpers.do loaded — `c(current_time)')"

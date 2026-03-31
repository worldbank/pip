/*==================================================
project:       Unit tests for pip_fun.mata
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify key Mata functions in pip_fun.mata:
               pip_retlist2locals, pip_locals2call, pip_abb_regex,
               pip_replace_in_pattern, pip_check_folder,
               pip_reverse_macro, pip_mkdir_recursive.
               Tests are fully offline — no API calls.
Layer:         Mata functions
==================================================*/
version 16.1
set more off

adopath ++ "../.."

* Load the Mata library (defines all pip_* Mata functions)
run "../../pip_fun.mata"

* Load shared assertion helpers
run "../test_helpers.do"

di as result "=== pip_fun.mata: Mata utility functions ==="

// ========================================================
// Test 1: pip_retlist2locals
// ========================================================
di as result "--- pip_retlist2locals ---"

// Create an rclass program that sets r(foo) and r(bar)
program define _pip_test_rclass_1, rclass
    return local foo "hello"
    return local bar "world"
end
_pip_test_rclass_1

// pip_retlist2locals should convert r(foo) and r(bar) to locals
mata: pip_retlist2locals("foo bar")
assert_local_equal, test("1a: pip_retlist2locals sets local foo") ///
    got("`foo'") expected("hello")
assert_local_equal, test("1b: pip_retlist2locals sets local bar") ///
    got("`bar'") expected("world")

program drop _pip_test_rclass_1

// ========================================================
// Test 2: pip_locals2call
// ========================================================
di as result "--- pip_locals2call ---"

local country "CHN"
local year    "2018"
// pip_locals2call("country year", "myresult") should produce "`country' `year'"
mata: pip_locals2call("country year", "myresult")
// Result is stored in local `myresult'
if ("`myresult'" != "`country' `year'") {
    di as error "FAIL Test 2: pip_locals2call produced '`myresult'' (expected '`country' `year'')"
    error 9
}
di as result "  PASS Test 2: pip_locals2call builds call string correctly"

// ========================================================
// Test 3: pip_abb_regex
// ========================================================
di as result "--- pip_abb_regex ---"

mata: pip_abb_regex(tokens("version ppp_year"), 3, "test_patterns")
// pip_abb_regex produces a SPACE-SEPARATED list of per-word regex patterns.
// Each token is used as: regexm(option, "^`p'") — same as pip.ado lines 290-300.
// Pattern for "version" (min 3 chars): "ve(r|rs|rsi|rsio|rsion)"
// Pattern for "ppp_year": "pp(p|p_|p_y|p_ye|p_yea|p_year)"

// ---- Test 3a: version abbreviations match via per-word patterns -----
foreach abbrev in ver vers versi versio version {
    local _matched 0
    foreach p of local test_patterns {
        if regexm("`abbrev'", "^`p'") {
            local _matched 1
            continue, break
        }
    }
    if (!`_matched') {
        di as error "FAIL Test 3a: '`abbrev'' should match version pattern"
        error 9
    }
}
di as result "  PASS Test 3a: version abbreviations match"

// ---- Test 3b: short strings don't match (anchored at start) -----
foreach too_short in ve v {
    local _matched 0
    foreach p of local test_patterns {
        if regexm("`too_short'", "^`p'") {
            local _matched 1
            continue, break
        }
    }
    if (`_matched') {
        di as error "FAIL Test 3b: '`too_short'' should NOT match (too short)"
        error 9
    }
}
di as result "  PASS Test 3b: short strings rejected"

// ---- Test 3c: ppp_year abbreviation matches -----
local _matched 0
foreach p of local test_patterns {
    if regexm("ppp", "^`p'") {
        local _matched 1
        continue, break
    }
}
if (!`_matched') {
    di as error "FAIL Test 3c: 'ppp' should match ppp_year pattern"
    error 9
}
di as result "  PASS Test 3c: ppp_year abbreviation matches"

// ========================================================
// Test 4: pip_replace_in_pattern
// ========================================================
di as result "--- pip_replace_in_pattern ---"

// Create a temp file with known content
tempfile test_file4
tempname fh4
file open `fh4' using "`test_file4'", write replace
file write `fh4' "global pip_pipmata_hash = " `""""' `""""' _n
file write `fh4' "global pip_lastupdate = " `""""' `""""' _n
file write `fh4' "exit" _n
file close `fh4'

// Replace the line matching "pip_pipmata_hash"
local new_line `"global pip_pipmata_hash  = "abc123""'
mata: pip_replace_in_pattern("`test_file4'", "pip_pipmata_hash", `"`new_line'"')
// Mata sets tempf/origf locals — copy the result
capture copy `tempf' "`origf'", replace

// Read back and verify
tempname fh4b
local found4 0
file open `fh4b' using "`test_file4'", read text
file read `fh4b' line
while r(eof) == 0 {
    if strpos(`"`line'"', "abc123") > 0 local found4 1
    file read `fh4b' line
}
file close `fh4b'
if (`found4' == 0) {
    di as error "FAIL Test 4: pip_replace_in_pattern did not write new line"
    error 9
}
di as result "  PASS Test 4: pip_replace_in_pattern replaces matching line"

// ========================================================
// Test 5: pip_check_folder
// ========================================================
di as result "--- pip_check_folder ---"

// Test on an existing directory (Stata's sysdir personal — always exists)
local existing_dir = c(tmpdir)
mata: st_local("_chk5", strofreal(pip_check_folder("`existing_dir'")))
if (`_chk5' != 1) {
    di as error "FAIL Test 5: pip_check_folder returned `_chk5' for existing dir '`existing_dir''"
    error 9
}
di as result "  PASS Test 5: pip_check_folder returns 1 for existing writable dir"

// ========================================================
// Test 6: pip_reverse_macro
// ========================================================
di as result "--- pip_reverse_macro ---"

local mylist "a b c d"
mata: pip_reverse_macro("mylist", 1)
assert_local_equal, test("6: pip_reverse_macro reverses list") ///
    got("`mylist'") expected("d c b a")

// Single element — should be unchanged
local single "only"
mata: pip_reverse_macro("single", 1)
assert_local_equal, test("6b: single element unchanged") got("`single'") expected("only")

// ========================================================
// Test 7: pip_mkdir_recursive
// ========================================================
di as result "--- pip_mkdir_recursive ---"

// Create a nested temp directory and verify it exists
local _base = c(tmpdir)
mata: st_local("_nested", pathjoin("`_base'", "pip_test_nested/subdir_a"))
mata: _rc7 = pip_mkdir_recursive("`_nested'", 1)
mata: st_local("_exists7", strofreal(direxists("`_nested'")))
if (`_exists7' != 1) {
    di as error "FAIL Test 7: pip_mkdir_recursive did not create nested dir '`_nested''"
    error 9
}
di as result "  PASS Test 7: pip_mkdir_recursive creates nested directories"

// Cleanup: remove test directories (best-effort)
capture {
    mata: st_local("_parent", pathjoin("`_base'", "pip_test_nested"))
    rmdir "`_nested'"
    rmdir "`_parent'"
}

clear
di as result _n "All pip_fun.mata tests passed."

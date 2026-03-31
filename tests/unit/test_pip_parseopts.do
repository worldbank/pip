/*==================================================
project:       Unit tests for pip_parseopts
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip_parseopts correctly parses subcommands and options
               into r-class returns. Tests are fully offline — no API calls.
Layer:         Option parsing
==================================================*/
version 16.1
set more off

adopath ++ "../.."
capture program drop pip_parseopts
run "../../pip_parseopts.ado"

* Load shared assertion helpers (relative path from unit/ to tests/)
run "../test_helpers.do"

di as result "=== pip_parseopts: option parsing ==="

// ---- Test 1: subcommand extraction -----
pip_parseopts cl, country(CHN)
local _sub = "`r(subcmd)'"
local _cty = "`r(country)'"
assert_local_equal, test("1a: subcmd==cl") got("`_sub'") expected("cl")
assert_local_equal, test("1b: country option returned") got("`_cty'") expected("country(CHN)")

// ---- Test 2: no subcommand (comma-only call) -----
pip_parseopts , country(CHN)
local _sub2 = "`r(subcmd)'"
if ("`_sub2'" != "") {
    di as error "  FAIL 2: no subcmd returns empty: got '`_sub2'' (expected '')"
    error 9
}
di as result "  PASS 2: no subcmd returns empty"

// ---- Test 3: all option names appear in r(optnames) -----
pip_parseopts cl, country(CHN) year(2018) povline(2.15)
local _optnames = "`r(optnames)'"
foreach opt in country year povline {
    if !strpos(" `_optnames' ", " `opt' ") {
        di as error "FAIL Test 3: '`opt'' not found in r(optnames) = '`_optnames''"
        error 9
    }
}
di as result "  PASS Test 3: all option names in r(optnames)"

// ---- Test 4: options with parenthesized values -----
pip_parseopts cl, povline(1.9) year(2015)
local _povline = "`r(povline)'"
local _year    = "`r(year)'"
assert_local_equal, test("4a: povline() returned") got("`_povline'") expected("povline(1.9)")
assert_local_equal, test("4b: year() returned") got("`_year'") expected("year(2015)")

// ---- Test 5: boolean (flag) options -----
pip_parseopts cl, fillgaps clear
local _fg  = "`r(fillgaps)'"
local _clr = "`r(clear)'"
assert_local_equal, test("5a: fillgaps flag returned") got("`_fg'") expected("fillgaps")
assert_local_equal, test("5b: clear flag returned") got("`_clr'") expected("clear")

// ---- Test 6: r(returnnames) lists all returned macro names -----
pip_parseopts wb, region(SSA) povline(2.15)
local _rnames = "`r(returnnames)'"
// subcmd and each option name must be in returnnames
foreach nm in subcmd region povline {
    if !strpos(" `_rnames' ", " `nm' ") {
        di as error "FAIL Test 6: '`nm'' not found in r(returnnames) = '`_rnames''"
        error 9
    }
}
di as result "  PASS Test 6: r(returnnames) contains subcmd and option names"

// ---- Test 7: subcommand with no options -----
pip_parseopts tables
local _sub7 = "`r(subcmd)'"
local _opts7 = "`r(optnames)'"
assert_local_equal, test("7a: subcmd==tables") got("`_sub7'") expected("tables")
assert_local_equal, test("7b: no options -> empty optnames") got("`_opts7'") expected("")

// ---- Test 8: pipoptions macro contains full option string -----
pip_parseopts cl, country(CHN) year(2018)
local _pipopt = "`r(pipoptions)'"
if ("`_pipopt'" == "") {
    di as error "FAIL Test 8: r(pipoptions) is empty"
    error 9
}
di as result "  PASS Test 8: r(pipoptions) non-empty"

di as result _n "All pip_parseopts tests passed."

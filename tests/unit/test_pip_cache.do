/*==================================================
project:       Unit tests for pip_cache
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip_cache subprograms (gethash, save, load, iscache,
               disabled-cache path) without any network calls.
               Tests use a temporary directory for the cache so the real
               user cache is never touched.
Layer:         Caching
==================================================*/
version 16.1
set more off

adopath ++ "../.."

* Load pip_cache and its dependencies
foreach _prog in pip_cache pip_cache_gethash pip_cache_iscache  ///
    pip_cache_delete pip_cache_info pip_cache_inventory           ///
    pip_setup_gethash {
    capture program drop `_prog'
}
run "../../pip_cache.ado"
run "../../pip_fun.mata"   // hash1() and pathjoin() used by pip_cache

* Load shared assertion helpers
run "../test_helpers.do"

di as result "=== pip_cache: hash, save, load, iscache ==="

// ---- Set up a temporary cache directory -----
// We redirect $pip_cachedir to a tempdir so no real cache is touched.
tempfile _cache_root
local _cache_dir = "`_cache_root'_dir"
mata: st_local("_cache_exists", strofreal(direxists("`_cache_dir'")))
if (`_cache_exists' == 0) {
    mata: _mkdir("`_cache_dir'", 1)
}

local _orig_cachedir "${pip_cachedir}"
global pip_cachedir "`_cache_dir'"

// ---- Test 1: same query produces same hash -----
pip_cache gethash, query("pip?country=CHN&year=2018&format=csv")
local hash1a = "`r(piphash)'"
pip_cache gethash, query("pip?country=CHN&year=2018&format=csv")
local hash1b = "`r(piphash)'"
assert_local_equal, test("1: same query -> same hash") got("`hash1a'") expected("`hash1b'")

// ---- Test 2: different queries produce different hashes -----
pip_cache gethash, query("pip?country=IND&year=2018&format=csv")
local hash2 = "`r(piphash)'"
if ("`hash1a'" == "`hash2'") {
    di as error "FAIL Test 2: different queries should produce different hashes"
    error 9
}
di as result "  PASS Test 2: different queries produce different hashes"

// ---- Test 3: hash format is _pip followed by digits -----
if !regexm("`hash1a'", "^_pip[0-9]+$") {
    di as error "FAIL Test 3: hash '`hash1a'' does not match _pip<digits> format"
    error 9
}
di as result "  PASS Test 3: hash format is _pip<digits>"

// ---- Test 4: empty query does not crash -----
capture pip_cache gethash, query("")
local _rc4 = _rc
assert_rc_zero, test("4: empty query does not crash") rc(`_rc4')

// ---- Test 5: save / load round-trip -----
// Create a small dataset to cache
clear
set obs 3
gen country_code = "TST"
gen year = 2020 + _n
gen headcount = _n * 0.1

local q5 "pip?country=TST&year=2020&format=csv"
pip_cache gethash, query("`q5'")
local hash5 = "`r(piphash)'"

// Save the dataset
pip_cache save, piphash("`hash5'") query("`q5'") cachedir("`_cache_dir'")

// Verify file exists on disk
mata: st_local("_file5", pathjoin("`_cache_dir'", "`hash5'.dta"))
cap confirm file "`_file5'"
assert_rc_zero, test("5a: cache file created on disk") rc(`=_rc')

// Load it back and verify contents
clear
pip_cache load, query("`q5'") cachedir("`_cache_dir'") clear
local pc5 = "`r(pc_exists)'"
assert_local_equal, test("5b: load returns pc_exists==1") got("`pc5'") expected("1")
assert_nobs_equal, test("5c: loaded data has 3 obs") expected(3)
assert_var_exists, test("5d: country_code var present") var(country_code)

// ---- Test 6: cacheforce bypasses existing cache -----
pip_cache load, query("`q5'") cachedir("`_cache_dir'") clear cacheforce
local pc6 = "`r(pc_exists)'"
assert_local_equal, test("6: cacheforce returns pc_exists==0") got("`pc6'") expected("0")

// ---- Test 7: load for missing file returns pc_exists==0 -----
pip_cache load, query("pip?country=ZZZ&year=9999&format=csv") cachedir("`_cache_dir'") clear
local pc7 = "`r(pc_exists)'"
assert_local_equal, test("7: missing file returns pc_exists==0") got("`pc7'") expected("0")

// ---- Test 8: pip_cache_iscache on cached vs non-cached data -----
// Load cached data and check characteristic
pip_cache load, query("`q5'") cachedir("`_cache_dir'") clear
pip_cache iscache
local hash8 = "`r(hash)'"
if ("`hash8'" == "") {
    di as error "FAIL Test 8a: iscache should return hash for cached data"
    error 9
}
di as result "  PASS Test 8a: iscache returns hash '`hash8'' for cached data"

// Fresh non-cached dataset has no characteristic
clear
set obs 2
gen x = 1
pip_cache iscache
local hash8b = "`r(hash)'"
if ("`hash8b'" != "") {
    di as error "  FAIL 8b: iscache returns empty hash for non-cached data: got '`hash8b''"
    error 9
}
di as result "  PASS 8b: iscache returns empty hash for non-cached data"

// ---- Test 9: caching disabled (pip_cachedir==0) -----
global pip_cachedir "0"
pip_cache load, query("`q5'") clear
local pc9  = "`r(pc_exists)'"
local hsh9 = "`r(piphash)'"
assert_local_equal, test("9a: disabled cache returns pc_exists==0") got("`pc9'") expected("0")
assert_local_equal, test("9b: disabled cache returns piphash==0") got("`hsh9'") expected("0")

// ---- Restore original cache dir and clean up -----
global pip_cachedir "`_orig_cachedir'"
// Remove temp cache dir and its contents
capture {
    local _tmpfiles: dir "`_cache_dir'" files "*"
    foreach _f of local _tmpfiles {
        erase "`_cache_dir'/`_f'"
    }
    rmdir "`_cache_dir'"
}

clear
di as result _n "All pip_cache unit tests passed."

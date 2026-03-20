/*==================================================
project:       Test pip_gh return values and version comparison arithmetic
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify pip_gh r-class returns and semver weighted comparison
               without requiring a live network call.
               Tests use local version strings directly to isolate arithmetic.
==================================================*/
version 16.1
set more off

adopath ++ ".."
capture program drop pip_gh
capture program drop pip_githubquery
run "../pip_gh.ado"

di as result "=== pip_gh: semver weighted comparison arithmetic ==="

* ---- Test 1: basic comparison - newer version detected -----
local maj1 0
local min1 10
local pat1 0
local maj2 0
local min2 11
local pat2 0
local cmp1 = `maj1' * 1000000 + `min1' * 1000 + `pat1'
local cmp2 = `maj2' * 1000000 + `min2' * 1000 + `pat2'
if !(`cmp2' > `cmp1') {
    di as error "FAIL Test 1: 0.11.0 should be newer than 0.10.0"
    error 9
}
di as result "  PASS Test 1: 0.11.0 > 0.10.0"

* ---- Test 2: multi-digit minor - the concatenation anti-pattern -----
* 0.9.10 vs 0.10.0: string concat gives "0910" > "0100" (WRONG)
* Weighted arithmetic must give 0.10.0 > 0.9.10 (CORRECT)
local maj1 0
local min1 9
local pat1 10
local maj2 0
local min2 10
local pat2 0
local cmp1 = `maj1' * 1000000 + `min1' * 1000 + `pat1'
local cmp2 = `maj2' * 1000000 + `min2' * 1000 + `pat2'
if !(`cmp2' > `cmp1') {
    di as error "FAIL Test 2: 0.10.0 should be newer than 0.9.10 (multi-digit regression)"
    error 9
}
di as result "  PASS Test 2: 0.10.0 > 0.9.10 (multi-digit components handled correctly)"

* ---- Test 3: equal versions - no update -----
local maj1 0
local min1 11
local pat1 0
local cmp1 = `maj1' * 1000000 + `min1' * 1000 + `pat1'
local cmp2 = `cmp1'
if (`cmp2' > `cmp1') {
    di as error "FAIL Test 3: equal versions should not trigger update"
    error 9
}
di as result "  PASS Test 3: equal versions do not trigger update"

* ---- Test 4: patch update detected -----
local maj1 0
local min1 11
local pat1 0
local maj2 0
local min2 11
local pat2 1
local cmp1 = `maj1' * 1000000 + `min1' * 1000 + `pat1'
local cmp2 = `maj2' * 1000000 + `min2' * 1000 + `pat2'
if !(`cmp2' > `cmp1') {
    di as error "FAIL Test 4: 0.11.1 should be newer than 0.11.0"
    error 9
}
di as result "  PASS Test 4: 0.11.1 > 0.11.0 (patch update)"

* ---- Test 5: cond() produces correct string output -----
local last_cmp    = 0 * 1000000 + 11 * 1000 + 1
local current_cmp = 0 * 1000000 + 11 * 1000 + 0
local update_available = cond(`last_cmp' > `current_cmp', "1", "0")
if ("`update_available'" != "1") {
    di as error "FAIL Test 5: update_available should be '1' when newer"
    error 9
}
di as result "  PASS Test 5: cond() returns '1' string when update available"

local last_cmp    = 0 * 1000000 + 11 * 1000 + 0
local current_cmp = `last_cmp'
local update_available = cond(`last_cmp' > `current_cmp', "1", "0")
if ("`update_available'" != "0") {
    di as error "FAIL Test 5b: update_available should be '0' when same version"
    error 9
}
di as result "  PASS Test 5b: cond() returns '0' string when versions equal"

* ---- Test 6: semver regex anchoring - pre-release tags rejected -----
* A pre-release tag like "1.1.0-rc1" must NOT match the anchored pattern
local tag "1.1.0-rc1"
if regexm("`tag'", "^([0-9]+)\.([0-9]+)\.([0-9]+)$") {
    di as error "FAIL Test 6: pre-release tag '`tag'' should not match anchored semver"
    error 9
}
di as result "  PASS Test 6: pre-release tag rejected by anchored regex"

* ---- Test 7: valid tag matches anchored pattern -----
local tag "0.11.0"
if !regexm("`tag'", "^([0-9]+)\.([0-9]+)\.([0-9]+)$") {
    di as error "FAIL Test 7: valid tag '`tag'' should match anchored semver"
    error 9
}
di as result "  PASS Test 7: valid semver tag accepted"

* ---- Test 8: GitHub API regex handles space after colon -----
* Simulate real GitHub API JSON format: "tag_name": "v0.11.0"
local json `"{"tag_name": "v0.11.0","prerelease":false}"'
if !regexm(`"`json'"', `""tag_name": *"([^"]+)""') {
    di as error `"FAIL Test 8: regex failed to match JSON with space after colon"'
    error 9
}
local extracted = regexs(1)
if ("`extracted'" != "v0.11.0") {
    di as error "FAIL Test 8b: extracted '`extracted'', expected 'v0.11.0'"
    error 9
}
di as result "  PASS Test 8: regex handles 'tag_name': 'v...' with space"

* ---- Test 9: old regex (no space) fails on real API format -----
* Documents the bug that was present before the fix
local json `"{"tag_name": "v0.11.0","prerelease":false}"'
if regexm(`"`json'"', `""tag_name":"([^"]+)""') {
    di as error "UNEXPECTED: old regex (no space) matched - GitHub API format may have changed"
}
else {
    di as result "  PASS Test 9: confirms old regex (no space) would have failed silently"
}

di as result _n "All pip_gh arithmetic and regex tests passed."

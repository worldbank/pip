*!version 0.11.0  <2026mar19>
/*==================================================
project:       Check whether a new version of pip is available on GitHub
Author:        R.Andres Castaneda
E-email:       acastanedaa@worldbank.org
url:
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     6 Oct 2022 - 16:35:59
Modification Date: 19 Mar 2026
Do-file version:    02
References:
Output:        r(update_available), r(latest_version), r(current_version),
               r(install_cmd)
==================================================*/


/*==================================================
              0: Program set up
==================================================*/
program define pip_gh, rclass
version 16.1

* ---- 1. Get installed version from 'which pip' output -----

capture which pip
if (_rc) exit 1   // pip not found - skip silently
local whichout = r(fn)

* The *!version line is the first line of pip.ado
* Assumes pip.ado starts with "*!version X.Y.Z" (standard Stata convention)
tempname fh
capture file open `fh' using `"`whichout'"', read text
if (_rc) exit 1   // can't open file - skip silently
capture file read `fh' line
local rc_fh = _rc              // save before file close resets _rc
capture file close `fh'        // always runs: file was opened successfully above
if (`rc_fh') exit 1   // can't read file - skip silently

* Parse version string from "*!version X.Y.Z"
if !regexm(`"`line'"', "([0-9]+)\.([0-9]+)\.([0-9]+)") exit 1
local crrMajor = regexs(1)
local crrMinor = regexs(2)
local crrPatch = regexs(3)
local crrtversion = "`crrMajor'.`crrMinor'.`crrPatch'"
* Weighted numeric comparison avoids wrong results with multi-digit components
* (e.g. concatenation: 0.9.10 -> "0910" > 0.10.0 -> "0100" would be wrong)
* Constraint: each component must be < 1000 for the weighting to be correct.
local current_cmp = `crrMajor' * 1000000 + `crrMinor' * 1000 + `crrPatch'


* ---- 2. Query GitHub API for latest release -----

pip_githubquery worldbank/pip
local latestversion = "`r(latestversion)'"
if ("`latestversion'" == "") exit 1   // API unreachable - skip silently

if regexm("`latestversion'", "^([0-9]+)\.([0-9]+)\.([0-9]+)$") {
	local lastMajor = regexs(1)
	local lastMinor = regexs(2)
	local lastPatch = regexs(3)
}
else exit 1   // tag is not a valid semver or is a pre-release - skip silently
local last_cmp = `lastMajor' * 1000000 + `lastMinor' * 1000 + `lastPatch'


* ---- 3. Build install command (prefer 'github' package if available) -----

capture which github
if (_rc == 0) {
	local install_cmd "github install worldbank/pip, replace"
}
else {
	local install_cmd `"net install pip, from("https://raw.githubusercontent.com/worldbank/pip/main/") replace"'
}


* ---- 4. Compare and return results -----
* r(update_available) is returned as string "1"/"0" (r-class macros are always strings)

local update_available = cond(`last_cmp' > `current_cmp', "1", "0")

return local update_available "`update_available'"
return local latest_version   = "`latestversion'"
return local current_version  = "`crrtversion'"
return local install_cmd      = `"`install_cmd'"'

end


*==================================================
* Auxiliary: query GitHub releases/latest API
*==================================================

program define pip_githubquery, rclass
/*
  Queries https://api.github.com/repos/<repo>/releases/latest and returns
  the tag name of the most recent release in r(latestversion).
  Fails silently if the network is unavailable or the repo has no releases.
*/
version 16.1
syntax anything(name=repo)

local latestversion ""
capture scalar drop `gh_json'   // pre-clear in case of prior interrupted run
tempname gh_json
capture {
	local page `"https://api.github.com/repos/`repo'/releases/latest"'
	scalar `gh_json' = fileread(`"`page'"')
	if regexm(scalar(`gh_json'), `""tag_name": *"([^"]+)""') {
		local latestversion = regexs(1)
	}
}
capture scalar drop `gh_json'

* Strip leading 'v' prefix from tag if present (e.g. "v0.11.0" -> "0.11.0")
if regexm("`latestversion'", "^v(.+)") local latestversion = regexs(1)

return local latestversion `latestversion'

end

exit
/* End of do-file */

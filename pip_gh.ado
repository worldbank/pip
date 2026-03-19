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

// ---- 1. Get installed version from 'which pip' output -----

capture which pip
if (_rc) {
	* pip not found â€” skip silently
	exit
}
local whichout = r(fn)

* The *!version line is the first line of pip.ado
tempname fh
capture {
	file open `fh' using `"`whichout'"', read text
	file read `fh' line
	file close `fh'
}
if (_rc) exit   // can't read file â€” skip silently

* Parse version string from "*!version X.Y.Z"
if !regexm(`"`line'"', "([0-9]+)\.([0-9]+)\.([0-9]+)") exit
local crrMajor = regexs(1)
local crrMinor = regexs(2)
local crrPatch = regexs(3)
local crrtversion = "`crrMajor'.`crrMinor'.`crrPatch'"
local current = `crrMajor'`crrMinor'`crrPatch'


// ---- 2. Query GitHub API for latest release -----

_pip_githubquery worldbank/pip
local latestversion = "`r(latestversion)'"
if ("`latestversion'" == "") exit   // API unreachable â€” skip silently

if regexm("`latestversion'", "([0-9]+)\.([0-9]+)\.([0-9]+)") {
	local lastMajor = regexs(1)
	local lastMinor = regexs(2)
	local lastPatch = regexs(3)
}
local last = `lastMajor'`lastMinor'`lastPatch'


// ---- 3. Build install command (prefer 'github' package if available) -----

capture which github
if (_rc == 0) {
	local install_cmd "github install worldbank/pip, replace"
}
else {
	local install_cmd `"net install pip, from("https://raw.githubusercontent.com/worldbank/pip/main/") replace"'
}


// ---- 4. Compare and return results -----

local update_available = (`last' > `current')

return local update_available = `update_available'
return local latest_version   = "`latestversion'"
return local current_version  = "`crrtversion'"
return local install_cmd      = `"`install_cmd'"'

end


//========================================================
// Auxiliary: query GitHub releases API
//========================================================

program define _pip_githubquery, rclass
/*
  Queries https://api.github.com/repos/<repo>/releases and returns
  the tag name of the most recent release in r(latestversion).
  Fails silently if the network is unavailable.
*/
version 16.1
syntax anything(name=repo)

preserve
drop _all

capture {
	local page "https://api.github.com/repos/`repo'/releases"
	scalar _pip_gh_page = fileread(`"`page'"')
	mata {
		lines = st_strscalar("_pip_gh_page")
		lines = ustrsplit(lines, ",")'
		lines = strtrim(lines)
		lines = stritrim(lines)
		lines = subinstr(lines, `"":""', "->")
		lines = subinstr(lines, `"""', "")
	}
	getmata lines, replace

	split lines, parse("->")
	rename lines? (code url)

	keep if regexm(url, "releases/tag")
	gen tag = regexs(2) if regexm(url, "(releases/tag/)(.*)")
	local latestversion = tag[1]
}
scalar drop _pip_gh_page

restore
return local latestversion `latestversion'

end

exit
/* End of do-file */

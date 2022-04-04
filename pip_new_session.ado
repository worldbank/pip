/*==================================================
project:       Execute in each new Stata session
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World bank
----------------------------------------------------
Creation Date:    30 Nov 2021 - 16:05:24
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_new_session, rclass
version 16.0

syntax [anything(name=subcommand)]  ///
[,                             	    /// 
pause                             /// 
] 

if ("`pause'" == "pause") pause on
else                      pause off


/*==================================================
1: Update PIP
==================================================*/

* mata: povcalnet_source("povcalnet") // creates local src
local cmd pip
local username "pip-technical-team"  // to modify

_pip_find_src `cmd'
local src = "`r(src)'"


* If PIP was installed from github
if (!regexm("`src'", "repec")) {
	
	* Check repository of files 
	* local cmd pip
	cap findfile github.dta, path("`c(sysdir_plus)'g/")
	if (_rc) {
		github install `username'/`cmd', replace
		cap window stopbox note "pip command has been reinstalled to " ///
		"keep record of new updates. Please type discard and retry."
		global pip_cmds_ssc = ""
		exit 
	}
	local ghfile "`r(fn)'"
	* use "`ghfile'", clear
	
	tempname ghdta 
	frame create `ghdta'
	frame `ghdta' {
		use "`ghfile'", clear
		qui keep if name == "`cmd'"  
		if _N == 0 {
			di in red "`cmd' package was not found"
			github install `username'/`cmd', replace
			cap window stopbox note "pip command has been reinstalled to " ///
			"keep record of new updates. Please type discard and retry."
			global pip_cmds_ssc = ""
			exit 
		}
		if _N > 1 {
			di as err "{p}multiple packages with this name are found!"      ///
			"this can be caused if you had installed multiple "     ///
			"packages from different repositories, but with an "    ///
			"identical name..." _n
			noi list
		}
		if _N == 1 {
			local repo        : di address[1]
			local crrtversion : di version[1]
		}
	}
	
	github query `repo'
	local latestversion = "`r(latestversion)'"
	* disp "`latestversion'"
	if regexm("`latestversion'", "([0-9]+)\.([0-9]+)\.([0-9]+)\.?([0-9]*)") {
		local lastMajor = regexs(1)
		local lastMinor = regexs(2)
		local lastPatch = regexs(3)		 
		local lastDevel = regexs(4)		 
	}
	if ("`lastDevel'" == "") local lastDevel 0
	local last    = `lastMajor'`lastMinor'`lastPatch'.`lastDevel'
	
	* github version `cmd'
	* local crrtversion =  "`r(version)'"
	if regexm("`crrtversion'", "([0-9]+)\.([0-9]+)\.([0-9]+)\.?([0-9]*)"){
		local crrMajor = regexs(1)
		local crrMinor = regexs(2)
		local crrPatch = regexs(3)
		local crrDevel = regexs(4)		 
	}
	if ("`crrDevel'" == "") local crrDevel 0
	local current = `crrMajor'`crrMinor'`crrPatch'.`crrDevel'
	disp "`current'"
	
	* force installation 
	if ("`crrtversion'" == "") {
		local username "pip-technical-team"  // to modify
		github install `username'/`cmd', replace version(`latestversion')
		cap window stopbox note "pip command has been reinstalled to " ///
		"keep record of new updates. Please type discard and retry."
		global pip_cmds_ssc = ""
		exit 
	}
	
	if (`last' > `current' ) {
		cap window stopbox rusure "There is a new version of `cmd' in Github (`latestversion')." ///
		"Would you like to install it now?"
		
		if (_rc == 0) {
			cap github install `repo', replace version(`latestversion')
			if (_rc == 0) {
				cap window stopbox note "Installation complete. please type" ///
				"discard in your command window to finish"
				local bye "exit"
			}
			else {
				noi disp as err "there was an error in the installation. " _n ///
				"please run the following to retry, " _n(2) ///
				"{stata github install `repo', replace}"
				local bye "error"
			}
		}	
		else local bye ""
		
	}  // end of checking github update
	
	else {
		noi disp as result "Github version of {cmd:`cmd'} is up to date."
		local bye ""
	}
	
} // end if installed from github 

else {  // if pip was installed from SSC
	
	qui adoupdate pip, ssconly
	if ("`r(pkglist)'" == "pip") {
		cap window stopbox rusure "There is a new version of pip in SSC." ///
		"Would you like to install it now?"
		
		if (_rc == 0) {
			cap ado update pip, ssconly update
			if (_rc == 0) {
				cap window stopbox note "Installation complete. please type" ///
				"discard in your command window to finish"
				local bye "exit"
			}
			else {
				noi disp as err "there was an error in the installation. " _n ///
				"please run the following to retry, " _n(2) ///
				"{stata ado update pip, ssconly update}"
				local bye "error"
			}
		}
		else local bye ""
	}  // end of checking SSC update
	else {
		noi disp as result "SSC version of {cmd:pip} is up to date."
		local bye ""
	}
}  // Finish checking pip update 


/*==================================================
2: Dependencies         
==================================================*/

*---------- check SSC commands

local ssc_cmds missings 

noi disp in y "Note: " in w "{cmd:pip} requires the packages " ///
"below from SSC: " _n in g "`ssc_cmds'"

foreach cmd of local ssc_cmds {
	capture which `cmd'
	if (_rc != 0) {
		ssc install `cmd'
		noi disp in g "{cmd:`cmd'} " in w _col(15) "installed"
	}
}

adoupdate `ssc_cmds', ssconly
if ("`r(pkglist)'" != "") adoupdate `r(pkglist)', update ssconly

global pip_cmds_ssc = 1  // make sure it does not execute again per session
`bye'

end 


//========================================================
// Aux programs
//========================================================

program define _pip_find_src, rclass 
syntax anything(name=cmd id="Package name")

qui {
	preserve
	drop _all
	
	// find stata.trk file 
	findfile stata.trk
	local fn = "`r(fn)'"
	
	// create copy
	tempfile statatrk
	copy "`r(fn)'" "`statatrk'"
	
	// import copy into stata
	import delimited using `statatrk',  bindquote(nobind)
	
	gen n = _n    // line number
	
	// find line where the package is used
	levelsof n if regexm(v1, "`cmd'.pkg"), sep(,) loca(pklines)
	
	if (`"`pklines'"' == `""') local src = "NotInstalled"
	else {
		
		// the latest source and subtract which refers to the source 
		local sourceline = max(0, `pklines') - 1 
		
		// get the source without the initial S
		if regexm(v1[`sourceline'], "S (.*)") local src = regexs(1)
	}
	
	// return info 
	return local src = "`src'"
} // end of qui
end 





exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



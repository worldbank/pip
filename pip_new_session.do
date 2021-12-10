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
version 16.1

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
_pip_find_src pip
local src = "`r(src)'"

* If PIP was installed from github
if (regexm("`src'", "github")) {
	local git_cmds pip
	
	foreach cmd of local git_cmds {
		
		* Check repository of files 
		* mata: povcalnet_source("`cmd'")
		_pip_find_src `cmd'
		local src = "`r(src)'"
		
		if regexm("`src'", "\.io/") {  // if site
			if regexm("`src'", "://([^ ]+)\.github") {
				local repo = regexs(1) + "/`cmd'"
			}
		}
		else {  // if branch
			if regexm("`src'", "\.com/([^ ]+)(/`cmd')") {
				local repo = regexs(1) + regexs(2) 
			}
		}
		
		qui github query `repo'
		local latestversion = "`r(latestversion)'"
		if regexm("`r(latestversion)'", "([0-9]+)\.([0-9]+)\.([0-9]+)"){
			local lastMajor = regexs(1)
			local lastMinor = regexs(2)
			local lastPatch = regexs(3)		 
		}
		
		qui github version `cmd'
		local crrtversion =  "`r(version)'"
		if regexm("`r(version)'", "([0-9]+)\.([0-9]+)\.([0-9]+)"){
			local crrMajor = regexs(1)
			local crrMinor = regexs(2)
			local crrPatch = regexs(3)
		}
		foreach x in repo cmd {
			local `x' : subinstr local `x' "." "", all 
			local `x' : subinstr local `x' "-" ".", all 
			if regexm("``x''", "([0-9]+)(\.)?([a-z]+)?([0-9]?)") {
				disp regexs(1) regexs(2) regexs(4)
			}
			
		}
		
		* force installation 
		if ("`crrtversion'" == "") {
			github install `repo', replace
			cap window stopbox note "github command has been reinstalled to " ///
			"keep record of new updates. Please type discard and retry."
			global pip_cmds_ssc = ""
			exit 
		}
		
		if (`lastMajor' > `crrMajor' | `lastMinor' > `crrMinor' | `lastPatch' > `crrPatch') {
			* if (`lastMajor'`lastMinor'`lastPatch' > `crrMajor'`crrMinor'`crrPatch') {
			cap window stopbox rusure "There is a new version of `cmd' in Github (`latestversion')." ///
			"Would you like to install it now?"
			
			if (_rc == 0) {
				cap github install `repo', replace
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
		
	} // end of loop
	
} // end if installed from github 

else if (regexm("`src'", "repec")) {  // if pip was installed from SSC
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
else {
	noi disp as result "Source of {cmd:pip} package not found." _n ///
	"You won't be able to benefit from latest updates."
	local bye ""
}


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



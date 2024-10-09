/*==================================================
project:       message to the user if file is installed from GitHub
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     6 Oct 2022 - 16:35:59
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
program define pip_gh, rclass
version 16.1


syntax [anything(name=subcommand)]  ///
[,                             	    ///
username(string)                    ///
cmd(string)                         ///
version(string)                     ///
pause                               /// 
check                               /// 
] 

if ("`pause'" == "pause") pause on
else                      pause off

if ("`cmd'" == "") {
	local cmd pip
}

if ("`username'" == "") {
	local username "worldbank"  
}


/*==================================================
              1: Update
==================================================*/

if ("`subcommand'" == "update") {
	* Check repository of files 
	* local cmd pip
	cap findfile github.dta, path("`c(sysdir_plus)'g/")
	if (_rc) {
		if ("`check'" == "check") {
			dis "pip update will install a new version of the {cmd:pip} package."
			dis "If you wish to proceed, run {cmd:pip update} without the check argument."
		}
		else {
			github install `username'/`cmd', replace
			cap window stopbox note "pip command has been reinstalled to " ///
			"keep record of new updates. Please type {stata discard} and retry."
			global pip_old_session = ""
		}
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
			if ("`check'" == "check") {
				dis "pip update will install a new version of the {cmd:pip} package."
				dis "If you wish to proceed, run {cmd:pip update} without the check argument."
			}
			else {
				di in red "`cmd' package was not found"
				github install `username'/`cmd', replace
				cap window stopbox note "pip command has been reinstalled to " ///
				"keep record of new updates. Please type discard and retry."
				global pip_old_session = ""
			}
			exit
		}
		if _N > 1 {
			di as err "{p}multiple {cmd:pip} packages found!"      ///
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
	
	* github query `repo'
	_tmp_githubquery `repo'
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
	* disp "`current'"
	
	* force installation 
	if ("`crrtversion'" == "") {
		if ("`check'" == "check") {
			dis "pip update will install a new version of the {cmd:pip} package."
			dis "If you wish to proceed, run {cmd:pip update} without the check argument."
		}
		else {
			local username "worldbank"  // to modify
			github install `username'/`cmd', replace version(`latestversion')
			cap window stopbox note "pip command has been reinstalled to " ///
			"keep record of new updates. Please type discard and retry."
			global pip_old_session = ""
		}
		exit 
	}
	
	if (`last' > `current' ) {
		if ("`check'" == "check") {
			dis "There is a new version of `cmd' in Github (`latestversion')."
			dis "If you wish to proceed, run {cmd:pip update} without the check argument."
			exit		
		}
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
	
	return local bye = "`bye'"
	
} // end if installed from github 



/*==================================================
              2: Message
==================================================*/
if (inlist("`subcommand'", "msg", "message")) {
	noi disp "You're using Github as the host of the {cmd:pip} Stata package." 
	noi disp "If you want to install the SSC version type {stata pip_install ssc}" 
}

//========================================================
// Install
//========================================================

if (inlist("`subcommand'", "install")) {
	pip_install gh, replace version(`version')
}


end

//========================================================
// Aux programs
//========================================================

// Temporal github query
program define _tmp_githubquery, rclass 
syntax anything

qui {
	
	preserve
	drop _all
	
	local page "https://api.github.com/repos/`anything'/releases"
	scalar page = fileread(`"`page'"')
	mata {
		lines = st_strscalar("page")
		lines = ustrsplit(lines, ",")'
		lines = strtrim(lines)
		lines = stritrim(lines)
		
		lines =  subinstr(lines, `"":""', "->")
		lines =  subinstr(lines, `"""', "")
	}
	getmata lines, replace
	
	split lines, parse ("->")
	rename lines? (code url)
	
	keep if regexm(url, "releases/tag")
	gen tag  = regexs(2) if regexm(url, "(releases/tag/)(.*)")
	local latestversion = tag[1]
	
}

return local latestversion `latestversion' 

end 

exit

/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



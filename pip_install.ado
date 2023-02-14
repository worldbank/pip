/*==================================================
project:       utility to install pip easily
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     6 Oct 2022 - 18:43:11
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_install, rclass
version 16.0


syntax [anything(name=src)]  ///
[,                           ///
username(string)             ///
cmd(string)                  ///
version(string)              ///
pause                        /// 
replace                      ///
path(string)                 ///
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
1: Search source
==================================================*/
qui pip_find_src, path(`path')
if ("`src'" == "") {	
	local src      = "`r(src)'"
}

//========================================================
//  Uninstall
//========================================================

// number of pip versions installed
local trk_code =  "`r(trk_code)'"
local trk_srcs = `"`r(trk_sources)'"'

local ncodes: list sizeof trk_code

if ("`src'" == "uninstall" | `ncodes' > 1) {
	
	if (`ncodes' > 1) {
	
		noi disp as err "There is more than one version of PIP installed in the same search path, `path'." _n ///
		as res "You need to uninstall {cmd:pip} in `path' or change installation path" ///
		" with option {it:path()}" _n ///
		"Type {it:yes} in the console and hitting enter to confirm uninstall of {cmd:pip}" _request(_confirm)
		if ("`confirm'" != "yes") {	
			error 
		}
	}
	while ("`trk_code'" != "") {
		local srcs : word 1 of `trk_srcs'
		if regexm(`"`srcs'"', "repec") {
			ado uninstall [`: word 1 of `trk_code'']
		}
		else {
			github uninstall [`: word 1 of `trk_code'']
		}
		qui pip_find_src, path(`path')
		local trk_code =  "`r(trk_code)'"
		local trk_srcs = `"`r(trk_sources)'"'
	}
	
	if ("`trk_code'" == "") {
		noi disp as res "{cmd:pip} was successfully uninstalled"
		if ("`src'" == "uninstall") exit
	}
	else {
		error
	}
}



/*==================================================
Install
==================================================*/

if (inlist(lower("`src'"), "github", "gh")) {
	local src "gh"
	local source "GitHub"
	local alt_src "ssc"
	local alt_source "SSC"
}
else if (lower("`src'") == "ssc") {
	local src "ssc"
	local source "SSC"
	local alt_src "gh"
	local alt_source "GitHub"
}
else {
	noi disp as error "source `src' is not available. Use either {it:gh} or {it:ssc}"
	error 
}

if ("`src'" == "ssc") {
	cap ado uninstall pip
}
else {
	cap github uninstall pip
}
if (_rc) {
	if (_rc == 111) {
		noi disp "package pip does not seems to be installed" // this should not ever happen
	}
	else {
		error _rc
	}
} 

if ("`src'" == "gh") {
	cap which github
	if (_rc) {
		net install github, from("https://haghish.github.io/github/")
	}
	
	cap noi github install `username'/`cmd', `replace' version(`version')
}
else {
	cap noi ssc install pip, `replace'
}
if (_rc) {
	noi disp as error _n "Something went wrong with the installation from `source'."
	
	if ("`src'" == "gh") {
		noi disp `"For troubleshooting, you can follow the instructions {browse "https://github.com/worldbank/pip#from-github":here}"'
	}
	
	noi disp "Alternatively, you could install {cmd:pip} from `alt_source'. Just type {stata pip_install `alt_src', replace}"
	error
}
global pip_source   = "`src'"

noi disp "You have successfully installed {cmd:pip} from `source'. Please type {stata discard} to load the recently installed version"

end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



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
[,                             	    ///
username(string)                   ///
cmd(string)                        ///
version(string)                    ///
pause                             /// 
replace                           ///
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
if ("`src'" == "") {
	
	if ("${pip_source}" == "") {
		pip_new_session, `pause'
	}
	
	local src = "${pip_source}"
}


/*==================================================
2: Install
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


cap ado uninstall pip
if (_rc) {
	if (_rc == 111) {
		noi disp "package pip does not seems to be installed"
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
	noi disp as error _n "Something went wrong with the installation from `source'"
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



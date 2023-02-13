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
path(string)                        ///
pause                             /// 
] 

if ("`pause'" == "pause") pause on
else                      pause off


/*==================================================
1: Update PIP
==================================================*/

* mata: povcalnet_source("povcalnet") // creates local src
local cmd pip
local username "worldbank"  // to modify

pip_find_src , path(`path')
local src = "`r(src)'"

//------------  If PIP was installed from github
if (!regexm("`src'", "ssc")) {
	
	pip_gh update, username(`username') cmd(`cmd') `pause'
	local bye = "`r(bye)'"
	local pip_source = "gh"
	
} // end if installed from github 

//------------ if pip was installed from SSC
else {  
	pip_ssc update, `pause'
	local bye = "`r(bye)'"
	local pip_source = "ssc"
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


* ----- Globals
global pip_cmds_ssc = 1  // make sure it does not execute again per session
global pip_source   = "`pip_source'"
`bye'

end 

exit

/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



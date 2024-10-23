/*==================================================
project:       update pip depending on source
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    13 Feb 2023 - 19:35:59
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
program define pip_update, rclass
syntax [anything(name=src)]  ///
[,                           ///
username(string)             ///
cmd(string)                  ///
version(string)              ///
pause                        /// 
replace                      ///
path(string)                 ///
check                        ///
] 

version 16.1


/*==================================================
	set up
==================================================*/

if ("`pause'" == "pause") pause on
else                      pause off


if ("`cmd'" == "") {
	local cmd pip
}

if ("`username'" == "") {
	local username "worldbank"  
}

//========================================================
// Update
//========================================================

pip_find_src , path(`path')
local src = "`r(src)'"
return add

//------------  If PIP was installed from github
if ("`src'" == "gh") {	
	pip_gh update, username(`username') cmd(`cmd') `pause' `check'
	return add
} // end if installed from github 

//------------ if pip was installed from SSC
else {  
	pip_ssc update, `pause' `check'
	return add
}  // Finish checking pip update 


end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



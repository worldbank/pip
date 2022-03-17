/*==================================================
project:       Define which server to use
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     1 Dec 2021 - 10:59:19
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_set_server, rclass
syntax [anything(name=server)]  ///
[,                             	/// 
pause                           /// 
] 

if ("`pause'" == "pause") pause on
else                      pause off

version 16.0

//========================================================
// Define server
//========================================================
*##s
* local server "prod"

//------------ If shortcut used
local current_server "https://api.worldbank.org/pip/v1" // production

if (inlist(lower("`server'"), "qa", "dev", "prod"))  {
		local server "${pip_svr_`server'}"
}


/*==================================================
2:  Server not defined
==================================================*/
if ("`server'" == "") {
	local server "`current_server'"
}

//========================================================
//  Test API Health
//========================================================


cap scalar tpage = fileread(`"`server'/health-check"')
* disp tpage

*##e


if (!regexm(tpage, "API is running") | _rc) {
	noi disp in red "There is a problem with PIP API server. Try again later"
	error
}

local url     = "`server'"	


//========================================================
// Return values
//========================================================

return local server = "`server'"
return local url    = "`url'"
return local base   = "`url'/pip"
return local base_grp  = "`url'/pip-grp"

end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



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
// Defina server
//========================================================


//------------ If shortcut used

* local current_server "https://pipscoreapiqa.worldbank.org"
local current_server "https://apiv2qa.worldbank.org"
* local current_server "https://api.worldbank.org" // production

if (inlist(lower("`server'"), "qa", "testing", "ar"))  {
		
	if (lower("`server'") == "qa")     {
		local server "${pip_svr_in}"
	}
	if (lower("`server'") == "testing") {
		local server "${pip_svr_ts}"
	}
	if (upper("`server'") == "AR") {
		local server "${pip_svr_ar}"
	}
	
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


cap scalar tpage = fileread(`"`server'/pip/v1/health-check"')

if (!regexm(tpage, "API is running") | _rc) {
	noi disp in red "There is a problem with PIP API server. Try again later"
	error
}

local base     = "`server'/pip/v1/pip"	
local base2    = "http://wzlxqpip01.worldbank.org/api/v1/pip-grp"


//========================================================
// Return values
//========================================================

return local server = "`server'"
return local base   = "`base'"
return local base2  = "`base2'"


end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



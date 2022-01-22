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


//------------ If shortcut used

* local current_server "https://pipscoreapiqa.worldbank.org"
local current_server "https://apiv2qa.worldbank.org"
local handle         "pip/v1"
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


cap scalar tpage = fileread(`"`server'/`handle'/health-check"')

if (!regexm(tpage, "API is running") | _rc) {
	noi disp in red "There is a problem with PIP API server. Try again later"
	error
}

local url     = "`server'/`handle'"	
local url2    = "http://wzlxqpip01.worldbank.org/`handle'"


//========================================================
// Return values
//========================================================

return local server = "`server'"
return local url    = "`url'"
return local base   = "`url'/pip"
return local base2  = "`url2'/pip-grp"
return local handle  = "`handle'"


end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



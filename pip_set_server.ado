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
[,                             	    /// 
pause                             /// 
] 

if ("`pause'" == "pause") pause on
else                      pause off

version 16.1


/*==================================================
1:  If Server defined
==================================================*/
if "`server'"!=""  {
	
	if !inlist(lower("`server'"), "int", "testing", "ar") {
		noi disp in red "the server requested does not exist" 
		error
	}
	
	if (lower("`server'") == "int")     {
		local server "${pip_svr_in}"
	}
	if (lower("`server'") == "testing") {
		local server "${pip_svr_ts}"
	}
	if (upper("`server'") == "AR") {
		local server "${pip_svr_ar}"
	}
	
	if ("`server'" == "") {
		noi disp in red "You don't have access to internal servers" _n /* 
		*/ "You're being redirected to public server"
		local server "https://pipscoreapiqa.worldbank.org"
		*local server "http://wzlxqpip01.worldbank.org"
	}
	
}
/*==================================================
2:  Server not defined
==================================================*/
else {
	local server "https://pipscoreapiqa.worldbank.org"
	*local server "http://wzlxqpip01.worldbank.org"
}

local base          = "`server'/api/v1/pip"	
*local base2             = "`server'/api/v1/pip-grp" // to exteract aggregated result 
local base2         = "http://wzlxqpip01.worldbank.org/api/v1/pip-grp"



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



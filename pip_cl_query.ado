/*==================================================
project:       Build country level query
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    12 May 2023 - 09:33:20
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
program define pip_cl_query, rclass
version 16
syntax ///
[ ,                             /// 
COUntry(string)                 /// 
REGion(string)                  /// 
YEAR(string)                    /// 
POVLine(numlist)                /// 
POPShare(numlist)	   	          /// 
PPP(numlist)                    /// 
COVerage(string)                /// 
FILLgaps                        /// 
VERsion(string)                 ///
] 

//========================================================
// conditions and set up
//========================================================

// country
local country = stritrim(ustrtrim("`country' `region'"))
local country : subinstr local country " " ",", all
if ("`country'" == "") local country = "all"
// year
local year: subinstr local year " " ",", all
if ("`year'" == "") local year = "all"

// fill gaps
if ("`fillgaps'" != "") local fill_gaps = "true"
else                    local fill_gaps = "false"
// reporting level
if ("`coverage'" == "") local reporting_level = "all"
else                    local reporting_level = "`coverage'"

//========================================================
// build query... THE ORDER IS VERY IMPORTANT
//========================================================

local params = "country year ppp fill_gaps " + ///
							 "reporting_level version welfare_type" 


foreach p of local params {
	if (`"``p''"' == `""') continue
	local query "`query'`p'=``p'' "
}
local query = ustrtrim("`query'")
local query : subinstr local query " " "&", all


//========================================================
//  Povline and Popshare are different
//========================================================


local optname = cond("`povline'" != "", "povline", "popshare")

if ("``optname''" == "") {
	global pip_last_queries "pip?`query'&format=csv"
	exit
}


tempname M
local i = 1
foreach v of local `optname' {
	// each povline or popshare + format
	local queryp = "pip?`query'&`optname'=`v'&format=csv" 
	if (`i' == 1) mata: `M' = "`queryp'"
	else            mata: `M' = `M' , "`queryp'"
	local ++i
}

mata: st_global("pip_last_queries", invtokens(`M'))


end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



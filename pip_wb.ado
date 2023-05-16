/*==================================================
project:       Interaction with the PIP API at aggregate level
Author:        R.Andres Castaneda 
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     2023-05-16 
Do-file version:    01
References:          
Output:             dta
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_wb, rclass
syntax ///
[ ,                             /// 
REGion(string)                  /// 
YEAR(string)                    /// 
POVLine(numlist)                /// 
PPP_year(numlist)               ///
COVerage(string)                /// 
CLEAR                           /// 
SERver(string)                  /// 
pause                           /// 
POVCALNET_format                ///
replace                         ///
VERsion(string)                 ///
IDEntity(string)                ///
RELease(numlist)                ///
cacheforce                      ///
] 

version 16.0

pip_timer pip_wb, on

if ("`pause'" == "pause") pause on
else                      pause off

qui {
	//========================================================
	// setup
	//========================================================
	//------------ get server url
	if ("${pip_host}" == "" | "`server'" != "") {
		pip_set_server,  server(`server')
	}
	
	//------------ Set versions
	if ("`version'" == "") {  // this should never be true
		noi pip_versions, server(`server')       /*
		*/                version(`version')     /*
		*/                release(`release')     /*
		*/                ppp_year(`ppp_year')   /*
		*/                identity(`identity')  
		local version    = "`r(version)'"		
	}
	//------------ Get auxiliary data
	pip_info, clear justdata `pause' server(`server') version(`version')
	
	//========================================================
	// Build query (queries returned in ${pip_last_queries}) 
	//========================================================
	pip_wb_query, region(`region') year(`year') povline(`povline')   /*
	*/            ppp(`ppp_year') coverage(`coverage')  version(`version')
	
	//========================================================
	// Getting data
	//========================================================
	
	//------------ download
	pip_timer pip_wb.pip_get, on
	pip_get, `clear' `cacheforce'
	pip_timer pip_wb.pip_get, off
	
	//------------ clean
	pip_timer pip_wb_clean, on
	pip_wb_clean, version(`version')
	pip_timer pip_wb_clean, off
	
	
	
	
}
pip_timer pip_wb, off
end


/*==================================================
Build CL query
==================================================*/
program define pip_wb_query, rclass
version 16
syntax ///
[ ,                             /// 
REGion(string)                  /// 
YEAR(string)                    /// 
POVLine(numlist)                /// 
PPP(numlist)                    /// 
COVerage(string)                /// 
VERsion(string)                 ///
] 

//========================================================
// conditions and set up
//========================================================
qui {
	
	// country
	local country = stritrim(ustrtrim("`region'"))
	local country : subinstr local country " " ",", all
	if ("`country'" == "") local country = "all"
	// year
	local year: subinstr local year " " ",", all
	if ("`year'" == "") local year = "all"
	
	// reporting level
	if ("`coverage'" == "") local reporting_level = "all"
	else                    local reporting_level = "`coverage'"
	
	//========================================================
	// build query... THE ORDER IS VERY IMPORTANT
	//========================================================
	
	local params = "country year reporting_level " + /* 
	 */             " version welfare_type" 
	
	
	foreach p of local params {
		if (`"``p''"' == `""') continue
		local query "`query'`p'=``p'' "
	}
	local query = ustrtrim("`query'")
	local query : subinstr local query " " "&", all
	
	
	//========================================================
	//  Povline
	//========================================================
	
	local endpoint "pip-grp"
	if ("`povline'" == "") {
		global pip_last_queries "`endpoint'?`query'&format=csv"
		exit
	}
	
	
	tempname M
	local i = 1
	foreach v of local povline {
		// each povline or popshare + format
		local queryp = "`endpoint'?`query'&povline=`v'&format=csv" 
		if (`i' == 1) mata: `M' = "`queryp'"
		else          mata: `M' = `M' , "`queryp'"
		local ++i
	}
	
	mata: st_global("pip_last_queries", invtokens(`M'))
}

end


/*==================================================
Clean Cl data
==================================================*/
program define pip_wb_clean, rclass
syntax, version(string)

version 16


qui {
	//========================================================
	// labels
	//========================================================
	
	
	//------------ All variables
	rename reporting_pop population
	
	label var region_code      "region code"
	label var reporting_year   "year"
	label var poverty_line     "poverty line in `ppp_version' PPP US\$ (per capita per day)"
	label var mean             "average daily per capita income/consumption in `ppp_version' PPP US\$"
	label var headcount        "poverty headcount"
	label var poverty_gap      "poverty gap"
	label var poverty_severity "squared poverty gap"
	label var population       "population in year"
	label var pop_in_poverty   "population in poverty"
	label var watts            "watts index"
	label var region_name      "world bank region"
	
	order region_name region_code reporting_year  poverty_line ///
	mean headcount poverty_gap  poverty_severity watts   ///
	population 
	
	//------------ Formatting
	format headcount poverty_gap poverty_severity watts mean  %8.4f
	
	format pop_in_poverty  population %15.0fc
	
	format poverty_line %6.2f
	
	local old "reporting_year"
	local new  "year"
	rename (`old') (`new')
	
	//------------ drop vars with missing value
	pip_utils dropvars
	
}

end


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:




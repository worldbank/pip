/*==================================================
project:       Interaction with the PIP API to generate country profile data
Author:        Tefera Bekele Degefu 
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     23 May 2023
Modification Date:   
Do-file version:    01
References:          
Output:             dta
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_cp, rclass
	syntax ///
	[ ,                             /// 
	COUntry(string)                 /// 
	POVLine(numlist)                /// 
	PPP_year(numlist)               ///
	CLEAR                           /// 
	SERver(string)                  /// 
	pause                           /// 
	replace                         ///
	cacheforce                      ///
	n2disp(passthru)                ///
	] 
	
	version 16.0
	
	pip_timer pip_cp, on
	
	if ("`pause'" == "pause") pause on
	else                      pause off

	qui {

		//========================================================
		// setup
		//========================================================
		//------------ setup 
		if ("${pip_version}" == "") {
			noi disp "{err}No version selected."
			error
		}
		tokenize "${pip_version}", parse("_")
		local ppp_year  `3'
		//------------ Get auxiliary data
		pip_auxframes
		

		//========================================================
		// Build query (queries returned in ${pip_last_queries}) 
		//========================================================
		pip_cp_query, country(`country') povline(`povline') ppp_version(`ppp_year') 
		
		//========================================================
		// Getting data
		//========================================================
		
		//------------ download
		pip_timer pip_cp.pip_get, on
		pip_get, `clear' `cacheforce'
		pip_timer pip_cp.pip_get, off

		//------------ clean
		pip_timer pip_cp_clean, on
		pip_cp_clean
		pip_timer pip_cp_clean, off
		
		//------------ Add data notes
		local datalabel "Country profile data"
		local datalabel = substr("`datalabel'", 1, 80)
		
		label data "`datalabel' (`c(current_date)')"
		
		//------------ display results
		noi pip_cp_display_results, `n2disp'
		
	}
	pip_timer pip_cp, off
end 



//------------Clean CP data

program define pip_cp_clean, rclass
	
	version 16
	
	//========================================================
	//  setup
	//========================================================
	if ("${pip_version}" == "") {
		noi disp "{err}No version selected."
		error
	}
	local version = "${pip_version}"
	tokenize "`version'", parse("_")
	local _version   = "_`1'_`3'_`9'"
	local ppp_version = `3'
	
	//========================================================
	//  Dealing with invalid values
	//========================================================
	*rename  prmld  mld
	qui {
		
		//========================================================
		// labels
		//========================================================
		
	
		//------------ partial variable labels * it needs to be completed
		label var country_code		  "country/economy code"
		label var survey_coverage   "survey coverage"
		label var reporting_year	  "year"
		label var welfare_type 		  "welfare measured by income or consumption"
		label var is_interpolated 	"data is interpolated"
		label var survey_acronym 	     "survey acronym"
		label var poverty_line 		  "poverty line in `ppp_version' PPP US\$ (per capita per day)"
		label var headcount 		    "poverty headcount"
		label var gini 				      "gini index"
		label var survey_comparability "survey comparability"
		label var comparable_spell 	   "comparability over time at country level" 

		
		//========================================================
		//  Sorting and Formatting
		//========================================================
		
		//------------Sorting
		sort country_code reporting_year survey_coverage 

	}			
end

//========================================================
// Sub programs
//========================================================

//------------ Build CP query

program define pip_cp_query, rclass
	version 16
	syntax ///
	[ ,                             /// 
	COUntry(string)                 /// 
	POVLine(numlist)                /// 
	ppp_version(numlist)                /// 
	] 
	
	//========================================================
	// conditions and set up
	//========================================================
	qui {
		
		// version
		local version "${pip_version}"
		
		//========================================================
		// build query... THE ORDER IS VERY IMPORTANT
		//========================================================
		
		local params = "country ppp_version" 
		
		foreach p of local params {
			if (`"``p''"' == `""') continue
			local query "`query'`p'=``p'' "
		}
		local query = ustrtrim("`query'")
		local query : subinstr local query " " "&", all
		

		//========================================================
		//  Povline 
		//========================================================
		
		local endpoint "cp-download"
		if ("`povline'" == "") {
			global pip_last_queries "`endpoint'?`query'&format=csv"
			exit
		}
		
		tempname M
		local i = 1
		foreach v of local povline {
			// each povline
			local queryp = "`endpoint'?`query'&povline=`v'&format=csv" 
			if (`i' == 1) mata: `M' = "`queryp'"
			else          mata: `M' = `M' , "`queryp'"
			local ++i
		}
		
		mata: st_global("pip_last_queries", invtokens(`M'))
	}
	
end


//------------ display results
program define pip_cp_display_results

	syntax , [n2disp(numlist)]
	
	if ("`n2disp'" == "") local n2disp 1
	local n2disp = min(`c(N)', `n2disp')
	
	if (`n2disp' > 1) {
		noi di as res _n "{ul: first `n2disp' observations}"
	} 
	else	if (`n2disp' == 1) {
		noi di as res _n "{ul: first observation}"
	}
	else {
		noi di as res _n "{ul: No observations available}"
	}	
	
	sort country_code reporting_year
	local varstodisp "country_code reporting_year poverty_line headcount welfare_time"
	local sepby "country_code"
	
	foreach v of local varstodisp {
		cap confirm var `v', exact
		if _rc continue 
		local v2d "`v2d' `v'"
	}
	
	noi list `v2d' in 1/`n2disp',  abbreviate(12)  sepby(`sepby') noobs
	
end

exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:

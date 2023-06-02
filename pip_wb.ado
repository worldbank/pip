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
	Year(string)                    /// 
	POVLine(numlist)                /// 
	PPP_year(numlist)               ///
	COVerage(string)                /// 
	CLEAR                           /// 
	pause                           /// 
	POVCALNET_format                ///
	replace                         ///
	cacheforce                      ///
	n2disp(passthru)                ///
	] 
	
	version 16.1
	
	pip_timer pip_wb, on
	
	if ("`pause'" == "pause") pause on
	else                      pause off
	
	qui {
		//========================================================
		// setup
		//========================================================
		
		//------------ Get auxiliary data
		pip_auxframes
		
		//========================================================
		// Build query (queries returned in ${pip_last_queries}) 
		//========================================================
		pip_wb_query, region(`region') year(`year') povline(`povline')   /*
		*/            ppp(`ppp_year') coverage(`coverage') 
		
		//========================================================
		// Getting data
		//========================================================
		
		//------------ download
		pip_timer pip_wb.pip_get, on
		pip_get, `clear' `cacheforce'
		pip_timer pip_wb.pip_get, off
		
		//------------ clean
		pip_timer pip_wb_clean, on
		pip_wb_clean
		pip_timer pip_wb_clean, off
		
		//------------ Add data notes
		local datalabel "WB poverty at regional and global level"
		local datalabel = substr("`datalabel'", 1, 80)
		
		label data "`datalabel' (`c(current_date)')"
		
		//------------ Display results
		noi pip_wb_display_results, `n2disp'
		
		//------------ Povcalnet format
		
		if ("`povcalnet_format'" != "") {
			noi disp "{p 2 4 2 70}{err}Warning: {res}option {it:povcalnet_format}" /* 
			*/	" is meant for replicability purposes only or to be used in Stata code " /* 
			*/ "that still executes the deprecated {cmd:povcalnet} command.{p_end}" _n
			
			pip_wb_povcalnet
		}
		
		
	}
	pip_timer pip_wb, off
end

//========================================================
// Sub programs
//========================================================

//------------ Build CL query

program define pip_wb_query, rclass
	version 16.1
	syntax ///
	[ ,                             /// 
	REGion(string)                  /// 
	YEAR(string)                    /// 
	POVLine(numlist)                /// 
	PPP(numlist)                    /// 
	COVerage(string)                /// 
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
		// version
		local version "${pip_version}"
		
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


//------------Clean Cl data
program define pip_wb_clean, rclass
	version 16.1
	if ("${pip_version}" == "") {
		noi disp "{err}No version selected."
		error
	}
	local version = "${pip_version}"
	tokenize "`version'", parse("_")
	local _version   = "_`1'_`3'_`9'"
	local ppp_version = `3'
	
	
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

//------------ display results
program define pip_wb_display_results
	
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
	
	sort region_code year 
	
	tempname tolist
	frame copy `c(frame)' `tolist'
	qui frame `tolist' {
		gsort region_code -year 
		
		count if (region_code == "WLD")
		local cwld = r(N)
		if (`cwld' >= `n2disp') {
			keep if (region_code == "WLD")			
		}
		noi list region_code year poverty_line headcount mean ///
		in 1/`n2disp',  abbreviate(12) noobs
	}
	
end


program define pip_wb_povcalnet
	ren year        requestyear
	ren population  reqyearpopulation
	
	//------------ Renaming and labeling
	
	rename region_code      regioncode
	rename poverty_line     povertyline
	rename poverty_gap      povgap
	rename poverty_severity povgapsqr
	
	keep requestyear regioncode povertyline mean headcount povgap ///
	povgapsqr reqyearpopulation
	order requestyear regioncode povertyline mean headcount povgap ///
	povgapsqr reqyearpopulation
	
	local Snames requestyear reqyearpopulation 
	
	local Rnames year population 
	
	local i = 0
	foreach var of local Snames {
		local ++i
		rename `var' `: word `i' of `Rnames''
	}
	
	//------------ Convert to monthly values
	replace mean = mean * (360/12)
end

exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:




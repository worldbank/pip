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
program define pip_agg, rclass
	version 16.1
	
	pip_timer pip_agg, on
	
	pip_agg_check_args `0'
	local optnames "`r(optnames)'" 
	mata: pip_retlist2locals("`optnames'")
	
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
		pip_agg_query,  year(`year') povline(`povline')   /*
		*/            ppp_version(`ppp_year') coverage(`coverage') /*
		*/            aggregate(`aggregate')
		
		//========================================================
		// Getting data
		//========================================================
		
		//------------ download
		pip_timer pip_agg.pip_get, on
		pip_get, `clear'
		pip_timer pip_agg.pip_get, off
		
		//------------ clean
		pip_timer pip_agg_clean, on
		pip_agg_clean, `nowcasts' `fillgaps' aggregate(`aggregate')
		pip_timer pip_agg_clean, off
		
		//------------ Add data notes
		local datalabel "WB poverty at regional and global level"
		local datalabel = substr("`datalabel'", 1, 80)
		
		label data "`datalabel' (`c(current_date)')"
		
		//------------ Display results
		noi pip_utils output, `n2disp' worldcheck   ///
		  sortvars(region_code year)                ///
		  dispvars(region_code year poverty_line headcount mean)
        
		//------------ Povcalnet format
		
		if ("`povcalnet_format'" != "") {
			noi disp "{p 2 4 2 70}{err}Warning: {res}option {it:povcalnet_format}" /* 
			*/	" is meant for replicability purposes only or to be used in Stata code " /* 
			*/ "that still executes the deprecated {cmd:povcalnet} command.{p_end}" _n
			
			pip_agg_povcalnet
		}
		
		
	}
	pip_timer pip_agg, off
end

program define pip_agg_check_args, rclass
	version 16.1
	syntax ///
	[ ,                             /// 
	AGGregate(string)             /// 
	Year(string)                    /// 
	POVLine(numlist)                /// 
	COVerage(string)                /// 
	CLEAR                           /// 
	pause                           /// 
	replace                         ///
	noFILLgaps                        ///
	noNOWcasts						///
	n2disp(passthru)                ///
    *                               ///
	] 
	
	//========================================================
	// setup
	//========================================================
	local version    = "${pip_version}"		
	tokenize "`version'", parse("_")
	local _version   = "_`1'_`3'_`9'"	
	local ppp_year = `3'
	
	//------------ Get auxiliary data
	pip_timer pov_check_args.auxframes, on
	pip_auxframes
	pip_timer pov_check_args.auxframes, off
	
	//========================================================
	// General checks
	//========================================================
	//------------ year
	if ("`year'" == "") local year "all"
	else if (lower("`year'") == "all") local year "all"
	else if (lower("`year'") == "last") local year "MRV"
	else if (lower("`year'") == "mrv") local year "MRV"
	else if (ustrregexm("`year'"), "[a-zA-Z]+") {
		noi disp "{err} `year' is not a valid {it:year} value" _n /* 
		*/  "only {it:all}, {it:MRV} or numeric values are accepted{txt}" _n
		error
	}
	else {
		numlist "`year'"
		local year = r(numlist)
	}
	
	return local year = "`year'"
	local optnames "`optnames' year"
	
	*---------- Coverage
	if (lower("`coverage'") == "all") local coverage = ""
	local coverage = lower("`coverage'")

	foreach c of local coverage {	
		
		if !inlist(lower("`c'"), "national", "rural", "urban", "") {
			noi disp in red `"option {it:coverage()} must be "national", "rural",  "urban" or "all" "'
			error
		}	
	}

	return local coverage = "`coverage'"
	local optnames "`optnames' coverage"
	
	//------------ aggregate
	
	local _version _20250930_2021_PROD // to comment
	frame _pip_cl`_version' {
		qui ds 
		local vars `r(varlist)'
		// Extract vars that do not end in _code or _name
		foreach var of local vars {
			if !regexm("`var'", "_code$") & !regexm("`var'", "_name$") {
				local keep_vars "`keep_vars' `var'"
			}
		}
		local av_agg "official pcn vintage `keep_vars'"
	}

	if ("`aggregate'" != "") {
		local aggregate = lower("`aggregate'")		
		local inagg: list aggregate in av_agg
		if (`inagg' == 0) {	
			noi disp "{err:agregate {it:`aggregate'} is not available.}" _n ///
			"Select one of the following:"
			foreach agg of local av_agg {
				noi disp "    - `agg'" 
			}
			error
		}
		else if (inlist("`aggregate'", "official", "wb", "region")) {
			local aggregate "wb"
		} 
		else if (inlist("`aggregate'", "pcn", "vintage", "regionpcn")) {
			local aggregate "vintage"
		}
	} 
	else {
		noi disp "{err: NOTE:} aggregates available:" _n 
		foreach agg of local av_agg {
			noi disp "    - `agg'" 
		}
		exit 10, clear
	}

	return local aggregate = "`aggregate'"
	local optnames "`optnames' aggregate"
	
		
	//------------ nowcasts
	// if ("`nowcasts'" != "") {
	// 	// if nowcasts is selected, fillgaps is also selected
	// 	local fillgaps = "fillgaps"
	// }
	return local nowcasts = "`nowcasts'"
	local optnames "`optnames' nowcasts"
	
	//------------ fillgaps
	return local fillgaps = "`fillgaps'"
	local optnames "`optnames' fillgaps"
		
	// poshare
	if ("`popshare'" != "") {
		noi disp in red "option {it:popshare()} can't be combined " /* 
		*/ "with subcommand {it:wb}" _n
		error
	}
		
	if ("`region'" != "") {
		return local region = "`region'"
		local optnames "`optnames' region"
	}
		
		// poverty line 
		
	if ("`povline'" == "")  {
			
		if ("`ppp_year'" == "2005") local povline = 1.25
		if ("`ppp_year'" == "2011") local povline = 1.9
		if ("`ppp_year'" == "2017") local povline = 2.15
		if ("`ppp_year'" == "2021") local povline = 3
	}
	return local povline  = "`povline'"
	local optnames "`optnames' povline"

	if ("`clear'" == "") local clear "clear"
	return local clear = "`clear'"
	local optnames "`optnames' clear"

	// allow n2disp as undocumented option
	if ("`n2disp'" != "") {
		return local n2disp = "`n2disp'"
		local optnames "`optnames' n2disp"
	}
	return local optnames "`optnames'"

end

//========================================================
// Sub programs
//========================================================

//------------ Build CL query

program define pip_agg_query, rclass
	version 16.1
	syntax ///
	[ ,                             /// 
	YEAR(string)                    /// 
	POVLine(numlist)                /// 
	ppp_version(numlist)            /// 
	COVerage(string)                ///
	AGGregate(string)               ///
	] 
	
	//========================================================
	// conditions and set up
	//========================================================
	qui {
		
		// country
		local country = "all"
		// year
		local year: subinstr local year " " ",", all
		if ("`year'" == "") local year = "all"
		
		// reporting level
		if ("`coverage'" == "") local reporting_level = "all"
		else                    local reporting_level = "`coverage'"
		
		// group_by
		if ("`aggregate'" == "") local group_by = "wb"
		else                     local group_by = "`aggregate'"
		// version
		local version "${pip_version}"
		
		//========================================================
		// build query... THE ORDER IS VERY IMPORTANT
		//========================================================
		
		local params = "country year reporting_level " + /* 
		*/             " version welfare_type ppp_version group_by" 
		
		
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
program define pip_agg_clean, rclass
	
	syntax  [, noNOWcasts noFILLgaps aggregate(string)]
	
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
		if ("`ppp_version'" == "2005") local pg_shortfall = 0
		if ("`ppp_version'" == "2011") local pg_shortfall = 22
		if ("`ppp_version'" == "2017") local pg_shortfall = 25
		if ("`ppp_version'" == "2021") local pg_shortfall = 28
		
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
		cap label var estimate_type    "type of estimate"
		label var spr	            "societal poverty rate, poverty headcount rate at the SPL"
		label var pg	            "prosperity gap, average shortfall from \$`pg_shortfall'/day"
		
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

		//------------drop unnecesary variables
		keep region_name region_code year poverty_line mean headcount ///
			 poverty_gap poverty_severity watts population spr pg estimate_type ///
			 pop_in_poverty
		
		//------------ Nowcasts and fillgaps
		if ("`fillgaps'" != "") {
			drop if estimate_type == "projection"
		}
		if ("`nowcasts'" != "") {
			drop if estimate_type == "nowcast"
		}
		
		//------------ drop vars with missing value
		pip_utils dropvars
		
	}
	
end

program define pip_agg_povcalnet
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




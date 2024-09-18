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
	version 16.1
	
	pip_timer pip_wb, on
	
	pip_wb_check_args `0'
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
		pip_wb_query, region(`region') year(`year') povline(`povline')   /*
		*/            ppp_version(`ppp_year') coverage(`coverage') 
		
		//========================================================
		// Getting data
		//========================================================
		
		//------------ download
		pip_timer pip_wb.pip_get, on
		pip_get, `clear' `cacheforce' `cachedir'
		pip_timer pip_wb.pip_get, off
		
		//------------ clean
		pip_timer pip_wb_clean, on
		pip_wb_clean, `nowcasts' `fillgaps'
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

program define pip_wb_check_args, rclass
	version 16.1
	syntax ///
	[ ,                             /// 
	REGion(string)                  /// 
	Year(string)                    /// 
	POVLine(numlist)                /// 
	COVerage(string)                /// 
	CLEAR                           /// 
	pause                           /// 
	POVCALNET_format                ///
	replace                         ///
	cacheforce                      ///
	FILLgaps                        ///
	NOWcasts						///
	n2disp(passthru)                ///
	cachedir(passthru) *            ///
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
	
	//------------ Region
	if ("`region'" != "") {
		local region = upper("`region'")
		
		if (regexm("`region'", "SAR")) {
			noi disp in red "Note: " in y "The official code of South Asia is" ///
			"{it: SAS}, not {it:SAR}. We'll make the change for you"
			local region: subinstr local region "SAR" "SAS", word 
		}
		
		//------------ Regions frame
		local frpiprgn "_pip_regions`_version'" 
		frame `frpiprgn' {
			levelsof region_code, local(av_regions)  clean
		}
		
		// Add all to have the same functionality as in country(all)
		local av_regions = "`av_regions'" + " ALL"
		
		local inregion: list region in av_regions
		if (`inregion' == 0) {
			
			noi disp in red "region `region' is not available." _n ///
			"Only the following are available:" _n "`av_regions'"
			
			error
		}
	}

	return local region = "`region'"
	local optnames "`optnames' region"
	
	//========================================================
	//  Aggregate level (wb)
	//========================================================

	if ("`country'" != "") {
		noi disp as err "option {it:country()} is not allowed with subcommand {it:wb}"
		noi disp as res "Note: " as txt "subcommand {it:wb} only accepts options {it:region()} and {it:year()}"
		error
	}
		
	//------------ nowcasts
	if ("`nowcasts'" != "") {
		// if nowcasts is selected, fillgaps is also selected
		local fillgaps = "fillgaps"
	}
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
	}
	return local povline  = "`povline'"
	local optnames "`optnames' povline"

	if ("`clear'" == "") local clear "clear"
	return local clear = "`clear'"
	local optnames "`optnames' clear"
	return local optnames "`optnames'"

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
	ppp_version(numlist)            /// 
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
		*/             " version welfare_type ppp_version" 
		
		
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
			global pip_last_queries "`endpoint'?`query'&format=csv&group_by=wb"
			exit
		}
		
		
		tempname M
		local i = 1
		foreach v of local povline {
			// each povline or popshare + format
			local queryp = "`endpoint'?`query'&povline=`v'&format=csv&group_by=wb" 
			if (`i' == 1) mata: `M' = "`queryp'"
			else          mata: `M' = `M' , "`queryp'"
			local ++i
		}
		
		mata: st_global("pip_last_queries", invtokens(`M'))
	}
	
end


//------------Clean Cl data
program define pip_wb_clean, rclass
	
	syntax  [, NOWcasts fillgaps ]
	
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
		cap label var estimate_type    "type of estimate"
		
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
		if ("`fillgaps'" == "") {
			drop if estimate_type == "projection"
		}
		if ("`nowcasts'" == "") {
			drop if estimate_type == "nowcast"
		}
		
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




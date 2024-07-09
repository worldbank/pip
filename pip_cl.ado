/*==================================================
project:       Interaction with the PIP API at the country level
Author:        R.Andres Castaneda 
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     5 Jun 2019 - 15:12:13
Modification Date:  October, 2021 
Do-file version:    01
References:          
Output:             dta
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_cl, rclass
	version 16.1
	
	pip_timer pip_cl, on

	pip_cl_check_args `0'
	
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
		pip_cl_query, country(`country') region(`region') year(`year') ///
		povline(`povline') popshare(`popshare')  `fillgaps' ///
		ppp(`ppp_year') coverage(`coverage') 
		
		//========================================================
		// Getting data
		//========================================================
		
		//------------ download
		pause cl> before get data 
		pip_timer pip_cl.pip_get, on
		pip_get, `clear' `cacheforce' `cachedir'
		pip_timer pip_cl.pip_get, off
		//------------ clean

		pause cl> before clean data 
		pip_timer pip_cl_clean, on
		pip_cl_clean
		pip_timer pip_cl_clean, off
		
		//------------ Add data notes
		if ("`fillgaps'" == "") local lvlabel "country level"	 
		else local lvlabel "Country level (lined up)"
		
		local datalabel "WB poverty at `lvlabel'"
		local datalabel = substr("`datalabel'", 1, 80)
		
		label data "`datalabel' (`c(current_date)')"
		
		//------------ display results
		noi pip_cl_display_results, `n2disp'
		
		//------------ Povcalnet format
		
		if ("`povcalnet_format'" != "") {
			noi disp "{p 2 4 2 70}{err}Warning: {res}option {it:povcalnet_format}" /* 
		 */	" is meant for replicability purposes only or to be used in Stata code " /* 
		 */ "that still executes the deprecated {cmd:povcalnet} command.{p_end}"
			
			pip_cl_povcalnet
		}
		
		
	}
	pip_timer pip_cl, off
end 


program define pip_cl_check_args, rclass
	version 16.1
	syntax ///
	[ ,                             /// 
	COUntry(string)                 /// 
	REGion(string)                  /// 
	Year(string)                    /// 
	POVLine(numlist)                /// 
	POPShare(numlist)	   	        /// 
	FILLgaps                        /// 
	COVerage(string)                /// 
	CLEAR(string) *                 /// 
	pause                           /// 
	POVCALNET_format                ///
	replace                         ///
	cacheforce                     ///
	n2disp(passthru)                ///
	cachedir(passthru)  *           ///
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
	// -------pause 
	if ("`pause'" == "pause") {
		return local pause = "pause"
		local optnames "`optnames' pause"
	}
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


	//========================================================
	//  Country Level (cl)
	//========================================================

	//------------ Poverty line 
	// defined popshare and defined povline = error
	if ("`popshare'" != "" & "`povline'" != "")  {
		noi disp as err "povline and popshare cannot be used at the same time"
		error
	}
	// Blank popshare and blank povline = default povline 1.9
	else if ("`popshare'" == "" & "`povline'" == "")  {
		
		if ("`ppp_year'" == "2005") local povline = 1.25
		if ("`ppp_year'" == "2011") local povline = 1.9
		if ("`ppp_year'" == "2017") local povline = 2.15
	}
	
	return local povline  = "`povline'"
	return local popshare = "`popshare'"
	local optnames "`optnames' povline popshare"
		
	//------------ fillgaps
	return local fillgaps = "`fillgaps'"
	local optnames "`optnames' fillgaps"

	if ("`clear'" == "") local clear "clear"
	return local clear = "`clear'"
	local optnames "`optnames' clear"

	*---------- Country
	// check availability 
	if ("`country'" != "") {
		local country = upper("`country'")
		frame _pip_fw`_version' {
			qui levelsof country_code, local(av_cts)  clean
		}
		
		// Add all to have the same functionality as in country(all)
		local av_cts = "`av_cts'" + " ALL"
		
		local inct: list country in av_cts
		if (`inct' == 0) {
			
			noi disp in red "Country `country' is not available." _n ///
			"Only the following are available:"
			noi pip_info
			
			error
		}
	}
		
	// Check if year is available
	if ("`country'" != "" & "`fillgaps'" == "" & !inlist(lower("`year'"), "all", "last","mrv","")) {
		
		tempname fw_temp
		frame copy _pip_fw`_version' `fw_temp'
		qui frame `fw_temp' {
			
			
			sum year, meanonly
			local maxyear = r(max)
			local minyear = r(min)
			
			local country = strtrim(stritrim("`country'"))
			local country_: subinstr local country " " "|"
			
			local year = strtrim(stritrim("`year'"))
			local year_: subinstr local year " " "|", all
			local yearc: subinstr local year " " ",", all
			
			local isgt = max(`maxyear', `yearc') == `maxyear'
			local islt = min(`minyear', `yearc') == `minyear'
			
			if (`isgt' == 0) {
				noi disp in red "`=max(0,`yearc')' is not available. " _n ///
				"The latest year available is {ul:`maxyear'}"
				error
			}
			
			if (`islt' == 0) {
				noi disp in red "`=min(`yearc',9999)' is not available. " _n ///
				"The first year available is {ul:`minyear'}"
				error
			}
			
			keep if regexm(country_code, "`country_'")
			keep if regexm(strofreal(year), "`year_'")
	  
			if (_N== 0) {
				noi disp in red "Survey year {ul:`year'} is not available in `country'." _n ///
				"Only the following are available:"
				noi pip_info, country(`country')
				error
			}
		}
	}
		
	local country = stritrim(ustrtrim("`country' `region'"))
	if (lower("`country'") != "all") local country = upper("`country'")
	if ("`country'" == "") local country "all" // to modify
	return local country = "`country'"
	local optnames "`optnames' country"
	return local optnames "`optnames'"
   
end

//========================================================
// Sub programs
//========================================================

//------------ Build CL query

program define pip_cl_query, rclass
	version 16.1
	syntax ///
	[ ,                             /// 
	COUntry(string)                 /// 
	REGion(string)                  /// 
	YEAR(string)                    /// 
	POVLine(numlist)                /// 
	POPShare(numlist)	   	          /// 
	PPP_version(numlist)                    /// 
	COVerage(string)                /// 
	FILLgaps                        /// 
	] 
	
	//========================================================
	// conditions and set up
	//========================================================
	qui {
		
		// country
		local country = stritrim(ustrtrim("`country'"))
		local country : subinstr local country " " ",", all
		if ("`country'" == "") local country = "all"
		// year
		local year: subinstr local year " " ",", all
		if ("`year'" == "") local year = "all"
		
		// fill gaps
		if ("`fillgaps'" != "") local fill_gaps = "true"
		else                    local fill_gaps = ""
		// reporting level
		if ("`coverage'" == "") local reporting_level = ""
		else                    local reporting_level = "`coverage'"
		// version
		local version "${pip_version}"
		
		//========================================================
		// build query... THE ORDER IS VERY IMPORTANT
		//========================================================
		noi disp "`country'"
		noi disp "test country"
		local params = "country year ppp_version fill_gaps " + ///
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
		
		local endpoint "pip"
		if ("``optname''" == "") {
			global pip_last_queries "`endpoint'?`query'&format=csv"
			exit
		}
		
		
		tempname M
		local i = 1
		foreach v of local `optname' {
			// each povline or popshare + format
			local queryp = "`endpoint'?`query'&`optname'=`v'&format=csv" 
			if (`i' == 1) mata: `M' = "`queryp'"
			else          mata: `M' = `M' , "`queryp'"
			local ++i
		}
		
		mata: st_global("pip_last_queries", invtokens(`M'))
	}
	
end


//------------Clean Cl data

program define pip_cl_clean, rclass
	
	version 16.1
	
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
	//   formating 
	//========================================================
	// string variables
	local str_vars "region_name  region_code  country_name  country_code  reporting_level survey_acronym survey_acronym survey_coverage welfare_type comparable_spell is_interpolated distribution_type estimation_type estimate_type"

	ds
	local all_vars "`r(varlist)'"

	local num_vars: list all_vars - str_vars

	* make sure all numeric variables are numeric -----------
	foreach var of local num_vars {
		cap destring `var', replace force
		if (_rc) {
			noi disp as error "{it:`var'} is not numeric or does not exist." _n ///
			"You're probably calling an old version of the PIP data"
		}
	}

	//------------  string variables
	foreach var of local str_vars {
		cap  tostring `var', replace force
		if (_rc) {
			noi disp in red "{it:`var'}" in y "is not string or does not exist." ///
			"You're probably calling an old version of the PIP data"
		}
	}


	//========================================================
	//  Dealing with invalid values
	//========================================================
	*rename  prmld  mld
	qui {
		
		foreach v of varlist polarization median gini mld decile? decile10 {
			cap replace `v'=. if `v'==-1 | `v' == 0
		}
		
		cap drop if ppp==""
		cap drop  svyinfoid
		
		
		//========================================================
		// labels
		//========================================================
		
		//------------ Survey coverage
		tostring survey_coverage, replace
		replace survey_coverage = "1" if survey_coverage == "rural"
		replace survey_coverage = "2" if survey_coverage == "urban"
		replace survey_coverage = "3" if survey_coverage == "national"
		
		destring survey_coverage, force replace
		label define survey_coverage 1 "rural"     /* 
		*/                       2 "urban"     /* 
		*/                       3 "national", modify
		
		label values survey_coverage survey_coverage
		
		//------------Welfare type
		replace welfare_type = "1" if welfare_type == "consumption"
		replace welfare_type = "2" if welfare_type == "income"
		destring welfare_type, force replace
		label define welfare_type 1 "consumption" 2 "income", modify
		label values welfare_type welfare_type
		
		//------------ All variables
		label var country_code		"country/economy code"
		label var country_name 		"country/economy name"
		label var region_code 		"region code"
		label var region_name 		"region name"
		label var survey_coverage   "survey coverage"
		label var reporting_year	"year"
		label var survey_year 		"survey year"
		label var welfare_type 		"welfare measured by income or consumption"
		label var is_interpolated 	"data is interpolated"
		label var distribution_type "data comes from grouped or microdata"
		label var ppp 				"`ppp_version' purchasing power parity"
		label var poverty_line 		"poverty line in `ppp_version' PPP US\$ (per capita per day)"
		label var mean				"average daily per capita income/consumption `ppp_version' PPP US\$"
		label var headcount 		"poverty headcount"
		label var poverty_gap 		"poverty gap"
		label var poverty_severity 	"squared poverty gap"
		label var watts 			"watts index"
		label var gini 				"gini index"
		label var median 			"median daily per capita income/consumption in `ppp_version' PPP US\$"
		label var mld 				"mean log deviation"
		label var reporting_pop 	"polarization"
		label var reporting_pop     "population in year"
		
		ds decile*
		local vardec = "`r(varlist)'"
		foreach var of local vardec {
			if regexm("`var'", "([0-9]+)") local q = regexs(1)
			label var `var' "decile `q' welfare share"
		}
		
		label var reporting_level 	   "reporting data level"
		label var survey_acronym 	   "survey acronym"     
		label var survey_comparability "survey comparability"
		label var comparable_spell 	   "comparability over time at country level"   
		label var cpi 				   "consumer price index (CPI) in `ppp_version' base"
		label var reporting_gdp 	   "GDP per capita in constant 2015 US\$, annual calendar year"
		label var reporting_pce 	   "HFCE per capita in constant 2015 US\$, annual calendar year"
		cap label var estimate_type        "type of estimate"
		
		//========================================================
		//  Sorting and Formatting
		//========================================================
		
		//------------Sorting
		sort country_code reporting_year survey_coverage 
		
		//------------ Formatting
		format headcount poverty_gap poverty_severity watts  gini mld ///
		decile*  mean polarization  /* survey_mean_ppp */  cpi %8.4f
		
		* format ppp survey_mean_lcu  %10.2fc
		format reporting_gdp  reporting_pce %15.2fc
		
		format reporting_pop %15.0fc
		
		format poverty_line %6.2f
		
		//------------ renaming variables
		local old survey_year reporting_year reporting_gdp reporting_pce /* 
		*/	        reporting_pop
		local new welfare_time year gdp hfce population
		rename (`old') (`new')
		
		
		//------------survey_time
		
		local frpipfw "_pip_fw`_version'"
		
		tempname frfw
		frame copy `frpipfw' `frfw'
		frame `frfw' {  
			drop year
			rename reporting_year year
		}
		
		frlink m:1 country_code year welfare_type, frame(`frfw') 
		frget survey_time, from(`frfw')
		
		//------------ Ordering vars
		order country_code country_name region_code                /*
		*/    region_name reporting_level year welfare_time        /*
		*/    welfare_type poverty_line mean headcount             /*
		*/    poverty_gap  poverty_severity watts gini             /*
		*/    median mld polarization population decile? decile10  /*
		*/    cpi ppp gdp hfce survey_comparability                /*
		*/    survey_acronym  survey_time  is_interpolated         /*
		*/    distribution_type survey_coverage
		
		
		//------------remaining labels
		label var welfare_time "time income or consumption refers to"
		label var survey_time  "time of survey in the field"
		
		//------------drop unnecesary variables
		cap drop estimation_type
		
		if ("`fillgaps'" != "") {
			drop ppp survey_time distribution_type gini mld polarization decile* median
		}
		
		//missings dropvars, force
		// drop var where all obs are missing
		
		pip_utils dropvars
		
	}			
end

//------------ display results
program define pip_cl_display_results
	
	syntax , [n2disp(integer 1)]

	local n2disp = min(`c(N)', `n2disp')
	
	//Display header
	if      `n2disp'==1 local MSG "first observation"
	else if `n2disp' >1 local MSG "first `n2disp' observations"
	else                local MSG "No observations available"
	noi dis as result _n "{ul:`MSG'}" 


	//Display contents
	sort country_code year
	local varstodisp "country_code year poverty_line headcount mean median welfare_type"
	local sepby "country_code"
	
	foreach v of local varstodisp {
		cap confirm var `v', exact
		if _rc continue 
		local v2d "`v2d' `v'"
	}	
	noi list `v2d' in 1/`n2disp',  abbreviate(12)  sepby(`sepby') noobs
end


program define pip_cl_povcalnet
	ren year       requestyear
	ren population reqyearpopulation
	
	
	local vars1 country_code region_code reporting_level welfare_time /*
	*/ welfare_type is_interpolated distribution_type poverty_line poverty_gap /*
	*/ poverty_severity country_name 
	
	local vars2 countrycode regioncode coveragetype datayear datatype isinterpolated usemicrodata /*
	*/povertyline povgap povgapsqr countryname
	
	local i = 0
	foreach var of local vars1 {
		local ++i
		cap confirm var `var', exact
		if _rc continue
		rename `var' `: word `i' of `vars2''
	}	
	
	local keepvars  countrycode countryname regioncode coveragetype requestyear /* 
	*/ datayear datatype isinterpolated usemicrodata /*
	*/ ppp povertyline mean headcount povgap povgapsqr watts gini /* 
	*/ median mld polarization reqyearpopulation decile? decile10
	
	foreach v of local keepvars {
		cap confirm var `v', exact
		if _rc continue
		local tokeep "`tokeep' `v'"
	}
	keep  `tokeep'
	order `tokeep'
	
	
	* Standardize names with R package	
	local Snames requestyear reqyearpopulation 
	
	local Rnames year population 
	
	local i = 0
	foreach var of local Snames {
		local ++i
		rename `var' `: word `i' of `Rnames''
	}
	
	sort countrycode year coveragetype
	
	//------------ Convert to monthly values
	replace mean = mean * (360/12)
	replace median = median * (360/12)
	
end 

exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:




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
	version 16.1
	
	pip_timer pip_cp, on
	
	pip_cp_check_args `0'
	
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
		pip_cp_query, country(`country') povline(`povline') ppp_version(`ppp_year') 
		
		//========================================================
		// Getting data
		//========================================================		
		//------------ download
		pip_timer pip_cp.pip_get, on
		pip_get, `clear' `cacheforce' `cachedir'
		pip_timer pip_cp.pip_get, off

		//------------ clean
		pip_timer pip_cp_clean, on
		pip_cp_clean
		pip_timer pip_cp_clean, off
		
		//------------ Add data notes
		local datalabel "Country profile data"
		local datalabel = substr("`datalabel'", 1, 80)
		
		label data "`datalabel' (`c(current_date)')"
		
		//========================================================
		// Getting data
		//========================================================		
		//------------ display results
		noi pip_cp_display_results, `n2disp'
		//noi pip_utils output, `n2disp' ///
        //sortvars(country_code reporting_year) ///
        //dispvars(country_code reporting_year poverty_line headcount welfare_time) ///
        //sepvar(country_code)
	}
	pip_timer pip_cp, off
end 


//----------- Check arguments
program define pip_cp_check_args, rclass
	version 16.1
	syntax ///
	[ ,                             /// 
	COUntry(string)                 /// 
	POVLine(numlist)                /// 
	PPP_year(numlist)               ///
	CLEAR *                         /// 
	SERver(string)                  /// 
	pause                           /// 
	replace                         ///
	cacheforce *                    ///
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
	//  Country profile (cp)
	//========================================================
		
	*---------- Country
	local country = stritrim(ustrtrim("`country' `region'"))
	if (lower("`country'") != "all") local country = upper("`country'")
	if ("`country'" == "") local country "all" // to modify
	return local country = "`country'"
	local optnames "`optnames' country"

	// poverty line 
	if ("`povline'" == "")  {
		
		if ("`ppp_year'" == "2005") local povline = 1.25
		if ("`ppp_year'" == "2011") local povline = 1.9
		if ("`ppp_year'" == "2017") local povline = 2.15
	}
	
	return local povline  = "`povline'"
	local optnames "`optnames' povline"
	return local optnames "`optnames'"
   
end



//------------Clean CP data
program define pip_cp_clean, rclass
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
	//  Dealing with invalid values
	//========================================================
	*rename  prmld  mld
	qui {
		
		//========================================================
		// labels
		//========================================================
		
	
		//------------ partial variable labels * it needs to be completed
		label var country_code	"country/economy code"
		label var reporting_year  "year"
		label var poverty_line  "poverty line in `ppp_version' PPP US\$ (per capita per day)"
		label var headcount  "poverty headcount"
		label var welfare_time  "Time income or consumption refers to"
		label var survey_coverage  "Survey coverage"
		label var is_interpolated "data is interpolated"
		label var survey_acronym  "survey acronym"
		label var survey_comparability "Survey comparability"
		label var comparable_spell "Comparability over time at country level"
		label var welfare_type  "welfare measured by income or consumption"
		label var headcount_ipl "% of population living in households with consumption or income per person below the international poverty line (IPL) at {PPP Year} international prices. "
		label var headcount_lmicpl  "% of population living in households with consumption or income per person below the global poverty line typical of Lower-middle-income countries (LMIC-PL) at {PPP Year} international prices. "
		label var headcount_umicpl "% of population living in households with consumption or income per person below the global poverty line typical of Upper-middle-income countries (UMIC-PL ) at {PPP Year} international prices."
		label var headcount_national  "National poverty headcount ratio is the percentage of the population living below the national poverty line. "
		label var gini  "GINI index (World Bank estimate)"
		label var theil  "Theil index (World Bank estimate)"
		label var share_b40_female  "Proportional of female group in the bottom 40%"
		label var share_t60_female  "Proportional of female group in the top 60%"
		label var share_b40_male  "Proportional of male group in the bottom 40%"
		label var share_t60_male  "Proportional of male group in the top 60%"
		label var share_b40_rural  "Proportional of rural group in the bottom 40%"
		label var share_t60_rural  "Proportional of rural group in the top 60%"
		label var share_b40_urban  "Proportional of urban group in the bottom 40%"
		label var share_t60_urban  "Proportional of urban group in the top 60%"
		label var share_b40agecat_0_14  "Proportional of 0 to 14 years old group in the bottom 40%"
		label var share_t60agecat_0_14  "Proportional of 0 to 14 years old group in the top 60%"
		label var share_b40agecat_15_64  "Proportional of 15 to 64 years old group in the bottom 40%"
		label var share_t60agecat_15_64  "Proportional of 15 to 64 years old group in the top 60%"
		label var share_b40agecat_65p  "Proportional of 65 and older group in the bottom 40%"
		label var share_t60agecat_65p  "Proportional of 65 and older group in the top 60%"
		label var share_b40edu_noedu  "Proportional of no education group in the bottom 40%"
		label var share_t60edu_noedu  "Proportional of no education group in the top 60%"
		label var share_b40edu_pri  "Proportional of primary education group in the bottom 40%"
		label var share_t60edu_pri  "Proportional of primary education group in the top 60%"
		label var share_b40edu_sec  "Proportional of secondary education group in the bottom 40%"
		label var share_t60edu_sec  "Proportional of secondary education group in the top 60%"
		label var share_b40edu_ter  "Proportional of tertiary education group in the bottom 40%"
		label var share_t60edu_ter  "Proportional of tertiary education group in the top 60%"
		label var mpm_education_attainment  "Multidimensional poverty, educational attainment (% of population deprived) "
		label var mpm_education_enrollment  "Multidimensional poverty, educational enrollment (% of population deprived)"
		label var mpm_electricity  "Multidimensional poverty, electricity (% of population deprived)"
		label var mpm_sanitation  "Multidimensional poverty, sanitation (% of population deprived)"
		label var mpm_water  "Multidimensional poverty, drinking water (% of population deprived)"
		label var mpm_monetary  "Multidimensional poverty, Monetary poverty (% of population deprived)"
		label var mpm_headcount "Multidimensional poverty, headcount ratio (% of population)"

		
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

	syntax , [n2disp(integer 1)]

	local n2disp = min(`c(N)', `n2disp')  

	//Display header
	if      `n2disp'==1 local MSG "first observation" 
	else if `n2disp' >1 local MSG "first `n2disp' observations"
	else                local MSG "No observations available"
	noi dis as result _n "{ul:`MSG'}"
	
	//Display contents
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

	// This program compares country level, wb aggregate , fill gaps and auxilary data with previous version of pip data
	
	clear all 
	pip cleanup
	
	// working directory
	local output "C:\Users\wb308892\OneDrive - WBG\Docs\Projects\pip\_output\"

	// This can also be used to compare new pip realease, when comparing data in dev server - set server and identity options
	global options = "clear povline(1.9 3.2 5.5) server(dev) identity(prod) ppp_year(2011)" 
	
	// variables in country level estimates
	local ctrylevel "mean headcount poverty_gap poverty_severity watts gini median mld polarization population decile1 decile2 decile3 decile4 decile5 decile6 decile7 decile8 decile9 decile10 cpi ppp gdp hfce"
	
	local ctrylvlnew "mean_curr headcount_curr poverty_gap_curr poverty_severity_curr watts_curr gini_curr median_curr mld_curr polarization_curr population_curr decile1_curr decile2_curr decile3_curr decile4_curr decile5_curr decile6_curr decile7_curr decile8_curr decile9_curr decile10_curr cpi_curr ppp_curr gdp_curr hfce_curr"
	
	* compare country estimates for poverty line 1.9, 3.2, and 5.5 with 20220408_2011_02_02_PROD

	*** 1) PPP round 2011
	pip, ${options} 
	sort country_code region_code year welfare_type poverty_line reporting_level
	duplicates report country_code region_code year welfare_type poverty_line reporting_level
	
	cap cf _all using "`output'pip_ctry_ppp11_version_0_3_2_9000.dta"

	if (_rc) {
		local i = 0
		foreach var of local ctrylevel {
			local ++i			
			rename `var' `: word `i' of `ctrylvlnew''
		}
		merge 1:1 country_code region_code year welfare_type poverty_line reporting_level using "`output'pip_ctry_ppp11_version_0_3_2_9000.dta", keepusing(`ctrylevel')
		
		keep if _ == 3 
		
		foreach var of local ctrylevel {
			gen `var'_diff = `var' - `var'_curr
		}
		
		summ *_diff
		keep if headcount_diff ~=0
		keep country_code region_code year welfare_type poverty_line reporting_level headcount_diff headcount_curr headcount
		order country_code region_code year welfare_type poverty_line reporting_level headcount_diff headcount_curr headcount
		export excel using "`output'_country_level_estimates.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in the country level data"
	}
		
	
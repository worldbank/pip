	// This program compares country level data with previous pip release data
	
	clear all 
	pip cleanup
	
	// working directory
	local output "C:\Users\wb308892\OneDrive - WBG\Docs\Projects\pip\test_data\"

	// setup global option for newly release pip data
	global options = "clear povline(1.9 3.2 5.5) server(dev) version(20220504_2011_02_02_INT)" 
	
	// variables in country level estimates
	local ctrylevel "mean headcount poverty_gap poverty_severity watts gini median mld polarization population decile1 decile2 decile3 decile4 decile5 decile6 decile7 decile8 decile9 decile10 cpi ppp gdp hfce"
	
	local ctrylvlnew "mean_curr headcount_curr poverty_gap_curr poverty_severity_curr watts_curr gini_curr median_curr mld_curr polarization_curr population_curr decile1_curr decile2_curr decile3_curr decile4_curr decile5_curr decile6_curr decile7_curr decile8_curr decile9_curr decile10_curr cpi_curr ppp_curr gdp_curr hfce_curr"
	
	* compare country estimates for poverty line 1.9, 3.2, and 5.5 

	*** 1) PPP round 2011
	pip, ${options} 
	sort country_code region_code year welfare_type poverty_line reporting_level
	duplicates report country_code region_code year welfare_type poverty_line reporting_level
	
	cap cf _all using "`output'country_ppp11.dta"

	if (_rc) {
		local i = 0
		foreach var of local ctrylevel {
			local ++i			
			rename `var' `: word `i' of `ctrylvlnew''
		}
		merge 1:1 country_code region_code year welfare_type poverty_line reporting_level using "`output'country_ppp11.dta", keepusing(`ctrylevel')
		
		*keep if _ == 3 
		
		foreach var of local ctrylevel {
			gen `var'_diff = `var' - `var'_curr
		}
		
		summ *_diff
		
		keep if headcount_diff !=0
		
		keep country_code region_code year welfare_type poverty_line reporting_level headcount_diff headcount_curr headcount _merge
		order country_code region_code year welfare_type poverty_line reporting_level headcount_diff headcount_curr headcount _merge
		export excel using "`output'_country_test_output.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in the country level data"
	}
		
	
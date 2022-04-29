	// This program compares wb aggregate data with previous pip versions
	
	clear all 
	pip cleanup
	
	// working directory
	local output "C:\Users\wb308892\OneDrive - WBG\Docs\Projects\pip\_output\"

	// This can also be used to compare new pip realease, when comparing data in dev server - set server and identity options
	global options = "wb, clear povline(1.9 3.2 5.5) server(dev) identity(prod) ppp_year(2011)" 
	
	// variables in wb aggregate data
	local wblevel "mean headcount poverty_gap poverty_severity watts population pop_in_poverty"
	
	local wblvlnew "mean_curr headcount_curr poverty_gap_curr poverty_severity_curr watts_curr population_curr pop_in_poverty_curr"
	
	* compare wb aggregate for poverty line 1.9, 3.2, and 5.5 with 20220408_2011_02_02_PROD

	*** 1) PPP round 2011
	pip ${options} 
	sort region_name year poverty_line
	duplicates report region_name year poverty_line
	
	cap cf _all using "`output'pip_wb_ppp11_version_0_3_2_9000.dta"

	if (_rc) {
		local i = 0
		foreach var of local wblevel {
			local ++i			
			rename `var' `: word `i' of `wblvlnew''
		}
		merge 1:1 region_name year poverty_line using "`output'pip_wb_ppp11_version_0_3_2_9000.dta", keepusing(`wblevel')
		
		keep if _ == 3 
		
		foreach var of local wblevel {
			gen `var'_diff = `var' - `var'_curr
		}
		
		summ *_diff
		keep if headcount_diff ~=0
		keep region_name region_code year poverty_line headcount headcount_curr headcount_diff
		order region_name region_code year poverty_line headcount headcount_curr headcount_diff
		export excel using "`output'_wb_aggregate_estimates.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in the wb aggregate data"
	}
		
	
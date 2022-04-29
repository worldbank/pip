	// This script saves pip benchmarks data for comparing future new releases
	clear all 
	pip cleanup
	
	// Version 
	local verDescription "version_0_3_2_9000"
	pip version
	
	// working directory
	local output "C:\Users\wb308892\OneDrive - WBG\Docs\Projects\pip\_output\"
	* get country estimates for poverty line 1.9, 3.2, and 5.5
	*** 20220408_2011_02_02_PROD

	*** 1) PPP round 2011
	pip, clear povline(1.9 3.2 5.5) ppp_year(2011) 
	sort country_code region_code year welfare_type poverty_line reporting_level
	notes: This data is generated based on 20220408_2011_02_02_PROD version 
	export delimited using "`output'pip_ctry_ppp11_`verDescription'.csv", replace
	save "`output'pip_ctry_ppp11_`verDescription'.dta", replace


	/*** 2) PPP round 2017
	pip, clear povline(2.15) ppp_year(2017)  
	sort country_code region_code year welfare_type poverty_line reporting_level
	notes: This data is generated based on 20220408_2011_02_02_PROD version 
	export delimited using "C:\Users\wb308892\OneDrive - WBG\Docs\Projects\pip\_output\pip_ctry_ppp17_`verDescription'.csv", replace */

	*******************************************************************************
	* get aggregate estimates for poverty line 1.9, 3.2, and 5.5
	*** 20220408_2011_02_02_PROD

	* 1) PPP round 2011
	pip wb, clear povline(1.9 3.2 5.5) ppp_year(2011)
	sort region_name year poverty_line
	notes: This data is generated based on 20220408_2011_02_02_PROD version
	export delimited using "`output'pip_wb_ppp11_`verDescription'.csv", replace
	save "`output'pip_wb_ppp11_`verDescription'.dta", replace

	/* 2) PPP round 2017
	pip wb, clear povline(1.9 3.2 5.5) ppp_year(2017)
	sort region_name year poverty_line
	notes: This data is generated based on 20220408_2011_02_02_PROD version
	export delimited using "C:\Users\wb308892\OneDrive - WBG\Docs\Projects\pip\_output\pip_wb_ppp17_`verDescription'.csv", replace */

	*******************************************************************************
	* filling gap data for all countries
	*** 20220408_2011_02_02_PROD

	* 1) PPP round 2011
	pip, fillgaps clear povline(1.9 3.2 5.5) ppp_year(2011)
	sort country_code region_code year welfare_type poverty_line reporting_level
	notes: This data is generated based on 20220408_2011_02_02_PROD version
	export delimited using "`output'pip_fillgaps_ppp11_`verDescription'.csv", replace
	save "`output'pip_fillgaps_ppp11_`verDescription'.dta", replace

	/* 2) PPP round 2017
	pip, fillgaps clear povline(1.9 3.2 5.5) ppp_year(2017)
	sort country_code region_code year welfare_type poverty_line reporting_level
	notes: This data is generated based on 20220408_2011_02_02_PROD version
	export delimited using "C:\Users\wb308892\OneDrive - WBG\Docs\Projects\pip\_output\pip_fillgaps_ppp17_`verDescription'.csv", replace */

	*******************************************************************************
	* auxilary tables
	*** 20220408_2011_02_02_PROD

	local tblist "countries country_coverage cpi decomposition dictionary framework gdp incgrp_coverage indicators interpolated_means pce pop pop_region poverty_lines ppp region_coverage regions survey_means"
	foreach tbl of local tblist {
		pip tables, table(`tbl') clear
		notes: This data is generated based on 20220408_2011_02_02_PROD version
		export delimited using "`output'pip\_output\pip_`tbl'_`verDescription'.csv", replace
		save "`output'pip_`tbl'_`verDescription'.dta", replace
	}

	// This script saves pip benchmarks data for comparing future new releases
	clear all 
	pip cleanup
	
	// Version 
	pip version
	
	// working directory
	local output "C:\Users\wb308892\OneDrive - WBG\Docs\Projects\pip\test_data\"
	* get country estimates for poverty line 1.9, 3.2, and 5.5
	*** 20220503_2011_02_02_PROD
	
	// setup option
	global options = "clear version(20220503_2011_02_02_PROD)" 

	*** 1) PPP round 2011
	pip, povline(1.9 3.2 5.5) ppp_year(2011) ${options} 
	sort country_code region_code year welfare_type poverty_line reporting_level
	notes: This data is generated based on 20220503_2011_02_02_PROD version 
	export delimited using "`output'country_ppp11.csv", replace
	save "`output'country_ppp11.dta", replace


	*** 2) PPP round 2017
	pip, povline(2.15) ppp_year(2017) ${options}
	sort country_code region_code year welfare_type poverty_line reporting_level
	notes: This data is generated based on 20220503_2011_02_02_PROD version 
	export delimited using "`output'country_ppp17.csv", replace
	save "`output'country_ppp17.dta", replace

	*******************************************************************************
	* get aggregate estimates for poverty line 1.9, 3.2, and 5.5
	*** 20220503_2011_02_02_PROD

	* 1) PPP round 2011
	pip wb, povline(1.9 3.2 5.5) ppp_year(2011) ${options}
	sort region_name year poverty_line
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	export delimited using "`output'wb_ppp11.csv", replace
	save "`output'wb_ppp11.dta", replace

	* 2) PPP round 2017
	pip wb, povline(2.15) ppp_year(2017) ${options}
	sort region_name year poverty_line
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	export delimited using "`output'wb_ppp17.csv", replace
	save "`output'wb_ppp17.dta", replace

	*******************************************************************************
	* filling gap data for all countries
	*** 20220503_2011_02_02_PROD

	* 1) PPP round 2011
	pip, fillgaps povline(1.9 3.2 5.5) ppp_year(2011) ${options}
	sort country_code region_code year welfare_type poverty_line reporting_level
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	export delimited using "`output'fillgaps_ppp11.csv", replace
	save "`output'fillgaps_ppp11.dta", replace

	* 2) PPP round 2017
	pip, fillgaps povline(2.15) ppp_year(2017) ${options}
	sort country_code region_code year welfare_type poverty_line reporting_level
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	export delimited using "`output'fillgaps_ppp17.csv", replace
	save "`output'fillgaps_ppp17.dta", replace

	*******************************************************************************
	* auxilary tables
	/*** 20220503_2011_02_02_PROD

	local tblist "countries country_coverage cpi decomposition dictionary framework gdp incgrp_coverage indicators interpolated_means pce pop pop_region poverty_lines ppp region_coverage regions survey_means"
	foreach tbl of local tblist {
		pip tables, table(`tbl') clear
		notes: This data is generated based on 20220408_2011_02_02_PROD version
		export delimited using "`output'pip_`tbl'_`verDescription'.csv", replace
		save "`output'pip_`tbl'_`verDescription'.dta", replace
	}
	*/
	* 1) countries
	pip tables, table(countries) ${options}
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	sort country_code
	export delimited using "`output'table_countries.csv", replace
	save "`output'table_countries.dta", replace
	
	* 2) country coverage
	pip tables, table(country_coverage) ${options}
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	sort country_code reporting_year pop_data_level
	export delimited using "`output'table_country_coverage.csv", replace
	save "`output'table_country_coverage.dta", replace
	
	* 3) cpi
	pip tables, table(cpi) ${options}
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	sort country_code data_level
	export delimited using "`output'table_cpi.csv", replace
	save "`output'table_cpi.dta", replace
	
	* 4) decomposition
	pip tables, table(decomposition) ${options}
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	sort variable_code variable_values
	export delimited using "`output'table_decomposition.csv", replace
	save "`output'table_decomposition.dta", replace
	
	* 5) dictionary
	pip tables, table(dictionary) ${options}
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	export delimited using "`output'table_dictionary.csv", replace
	save "`output'table_dictionary.dta", replace
	
	* 6) framework
	pip tables, table(framework) ${options}
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	sort country_code year survey_coverage welfare_type
	export delimited using "`output'table_framework.csv", replace
	save "`output'table_framework.dta", replace
	
	* 7) gdp
	pip tables, table(gdp) ${options}
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	sort country_code data_level
	export delimited using "`output'table_gdp.csv", replace
	save "`output'table_gdp.dta", replace
	
	* 8) incgrp_coverage
	pip tables, table(incgrp_coverage) ${options}
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	sort reporting_year
	export delimited using "`output'table_incgrp_coverage.csv", replace
	save "`output'table_incgrp_coverage.dta", replace
	
	* 9) indicators ****
	pip tables, table(indicators) ${options}
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	export delimited using "`output'table_indicators.csv", replace
	save "`output'table_indicators.dta", replace
	
	* 10) interpolated_means
	pip tables, table(interpolated_means) ${options}
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	sort survey_id interpolation_id
	export delimited using "`output'table_interpolated_means.csv", replace
	save "`output'table_interpolated_means.dta", replace
	
	* 11) pce
	pip tables, table(pce) ${options}
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	sort  country_code data_level
	export delimited using "`output'table_pce.csv", replace
	save "`output'table_pce.dta", replace
	
	* 12) pop
	pip tables, table(pop) ${options}	
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	sort country_code data_level
	export delimited using "`output'table_pop.csv", replace
	save "`output'table_pop.dta", replace
	
	* 13) pop_region
	pip tables, table(pop_region) ${options}	
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	sort region_code reporting_year
	export delimited using "`output'table_pop_region.csv", replace
	save "`output'table_pop_region.dta", replace
	
	* 14) poverty_lines
	pip tables, table(poverty_lines) ${options}	
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	sort name
	export delimited using "`output'table_poverty_lines.csv", replace
	save "`output'table_poverty_lines.dta", replace
	
	* 15) ppp
	pip tables, table(ppp) ${options}	
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	sort country_code data_level
	export delimited using "`output'table_ppp.csv", replace
	save "`output'table_ppp.dta", replace
	
	* 16) regions
	pip tables, table(regions) ${options}	
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	sort region_code
	export delimited using "`output'table_regions.csv", replace
	save "`output'table_regions.dta", replace

	* 17) regions_coverage
	pip tables, table(region_coverage) ${options}	
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	sort reporting_year pcn_region_code
	export delimited using "`output'table_region_coverage.csv", replace
	save "`output'table_region_coverage.dta", replace
	
	* 18) survey means
	pip tables, table(survey_means) ${options}
	notes: This data is generated based on 20220503_2011_02_02_PROD version
	sort survey_year survey_coverage welfare_type reporting_level
	export delimited using "`output'table_survey_means.csv", replace
	save "`output'table_survey_means.dta", replace	
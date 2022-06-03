	// This program compares auxilary data with previous version
	
	clear all 
	pip cleanup

	// Version 
	pip version
	
	// setup global option for newly release pip data
	*global options = "clear server(dev) identity(INT) " 
	global options = "clear server(dev) version(20220504_2011_02_02_INT)"
	
	// working directory
	local output "C:\Users\wb308892\OneDrive - WBG\Docs\Projects\pip\test_data\"
	
	* 1) countries
	pip tables, table(countries) ${options}
	sort country_code
	duplicates report country_code
	cap cf _all using "`output'table_countries.dta"
	
	if (_rc) {

		rename (region_code country_name income_group iso2_code) (region_code_curr country_name_curr income_group_curr iso2_code_curr)
		merge 1:1 country_code using "`output'table_countries.dta"
		
		*keep if _ == 3 
		
		local varList "region_code country_name income_group iso2_code"
		foreach var of local varList {
			gen `var'_diff = (`var' ~= `var'_curr)
		}
		
		tempvar diff 
		egen `diff' = rsum(region_code_diff country_name_diff income_group_diff iso2_code_diff )
		
		keep if `diff' != 0 
		
		keep country_code region_code region_code_curr country_name country_name_curr income_group income_group_curr iso2_code iso2_code_curr _merge
		order country_code region_code region_code_curr country_name country_name_curr income_group income_group_curr iso2_code iso2_code_curr _merge
		export excel using "`output'_table_country_test_output.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in the country identification data"
	} 

	* 2) country coverage
	pip tables, table(country_coverage) ${options}
	sort country_code reporting_year pop_data_level
	duplicates report country_code reporting_year pop_data_level
	cap cf _all using "`output'table_country_coverage.dta"
	
	if (_rc) {
		
		local vList "pcn_region_code welfare_type reporting_level survey_year_before survey_year_after pop incgroup_historical coverage"
		local vListCurr "pcn_region_code_curr welfare_type_curr reporting_level_curr survey_year_before_curr survey_year_after_curr pop_curr incgroup_historical_curr coverage_curr"
		local i = 0
		foreach var of local vList {
			local ++i			
			rename `var' `: word `i' of `vListCurr''
		} 
		
		merge 1:1 country_code reporting_year pop_data_level using "`output'table_country_coverage.dta"
		
		*keep if _ == 3 
		
		local varList "survey_year_before survey_year_after pop"
		foreach var of local varList {
			recode `var' `var'_curr (.=0)
			gen `var'_diff = `var' - `var'_curr
		}
		
		local varList "pcn_region_code welfare_type reporting_level incgroup_historical coverage"
		foreach var of local varList {
			gen `var'_diff = (`var' ~= `var'_curr)
		}
		
		tempvar diff 
		egen `diff' = rsum(pcn_region_code_diff welfare_type_diff reporting_level_diff survey_year_before_diff survey_year_after_diff pop_diff incgroup_historical_diff coverage_diff)
		
		keep if `diff' != 0 
		
		keep country_code reporting_year pop_data_level pcn_region_code pcn_region_code_curr welfare_type welfare_type_curr reporting_level reporting_level_curr survey_year_before survey_year_before_curr survey_year_after survey_year_after_curr pop pop_curr incgroup_historical incgroup_historical_curr coverage coverage_curr _merge
		order country_code reporting_year pop_data_level pcn_region_code pcn_region_code_curr welfare_type welfare_type_curr reporting_level reporting_level_curr survey_year_before survey_year_before_curr survey_year_after survey_year_after_curr pop pop_curr incgroup_historical incgroup_historical_curr coverage coverage_curr _merge
		export excel using "`output'_table_country_coverage_test_output.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in the country identification data"
	} 
	
	* 3) cpi
	pip tables, table(cpi) ${options}
	sort country_code data_level
	duplicates report country_code data_level
	cap cf _all using "`output'table_cpi.dta"
	
	if (_rc) {
		
		local vList "v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26 v27 v28 v29 v30 v31 v32 v33 v34 v35 v36 v37 v38 v39 v40 v41 v42 v43 v44 v45 v46"
		local vListCurr "v3_curr v4_curr v5_curr v6_curr v7_curr v8_curr v9_curr v10_curr v11_curr v12_curr v13_curr v14_curr v15_curr v16_curr v17_curr v18_curr v19_curr v20_curr v21_curr v22_curr v23_curr v24_curr v25_curr v26_curr v27_curr v28_curr v29_curr v30_curr v31_curr v32_curr v33_curr v34_curr v35_curr v36_curr v37_curr v38_curr v39_curr v40_curr v41_curr v42_curr v43_curr v44_curr v45_curr v46_curr"
		local i = 0
		foreach var of local vList {
			local ++i			
			rename `var' `: word `i' of `vListCurr''
		} 
		
		merge 1:1 country_code data_level using "`output'table_cpi.dta"
		
		*keep if _ == 3 
		
		foreach var of local vList {
			gen `var'_diff = (`var' ~= `var'_curr)
		}
		
		tempvar diff 
		egen `diff' = rsum(v3_diff v4_diff v5_diff v6_diff v7_diff v8_diff v9_diff v10_diff v11_diff v12_diff v13_diff v14_diff v15_diff v16_diff v17_diff v18_diff v19_diff v20_diff v21_diff v22_diff v23_diff v24_diff v25_diff v26_diff v27_diff v28_diff v29_diff v30_diff v31_diff v32_diff v33_diff v34_diff v35_diff v36_diff v37_diff v38_diff v39_diff v40_diff v41_diff v42_diff v43_diff v44_diff v45_diff v46_diff)
		
		keep if `diff' != 0 

		order country_code data_level v3 v3_curr v4 v4_curr v5 v5_curr v6 v6_curr v7 v7_curr v8 v8_curr v9 v9_curr v10 v10_curr v11 v11_curr v12 v12_curr v13 v13_curr v14 v14_curr v15 v15_curr v16 v16_curr v17 v17_curr v18 v18_curr v19 v19_curr v20 v20_curr v21 v21_curr v22 v22_curr v23 v23_curr v24 v24_curr v25 v25_curr v26 v26_curr v27 v27_curr v28 v28_curr v29 v29_curr v30 v30_curr v31 v31_curr v32 v32_curr v33 v33_curr v34 V34_curr v35 v35_curr v36 v36_curr v37 v37_curr v38 v38_curr v39 v39_curr v40 v40_curr v41 v41_curr v42 v42_curr v43 v43_curr v44 v44_curr v45 V45_curr v46 v46_curr _merge
		export excel using "`output'_table_cpi_test_output.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in cpi data"
	}
	
	
	* 4) decomposition
	pip tables, table(decomposition) ${options}
	sort variable_code variable_values
	duplicates report variable_code variable_values
	cap cf _all using "`output'table_decomposition.dta"
	
	if (_rc) {
		merge 1:1 variable_code variable_values using "`output'table_decomposition.dta"
		export excel using "`output'_decomposition_table.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in decomposition data"
	} 
	

	* 5) dictionary
	pip tables, table(dictionary) ${options}
	cap cf _all using "`output'table_dictionary.dta"
	
	if (_rc) {
		export excel using "`output'_table_dictionary_test_output.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in dictionary data"
	}
	
	* 6) framework
	pip tables, table(framework) ${options}
	sort country_code year survey_coverage welfare_type
	duplicates report country_code year survey_coverage welfare_type
	cap cf _all using "`output'table_framework.dta"
	
	if (_rc) {
		local vList "wb_region_code pcn_region_code country_name surveyid_year survey_year survey_acronym use_imputed use_microdata use_bin use_groupdata survey_comparability survey_time surv_title"
		local vListCurr "wb_region_code_curr pcn_region_code_curr country_name_curr surveyid_year_curr survey_year_curr survey_acronym_curr use_imputed_curr use_microdata_curr use_bin_curr use_groupdata_curr survey_comparability_curr survey_time_curr surv_title_curr"
		
		local i = 0
		foreach var of local vList {
			local ++i			
			rename `var' `: word `i' of `vListCurr''
		} 
		
		merge 1:1 country_code year survey_coverage welfare_type using "`output'table_framework.dta"
		
		*keep if _ == 3 
		foreach var of local vList {
			gen `var'_diff = (`var' ~= `var'_curr)
		}
		
		tempvar diff 
		egen `diff' = rsum(wb_region_code_diff pcn_region_code_diff country_name_diff surveyid_year_diff survey_year_diff survey_acronym_diff use_imputed_diff use_microdata_diff use_bin_diff use_groupdata_diff survey_comparability_diff survey_time_diff surv_title_diff)
		
		keep if `diff' != 0 

		keep country_code year survey_coverage welfare_type wb_region_code wb_region_code_curr pcn_region_code pcn_region_code_curr country_name country_name_curr surveyid_year surveyid_year_curr survey_year survey_year_curr survey_acronym survey_acronym_curr use_imputed use_imputed_curr use_microdata use_microdata_curr use_bin use_bin_curr use_groupdata use_groupdata_curr survey_comparability survey_comparability_curr survey_time survey_time_curr surv_title surv_title_curr _merge
		
		order country_code year survey_coverage welfare_type wb_region_code wb_region_code_curr pcn_region_code pcn_region_code_curr country_name country_name_curr surveyid_year surveyid_year_curr survey_year survey_year_curr survey_acronym survey_acronym_curr use_imputed use_imputed_curr use_microdata use_microdata_curr use_bin use_bin_curr use_groupdata use_groupdata_curr survey_comparability survey_comparability_curr survey_time survey_time_curr surv_title surv_title_curr _merge
		
		export excel using "`output'_table_framework_test_output.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in framework data"
	} 
	
	
	* 7) gdp
	pip tables, table(gdp) ${options}
	sort country_code data_level
	duplicates report country_code data_level
	cap cf _all using "`output'table_gdp.dta"
	
	if (_rc) {
		
		local vList "v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26 v27 v28 v29 v30 v31 v32 v33 v34 v35 v36 v37 v38 v39 v40 v41 v42 v43 v44 v45 v46"
		local vListCurr "v3_curr v4_curr v5_curr v6_curr v7_curr v8_curr v9_curr v10_curr v11_curr v12_curr v13_curr v14_curr v15_curr v16_curr v17_curr v18_curr v19_curr v20_curr v21_curr v22_curr v23_curr v24_curr v25_curr v26_curr v27_curr v28_curr v29_curr v30_curr v31_curr v32_curr v33_curr v34_curr v35_curr v36_curr v37_curr v38_curr v39_curr v40_curr v41_curr v42_curr v43_curr v44_curr v45_curr v46_curr"
		
		local i = 0
		foreach var of local vList {
			local ++i			
			rename `var' `: word `i' of `vListCurr''
		} 
		
		merge 1:1 country_code data_level using "`output'table_gdp.dta"
		
		*keep if _ == 3 
		
		foreach var of local vList {
			gen `var'_diff = (`var' ~= `var'_curr)
		}
		
		tempvar diff 
		egen `diff' = rsum(v3_diff v4_diff v5_diff v6_diff v7_diff v8_diff v9_diff v10_diff v11_diff v12_diff v13_diff v14_diff v15_diff v16_diff v17_diff v18_diff v19_diff v20_diff v21_diff v22_diff v23_diff v24_diff v25_diff v26_diff v27_diff v28_diff v29_diff v30_diff v31_diff v32_diff v33_diff v34_diff v35_diff v36_diff v37_diff v38_diff v39_diff v40_diff v41_diff v42_diff v43_diff v44_diff v45_diff v46_diff)
		
		keep if `diff' != 0 

		keep country_code data_level v3 v3_curr v4 v4_curr v5 v5_curr v6 v6_curr v7 v7_curr v8 v8_curr v9 v9_curr v10 v10_curr v11 v11_curr v12 v12_curr v13 v13_curr v14 v14_curr v15 v15_curr v16 v16_curr v17 v17_curr v18 v18_curr v19 v19_curr v20 v20_curr v21 v21_curr v22 v22_curr v23 v23_curr v24 v24_curr v25 v25_curr v26 v26_curr v27 v27_curr v28 v28_curr v29 v29_curr v30 v30_curr v31 v31_curr v32 v32_curr v33 v33_curr v34 V34_curr v35 v35_curr v36 v36_curr v37 v37_curr v38 v38_curr v39 v39_curr v40 v40_curr v41 v41_curr v42 v42_curr v43 v43_curr v44 v44_curr v45 V45_curr v46 v46_curr _merge		 
		
		order country_code data_level v3 v3_curr v4 v4_curr v5 v5_curr v6 v6_curr v7 v7_curr v8 v8_curr v9 v9_curr v10 v10_curr v11 v11_curr v12 v12_curr v13 v13_curr v14 v14_curr v15 v15_curr v16 v16_curr v17 v17_curr v18 v18_curr v19 v19_curr v20 v20_curr v21 v21_curr v22 v22_curr v23 v23_curr v24 v24_curr v25 v25_curr v26 v26_curr v27 v27_curr v28 v28_curr v29 v29_curr v30 v30_curr v31 v31_curr v32 v32_curr v33 v33_curr v34 V34_curr v35 v35_curr v36 v36_curr v37 v37_curr v38 v38_curr v39 v39_curr v40 v40_curr v41 v41_curr v42 v42_curr v43 v43_curr v44 v44_curr v45 V45_curr v46 v46_curr _merge
		
		export excel using "`output'_table_gdp_test_output.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in gdp data"
	}

	* 8) incgrp_coverage
	pip tables, table(incgrp_coverage) ${options}
	sort reporting_year
	duplicates report reporting_year
	cap cf _all using "`output'table_incgrp_coverage.dta"
	
	if (_rc) {
		
		rename (incgroup_historical coverage) (incgroup_historical_curr coverage_curr) 
		
		merge 1:1 reporting_year using "`output'table_incgrp_coverage.dta"
		
		*keep if _ == 3 
		gen incgroup_historical_diff = (incgroup_historical ~= incgroup_historical_curr)
		gen coverage_diff = (coverage ~= coverage_curr)
		
		tempvar diff 
		egen `diff' = rsum(incgroup_historical_diff coverage_diff)
		
		keep if `diff' != 0 

		keep reporting_year	incgroup_historical incgroup_historical_curr coverage coverage_curr	_merge
		order reporting_year incgroup_historical incgroup_historical_curr coverage coverage_curr _merge
		
		export excel using "`output'_table_incgrp_coverage_test_output.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in incgrp coverage data"
	}	
		
	* 9) indicators ****
	pip tables, table(indicators) clear
	cap cf _all using "`output'table_indicators.dta"
	
	if (_rc) {
		export excel using "`output'_indicators_table.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in indicators data"
	}

	
	* 10) interpolated_means
	pip tables, table(interpolated_means) ${options}
	sort survey_id interpolation_id
	duplicates report survey_id interpolation_id
	cap cf _all using "`output'table_interpolated_means.dta"
	
	if (_rc) {
		
		local vList "cache_id wb_region_code pcn_region_code country_code reporting_year surveyid_year survey_year survey_time survey_acronym survey_coverage survey_comparability comparable_spell welfare_type survey_mean_lcu survey_mean_ppp predicted_mean_ppp ppp cpi reporting_pop reporting_gdp reporting_pce pop_data_level gdp_data_level pce_data_level cpi_data_level ppp_data_level reporting_level distribution_type gd_type is_interpolated is_used_for_line_up is_used_for_aggregation estimation_type display_cp"
		
		local vListCurr "cache_id_curr wb_region_code_curr pcn_region_code_curr country_code_curr reporting_year_curr surveyid_year_curr survey_year_curr survey_time_curr survey_acronym_curr survey_coverage_curr survey_comparability_curr comparable_spell_curr welfare_type_curr survey_mean_lcu_curr survey_mean_ppp_curr predicted_mean_ppp_curr ppp_curr cpi_curr reporting_pop_curr reporting_gdp_curr reporting_pce_curr pop_data_level_curr gdp_data_level_curr pce_data_level_curr cpi_data_level_curr ppp_data_level_curr reporting_level_curr distribution_type_curr gd_type_curr is_interpolated_curr is_used_for_line_up_curr is_used_for_aggregation_curr estimation_type_curr display_cp_curr"
		
		local i = 0
		foreach var of local vList {
			local ++i			
			rename `var' `: word `i' of `vListCurr''
		} 
		
		merge 1:1 survey_id interpolation_id using "`output'table_interpolated_means.dta"
		
		*keep if _ == 3 
		
		local varList "reporting_year surveyid_year survey_year survey_comparability survey_mean_lcu survey_mean_ppp predicted_mean_ppp ppp cpi reporting_pop reporting_gdp reporting_pce display_cp"
		foreach var of local varList {
			recode `var' `var'_curr (.=0)
			gen `var'_diff = `var' - `var'_curr
		}
		
		local varList "cache_id wb_region_code pcn_region_code country_code survey_time survey_coverage survey_acronym comparable_spell welfare_type pop_data_level gdp_data_level pce_data_level cpi_data_level ppp_data_level reporting_level distribution_type gd_type is_interpolated is_used_for_line_up is_used_for_aggregation estimation_type"
		
		foreach var of local varList {
			gen `var'_diff = (`var' ~= `var'_curr)
		}
		
		tempvar diff 
		egen `diff' = rsum(cache_id_diff wb_region_code_diff pcn_region_code_diff country_code_diff reporting_year_diff surveyid_year_diff survey_year_diff survey_time_diff survey_acronym_diff survey_coverage_diff survey_comparability_diff comparable_spell_diff welfare_type_diff survey_mean_lcu_diff survey_mean_ppp_diff predicted_mean_ppp_diff ppp_diff cpi_diff reporting_pop_diff reporting_gdp_diff reporting_pce_diff pop_data_level_diff gdp_data_level_diff pce_data_level_diff cpi_data_level_diff ppp_data_level_diff reporting_level_diff distribution_type_diff gd_type_diff is_interpolated_diff is_used_for_line_up_diff is_used_for_aggregation_diff estimation_type_diff display_cp_diff)
		
		keep if `diff' != 0
		
		keep survey_id interpolation_id cache_id cache_id_curr wb_region_code wb_region_code_curr pcn_region_code pcn_region_code_curr country_code country_code_curr reporting_year reporting_year_curr surveyid_year surveyid_year_curr survey_year survey_year_curr survey_time survey_time_curr survey_acronym survey_acronym_curr survey_coverage survey_coverage_curr survey_comparability survey_comparability_curr comparable_spell comparable_spell_curr welfare_type welfare_type_curr survey_mean_lcu survey_mean_lcu_curr survey_mean_ppp survey_mean_ppp_curr predicted_mean_ppp predicted_mean_ppp_curr ppp ppp_curr cpi cpi_curr reporting_pop reporting_pop_curr reporting_gdp reporting_gdp_curr reporting_pce reporting_pce_curr pop_data_level pop_data_level_curr gdp_data_level gdp_data_level_curr pce_data_level pce_data_level_curr cpi_data_level cpi_data_level_curr ppp_data_level ppp_data_level_curr reporting_level reporting_level_curr distribution_type distribution_type_curr gd_type gd_type_curr is_interpolated is_interpolated_curr is_used_for_line_up is_used_for_line_up_curr is_used_for_aggregation is_used_for_aggregation_curr estimation_type estimation_type_curr display_cp display_cp_curr _merge

		order survey_id interpolation_id cache_id cache_id_curr wb_region_code wb_region_code_curr pcn_region_code pcn_region_code_curr country_code country_code_curr reporting_year reporting_year_curr surveyid_year surveyid_year_curr survey_year survey_year_curr survey_time survey_time_curr survey_acronym survey_acronym_curr survey_coverage survey_coverage_curr survey_comparability survey_comparability_curr comparable_spell comparable_spell_curr welfare_type welfare_type_curr survey_mean_lcu survey_mean_lcu_curr survey_mean_ppp survey_mean_ppp_curr predicted_mean_ppp predicted_mean_ppp_curr ppp ppp_curr cpi cpi_curr reporting_pop reporting_pop_curr reporting_gdp reporting_gdp_curr reporting_pce reporting_pce_curr pop_data_level pop_data_level_curr gdp_data_level gdp_data_level_curr pce_data_level pce_data_level_curr cpi_data_level cpi_data_level_curr ppp_data_level ppp_data_level_curr reporting_level reporting_level_curr distribution_type distribution_type_curr gd_type gd_type_curr is_interpolated is_interpolated_curr is_used_for_line_up is_used_for_line_up_curr is_used_for_aggregation is_used_for_aggregation_curr estimation_type estimation_type_curr display_cp display_cp_curr _merge
		
		export excel using "`output'_table_interpolated_means_test_output.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in the interpolated means data"
	}	
	
	
	* 11) pce
	pip tables, table(pce) ${options}
	sort country_code data_level
	duplicates report country_code data_level
	cap cf _all using "`output'table_pce.dta"
	
	if (_rc) {
		
		local vList "v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26 v27 v28 v29 v30 v31 v32 v33 v34 v35 v36 v37 v38 v39 v40 v41 v42 v43 v44 v45 v46"
		local vListCurr "v3_curr v4_curr v5_curr v6_curr v7_curr v8_curr v9_curr v10_curr v11_curr v12_curr v13_curr v14_curr v15_curr v16_curr v17_curr v18_curr v19_curr v20_curr v21_curr v22_curr v23_curr v24_curr v25_curr v26_curr v27_curr v28_curr v29_curr v30_curr v31_curr v32_curr v33_curr v34_curr v35_curr v36_curr v37_curr v38_curr v39_curr v40_curr v41_curr v42_curr v43_curr v44_curr v45_curr v46_curr"
		
		local i = 0
		foreach var of local vList {
			local ++i			
			rename `var' `: word `i' of `vListCurr''
		} 
		
		merge 1:1 country_code data_level using "`output'table_pce.dta"
		
		*keep if _ == 3 
	
		foreach var of local vList {
			recode `var' `var'_curr (.=0)
			gen `var'_diff = `var' - `var'_curr
		}

		tempvar diff 
		egen `diff' = rsum(v3_diff v4_diff v5_diff v6_diff v7_diff v8_diff v9_diff v10_diff v11_diff v12_diff v13_diff v14_diff v15_diff v16_diff v17_diff v18_diff v19_diff v20_diff v21_diff v22_diff v23_diff v24_diff v25_diff v26_diff v27_diff v28_diff v29_diff v30_diff v31_diff v32_diff v33_diff v34_diff v35_diff v36_diff v37_diff v38_diff v39_diff v40_diff v41_diff v42_diff v43_diff v44_diff v45_diff v46_diff)
		
		keep if `diff' != 0 

		keep country_code data_level v3 v3_curr v4 v4_curr v5 v5_curr v6 v6_curr v7 v7_curr v8 v8_curr v9 v9_curr v10 v10_curr v11 v11_curr v12 v12_curr v13 v13_curr v14 v14_curr v15 v15_curr v16 v16_curr v17 v17_curr v18 v18_curr v19 v19_curr v20 v20_curr v21 v21_curr v22 v22_curr v23 v23_curr v24 v24_curr v25 v25_curr v26 v26_curr v27 v27_curr v28 v28_curr v29 v29_curr v30 v30_curr v31 v31_curr v32 v32_curr v33 v33_curr v34 v34_curr v35 v35_curr v36 v36_curr v37 v37_curr v38 v38_curr v39 v39_curr v40 v40_curr v41 v41_curr v42 v42_curr v43 v43_curr v44 v44_curr v45 v45_curr v46 v46_curr _merge		
		
		order country_code data_level v3 v3_curr v4 v4_curr v5 v5_curr v6 v6_curr v7 v7_curr v8 v8_curr v9 v9_curr v10 v10_curr v11 v11_curr v12 v12_curr v13 v13_curr v14 v14_curr v15 v15_curr v16 v16_curr v17 v17_curr v18 v18_curr v19 v19_curr v20 v20_curr v21 v21_curr v22 v22_curr v23 v23_curr v24 v24_curr v25 v25_curr v26 v26_curr v27 v27_curr v28 v28_curr v29 v29_curr v30 v30_curr v31 v31_curr v32 v32_curr v33 v33_curr v34 v34_curr v35 v35_curr v36 v36_curr v37 v37_curr v38 v38_curr v39 v39_curr v40 v40_curr v41 v41_curr v42 v42_curr v43 v43_curr v44 v44_curr v45 v45_curr v46 v46_curr _merge
		
		export excel using "`output'_table_pce_test_output.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in pce data"
	}	
	
	* 12) pop
	pip tables, table(pop) ${options}	
	sort country_code data_level
	duplicates report country_code data_level
	cap cf _all using "`output'table_pop.dta"
	
	if (_rc) {
		
		local vList "v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26 v27 v28 v29 v30 v31 v32 v33 v34 v35 v36 v37 v38 v39 v40 v41 v42 v43 v44 v45 v46"
		local vListCurr "v3_curr v4_curr v5_curr v6_curr v7_curr v8_curr v9_curr v10_curr v11_curr v12_curr v13_curr v14_curr v15_curr v16_curr v17_curr v18_curr v19_curr v20_curr v21_curr v22_curr v23_curr v24_curr v25_curr v26_curr v27_curr v28_curr v29_curr v30_curr v31_curr v32_curr v33_curr v34_curr v35_curr v36_curr v37_curr v38_curr v39_curr v40_curr v41_curr v42_curr v43_curr v44_curr v45_curr v46_curr"
		
		local i = 0
		foreach var of local vList {
			local ++i			
			rename `var' `: word `i' of `vListCurr''
		} 
		
		merge 1:1 country_code data_level using "`output'table_pop.dta"
		
		*keep if _ == 3 
	
		foreach var of local vList {
			recode `var' `var'_curr (.=0)
			gen `var'_diff = `var' - `var'_curr
		}

		tempvar diff 
		egen `diff' = rsum(v3_diff v4_diff v5_diff v6_diff v7_diff v8_diff v9_diff v10_diff v11_diff v12_diff v13_diff v14_diff v15_diff v16_diff v17_diff v18_diff v19_diff v20_diff v21_diff v22_diff v23_diff v24_diff v25_diff v26_diff v27_diff v28_diff v29_diff v30_diff v31_diff v32_diff v33_diff v34_diff v35_diff v36_diff v37_diff v38_diff v39_diff v40_diff v41_diff v42_diff v43_diff v44_diff v45_diff v46_diff)
		
		keep if `diff' != 0 

		keep country_code data_level v3 v3_curr v4 v4_curr v5 v5_curr v6 v6_curr v7 v7_curr v8 v8_curr v9 v9_curr v10 v10_curr v11 v11_curr v12 v12_curr v13 v13_curr v14 v14_curr v15 v15_curr v16 v16_curr v17 v17_curr v18 v18_curr v19 v19_curr v20 v20_curr v21 v21_curr v22 v22_curr v23 v23_curr v24 v24_curr v25 v25_curr v26 v26_curr v27 v27_curr v28 v28_curr v29 v29_curr v30 v30_curr v31 v31_curr v32 v32_curr v33 v33_curr v34 V34_curr v35 v35_curr v36 v36_curr v37 v37_curr v38 v38_curr v39 v39_curr v40 v40_curr v41 v41_curr v42 v42_curr v43 v43_curr v44 v44_curr v45 V45_curr v46 v46_curr _merge		
		
		order country_code data_level v3 v3_curr v4 v4_curr v5 v5_curr v6 v6_curr v7 v7_curr v8 v8_curr v9 v9_curr v10 v10_curr v11 v11_curr v12 v12_curr v13 v13_curr v14 v14_curr v15 v15_curr v16 v16_curr v17 v17_curr v18 v18_curr v19 v19_curr v20 v20_curr v21 v21_curr v22 v22_curr v23 v23_curr v24 v24_curr v25 v25_curr v26 v26_curr v27 v27_curr v28 v28_curr v29 v29_curr v30 v30_curr v31 v31_curr v32 v32_curr v33 v33_curr v34 v34_curr v35 v35_curr v36 v36_curr v37 v37_curr v38 v38_curr v39 v39_curr v40 v40_curr v41 v41_curr v42 v42_curr v43 v43_curr v44 v44_curr v45 v45_curr v46 v46_curr _merge
		
		export excel using "`output'_table_pop_test_output.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in pop data"
	}	


	* 13) pop_region
	pip tables, table(pop_region) ${options}	
	sort region_code reporting_year
	duplicates report region_code reporting_year
	cap cf _all using "`output'table_pop_region.dta"
	
	if (_rc) {
		rename (reporting_pop grouping_type) (reporting_pop_curr grouping_type_curr)
		merge 1:1 region_code reporting_year using "`output'table_pop_region.dta"
		
		*keep if _ == 3 
		
		gen reporting_pop_diff = reporting_pop - reporting_pop_curr
		gen grouping_type_diff = (grouping_type ~= grouping_type_curr)

		tempvar diff 
		egen `diff' = rsum(reporting_pop_diff grouping_type_diff)
		
		keep if `diff' != 0
		
		keep region_code reporting_year reporting_pop reporting_pop_curr grouping_type grouping_type_curr _merge
		order region_code reporting_year reporting_pop reporting_pop_curr grouping_type grouping_type_curr _merge
		export excel using "`output'_table_pop_region_test_output.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in regional population data"
	}
	
		
	* 14) poverty_lines
	pip tables, table(poverty_lines) ${options}
	sort name
	duplicates report name
	cap cf _all using "`output'table_poverty_lines.dta"
	
	if (_rc) {
		rename (poverty_line is_default is_visible) (poverty_line_curr is_default_curr is_visible_curr)
		merge 1:1 name using "`output'table_poverty_lines.dta"
		
		*keep if _ == 3 
		
		gen poverty_line_diff = poverty_line - poverty_line_curr
		gen is_default_diff = (is_default ~= is_default_curr)
		gen is_visible_diff = (is_visible ~= is_visible_curr)

		tempvar diff 
		egen `diff' = rsum(poverty_line_diff is_default_diff is_visible_diff)
		
		keep if `diff' != 0 
		
		keep name poverty_line poverty_line_curr is_default is_default_curr is_visible is_visible_curr _merge
		order name poverty_line poverty_line_curr is_default is_default_curr is_visible is_visible_curr _merge
		export excel using "`output'_table_poverty_lines_test_output.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in poverty lines data"
	}
	
	
	* 15) ppp
	pip tables, table(ppp) ${options}	
	sort country_code data_level
	duplicates report country_code data_level
	cap cf _all using "`output'table_ppp.dta"
	
		if (_rc) {
		rename v3 v3_curr
		merge 1:1 country_code data_level using "`output'table_ppp.dta"
		
		*keep if _ == 3 
		
		gen v3_diff = v3 - v3_curr

		keep if v3_diff != 0 
		
		keep country_code data_level v3 v3_curr _merge
		order country_code data_level v3 v3_curr _merge
		export excel using "`output'_table_ppp_test_output.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in ppp data"
	}


	* 16) regions
	pip tables, table(regions) ${options}	
	sort region_code
	duplicates report region_code
	cap cf _all using "`output'table_regions.dta"
	
		if (_rc) {
		rename (region grouping_type) (region_curr grouping_type_curr)
		merge 1:1 region_code using "`output'table_regions.dta"
		
		*keep if _ == 3 
		
		gen region_diff = (region ~= region_curr)
		gen grouping_type_diff = (grouping_type ~= grouping_type_curr)

		tempvar diff 
		egen `diff' = rsum(region_diff grouping_type_diff)
		keep if `diff' != 0 
		
		keep region_code region region_curr grouping_type grouping_type_curr _merge
		order region_code region region_curr grouping_type grouping_type_curr _merge
		export excel using "`output'_table_regions_test_output.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in region description data"
	}
		
	* 17) regions_coverage
	pip tables, table(region_coverage) ${options}
	sort reporting_year pcn_region_code
	duplicates report reporting_year pcn_region_code	
	cap cf _all using "`output'table_region_coverage.dta"
	
	if (_rc) {
		rename coverage coverage_curr
		merge 1:1 reporting_year pcn_region_code using "`output'table_region_coverage.dta"
		
		*keep if _ == 3 
		
		gen coverage_diff = coverage - coverage_curr

		keep if coverage_diff != 0 
		
		keep reporting_year pcn_region_code coverage coverage_curr _merge
		order reporting_year pcn_region_code coverage coverage_curr _merge
		export excel using "`output'_table_region_coverage_test_output.xlsx", firstrow(varlab) replace
	} 
	else {
		disp "There is no change in region coverage data"
	}	
	
	
	

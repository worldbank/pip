/*==================================================
project:       Clean data downloaded from PIP API
Author:        R.Andres Castaneda 
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     5 Jun 2019 - 17:09:04
Modification Date:  September, 2021 
Do-file version:    02
References: Adopted from povcalnet_clean
Output:             dta
==================================================*/

/*==================================================
                        0: Program set up
==================================================*/
program define pip_clean, rclass

version 16.0

syntax anything(name=type),      ///
             [                   ///
								year(string)     ///
								region(string)   ///
								iso              ///
								wb				    ///
								nocensor			///
								pause			///
             ]

if ("`pause'" == "pause") pause on
else                      pause off


/*==================================================
              1: type 1
==================================================*/

if ("`type'" == "1") {

	if  ("`year'" == "last"){
		bys country_code: egen maximum_y = max(reporting_year)
		keep if maximum_y ==  reporting_year
		drop maximum_y
	}


	***************************************************
	* 5. Labeling/cleaning
	***************************************************
	// check if country data frame is available
	
	pip_info, clear justdata `pause' server(`server')
	
	frlink m:1 country_code, frame(_pip_countries) generate(ctry_name)
	frget country_name, from(ctry_name)
	
	frlink m:1 region_code, frame(_pip_regions) generate(rgn_name)
	frget region, from(rgn_name)
	
	drop ctry_name rgn_name
	
	local orgvar country_name region reporting_pop reporting_pce pce_data_level
	local newvar countryname region_name population reporting_hfce hfce_data_level
			
	local i = 0
		foreach var of local orgvar {
			local ++i
			rename `var' `: word `i' of `newvar''
		}	
		
	if "`iso'"!="" {
		cap replace country_code = "XKX" if country_code == "KSV"
		cap replace country_code = "TLS" if country_code == "TMP"
		cap replace country_code = "PSE" if country_code == "WBG"
		cap replace country_code = "COD" if country_code == "ZAR"
	}

	*rename  prmld  mld
	foreach v of varlist polarization median gini mld decile? decile10 {
		qui cap replace `v'=. if `v'==-1 | `v' == 0
	}

	cap drop if ppp==""
	cap drop  svyinfoid
	
	pause query - after replacing invalid values to missing values
	
	* cap drop  polarization
	qui count
	local obs=`r(N)'
	
	tostring survey_coverage, replace
	
	replace survey_coverage = "1" if survey_coverage == "rural"
	replace survey_coverage = "2" if survey_coverage == "urban"
	replace survey_coverage = "4" if survey_coverage == "A" // not available in pip data
	replace survey_coverage = "3" if survey_coverage == "national"
	destring survey_coverage, force replace
	label define survey_coverage 1 "Rural"     /* 
	 */                       2 "Urban"     /* 
	 */                       3 "National"  /* 
	 */                       4 "National (Aggregate)", modify
	 
	label values survey_coverage survey_coverage

	replace welfare_type = "1" if welfare_type == "consumption"
	replace welfare_type = "2" if welfare_type == "income"
	destring welfare_type, force replace
	label define welfare_type 1 "Consumption" 2 "Income", modify
	label values welfare_type welfare_type

	label var country_code		"Country/Economy code"
	label var countryname 		"Country/Economy name"
	label var region_code 		"Region code"
	label var region_name 		"Region name"
	label var survey_coverage 	"Survey coverage"
	label var reporting_year	"Year"
	label var survey_year 		"Survey year"
	label var welfare_type 		"Welfare measured by income or consumption"
	label var is_interpolated 	"Data is interpolated"
	label var distribution_type "Data comes from grouped or microdata"
	label var ppp 				"2011 Purchasing Power Parity"
	label var poverty_line 		"Poverty line in PPP$ (per capita per day)"
	label var mean				"Average monthly per capita income/consumption PPP$"
	label var headcount 		"Poverty Headcount"
	label var poverty_gap 		"Poverty Gap"
	label var poverty_severity 	"Squared poverty gap"
	label var watts 			"Watts index"
	label var gini 				"Gini index"
	label var median 			"Median monthly income or expenditure in PPP$"
	label var mld 				"Mean Log Deviation"
	label var polarization 		"Polarization"
	label var population 		"Population in year"
	label var decile1 			"Share of total welfare in decile 1"
	label var decile2 			"Share of total welfare in decile 2"
	label var decile3 			"Share of total welfare in decile 3"
	label var decile4 			"Share of total welfare in decile 4"
	label var decile5 			"Share of total welfare in decile 5"
	label var decile6 			"Share of total welfare in decile 6"
	label var decile7 			"Share of total welfare in decile 7"
	label var decile8 			"Share of total welfare in decile 8"
	label var decile9 			"Share of total welfare in decile 9"
	label var decile10 			"Share of total welfare in decile 10"
	label var reporting_level 	"Reporting data level"
	label var survey_acronym 	"Survey acronym"     
	label var survey_comparability "Survey comparability"
	label var comparable_spell 	"Comparability over time at country level"
	label var survey_mean_lcu 	"Daily mean income or expenditure in LCU"
	label var survey_mean_ppp 	"Daily mean income or expenditure in PPP$"
	label var predicted_mean_ppp "Daily interpolated mean in PPP$"       
	label var cpi 				"Consumer Price Index (CPI)"
	label var cpi_data_level 	"CPI data level"
	label var ppp_data_level 	"PPP data level"
	label var pop_data_level 	"Population level"
	label var reporting_gdp 	"Reported GDP"
	label var gdp_data_level 	"GDP data level"
	label var reporting_hfce 	"Reported per capita"
	label var hfce_data_level 	"Per capita data level"
	label var is_used_for_aggregation "Used for aggregation"
	label var estimation_type 	"Estimation type"

	sort country_code reporting_year survey_coverage 
	
	
	order country_code countryname region_code region_name survey_coverage     ///
	reporting_year survey_year welfare_type is_interpolated distribution_type  ///
	ppp poverty_line mean headcount poverty_gap poverty_severity watts gini    ///
	median mld polarization population decile? decile10
	
	
	//------------ Formatting
	format headcount poverty_gap poverty_severity watts  gini mld polarization ///
	decile*  mean survey_mean_ppp  cpi %8.4f
	
	format ppp survey_mean_lcu  %10.2fc
	format reporting_gdp  reporting_hfce %15.2fc
	
	format population %15.0fc
	
}

/*==================================================
              2: for Aggregate requests
==================================================*/
if ("`type'" == "2") {
	
	
	if  ("`year'" == "last") {
		tempvar maximum_y
		bys region_code: egen `maximum_y' = max(reporting_year)
		keep if `maximum_y' ==  reporting_year
	}
	
	***************************************************
	* 4. Renaming and labeling
	***************************************************
	
	rename reporting_pop population

	label var region_code      "Region code"
	label var reporting_year   "Year"
	label var poverty_line     "Poverty line in PPP$ (per capita per day)"
	label var mean             "Average monthly per capita income/consumption in PPP$"
	label var headcount        "Poverty Headcount"
	label var poverty_gap      "Poverty Gap"
	label var poverty_severity "Squared poverty gap"
	label var population       "Population in year"
	label var pop_in_poverty   "Population in poverty"
	label var watts            "Watts index"
	
	order region_code reporting_year  poverty_line mean headcount poverty_gap ///
	poverty_severity watts population 
	
	//------------ Formatting
	format headcount poverty_gap poverty_severity watts mean  %8.4f
	
	format pop_in_poverty  population %15.0fc

} // end of type 2



end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



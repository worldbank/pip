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
wb				       ///
nocensor			   ///
pause			       ///
version(string)  ///
]

if ("`pause'" == "pause") pause on
else                      pause off


//------------ version
if ("`version'" != "") {
	local version_qr = "&version=`version'"
	tokenize "`version'", parse("_")
	local _version   = "_`1'_`3'_`9'"
}
else {
	local version_qr = ""
	local _version   = ""
}



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
	
	pip_info, clear justdata `pause' server(`server') version(`version')
	
	local orgvar  reporting_pop reporting_pce 
	local newvar  population reporting_hfce
	
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
	label var country_name 		"Country/Economy name"
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
	
	ds decile*
	local vardec = "`r(varlist)'"
	foreach var of local vardec {
		if regexm("`var'", "([0-9]+)") local q = regexs(1)
		label var `var' "Decile `q' welfare share"
	}
	
	label var reporting_level 	"Reporting data level"
	label var survey_acronym 	"Survey acronym"     
	label var survey_comparability "Survey comparability"
	label var comparable_spell 	"Comparability over time at country level"   
	label var cpi 				"Consumer Price Index (CPI)"
	label var reporting_gdp 	"Reported GDP"
	label var reporting_hfce 	"Reported per capita"
	
	sort country_code reporting_year survey_coverage 
	
	//------------ Formatting
	format headcount poverty_gap poverty_severity watts  gini mld polarization ///
	decile*  mean /* survey_mean_ppp */  cpi %8.4f
	
	* format ppp survey_mean_lcu  %10.2fc
	format reporting_gdp  reporting_hfce %15.2fc
	
	format population %15.0fc
	
	format poverty_line %6.2f
	
	//------------ New variable names
	
	local old "survey_year reporting_year  reporting_gdp reporting_hfce"
	local new  "welfare_time year gdp hfce"
	rename (`old') (`new')
	 */
	
	//------------survey_time	
	gen survey_time = strofreal(year)
	replace survey_time = strofreal(year) + "-" + strofreal(year + 1) /* 
     */	             if mod(welfare_time, 1) > 0
	replace survey_time = strofreal(year + 1)     /* 
     */              if regexm(upper(survey_acronym), "SILC") 
						
	
	
	order country_code country_name region_code region_name survey_coverage ///
	year welfare_time welfare_type poverty_line mean headcount ///
	poverty_gap  poverty_severity watts gini    ///
	median mld polarization population decile? decile10 cpi ppp gdp hfce ///
	survey_comparability   ///
	survey_acronym  survey_time  is_interpolated distribution_type
	
	
	//------------remaining labels
	label var welfare_time "Time income or consumption refers to"
	label var survey_time  "Time of survey in the field"
		
	//------------drop unnecesary variables
	cap drop estimation_type	
	qui missings dropvars, force
	
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
	label var region_name      "World Bank Region"
	
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
	
	qui missings dropvars, force
	
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



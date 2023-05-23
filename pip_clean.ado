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
fillgaps			   ///
nocensor			   ///
pause			       ///
version(string)  ///
server(string)   ///
]

if ("`pause'" == "pause") pause on
else                      pause off


//------------ version
if ("`version'" != "") {
	local version_qr = "&version=`version'"
	tokenize "`version'", parse("_")
	local _version   = "_`1'_`3'_`9'"
	local ppp_version = `3'
}
else {
	local version_qr = ""
	local _version   = ""
}



/*==================================================
1: type 1
==================================================*/

qui if ("`type'" == "1") {
	
	if  ("`year'" == "last"){
		bys country_code: egen maximum_y = max(reporting_year)
		keep if maximum_y ==  reporting_year
		drop maximum_y
	}
	
	
	***************************************************
	* 5. Labeling/cleaning
	***************************************************
	// check if country data frame is available
	
	pip_auxframes
	
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
	label define survey_coverage 1 "rural"     /* 
	*/                       2 "urban"     /* 
	*/                       3 "national"  /* 
	*/                       4 "national (aggregate)", modify
	
	label values survey_coverage survey_coverage
	
	replace welfare_type = "1" if welfare_type == "consumption"
	replace welfare_type = "2" if welfare_type == "income"
	destring welfare_type, force replace
	label define welfare_type 1 "consumption" 2 "income", modify
	label values welfare_type welfare_type
	
	label var country_code		  "country/economy code"
	label var country_name 		  "country/economy name"
	label var region_code 		  "region code"
	label var region_name 		  "region name"
	label var survey_coverage   "survey coverage"
	label var reporting_year	  "year"
	label var survey_year 		  "survey year"
	label var welfare_type 		  "welfare measured by income or consumption"
	label var is_interpolated 	"data is interpolated"
	label var distribution_type "data comes from grouped or microdata"
	label var ppp 				      "`ppp_version' purchasing power parity"
	label var poverty_line 		  "poverty line in `ppp_version' PPP US\$ (per capita per day)"
	label var mean				      "average daily per capita income/consumption `ppp_version' PPP US\$"
	label var headcount 		    "poverty headcount"
	label var poverty_gap 		  "poverty gap"
	label var poverty_severity 	"squared poverty gap"
	label var watts 			      "watts index"
	label var gini 				      "gini index"
	label var median 			      "median daily per capita income/consumption in `ppp_version' PPP US\$"
	label var mld 				      "mean log deviation"
	label var polarization 		  "polarization"
	label var population 		    "population in year"
	
	ds decile*
	local vardec = "`r(varlist)'"
	foreach var of local vardec {
		if regexm("`var'", "([0-9]+)") local q = regexs(1)
		label var `var' "decile `q' welfare share"
	}
	
	label var reporting_level 	   "reporting data level"
	label var survey_acronym 	     "survey acronym"     
	label var survey_comparability "survey comparability"
	label var comparable_spell 	   "comparability over time at country level"   
	label var cpi 				         "consumer price index (CPI) in `ppp_version' base"
	label var reporting_gdp 	     "GDP per capita in constant 2015 US\$, annual calendar year"
	label var reporting_hfce 	     "HFCE per capita in constant 2015 US\$, annual calendar year"
	
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
	
	local frpipfw "_pip_fw`_version'"
	
	tempname frfw
	frame copy `frpipfw' `frfw'
	frame `frfw' {  
		drop year
		rename reporting_year year
	}
	
	frlink m:1 country_code year welfare_type, frame(`frfw') 
	frget survey_time, from(`frfw')
	
	
	order country_code country_name region_code region_name reporting_level  ///
	year welfare_time welfare_type poverty_line mean headcount ///
	poverty_gap  poverty_severity watts gini    ///
	median mld polarization population decile? decile10 cpi ppp gdp hfce ///
	survey_comparability   ///
	survey_acronym  survey_time  is_interpolated distribution_type survey_coverage
	
	
	//------------remaining labels
	label var welfare_time "time income or consumption refers to"
	label var survey_time  "time of survey in the field"
	
	//------------drop unnecesary variables
	cap drop estimation_type
	
	if ("`fillgaps'" != "") {
		drop ppp survey_time distribution_type gini mld polarization decile* median
	}
	
	qui missings dropvars, force
}

/*==================================================
2: for Aggregate requests
==================================================*/
qui if ("`type'" == "2") {
	
	
	if  ("`year'" == "last") {
		tempvar maximum_y
		bys region_code: egen `maximum_y' = max(reporting_year)
		keep if `maximum_y' ==  reporting_year
	}
	
	***************************************************
	* 4. Renaming and labeling
	***************************************************
	
	rename reporting_pop population
	
	label var region_code      "region code"
	label var reporting_year   "year"
	label var poverty_line     "poverty line in `ppp_version' PPP US\$ (per capita per day)"
	label var mean             "average daily per capita income/consumption in `ppp_version' PPP US\$"
	label var headcount        "poverty headcount"
	label var poverty_gap      "poverty gap"
	label var poverty_severity "squared poverty gap"
	label var population       "population in year"
	label var pop_in_poverty   "population in poverty"
	label var watts            "watts index"
	label var region_name      "world bank region"
	
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


/*==================================================
Delete Obs with no headcount or Poverty line
==================================================*/

qui {
	cap confirm var country_code, exact
	if (_rc) {
		local geo region_code
	}
	else {
		local geo country_code
	}
	
	tempvar misspl
	gen `misspl' = poverty_line == .
	qui count if `misspl'
	if (r(N) > 0) {
		noi disp as err "Warning: The API returned an invalid poverty " ///
		"line for the following combinations. Observations are deleted." ///
		_n "Please, contact PIP Technical Team at "
		
		noi list `geo' year  if `misspl', clean noobs
		drop if `misspl'
	}
	
	tempvar misshc
	gen `misshc' = headcount == .
	qui count if `misshc'
	if (r(N) > 0) {
		noi disp as err "Warning: The following combinations do not " ///
		"have valid poverty headcount. Obs will be deleted"
		
		noi list `geo' year poverty_line if `misshc', clean noobs
		drop if `misshc'
	}
}


end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



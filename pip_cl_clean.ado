/*==================================================
project:       clean after downloading
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    15 May 2023 - 17:42:50
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_cl_clean, rclass
syntax, version(string)

version 16

//========================================================
//  setup
//========================================================
tokenize "`version'", parse("_")
local _version   = "_`1'_`3'_`9'"
local ppp_version = `3'

//========================================================
//  Dealing with invalid values
//========================================================
*rename  prmld  mld
qui {
	foreach v of varlist polarization median gini mld decile? decile10 {
		cap replace `v'=. if `v'==-1 | `v' == 0
	}
	
	cap drop if ppp==""
	cap drop  svyinfoid
	
	
	//========================================================
	// labels
	//========================================================
	
	//------------ Survey coverage
	tostring survey_coverage, replace
	replace survey_coverage = "1" if survey_coverage == "rural"
	replace survey_coverage = "2" if survey_coverage == "urban"
	replace survey_coverage = "3" if survey_coverage == "national"
	
	destring survey_coverage, force replace
	label define survey_coverage 1 "rural"     /* 
	*/                       2 "urban"     /* 
	*/                       3 "national", modify
	
	label values survey_coverage survey_coverage
	
	//------------Welfare type
	replace welfare_type = "1" if welfare_type == "consumption"
	replace welfare_type = "2" if welfare_type == "income"
	destring welfare_type, force replace
	label define welfare_type 1 "consumption" 2 "income", modify
	label values welfare_type welfare_type
	
	//------------ All variables
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
	label var reporting_pop 	  "polarization"
	label var reporting_pop     "population in year"
	
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
	label var reporting_pce 	     "HFCE per capita in constant 2015 US\$, annual calendar year"
	
	//========================================================
	//  Sorting and Formatting
	//========================================================
	
	//------------Sorting
	sort country_code reporting_year survey_coverage 
	
	//------------ Formatting
	format headcount poverty_gap poverty_severity watts  gini mld ///
	decile*  mean polarization  /* survey_mean_ppp */  cpi %8.4f
	
	* format ppp survey_mean_lcu  %10.2fc
	format reporting_gdp  reporting_pce %15.2fc
	
	format reporting_pop %15.0fc
	
	format poverty_line %6.2f
	
	//------------ renaming variables
	local old survey_year reporting_year reporting_gdp reporting_pce /* 
 */	        reporting_pop
	local new welfare_time year gdp hfce population
	rename (`old') (`new')
	
	
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
	
	//------------ Ordering vars
	order country_code country_name region_code                /*
	*/    region_name reporting_level year welfare_time        /*
	*/    welfare_type poverty_line mean headcount             /*
	*/    poverty_gap  poverty_severity watts gini             /*
	*/    median mld polarization population decile? decile10  /*
	*/    cpi ppp gdp hfce survey_comparability                /*
	*/    survey_acronym  survey_time  is_interpolated         /*
	*/    distribution_type survey_coverage
	
	
	//------------remaining labels
	label var welfare_time "time income or consumption refers to"
	label var survey_time  "time of survey in the field"
	
	//------------drop unnecesary variables
	cap drop estimation_type
	
	if ("`fillgaps'" != "") {
		drop ppp survey_time distribution_type gini mld polarization decile* median
	}
	
	missings dropvars, force
	
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



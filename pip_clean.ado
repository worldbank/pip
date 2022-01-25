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
								wb				///
								nocensor			///
								rc(string)       ///
								pause			///
             ]

if ("`pause'" == "pause") pause on
else                      pause off

/*==================================================
           handling errors
==================================================*/

if ("`rc'" == "copy") {
	noi dis ""
	noi dis in red "It was not possible to download data from the PIP API."
	noi dis ""
	noi dis in white `"(1) Please check your Internet connection by "' _c 
	*noi dis in white  `"{browse "http://iresearch.worldbank.org/PovcalNet/home.aspx" :clicking here}"'
	noi dis in white  `"{browse "https://pipscoreapiqa.worldbank.org" :clicking here}"' // needs to be replaced
	noi dis in white `"(2) Please consider adjusting your Stata timeout parameters. For more details see {help netio}"'
	noi dis in white `"(3) Please send us an email to:"'
	noi dis in white _col(8) `"email: data@worldbank.org"'
	noi dis in white _col(8) `"subject: pip query error 20 on `c(current_date)' `c(current_time)'"'
	noi di ""
	error 673
}

if ("`rc'" == "in" | c(N) == 0) {
	noi di ""
	noi di as err "There was a problem loading the downloaded data." /* 
	 */ _n "Check that all parameters are correct and try again."
	noi dis as text  `"{p 4 4 2} You could use the {stata pip_info:guided selection} instead. {p_end}"'
	noi di ""
	break
	error 
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
	
	frame dir 
	local av_frames "`r(frames)'"
	local av_frames: subinstr local  av_frames " " "|", all
	local av_frames = "^(" + "`av_frames'" + ")"
	
	//------------ countries frame
	local frpipcts "_pip_countries"
	if (!regexm("`frpipcts'", "`av_frames'")) {
		
		frame create `frpipcts'
		
		frame `frpipcts' {
			
			local csvfile0  = "`url'/aux?table=countries&format=csv"
			cap import delimited using "`csvfile0'", clear varn(1)
			
			if (_rc != 0 ) {
				noi disp in red "There is a problem accessing country name data." 
				noi disp in red "to check your connection, copy and paste in your browser the following address:" _n /* 
				*/	_col(4) in w `"`csvfile0'"'
				
				error 
			} 
			
			drop iso2_code
			sort country_code
		}
		
	}
	
	frlink m:1 country_code, frame(_pip_countries) generate(ctry_name)
	frget country_name, from(ctry_name)
	
	drop ctry_name
	
	rename country_name countryname
	
	order country_code countryname region_code survey_coverage reporting_year survey_year welfare_type is_interpolated distribution_type /*
	*/ ppp poverty_line mean headcount poverty_gap poverty_severity watts gini median mld polarization reporting_pop decile? decile10
	
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

	label var is_interpolated   "Data is interpolated"
	label var country_code      "Country/Economy Code"
	label var distribution_type "Data comes from grouped or microdata"
	label var countryname       "Country/Economy Name"
	label var region_code       "Region Code"
	label var region            "Region Name"
	label var survey_coverage   "Coverage"
	label var reporting_year    "Year you requested"
	label var survey_year       "Survey year"
	label var welfare_type      "Welfare measured by income or consumption"
	label var ppp               "Purchasing Power Parity"
	label var poverty_line      "Poverty line in PPP$ (per capita per day)"
	label var mean              "Average monthly per capita income/consumption in PPP$"
	label var headcount         "Poverty Headcount"
	label var poverty_gap       "Poverty Gap."
	label var poverty_severity  "Squared poverty gap."
	label var watts             "Watts index"
	label var gini              "Gini index"
	label var median            "Median monthly income or expenditure in PPP$"
	label var mld               "Mean Log Deviation"
	label var reporting_pop     "Population in year"

	sort country_code reporting_year survey_coverage 
}

/*==================================================
              2: for Aggregate requests
==================================================*/
if ("`type'" == "2") {
	if  ("`region'" != "" & region_code != "CUSTOM") {
		tempvar keep_this
		gen `keep_this' = 0
		local region_l = `""`region'""'
		local region_l: subinstr local region_l " " `"", ""', all

		dis "`region_l'"
		dis "`keep_this'"
		
		replace `keep_this' = 1 if inlist(region_code, `region_l')
		if lower("`region'") == "all" replace `keep_this' = 1
		keep if `keep_this' == 1 
	}
	
	pause clean - after dropping by region 
	
	if  ("`year'" == "last") {
		tempvar maximum_y
		bys region_code: egen `maximum_y' = max(reporting_year)
		keep if `maximum_y' ==  reporting_year
	}
	
	***************************************************
	* 4. Renaming and labeling
	***************************************************

	label var region_code      "Region code"
	label var reporting_year   "Year you requested"
	label var poverty_line     "Poverty line in PPP$ (per capita per day)"
	label var mean             "Average monthly per capita income/consumption in PPP$"
	label var headcount        "Poverty Headcount"
	label var poverty_gap      "Poverty Gap"
	label var poverty_severity "Squared poverty gap"
	label var reporting_pop    "Population in year"
	label var pop_in_poverty   "Population in poverty"
	
	order reporting_year region_code poverty_line mean headcount poverty_gap poverty_severity reporting_pop

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



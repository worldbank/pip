/*==================================================
project:       Transform to PovcalNet old format
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     1 Dec 2021 - 11:27:35
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_povcalnet_format, rclass

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

noi disp in red "Warning: " in yellow /// 
"option {it:povcalnet_format} is intended only to " _n ///
"replicate results or to use Stata code that still" _n ///
"executes the deprecated {cmd:povcalnet} command."

/*==================================================
1:  country data 
==================================================*/

if ("`type'" == "1") {

	if  ("`year'" == "last"){
		bys country_code: egen maximum_y = max(reporting_year)
		keep if maximum_y ==  reporting_year
		drop maximum_y
	}

	pause check rename option 1
	
	***************************************************
	* 5. Labeling/cleaning
	***************************************************
	gen countryname = ""
	
	local vars1 country_code region_code survey_coverage reporting_year survey_year /*
	*/welfare_type is_interpolated distribution_type poverty_line poverty_gap /*
	*/poverty_severity reporting_pop
	
	local vars2 countrycode regioncode coveragetype year datayear datatype isinterpolated usemicrodata /*
	*/povertyline povgap povgapsqr population
	
	local i = 0
	foreach var of local vars1 {
		local ++i
		rename `var' `: word `i' of `vars2''
	}	
	
	keep countrycode countryname regioncode coveragetype year datayear datatype isinterpolated usemicrodata /*
	*/ ppp povertyline mean headcount povgap povgapsqr watts gini median mld polarization population decile? decile10
	
	order countrycode countryname regioncode coveragetype year datayear datatype isinterpolated usemicrodata /*
	*/ ppp povertyline mean headcount povgap povgapsqr watts gini median mld polarization population decile? decile10
	
	if "`iso'"!="" {
		cap replace countrycode="XKX" if countrycode=="KSV"
		cap replace countrycode="TLS" if countrycode=="TMP"
		cap replace countrycode="PSE" if countrycode=="WBG"
		cap replace countrycode="COD" if countrycode=="ZAR"
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
	
	tostring coveragetype, replace
	
	replace coveragetype = "1" if coveragetype == "rural"
	replace coveragetype = "2" if coveragetype == "urban"
	replace coveragetype = "4" if coveragetype == "A" // not available in pip data
	replace coveragetype = "3" if coveragetype == "national"
	destring coveragetype, force replace
	label define coveragetype 1 "Rural"     /* 
	 */                       2 "Urban"     /* 
	 */                       3 "National"  /* 
	 */                       4 "National (Aggregate)", modify
	 
	label values coveragetype coveragetype

	replace datatype = "1" if datatype == "consumption"
	replace datatype = "2" if datatype == "income"
	destring datatype, force replace
	label define datatype 1 "Consumption" 2 "Income", modify
	label values datatype datatype

	label var isinterpolated    "Data is interpolated"
	label var countrycode       "Country/Economy Code"
	label var usemicrodata      "Data comes from grouped or microdata"
	label var countryname       "Country/Economy Name"
	label var regioncode        "Region Code"
	label var region            "Region Name"
	label var coveragetype      "Coverage"
	label var year              "Year you requested"
	label var datayear          "Survey year"
	label var datatype          "Welfare measured by income or consumption"
	label var ppp               "Purchasing Power Parity"
	label var povertyline       "Poverty line in PPP$ (per capita per day)"
	label var mean              "Average monthly per capita income/consumption in PPP$"
	label var headcount         "Poverty Headcount"
	label var povgap            "Poverty Gap."
	label var povgapsqr         "Squared poverty gap."
	label var watts             "Watts index"
	label var gini              "Gini index"
	label var median            "Median monthly income or expenditure in PPP$"
	label var mld               "Mean Log Deviation"
	label var population        "Population in year"

	//------------ Convert to monthly values
	replace mean = mean * (360/12)
	replace median = median * (360/12)

	sort countrycode year coveragetype
}

/*==================================================
2: for Aggregate requests
==================================================*/
if ("`type'" == "2") {
	
  //------------ Renaming and labeling
	
	rename region_code regioncode
	rename poverty_line povertyline
	rename poverty_gap povgap
	rename poverty_severity povgapsqr
	
	keep reporting_year regioncode povertyline mean headcount povgap povgapsqr reporting_pop
	order reporting_year regioncode povertyline mean headcount povgap povgapsqr reporting_pop
	
	local Snames reporting_year reporting_pop 
	
	local Rnames year population 
	
	local i = 0
	foreach var of local Snames {
		local ++i
		rename `var' `: word `i' of `Rnames''
	}
	
	label var year              "Year you requested"
	label var regioncode        "Region code"
	label var povertyline       "Poverty line in PPP$ (per capita per day)"
	label var mean              "Average monthly per capita income/consumption in PPP$"
	label var headcount         "Poverty Headcount"
	label var povgap            "Poverty Gap"
	label var povgapsqr         "Squared poverty gap"
	label var population        "Population in year"
	//------------ Convert to monthly values
	
	replace mean = mean * (360/12)
	
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



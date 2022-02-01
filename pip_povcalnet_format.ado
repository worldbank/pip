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
syntax [anything(name=type)]  ///
[,                             	/// 
pause                           /// 
] 

if ("`pause'" == "pause") pause on
else                      pause off

version 16.0


noi disp in red "Warning: option {it:povcalnet_format} is intended only to " _n ///
"replicate results or to use Stata code that still" _n ///
"executes the deprecated {cmd:povcalnet} command."

/*==================================================
1:  country data 
==================================================*/
ren reporting_year requestyear
ren reporting_pop reqyearpopulation
if ("`type'" == "1") {
	
	local vars1 country_code region_code reporting_level survey_year /*
	*/welfare_type is_interpolated distribution_type poverty_line poverty_gap /*
	*/poverty_severity // reporting_pop
	
	local vars2 countrycode regioncode coveragetype datayear datatype isinterpolated usemicrodata /*
	*/povertyline povgap povgapsqr //population
	
	local i = 0
	foreach var of local vars1 {
		local ++i
		rename `var' `: word `i' of `vars2''
	}	
	
	keep countrycode countryname regioncode coveragetype requestyear /* 
	 */ datayear datatype isinterpolated usemicrodata /*
   */ ppp povertyline mean headcount povgap povgapsqr watts gini /* 
	 */ median mld polarization reqyearpopulation decile? decile10
	
	order countrycode countryname regioncode coveragetype requestyear /* 
  */	datayear datatype isinterpolated usemicrodata /*
	*/  ppp povertyline mean headcount povgap povgapsqr watts gini /* 
  */	median mld polarization reqyearpopulation decile? decile10
	
	
	* Standardize names with R package	
	local Snames requestyear reqyearpopulation 
	
	local Rnames year population 
	
	local i = 0
	foreach var of local Snames {
		local ++i
		rename `var' `: word `i' of `Rnames''
	}
	
	sort countrycode year coveragetype
	
	//------------ Convert to monthly values
	replace mean = mean * (360/12)
	replace median = median * (360/12)

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
	
	keep requestyear regioncode povertyline mean headcount povgap povgapsqr reqyearpopulation
	order requestyear regioncode povertyline mean headcount povgap povgapsqr reqyearpopulation
	
	local Snames requestyear reqyearpopulation 
	
	local Rnames year population 
	
	local i = 0
	foreach var of local Snames {
		local ++i
		rename `var' `: word `i' of `Rnames''
	}
	
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



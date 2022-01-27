/*==================================================
project:       Interaction with the PIP API at the country level
Author:        R.Andres Castaneda 
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     5 Jun 2019 - 15:12:13
Modification Date:  October, 2021 
Do-file version:    01
References:          
Output:             dta
==================================================*/

/*==================================================
                        0: Program set up
==================================================*/
program define pip_cl, rclass
syntax ,   server(string)        ///
           handle(string)        ///
          [                       ///
           country(string)       ///
           year(string)          ///
           povline(numlist)      ///
           ppp(numlist)          ///
           coverage(string)      /// 
           clear                 ///
           pause                 /// 
           iso                   /// 
           noDIPSQuery           /// 
         ]

version 16.0

if ("`pause'" == "pause") pause on
else                      pause off

qui {
/*==================================================
           conditions and setup 
==================================================*/


local base = "`server'/`handle'/pip"


if ("`povline'" == "")  local povline  1.9
if ("`ppp'" == "")      local ppp      -1
if ("`coverage'" == "") local coverage -1

*---------- download guidance data
pip_info, clear justdata `pause'

cwf _pip_lkup

levelsof country_code, local(countries) clean
if (lower("`country'") != "all") {

	local uniq_country : list uniq country
	
	local ncountries: list uniq_country  - countries
	local avai_country: list uniq_country  & countries
	
	local countries:  list country | avai_country

}

if ("`ncountries'" != "") {
	if wordcount("`ncountries'") == 1 local be "is"
	if wordcount("`ncountries'") > 1 local be "are"

	noi disp as err "Warning: " _c
	noi disp as input `"`ncountries' `be' not part of the country list"' /* 
	 */ _n "available in PIP. See {stata povcalnet info}"
	 
}	

if ("`countries'" == "") {
	noi disp in red "None of the countries provided in {it:country()} is available in PIP"
	error
}

*---------- alternative macros
local ct = "`countries'" 
local pl = "`povline'" 
local pp = "`ppp'"     
local yr = "`year'"    
local cv = "`coverage'"

/*==================================================
              1: Evaluate parameters
==================================================*/

*----------1.1: counting words

local nct = wordcount("`ct'")  // number of countries
local npl = wordcount("`pl'")  // number of poverty lines
local npp = wordcount("`pp'")  // number of PPP values
local nyr = wordcount("`yr'")  // number of years
local ncv = wordcount("`cv'")  // number of coverage

matrix A = `nct' \ `npl' \ `npp' \ `nyr' \ `ncv'
mata:  A = st_matrix("A"); /* 
 */    B = ((A :== A[1]) + (A :== 1) :>= 1); /* 
 */    st_local("m", strofreal(mean(B)))

if (`m' != 1) {
	noi disp in r "number of elements in options {it:povline(), ppp(), year()} and " _n /* 
	 */ "{it:coverage()} must be equal to 1 or to the number of countries in option {it:country()}"
	 error 197
}

*----------1.2: Expand macros of size one
local n = _n
foreach o in pl pp yr cv {
	if (`n`o'' == 1) {
		local `o': disp _dup(`nct') " ``o'' "
	}
}

/*==================================================
            2:  Download data
==================================================*/

*----------2.1: download data
tempfile clfile
local queryfull "`base'?format=csv"
return local queryfull = "`queryfull'"

local rc = 0
cap copy "`queryfull'" `clfile'
if (_rc == 0) {
	cap insheet using `clfile', clear name
	if (_rc != 0) local rc "in"
} 
else {
	local rc "copy"
} 

*---------- 2.2 create filter conditions in loop
local j = 0
local n = 1
local kquery = ""   // whole filter condition to extract data
foreach ict of local countries {
	
	* corresponding element to each country
	foreach o in pl yr pp cv {
		local i`o': word `n' of ``o''
	}
	
	*---------- coverage
	if inlist("`icv'", "-1", "all") & ("`ipp'" == "-1") {
		local kquery "`kquery' | (country_code == "`ict'" & reporting_year == `iyr')"
		return local kquery_`j' = "`kquery_`j''"
	} 
	else if inlist("`icv'", "-1", "all") & ("`ipp'" != "-1") {
		local kquery "`kquery' | (country_code == "`ict'"  & reporting_year == `iyr'  & ppp ==  "`ipp'")"
		return local kquery_`j' = "`kquery_`j''"
	}
	else if !inlist("`icv'", "-1", "all") & ("`ipp'" == "-1") {
		local kquery "`kquery' | (country_code == "`ict'"  & reporting_year == `iyr'  & survey_coverage == "`icv'")"
		return local kquery_`j' = "`kquery_`j''"
	} 
	else {
		local kquery "`kquery' | (country_code == "`ict'"  & reporting_year == `iyr'  & ppp ==  "`ipp'"  & survey_coverage == "`icv'")"
		return local kquery_`j' = "`kquery_`j''"
	}
	
	local ++j
	local ++n
} 

local kquery : subinstr  local kquery  "|" " "
keep if `kquery'

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




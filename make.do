// the 'make.do' file is automatically created by 'github' package.
// execute the code below to generate the package installation files.
// DO NOT FORGET to update the version of the package, if changed!
// for more information visit http://github.com/haghish/github

make pip, replace toc pkg                         ///  readme
		version(0.3.3)                          ///
    license("MIT")                                                          ///
    author("R.Andres Castaneda")                                            ///
    affiliation("The World Bank")                                           ///
    email("acastanedaa@worldbank.org")                                      ///
    url("")                                                                 ///
    title("Poverty and Inequality Platform Stata wrapper")                  ///
    description("World Bank PIP API Stata wrapper")                         ///
    install("pip.ado;pip.sthlp;pip_cl.ado;pip_clean.ado;pip_countries.sthlp;pip_drop.ado;pip_examples.ado;pip_info.ado;pip_new_session.ado;pip_povcalnet_format.ado;pip_query.ado;pip_set_server.ado;pip_cache.ado;pip_versions.ado;pip_tables.ado;pip_cleanup.ado") ///
    ancillary("")                                                         


* ------------------------------------------------------------------------------
* Testing basic examples
* ------------------------------------------------------------------------------
global options = "server(dev) clear"
cap frame drop tmpfr
frame create tmpfr strL cmd
frame post tmpfr ("pip versions")  // first command 
frame post tmpfr ("pip, country(col arg) year(last) ${options}") // load latest available survey-year estimates for sampel countries
frame post tmpfr ("pip, info ${options}") // load clickable menu
frame post tmpfr ("pip, country(all) coverage('urban') ${options}") // load only urban coverage level
frame post tmpfr ("pip, country(COL BRA ARG IND) year(2015) ${options}") // country estimation at $1.9 in 2015. Since there are no surveys in ARG and IND in 2015, results are loaded for COL and BRA
frame post tmpfr ("pip, country(COL BRA ARG IND) year(2015) fillgaps ${options}") // filling gaps for ARG and IND. Only works for reference years
frame post tmpfr ("pip wb, year(2015) ${options}") // World Bank aggregation
frame post tmpfr ("pip wb, region(SAR LAC) ${options}") 
frame post tmpfr ("pip wb, ${options}") 
*frame post tmpfr ("pip cl, country(COL BRA ARG IND) year(2011) clear coverage('national national urban national') ${options}") 
frame post tmpfr ("pip, region(EAP) year(all) ${options}")
frame post tmpfr ("pip tables, ${options}")
frame post tmpfr ("pip tables, table(countries) ${options}")
frame post tmpfr ("pip tables, table(country_coverage) ${options}")
frame post tmpfr ("pip tables, table(cpi) ${options}")
frame post tmpfr ("pip tables, table(decomposition) ${options}")
frame post tmpfr ("pip tables, table(dictionary) ${options}")
frame post tmpfr ("pip tables, table(framework) ${options}")
frame post tmpfr ("pip tables, table(gdp) ${options}")
frame post tmpfr ("pip tables, table(incgrp_coverage) ${options}")
frame post tmpfr ("pip tables, table(indicators) ${options}")
frame post tmpfr ("pip tables, table(interpolated_means) ${options}")
frame post tmpfr ("pip tables, table(pce) ${options}")
frame post tmpfr ("pip tables, table(pop) ${options}")
frame post tmpfr ("pip tables, table(pop_region) ${options}")
frame post tmpfr ("pip tables, table(poverty_lines) ${options}")
frame post tmpfr ("pip tables, table(ppp) ${options}")
frame post tmpfr ("pip tables, table(region_coverage) ${options}")
frame post tmpfr ("pip tables, table(regions) ${options}")
frame post tmpfr ("pip tables, table(survey_means) ${options}")


frame tmpfr {
	global N = _N
}

forvalues i = 1/$N {
	local cmd = _frval(tmpfr, cmd, `i')
	cap `cmd'
	if _rc noi disp "`cmd' - NOT WORKING"
}

*******************************************************************************

// Compare dev and prod versions

cap clear all 
cap pip cleanup
	
// Version 
pip version

// setup dev options	
global options = "server(dev) clear"

// 1- compare country level estimates for ppp 2011
* ppp 2011
cap pip, povline(1.9 3.2 5.5) ppp_year(2011) clear
cap sort country_code region_code year welfare_type poverty_line reporting_level
cap duplicates report country_code region_code year welfare_type poverty_line reporting_level
cap assert r(unique_value)==r(N)

tempfile prod_data
cap save `prod_data', replace

cap pip, povline(1.9 3.2 5.5) ppp_year(2011) ${options} 
cap sort country_code region_code year welfare_type poverty_line reporting_level
cap duplicates report country_code region_code year welfare_type poverty_line reporting_level
cap assert r(unique_value)==r(N)

cap cf _all using `prod_data'

if _rc noi disp as err "Country level estimates of PROD and DEV don't match"


*******************************************************************************/

// 2- wb aggregate estimates for poverty line 1.9, 3.2, and 5.5

* PPP round 2011
cap pip wb, povline(1.9 3.2 5.5) ppp_year(2011) clear
cap sort region_name year poverty_line
cap duplicates report region_name year poverty_line
cap assert r(unique_value)==r(N)

tempfile prod_data
cap save `prod_data', replace

cap pip ${options} 
cap sort region_name year poverty_line
cap duplicates report region_name year poverty_line
cap assert r(unique_value)==r(N)

cap	cap cf _all using `prod_data'

if _rc noi disp as err "WB aggregate data of PROD and DEV don't match"

*******************************************************************************
* 3- filling gap data for all countries

* PPP round 2011
cap pip, fillgaps povline(1.9 3.2 5.5) ppp_year(2011) clear
cap sort country_code region_code year welfare_type poverty_line reporting_level
cap duplicates report country_code region_code year welfare_type poverty_line reporting_level
cap assert r(unique_value)==r(N)

tempfile prod_data
cap save `prod_data', replace

cap pip, ${options} 
cap sort country_code region_code year welfare_type poverty_line reporting_level
cap duplicates report country_code region_code year welfare_type poverty_line reporting_level
cap assert r(unique_value)==r(N)	
	
cap cf _all using `prod_data'
if _rc noi disp as err "Fillgaps data of PROD and DEV don't match"

*******************************************************************************
* auxilary tables
* 1) countries
cap pip tables, table(countries) clear
cap sort country_code
cap duplicates report country_code
cap assert r(unique_value)==r(N)

tempfile prod_data
cap save `prod_data', replace

cap pip tables, table(countries) ${options}
cap sort country_code
cap duplicates report country_code
cap assert r(unique_value)==r(N)

cap cf _all using `prod_data'
	
if _rc noi disp as err "Auxilary tables - countries data of PROD and DEV don't match" 

*******************************************************************************
* 2) country coverage
cap	pip tables, table(country_coverage) clear
cap	sort country_code reporting_year pop_data_level
cap duplicates report country_code reporting_year pop_data_level
cap assert r(unique_value)==r(N)

tempfile prod_data
cap save `prod_data', replace

cap pip tables, table(country_coverage) ${options}
cap sort country_code reporting_year pop_data_level
cap duplicates report country_code reporting_year pop_data_level
cap assert r(unique_value)==r(N)

cap cf _all using `prod_data'

if _rc noi disp as err "Auxilary tables - country_coverage data of PROD and DEV don't match" 

*******************************************************************************
* 3) cpi
cap	pip tables, table(cpi) clear
cap	sort country_code data_level
cap duplicates report country_code data_level
cap assert r(unique_value)==r(N)

tempfile prod_data
cap save `prod_data', replace

cap pip tables, table(cpi) ${options}
cap sort country_code data_level
cap duplicates report country_code data_level
cap assert r(unique_value)==r(N)

cap cf _all using `prod_data'

if _rc noi disp as err "Auxilary tables - cpi data of PROD and DEV don't match"

*******************************************************************************
* 4) decomposition
cap	pip tables, table(decomposition) clear
cap	sort variable_code variable_values
cap duplicates report variable_code variable_values
cap assert r(unique_value)==r(N)

tempfile prod_data
cap save `prod_data', replace

cap pip tables, table(decomposition) ${options}
cap	sort variable_code variable_values
cap duplicates report variable_code variable_values
cap assert r(unique_value)==r(N)

cap cf _all using  `prod_data'

if _rc noi disp as err "Auxilary tables - decomposition data of PROD and DEV don't match"

*******************************************************************************
* 5) dictionary
cap pip tables, table(dictionary) clear
tempfile prod_data
cap save `prod_data', replace

cap pip tables, table(dictionary) ${options}
cap cf _all using `prod_data'

if _rc noi disp as err "Auxilary tables - dictionary data of PROD and DEV don't match"

*******************************************************************************
* 6) framework
cap pip tables, table(framework) clear
cap sort country_code year survey_coverage welfare_type
cap duplicates report country_code year survey_coverage welfare_type
cap assert r(unique_value)==r(N)

tempfile prod_data
cap save `prod_data', replace

cap	pip tables, table(framework) ${options}
cap	sort country_code year survey_coverage welfare_type
cap duplicates report country_code year survey_coverage welfare_type
cap assert r(unique_value)==r(N)

cap cf _all using `prod_data'
	
if _rc noi disp as err "Auxilary tables - framework data of PROD and DEV don't match"

*******************************************************************************
* 7) gdp
cap pip tables, table(gdp) clear
cap	sort country_code data_level
cap duplicates report country_code data_level
cap assert r(unique_value)==r(N)

tempfile prod_data
cap save `prod_data', replace

cap pip tables, table(gdp) ${options}
cap	sort country_code data_level
cap duplicates report country_code data_level
cap assert r(unique_value)==r(N)

cap cf _all using `prod_data'

if _rc noi disp as err "Auxilary tables - gdp data of PROD and DEV don't match" 

*******************************************************************************
* 8) incgrp_coverage
cap	pip tables, table(incgrp_coverage) clear
cap	sort reporting_year
cap duplicates report reporting_year
cap assert r(unique_value)==r(N)

tempfile prod_data
cap save `prod_data', replace

cap pip tables, table(incgrp_coverage) ${options}
cap sort reporting_year
cap duplicates report reporting_year
cap assert r(unique_value)==r(N)

cap cf _all using  `prod_data'

if _rc noi disp as err "Auxilary tables - incgrp_coverage data of PROD and DEV don't match"

*******************************************************************************
* 9) indicators ****
cap pip tables, table(indicators) clear
tempfile prod_data
cap save `prod_data', replace

cap pip tables, table(indicators) clear
cap cf _all using "`output'table_indicators.dta"

if _rc noi disp as err "Auxilary tables - indicators data of PROD and DEV don't match"

*******************************************************************************
* 10) interpolated_means
cap pip tables, table(interpolated_means) clear
cap	sort survey_id interpolation_id
cap duplicates report survey_id interpolation_id
cap assert r(unique_value)==r(N)

tempfile prod_data
cap save `prod_data', replace

cap pip tables, table(interpolated_means) ${options}
cap sort survey_id interpolation_id
cap duplicates report survey_id interpolation_id
cap assert r(unique_value)==r(N)

cap cf _all using `prod_data'
	
if _rc noi disp as err "Auxilary tables - interpolated_means data of PROD and DEV don't match"

*******************************************************************************
* 11) pce
cap pip tables, table(pce) clear
cap	sort  country_code data_level
cap duplicates report country_code data_level
cap assert r(unique_value)==r(N)

tempfile prod_data
cap save `prod_data', replace

cap pip tables, table(pce) ${options}
cap sort country_code data_level
cap duplicates report country_code data_level
cap assert r(unique_value)==r(N)

cap cf _all using `prod_data'
	
if _rc noi disp as err "Auxilary tables - pce data of PROD and DEV don't match"

*******************************************************************************
* 12) pop
cap pip tables, table(pop) clear
cap	sort country_code data_level
cap duplicates report country_code data_level
cap assert r(unique_value)==r(N)

tempfile prod_data
cap save `prod_data', replace


cap pip tables, table(pop) ${options}	
cap sort country_code data_level
cap duplicates report country_code data_level
cap assert r(unique_value)==r(N)

cap cf _all using `prod_data'

if _rc noi disp as err "Auxilary tables - population data of PROD and DEV don't match"

*******************************************************************************
* 13) pop_region
cap	pip tables, table(pop_region) clear	
cap	sort region_code reporting_year
cap duplicates report region_code reporting_year
cap assert r(unique_value)==r(N)

tempfile prod_data
cap save `prod_data', replace

cap pip tables, table(pop_region) ${options}	
cap	sort region_code reporting_year
cap	duplicates report region_code reporting_year
cap assert r(unique_value)==r(N)

cap cf _all using `prod_data'
	
if _rc noi disp as err "Auxilary tables - pop_region data of PROD and DEV don't match"

*******************************************************************************
* 14) poverty_lines
cap pip tables, table(poverty_lines) clear
cap	sort name
cap duplicates report name
cap assert r(unique_value)==r(N)

tempfile prod_data
cap save `prod_data', replace

cap	pip tables, table(poverty_lines) ${options}
cap	sort name
cap duplicates report name
cap assert r(unique_value)==r(N)

cap cf _all using `prod_data'
	
if _rc noi disp as err "Auxilary tables - poverty_lines data of PROD and DEV don't match"

*******************************************************************************
* 15) ppp
cap	pip tables, table(ppp) clear	
cap	sort country_code data_level
cap duplicates report country_code data_level
cap assert r(unique_value)==r(N)

tempfile prod_data
cap save `prod_data', replace

cap	pip tables, table(ppp) ${options}	
cap	sort country_code data_level
cap	duplicates report country_code data_level
cap assert r(unique_value)==r(N)

cap cf _all using `prod_data'
	
if _rc noi disp as err "Auxilary tables - ppp data of PROD and DEV don't match"

*******************************************************************************
* 16) regions
cap	pip tables, table(regions) clear
cap	sort region_code
cap duplicates report region_code
cap assert r(unique_value)==r(N)

tempfile prod_data
cap save `prod_data', replace

cap	pip tables, table(regions) ${options}	
cap	sort region_code
cap	duplicates report region_code
cap assert r(unique_value)==r(N)

cap cf _all using `prod_data'
	
if _rc noi disp as err "Auxilary tables - regions data of PROD and DEV don't match"

*******************************************************************************
* 17) regions_coverage
cap	pip tables, table(region_coverage) clear	
cap	sort reporting_year pcn_region_code
cap duplicates report reporting_year pcn_region_code
cap assert r(unique_value)==r(N)

tempfile prod_data
cap save `prod_data', replace

cap	pip tables, table(region_coverage) ${options}
cap	sort reporting_year pcn_region_code
cap	duplicates report reporting_year pcn_region_code	
cap assert r(unique_value)==r(N)

cap cf _all using `prod_data'
	
if _rc noi disp as err "Auxilary tables - region_coverage data of PROD and DEV don't match" 
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
global options = "server(dev)"

// 1- compare country level estimates for ppp 2011
* ppp 2011
qui {
	local cmd "povline(1.9 3.2 5.5) ppp_year(2011) clear"
	pip, `cmd' 
	sort country_code region_code year welfare_type poverty_line reporting_level
	duplicates report country_code region_code year welfare_type poverty_line reporting_level
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in country estimate (PROD) data"
	
	tempfile prod_data
	save `prod_data', replace

	pip, `cmd' ${options} 
	sort country_code region_code year welfare_type poverty_line reporting_level
	duplicates report country_code region_code year welfare_type poverty_line reporting_level
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in country estimate (DEV) data"
	
	cap cf _all using `prod_data'

	if _rc noi disp as err "Country level estimates of PROD and DEV don't match"
}

*******************************************************************************/

// 2- wb aggregate estimates for poverty line 1.9, 3.2, and 5.5

* PPP round 2011
qui {
	local cmd "wb, povline(1.9 3.2 5.5) ppp_year(2011) clear"
	pip `cmd'
	sort region_name year poverty_line
	duplicates report region_name year poverty_line
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in WB aggregate data (PROD) data"
	
	tempfile prod_data
	save `prod_data', replace

	pip `cmd' ${options} 
	sort region_name year poverty_line
	duplicates report region_name year poverty_line
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in WB aggregate data (DEV) data"
	
	cap	cf _all using `prod_data'
	if _rc noi disp as err "WB aggregate data of PROD and DEV don't match"
}


*******************************************************************************
* 3- filling gap data for all countries

* PPP round 2011
qui {
	local cmd "fillgaps povline(1.9 3.2 5.5) ppp_year(2011) clear"
	pip, `cmd'
	sort country_code region_code year welfare_type poverty_line reporting_level
	duplicates report country_code region_code year welfare_type poverty_line reporting_level
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in fillgaps data (PROD) data"

	tempfile prod_data
	save `prod_data', replace

	pip, `cmd' ${options} 
	sort country_code region_code year welfare_type poverty_line reporting_level
	duplicates report country_code region_code year welfare_type poverty_line reporting_level
	cap assert r(unique_value)==r(N)	
	if _rc noi disp as err "Duplicate records in fillgaps data (DEV) data"
	
	cap	cf _all using `prod_data'
	if _rc noi disp as err "Fillgaps data of PROD and DEV don't match"
}


*******************************************************************************
* auxilary tables
* 1) countries
qui {
	local cmd "tables, table(countries) clear"
	pip `cmd'
	sort country_code
	duplicates report country_code
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - countries data (PROD) data"

	tempfile prod_data
	save `prod_data', replace

	pip `cmd' ${options}
	sort country_code
	duplicates report country_code
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - countries data (DEV) data"

	cap cf _all using `prod_data'
		
	if _rc noi disp as err "Auxilary tables - countries data of PROD and DEV don't match"
}

*******************************************************************************
* 2) country coverage
qui {
	local cmd "tables, table(country_coverage) clear"
	pip `cmd'
	sort country_code reporting_year pop_data_level
	duplicates report country_code reporting_year pop_data_level
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - country_coverage data (PROD) data"

	tempfile prod_data
	save `prod_data', replace

	pip `cmd' ${options}
	sort country_code reporting_year pop_data_level
	duplicates report country_code reporting_year pop_data_level
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - country_coverage data (DEV) data"

	cap cf _all using `prod_data'

	if _rc noi disp as err "Auxilary tables - country_coverage data of PROD and DEV don't match" 
}

*******************************************************************************
* 3) cpi
qui {
	local cmd "tables, table(cpi) clear"
	pip `cmd'
	sort country_code data_level
	duplicates report country_code data_level
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - cpi data (PROD) data"

	tempfile prod_data
	cap save `prod_data', replace

	pip `cmd' ${options}
	sort country_code data_level
	duplicates report country_code data_level
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - cpi data (DEV) data"

	cap cf _all using `prod_data'

	if _rc noi disp as err "Auxilary tables - cpi data of PROD and DEV don't match" 
}

*******************************************************************************
* 4) decomposition
qui {
	local cmd "tables, table(decomposition) clear"
	pip `cmd'
	sort variable_code variable_values
	duplicates report variable_code variable_values
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - decomposition data (PROD) data"

	tempfile prod_data
	cap save `prod_data', replace

	pip `cmd' ${options}
	sort variable_code variable_values
	duplicates report variable_code variable_values
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - decomposition data (DEV) data"

	cap cf _all using  `prod_data'

	if _rc noi disp as err "Auxilary tables - decomposition data of PROD and DEV don't match"
}

*******************************************************************************
* 5) dictionary
qui {
	local cmd " tables, table(dictionary) clear"
	pip `cmd'
	tempfile prod_data
	save `prod_data', replace

	pip `cmd' ${options}
	cap cf _all using `prod_data'

	if _rc noi disp as err "Auxilary tables - dictionary data of PROD and DEV don't match"
}


*******************************************************************************
* 6) framework
qui {
	local cmd "tables, table(framework) clear"
	pip `cmd'
	sort country_code year survey_coverage welfare_type
	duplicates report country_code year survey_coverage welfare_type
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - framework data (PROD) data"

	tempfile prod_data
	cap save `prod_data', replace

	pip `cmd' ${options}
	sort country_code year survey_coverage welfare_type
	duplicates report country_code year survey_coverage welfare_type
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - framework data (DEV) data"

	cap cf _all using  `prod_data'

	if _rc noi disp as err "Auxilary tables - framework data of PROD and DEV don't match"
}


*******************************************************************************
* 7) gdp
qui {
	local cmd "tables, table(gdp) clear"
	pip `cmd'
	sort country_code data_level
	duplicates report country_code data_level
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - gdp data (PROD) data"

	tempfile prod_data
	cap save `prod_data', replace

	pip `cmd' ${options}
	sort country_code data_level
	duplicates report country_code data_level
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - gdp data (DEV) data"

	cap cf _all using  `prod_data'

	if _rc noi disp as err "Auxilary tables - gdp data of PROD and DEV don't match"
}

*******************************************************************************
* 8) incgrp_coverage
qui {
	local cmd "tables, table(incgrp_coverage) clear"
	pip `cmd'
	sort reporting_year
	duplicates report reporting_year
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - incgrp_coverage data (PROD) data"

	tempfile prod_data
	cap save `prod_data', replace

	pip `cmd' ${options}
	sort reporting_year
	duplicates report reporting_year
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - incgrp_coverage data (DEV) data"

	cap cf _all using  `prod_data'

	if _rc noi disp as err "Auxilary tables - incgrp_coverage data of PROD and DEV don't match"
}

*******************************************************************************
* 9) indicators ****
qui {
	local cmd " tables, table(indicators) clear"
	pip `cmd'
	tempfile prod_data
	save `prod_data', replace

	pip `cmd' ${options}
	cap cf _all using `prod_data'

	if _rc noi disp as err "Auxilary tables - indicators data of PROD and DEV don't match"
}

*******************************************************************************
* 10) interpolated_means
qui {
	local cmd "tables, table(interpolated_means) clear"
	pip `cmd'
	sort survey_id interpolation_id
	duplicates report survey_id interpolation_id
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - interpolated_means data (PROD) data"

	tempfile prod_data
	cap save `prod_data', replace

	pip `cmd' ${options}
	sort survey_id interpolation_id
	duplicates report survey_id interpolation_id
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - interpolated_means data (DEV) data"

	cap cf _all using  `prod_data'

	if _rc noi disp as err "Auxilary tables - interpolated_means data of PROD and DEV don't match"
}

*******************************************************************************
* 11) pce
qui {
	local cmd "tables, table(pce) clear"
	pip `cmd'
	sort country_code data_level
	duplicates report country_code data_level
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - pce data (PROD) data"

	tempfile prod_data
	cap save `prod_data', replace

	pip `cmd' ${options}
	sort country_code data_level
	duplicates report country_code data_level
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - pce data (DEV) data"

	cap cf _all using  `prod_data'

	if _rc noi disp as err "Auxilary tables - pce data of PROD and DEV don't match"
}

*******************************************************************************
* 12) pop
qui {
	local cmd "tables, table(pop) clear"
	pip `cmd'
	sort country_code data_level
	duplicates report country_code data_level
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - pop data (PROD) data"

	tempfile prod_data
	cap save `prod_data', replace

	pip `cmd' ${options}
	sort country_code data_level
	duplicates report country_code data_level
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - pop data (DEV) data"

	cap cf _all using  `prod_data'

	if _rc noi disp as err "Auxilary tables - pop data of PROD and DEV don't match"
}

*******************************************************************************
* 13) pop_region
qui {
	local cmd "tables, table(pop_region) clear"
	pip `cmd'
	sort region_code reporting_year
	duplicates report region_code reporting_year
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - pop_region data (PROD) data"

	tempfile prod_data
	cap save `prod_data', replace

	pip `cmd' ${options}
	sort region_code reporting_year
	duplicates report region_code reporting_year
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - pop_region data (DEV) data"

	cap cf _all using  `prod_data'

	if _rc noi disp as err "Auxilary tables - pop_region data of PROD and DEV don't match"
}

*******************************************************************************
* 14) poverty_lines
qui {
	local cmd "tables, table(poverty_lines) clear"
	pip `cmd'
	sort name
	duplicates report name
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - poverty_lines data (PROD) data"

	tempfile prod_data
	cap save `prod_data', replace

	pip `cmd' ${options}
	sort name
	duplicates report name
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - poverty_lines data (DEV) data"

	cap cf _all using  `prod_data'

	if _rc noi disp as err "Auxilary tables - poverty_lines data of PROD and DEV don't match"
}

*******************************************************************************
* 15) ppp
qui {
	local cmd "tables, table(ppp) clear"
	pip `cmd'
	sort country_code data_level
	duplicates report country_code data_level
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - ppp data (PROD) data"

	tempfile prod_data
	cap save `prod_data', replace

	pip `cmd' ${options}
	sort country_code data_level
	duplicates report country_code data_level
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - ppp data (DEV) data"

	cap cf _all using  `prod_data'

	if _rc noi disp as err "Auxilary tables - ppp data of PROD and DEV don't match"
}

*******************************************************************************
* 16) regions
qui {
	local cmd "tables, table(regions) clear"
	pip `cmd'
	sort region_code
	duplicates report region_code
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - regions data (PROD) data"

	tempfile prod_data
	cap save `prod_data', replace

	pip `cmd' ${options}
	sort region_code
	duplicates report region_code
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - regions data (DEV) data"

	cap cf _all using  `prod_data'

	if _rc noi disp as err "Auxilary tables - regions data of PROD and DEV don't match"
}

*******************************************************************************
* 17) regions_coverage
qui {
	local cmd "tables, table(region_coverage) clear"
	pip `cmd'
	sort reporting_year pcn_region_code
	duplicates report reporting_year pcn_region_code
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - regions_coverage data (PROD) data"

	tempfile prod_data
	cap save `prod_data', replace

	pip `cmd' ${options}
	sort reporting_year pcn_region_code
	duplicates report reporting_year pcn_region_code
	cap assert r(unique_value)==r(N)
	if _rc noi disp as err "Duplicate records in auxilary tables - regions_coverage data (DEV) data"

	cap cf _all using  `prod_data'

	if _rc noi disp as err "Auxilary tables - regions_coverage data of PROD and DEV don't match"
}
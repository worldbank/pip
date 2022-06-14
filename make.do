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

* display available versions of pip data 
cap pip versions
if (_rc) {
	disp as err "pip versions - not working"
	exit
}
* 1.1. Load latest available survey-year estimates for Colombia and Argentina

cap pip, country(col arg) year(last) ${options}
if (_rc) {
	disp as err "pip, country(col arg) year(last) server(dev) clear - not working"
	exit
}
* 1.2. Load clickable menu

cap pip, info ${options}
if (_rc) {
	disp as err "pip, info server(dev) clear - not working"
	exit
}
* 1.3. Load only urban coverage level

cap pip, country(all) coverage("urban") ${options}
if (_rc) {
	disp as err "pip, country(all) coverage('urban') server(dev) clear - not working"
	exit
}
* 2. inIllustration of differences between queries  
* 2.1. Country estimation at $1.9 in 2015. Since there are no surveys in ARG and IND in 2015, results are loaded for COL and BRA
cap pip, country(COL BRA ARG IND) year(2015) ${options}
if (_rc) {
	disp as err "pip, country(COL BRA ARG IND) year(2015) server(dev) clear - not working"
	exit
}
* 2.2. fill-gaps. Filling gaps for ARG and IND. Only works for reference years.
cap pip, country(COL BRA ARG IND) year(2015) fillgaps ${options}
if (_rc) {
	disp as err "pip, country(COL BRA ARG IND) year(2015) fillgaps server(dev) clear - not working"
	exit
}
* 2.4. World Bank aggregation (country() is not available)
cap pip wb, year(2015) ${options}
if (_rc) {
	disp as err "pip wb, year(2015) server(dev) clear - not working"
	exit
}

cap pip wb, region(SAR LAC) ${options}
if (_rc) {
	disp as err "pip wb, region(SAR LAC) server(dev) clear - not working"
	exit
} 

cap pip wb, ${options}
if (_rc) {
	disp as err "pip wb, server(dev) clear - not working"
	exit
}

/* 2.5. One-on-one query.
cap pip cl, country(COL BRA ARG IND) year(2011) clear coverage("national national urban national")
if (_rc) {
	disp as err "cap pip versions - not working"
}
*/

* region 
cap pip, region(EAP) year(all) ${options} 
if (_rc) {
	disp as err "pip, region(EAP) year(all) server(dev) clear  - not working"
	exit
}

* auxilary tables
cap pip tables, ${options} 
if (_rc) {
	disp as err "pip tables, server(dev) clear  - not working"
	exit
}

* check individual auxilary tables
local tblist "countries country_coverage cpi decomposition dictionary framework gdp incgrp_coverage indicators interpolated_means pce pop pop_region poverty_lines ppp region_coverage regions survey_means"
foreach tbl of local tblist {
	cap pip tables, ${options} table(`tbl')
	if (_rc) {
		disp as err "pip tables, server(dev) clear table(`tbl') - not working"
	exit
	}
}


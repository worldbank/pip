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
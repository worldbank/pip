// the 'make.do' file is automatically created by 'github' package.
// execute the code below to generate the package installation files.
// DO NOT FORGET to update the version of the package, if changed!
// for more information visit http://github.com/haghish/github

*##s

cap program drop getfiles
program define getfiles, rclass

args mask

local f2add: dir . files "`mask'", respectcase

foreach a of local f2add {
	local as "`as' `a'"
}
local as = trim("`as'")
local as: subinstr local as " " ";", all

return local files = "`as'"
end


cd "c:/Users/`c(username)'/OneDrive - WBG/WorldBank/DECDG/PIP/pip"
getfiles "*.ado"
local as = "`r(files)'"

getfiles "*.sthlp"
local hs = "`r(files)'"

getfiles "*.mata"
local ms = "`r(files)'"


getfiles "*.dlg"
local ds = "`r(files)'"


local toins  "`as';`hs';`ms';`ds'"
disp "`toins'"


make pip, replace toc pkg                                  ///  readme
		version(0.10.8)                                        ///
    license("MIT")                                         ///
    author("R.Andres Castaneda")                           ///
    affiliation("The World Bank")                          ///
    email("acastanedaa@worldbank.org")                     ///
    url("")                                                ///
    title("Poverty and Inequality Platform Stata wrapper") ///
    description("World Bank PIP API Stata wrapper")        ///
    install("`toins'")                                     ///
    ancillary("")                                                         

*##e


* ------------------------------------------------------------------------------
* Testing basic examples
* ------------------------------------------------------------------------------
clear all
pip cleanup

global options = "server(qa) clear"
cap frame drop tmpfr
frame create tmpfr strL cmd
frame post tmpfr ("pip versions")  // first command 
frame post tmpfr ("pip, country(col arg) year(last) ${options}") // load latest available survey-year estimates for sampel countries
frame post tmpfr ("pip, info ${options}") // load clickable menu
frame post tmpfr ("pip, country(all) coverage(urban) ${options}") // load only urban coverage level
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

// Version 
pip version

// setup dev options	
global options = "server(qa)"

// Function to avoid errors and scale up check

cap program drop pip_prod_dev
program define pip_prod_dev
syntax , ///
cmd(string) ///
sorting_vars(string) ///
[ ///
test_label(string) ///
test_server(string) ///
main_server(string)  ///
disp                 ///
* /// pip options
]

// Conditions
qui {
	if ("`test_label'" == "") {
		local test_label "Unknown"
	}
	
	if ("`test_server'" == "") {
		local test_server "dev"
	}
	
	if ("`main_server'" == "") {
		local main_server "prod"
		
	}
	// tests
	pip `cmd' `options' server(`main_server')
	duplicates report `sorting_vars'
	cap assert r(unique_value)==r(N)
	if _rc {
		noi disp as err "Duplicate records in `test_label' (server `main_server') data"
		exit
	}
	
	sort `sorting_vars'
	tempfile main_data
	save `main_data'
	
	pip `cmd' `options' server(`test_server') 
	duplicates report `sorting_vars'
	cap assert r(unique_value)==r(N)
	if _rc {
		noi disp as err "Duplicate records in `test_label' (server `test_server') data"
		exit
	}
	
	sort `sorting_vars'
	if ("`disp'" == "") {
		cap cf _all using `main_data'
		if _rc {
			noi disp as err "`test_label' of `main_server' and `test_server' don't match"
			
			noi disp "Display details " `"{stata `"pip_prod_dev `0' disp"':here}"'
		}
		
	}
	else {
		noi cf _all using `main_data', verbose all
	}
}

end  

// 1- compare country level estimates for ppp 2017
pip_prod_dev, ///
cmd(", povline(2.15 3.65 6.85) clear") ///
sorting_vars("country_code region_code year welfare_type poverty_line reporting_level") ///
test_label("Country estimate") 

// 2- wb aggregate estimates for poverty line 2.15, 3.65, and 6.85
pip_prod_dev, ///
cmd("wb, povline(2.15 3.65 6.85) clear") ///
sorting_vars("region_name year poverty_line") ///
test_label("WB aggregate") 

// 3- filling gap data for all countries
pip_prod_dev, ///
cmd(", fillgaps povline(2.15 3.65 6.85) clear") ///
sorting_vars("country_code region_code year welfare_type poverty_line reporting_level") ///
test_label("Fillgaps data") 

*******************************************************************************
* auxilary tables
// 1) countries
pip_prod_dev, ///
cmd("tables, table(countries) clear") ///
sorting_vars("country_code") ///
test_label("Auxilary table - countries") 

// 2) country coverage
pip_prod_dev, ///
cmd("tables, table(country_coverage) clear") ///
sorting_vars("country_code year pop_data_level") ///
test_label("Auxilary table - country_coverage") 

// 3) cpi
pip_prod_dev, ///
cmd("tables, table(cpi) clear") ///
sorting_vars("country_code data_level") ///
test_label("Auxilary table - cpi") 

// 4) decomposition
pip_prod_dev, ///
cmd("tables, table(decomposition) clear") ///
sorting_vars("variable_code variable_values") ///
test_label("Auxilary table - decomposition") 

// 5) dictionary
pip_prod_dev, ///
cmd("tables, table(dictionary) clear") ///
sorting_vars("variable") ///
test_label("Auxilary table - dictionary") 

// 6) framework
pip_prod_dev, ///
cmd("tables, table(framework) clear") ///
sorting_vars("country_code year survey_coverage welfare_type") ///
test_label("Auxilary table - framework") 

// 7) gdp
pip_prod_dev, ///
cmd("tables, table(gdp) clear") ///
sorting_vars("country_code data_level") ///
test_label("Auxilary table - gdp") 

// 8) incgrp_coverage
pip_prod_dev, ///
cmd("tables, table(incgrp_coverage) clear") ///
sorting_vars("year") ///
test_label("Auxilary table - incgrp_coverage") 

// 9) indicators
pip_prod_dev, ///
cmd("tables, table(indicators) clear") ///
sorting_vars("indicator_code page") ///
test_label("Auxilary table - indicators") 

// 10) interpolated_means
pip_prod_dev, ///
cmd("tables, table(interpolated_means) clear") ///
sorting_vars("survey_id interpolation_id") ///
test_label("Auxilary table - interpolated_means") 

// 11) pce
pip_prod_dev, ///
cmd("tables, table(pce) clear") ///
sorting_vars("country_code data_level") ///
test_label("Auxilary table - pce") 

// 12) pop
pip_prod_dev, ///
cmd("tables, table(pop) clear") ///
sorting_vars("country_code data_level") ///
test_label("Auxilary table - pop") 

// 13) pop_region
pip_prod_dev, ///
cmd("tables, table(pop_region) clear") ///
sorting_vars("region_code year") ///
test_label("Auxilary table - pop_region") 

// 14) poverty_lines
pip_prod_dev, ///
cmd("tables, table(poverty_lines) clear") ///
sorting_vars("name") ///
test_label("Auxilary table - poverty_lines") 

// 15) ppp
pip_prod_dev, ///
cmd("tables, table(ppp) clear") ///
sorting_vars("country_code data_level") ///
test_label("Auxilary table - ppp") 

// 16) regions
pip_prod_dev, ///
cmd("tables, table(regions) clear") ///
sorting_vars("region_code") ///
test_label("Auxilary table - regions") 

// 17) regions_coverage
pip_prod_dev, ///
cmd("tables, table(region_coverage) clear") ///
sorting_vars("year pcn_region_code") ///
test_label("Auxilary table - regions_coverage") 



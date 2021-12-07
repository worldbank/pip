*********************************************************************************
* pip_info                                                          		*
*********************************************************************************


program def pip_info, rclass

version 16.0

syntax    [,       ///
COUntry(string)    ///
REGion             ///
AGGregate          ///
clear              ///
justdata           /// programmers option
pause              /// debugging
server(string)     ///
POVCALNET_format   ///
] 

if ("`pause'" == "pause") pause on
else                      pause off

qui {

	//if ("`clear'" == "") preserve
	
	*---------- API defaults
	
	if "`server'" == ""  {
		local site_name = "api/v1"
		local server   = "https://pipscoreapiqa.worldbank.org"
		*local server = "http://wzlxqpip01.worldbank.org"
		local url = "`server'/`site_name'"
		return local site_name = "`site_name'"
		return local url       = "`url'"
	} 
	else {
		local url "https://pipscoreapiqa.worldbank.org/api/v1"
		*local url "http://wzlxqpip01.worldbank.org/api/v1"
	}
	
	***************************************************
	* 0. Country name
	***************************************************	
	tempfile temp100
	
	local csvfile0  = "`url'/aux?table=countries&format=csv"
	return local csvfile0 = "`csvfile0'"
	
	cap copy "`csvfile0'" `temp100'
	if (_rc != 0 ) {
		noi disp in red "There is a problem accessing country name data." 
	  noi disp in red "to check your connection, copy and paste in your browser the following address:" _n /* 
		*/	_col(4) in w `"`url'/aux?table=countries&format=csv"'
		
		error 
	} 

	import delim using `temp100',  delim(",()") stringc(_all) /* 
	*/                              stripq(yes) varnames(1)  clear 	
	
	keep country_code country_name income_group
	sort country_code
	save `temp100', replace
	
	***************************************************
	* 1. Load guidance database
	***************************************************
	
	tempfile temp1000
	
	local csvfile  = "`url'/pip?format=csv"
	return local csvfile = "`csvfile'"
	
	cap copy "`csvfile'" `temp1000'
	if (_rc != 0 ) {
		noi disp in red "There is a problem accessing the information file." 
	  noi disp in red "to check your connection, copy and paste in your browser the following address:" _n /* 
		*/	_col(4) in w `"`url'/pip?format=csv"'
		
		error 
	} 

	import delim using `temp1000',  delim(",()") stringc(_all) /* 
	*/                              stripq(yes) varnames(1)  clear 
	
	local orgvar region_code survey_coverage reporting_year 
	local newvar wb_region coverage_level reporting_year 
	
	local i = 0
	foreach var of local orgvar {
		local ++i
		rename `var' `: word `i' of `newvar''
	}	

	keep country_code wb_region coverage_level survey_year reporting_year 
	order country_code wb_region coverage_level survey_year reporting_year
	sort country_code

	merge country_code using `temp100'
	collapse _merge, by(country_code country_name wb_region coverage_level reporting_year income_group)
	drop _merge
	order country_code country_name wb_region coverage_level reporting_year income_group
	
	gen year = ""
	tostring reporting_year, replace
	tempfile lkupdata
	save `lkupdata', replace
	levelsof country_code , local(ctry)
	foreach ct of local ctry{
	    preserve
	    levelsof coverage_level, local(cv_area)
		disp `cv_area'
		foreach cv of local cv_area {
		    keep if country_code == "`ct'" & coverage_level == "`cv'"
		    levelsof reporting_year, local(year) sep(,) clean
			disp `year'
			replace year = "`year'" if coverage_level == "`cv'"
			append using `lkupdata'
			save `lkupdata', replace
		}
		restore
	}
			
	use `lkupdata', clear
	drop if year == ""
	sort country_code
	duplicates drop country_code country_name wb_region coverage_level income_group year, force
	drop reporting_year
	
	if ("`justdata'" != "") exit

	***************************************************
	* 2. Inital listing with countries and regions
	***************************************************
	
	if  ("`country'" == "") & ("`region'" == "") {
		qui{
			noi disp in y  _n "{title:Available Surveys}: " in g "Select a country or region" 
			noi disp in y  _n "{title: Countries}"  
			
			quietly levelsof country_code , local(countries) 
			local current_line = 0
			foreach cccc of local countries{
				local current_line = `current_line' + 1 
				
				if ("`povcalnet_format'" != "") {
					local display_this = "{stata pip_info, country(`cccc') clear povcalnet : `cccc'} "
				} 
				else {
				    local display_this = "{stata pip_info, country(`cccc') clear : `cccc'} "
				}				
	
				if (`current_line' < 10) noi display in y `"`display_this'"' _continue 
				else{
					noi display in y `"`display_this'"' 
					local current_line = 0
				}
			}
			
			noi disp in y  _n(2) "{title: Regions}"
			quietly levelsof wb_region, local(regions)
			
			foreach i_reg of local regions{
				local current_line = 0
				if ("`povcalnet_format'" != "") {
					local dipsthis "{stata  pip, region(`i_reg') year(all) aggregate povcalnet clear:`i_reg' }"
				} 
				else {
				    local dipsthis "{stata  pip, region(`i_reg') year(all) aggregate clear:`i_reg' }"
				}	
				noi disp " `dipsthis' " _c
			}
			
			if ("`povcalnet_format'" != "") {
				noi display in y _n "{stata pip_info, region povcalnet povcalnet clear: World Bank regions by year}"
			} 
			else {
				noi display in y _n "{stata pip_info, region clear: World Bank regions by year}"
			}
				
			noi display _n ""
			exit
		}
	}
	
	***************************************************
	* 3. Listing of country surveys
	***************************************************
	
	if  ("`country'" != "") & ("`region'" == "") {
		qui{
			noi disp in y  _n "{title:Available Surveys for `country'}" 	
			preserve
			local country = upper("`country'")
			keep if country_code == "`country'"
			
			local link_detail = "`url'/Docs/CountryDocs/`country'.htm"
			noi display `"{browse "`link_detail'" : Detailed information (browser)}"'
			
			local nobs = _N
			local current_line = 0
			local index_s = 1
			
			foreach n of numlist 1/`nobs' {
				noi disp in y  _n "`=country_name[`index_s']'-`=coverage_level[`index_s']'" 	
				noi disp in y  "survey year" 	
				local years_current = "`=year[`index_s']'"
				local coverage = "`=coverage_level[`index_s']'"
				local years_current: subinstr local years_current "," " ", all 
				local index_s = `index_s'+ 1 
				
				foreach ind_y of local years_current {
					local current_line = `current_line' + 1 
					local ind_y_c=substr("`ind_y'",1,4)
					if ("`povcalnet_format'" != "") {
					    local display_this = "{stata  pip, country(`country') year(`ind_y') coverage(`coverage') povcalnet clear: `ind_y_c'}"
					} 
					else {
						local display_this = "{stata  pip, country(`country') year(`ind_y') coverage(`coverage') clear: `ind_y_c'}"
					}	
				
							
					if (`current_line' < 10) noi display in y `"`display_this'"' _continue 
					else{
						noi display in y `"`display_this'"' 
						local current_line = 0		
					}
				}	
				
				if ("`povcalnet_format'" != "") {
				    noi display `"{stata  pip, country(`country') year(all) coverage(`coverage') povcalnet clear: All}"'
				} 
				else {
					noi display `"{stata  pip, country(`country') year(all) coverage(`coverage')  clear: All}"'
				}
				
			}
			restore
			noi display _n ""
			exit
			break
		}
	}	
	
	***************************************************
	* 4. Listing of regions
	***************************************************
	if  ("`country'" == "") & ("`region'" != "") {
		qui{
			noi disp in y  _n "{title:Available Surveys}" 
			noi disp in y  _n "{title:Select a Year}" 	
			
			quietly levelsof wb_region, local(regions)
			
			foreach i_reg of local regions{
				local current_line = 0
				noi disp in y  _n "`i_reg'" 
				local years_current = "$refyears"
				foreach ind_y of local years_current {
					local current_line = `current_line' + 1 
					if ("`povcalnet_format'" != "") {
						local display_this = "{stata  pip, region(`i_reg') year(`ind_y') aggregate povcalnet clear: `ind_y'}"	
					} 
					else {
						local display_this = "{stata  pip, region(`i_reg') year(`ind_y') aggregate clear: `ind_y'}"	
					}
						
					if (`current_line' < 10) noi display in y `"`display_this'"' _continue 
					else{
						noi display in y `"`display_this'"' 
						local current_line = 0		
					}
				}
				if ("`povcalnet_format'" != "") {
					noi display in y "{stata  pip, region(`i_reg') year(all) aggregate povcalnet clear: All}"
				} 
				else {
					noi display in y "{stata  pip, region(`i_reg') year(all) aggregate clear: All}"
				}
								
								
			}
			noi display _n ""
			exit
			break
		}
	}
}

end	

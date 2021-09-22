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
] 

if ("`pause'" == "pause") pause on
else                      pause off

*set trace on
qui {
	
	if ("`clear'" == "") preserve
	
	
	*---------- API defaults
	
	if "`server'" == ""  {
		local site_name = "api/v1"
		local server   = "https://ippscoreapidev.aseqa.worldbank.org"
		local url = "`server'/`site_name'"
		return local site_name = "`site_name'"
		return local url       = "`url'"
	} 
	else {
		local url "https://ippscoreapidev.aseqa.worldbank.org/api/v1"
	}
	
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
	

	local orgvar region_code gdp_data_level survey_year
	local newvar wb_region coverage_level year 
	
	local i = 0
	foreach var of local orgvar {
		local ++i
		rename `var' `: word `i' of `newvar''
	}	

	keep country_code wb_region coverage_level year 
	order country_code wb_region coverage_level year
	
	duplicates report
	
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
				local display_this = "{stata pip_info, country(`cccc') clear: `cccc'} "
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
				local dipsthis "{stata  pip, region(`i_reg') year(all) aggregate clear:`i_reg' }"
				noi disp " `dipsthis' " _c
			}
			
			noi display in y _n "{stata pip_info, region clear: World Bank regions by year}"		
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
				noi disp in y  "year (survey year)" 	
				local years_current = "`=year[`index_s']'"
				local coverage = "`=coverage_level[`index_s']'"
				local years_current: subinstr local years_current "," " ", all 
				local index_s = `index_s'+ 1 
				
				foreach ind_y of local years_current {
					local current_line = `current_line' + 1 
					local ind_y_c=substr("`ind_y'",1,4)
					local display_this = "{stata  pip, country(`country') year(`ind_y') coverage(`coverage')   clear: `ind_y_c'(`ind_y')}"		
					if (`current_line' < 10) noi display in y `"`display_this'"' _continue 
					else{
						noi display in y `"`display_this'"' 
						local current_line = 0		
					}
				}	
				
				noi display `"{stata  pip, country(`country') year(all) coverage(`coverage')  clear: All}"'
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
					local display_this = "{stata  pip, region(`i_reg') year(`ind_y') aggregate clear: `ind_y'}"		
					if (`current_line' < 10) noi display in y `"`display_this'"' _continue 
					else{
						noi display in y `"`display_this'"' 
						local current_line = 0		
					}
				}
				noi display in y "{stata  pip, region(`i_reg') year(all) aggregate clear: All}"				
			}
			noi display _n ""
			exit
			break
		}
	}
}

end	

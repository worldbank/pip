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
	pip_set_server  `server', `pause'
	*return add
	local server = "`r(server)'"
	local base   = "`r(base)'"
	local base2  = "`r(base2)'"
	
	local site_name = "api/v1"
	local url = "`server'/`site_name'"
	
	return local site_name = "`site_name'"
	return local url       = "`url'"
	
	
	***************************************************
	* 0. Info frame 
	***************************************************	
	
	//------------ Find available frames
	frame dir 
	local av_frames "`r(frames)'"
	local av_frames: subinstr local  av_frames " " "|", all
	local av_frames = "^(" + "`av_frames'" + ")"
	
	//------------ countries frame
	local frpipcts "_pip_countries"
	if (!regexm("`frpipcts'", "`av_frames'")) {
		
		frame create `frpipcts'
		
		frame `frpipcts' {
			
			local csvfile0  = "`url'/aux?table=countries&format=csv"
			cap import delimited using "`csvfile0'", clear varn(1)
			
			if (_rc != 0 ) {
				noi disp in red "There is a problem accessing country name data." 
				noi disp in red "to check your connection, copy and paste in your browser the following address:" _n /* 
				*/	_col(4) in w `"`csvfile0'"'
				
				error 
			} 
			
			drop iso2_code
			sort country_code
		}
		
	}
	//------------ interpolated means frame
	
	local frpipim "_pip_int_means"
	if (!regexm("`frpipim'", "`av_frames'")) {
		
		frame create `frpipim'
		
		frame `frpipim' {
			
			local csvfile  = "`url'/aux?table=interpolated_means&format=csv"
			cap import delim using "`csvfile'", clear varn(1)
			if (_rc != 0 ) {
				noi disp in red "There is a problem accessing the information file." 
				noi disp in red "to check your connection, copy and paste in your browser the following address:" _n /* 
				*/	_col(4) in w `"`csvfile'"'
				
				error 
			} 
			
		}
		
	}
	
	if ("`justdata'" != "") exit
	
	//========================================================
	//  To be continued by Tefera
	//========================================================
	
	local frlkup "_pip_lkup"
	if (!regexm("`frlkup'", "`av_frames'")) {
	
		frame copy `frpipim' `frlkup'
		
		frame `frlkup' {
				
			// and do all that is below 
		
		}
		
		
	}
	
	local orgvar survey_coverage reporting_year 
	local newvar coverage_level reporting_year 
	
	local i = 0
	foreach var of local orgvar {
		local ++i
		rename `var' `: word `i' of `newvar''
	}	
	
	keep country_code coverage_level survey_year reporting_year 
	order country_code coverage_level survey_year reporting_year
	sort country_code
	
	merge country_code using `temp100'
	collapse _merge, by(country_code country_name coverage_level reporting_year income_group)
	drop _merge
	order country_code country_name coverage_level reporting_year income_group
	
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
				noi disp in y  "survey year" 	
				local years_current = "`=year[`index_s']'"
				local coverage = "`=coverage_level[`index_s']'"
				local years_current: subinstr local years_current "," " ", all 
				local index_s = `index_s'+ 1 
				
				foreach ind_y of local years_current {
					local current_line = `current_line' + 1 
					local ind_y_c=substr("`ind_y'",1,4)
					local display_this = "{stata  pip, country(`country') year(`ind_y') coverage(`coverage')   clear: `ind_y_c'}"		
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

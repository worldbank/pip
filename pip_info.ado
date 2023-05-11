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
version(string)    ///
POVCALNET_format   ///
] 

if ("`pause'" == "pause") pause on
else                      pause off

qui {
	
	//if ("`clear'" == "") preserve
	
	*---------- API defaults
	if ("${pip_host}" == "" | server != "") {
		pip_set_server,  server(`server')
		local server    = "`r(server)'"
		local url       = "`r(url)'"
		return add		
	}
	
	//------------ version
	if ("`version'" != "") {
		local version_qr = "&version=`version'"
		tokenize "`version'", parse("_")
		local _version   = "_`1'_`3'_`9'"
	}
	else {
		local version_qr = ""
		local _version   = ""
	}
	
	
	***************************************************
	* 0. Info frame 
	***************************************************	
	
	local curframe = c(frame)
	
	//------------ Find available frames
	frame dir 
	local av_frames "`r(frames)'"
	local av_frames: subinstr local  av_frames " " "|", all
	local av_frames = "^(" + "`av_frames'" + ")"
	
	//------------ countries frame
	local frpipcts "_pip_cts`_version'"
	if (!regexm("`frpipcts'", "`av_frames'")) {
		
		frame create `frpipcts'
		
		frame `frpipcts' {
			
			cap pip_tables countries, server(`server') version(`version') clear
			local rc1 = _rc
			
			if (`rc1' == 0) {
				cap confirm new var iso2_code
				if (_rc) {
					drop iso2_code
				}
				sort country_code
			}
		}
		
		// drop frame if error happened
		if (`rc1' != 0) {
			local csvfile0  = "${pip_host}/aux?table=countries`version_qr'&format=csv"
			
			noi disp in red "There is a problem accessing country name data." 
			noi disp in red "to check your connection, copy and paste in your browser the following address:" _n /* 
			*/	_col(4) in w `"`csvfile0'"'
			frame drop `frpipcts'
			error 
		} 
		
	}
	
	//------------ regions frame
	local frpiprgn "_pip_regions`_version'"
	if (!regexm("`frpiprgn'", "`av_frames'")) {
		
		frame create `frpiprgn'
		
		frame `frpiprgn' {
			
			cap pip_tables regions, server(`server') version(`version') clear
			local rc1 = _rc
			
			if (`rc1' == 0) {
				drop grouping_type
				sort region_code
			}
		}
		
		// drop frame if error happened
		if (`rc1' != 0) {
			local csvfilergn  = "${pip_host}/aux?table=regions`version_qr'&format=csv"
			noi disp in red "There is a problem accessing region name data." 
			noi disp in red "to check your connection, copy and paste in your browser the following address:" _n /* 
			*/	_col(4) in w `"`csvfilergn'"'
			frame drop `frpiprgn'
			error 
		} 
		
	}	
	
	
	
	//------------ regions price framework
	local frpipfw "_pip_fw`_version'"
	if (!regexm("`frpipfw'", "`av_frames'")) {
		frame create `frpipfw'
		
		frame `frpipfw' {
			
			cap pip_tables framework, server(`server') version(`version') clear
			
			//------------format variables to make them link to data. 
			rename welfare_type wt
			label define welfare_type 1 "consumption" 2 "income"
			encode wt, gen(welfare_type)
			
			local rc1 = _rc
		}
		
		// drop frame if error happened
		if (`rc1' != 0) {
			local csvfile2  = "${pip_host}/aux?table=framework`version_qr'&format=csv"
			
			noi disp in red "There is a problem accessing framework name data." 
			noi disp in red "to check your connection, copy and paste in your browser the following address:" _n /* 
			*/	_col(4) in w `"`csvfile2'"'
			frame drop `frpipfw'
			error 
		} 
		
	}
	
	*if ("`justdata'" != "") exit
	
	//========================================================
	//  generating a lookup data
	//========================================================
	
	local frlkupb "_pip_lkupb`_version'"
	if (!regexm("`frlkupb'", "`av_frames'")) {
		
		frame copy `frpipfw' `frlkupb'
		
		
		frame `frlkupb' {
			
			keep country_code country_name wb_region_code pcn_region_code survey_coverage surveyid_year
			
			local orgvar survey_coverage surveyid_year
			local newvar coverage_level reporting_year 
			
			local i = 0
			foreach var of local orgvar {
				local ++i
				rename `var' `: word `i' of `newvar''
			}	
			
			tostring reporting_year, replace
			gen year = reporting_year
			duplicates drop
			
			reshape wide year, i( wb_region_code pcn_region_code country_code coverage_level country_name) j(reporting_year) string
			
			egen year    = concat(year*), p(" ")
			replace year = stritrim(year)
			replace year = subinstr(year," ", ",",.)
			
			keep country_code country_name wb_region_code pcn_region_code coverage_level year
			order country_code country_name wb_region_code pcn_region_code coverage_level year
			
		}
	}
	
	
	local frlkupwr "_pip_lkup_wrk"
	frame copy `frlkupb' `frlkupwr', replace
	if ("`justdata'" != "") exit
	
	***************************************************
	* 2. Inital listing with countries and regions
	***************************************************
	
	if  ("`country'" == "") & ("`region'" == "") {
		
		noi disp in y  _n "{title:Available Surveys}: " in g "Select a country or region" 
		noi disp in y  _n "{title: Countries}"  
		
		frame `frlkupwr' {
			
			quietly levelsof country_code , local(countries) 
			local current_line = 0
			foreach cccc of local countries{
				local current_line = `current_line' + 1 
				local display_this = "{stata pip_info, country(`cccc') clear server(`server') version(`version'): `cccc'} "
				if (`current_line' < 8) noi display in y `"`display_this'"' _continue 
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
		} // end of frame
		
		noi display in y _n "{stata pip_info, region clear: World Bank regions by year}"		
		noi display _n ""
		
		cwf `curframe'
		exit
	} // end of condition
	
	***************************************************
	* 3. Listing of country surveys
	***************************************************
	
	if  ("`country'" != "") & ("`region'" == "") {
		
		frame `frlkupwr' {
			
			noi disp in y  _n "{title:Available Surveys for `country'}" 	
			local country = upper("`country'")
			keep if country_code == "`country'"
			
			local link_detail = "https://pip.worldbank.org/country-details/`country'"
			
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
					local display_this = "{stata  pip, country(`country') year(`ind_y') server(`server') coverage(`coverage')   clear: `ind_y_c'}"		
					if (`current_line' < 10) noi display in y `"`display_this'"' _continue 
					
					else {
						noi display in y `"`display_this'"' 
						local current_line = 0		
					}
					
				} // end of inner loop	
				
				noi display `"{stata  pip, country(`country') year(all) coverage(`coverage')  clear: All}"'
				
			} // end of loop
			
			
			noi display _n ""
			
		} // end of frame
		
		cwf `curframe'
		exit	
	}	 // end of condition 
	
	***************************************************
	* 4. Listing of regions
	***************************************************
	if  ("`country'" == "") & ("`region'" != "") {
		
		frame `frlkupwr' {
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
			} // end of loop 
			
		} // end of frame
		noi display _n ""
		cwf `curframe'
		exit			
		
	}	 // end of condition 
	
} // end of large quietly

end	

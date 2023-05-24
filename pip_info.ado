*********************************************************************************
* pip_info                                                          		*
*********************************************************************************


program define pip_info, rclass
	
	version 16.0
	
	syntax    [,          ///
	COUntry(string)       ///
	REGion                ///
	pause                 /// debugging
	clear                 ///
	release(passthru)     ///
	ppp_year(passthru)    ///
	identity(passthru)    ///
	version(passthru)     ///
	] 
	
	if ("`pause'" == "pause") pause on
	else                      pause off
	
	qui {
		
		//========================================================
		// setup
		//========================================================
		local curframe = c(frame)
		//------------ version
		if ("${pip_version}" == "") {
			pip_timer pip_info.pip_versions, on
			pip_versions, `release' `ppp_year' `identity' `version'	
			pip_timer pip_info.pip_versions, off
		}
		
		
		local version_qr = "&version=${pip_version}"
		tokenize "${pip_version}", parse("_")
		local _version   = "_`1'_`3'_`9'"
		
		//------------ Get auxiliary data
		pip_auxframes
		
		local frlkupwr "_pip_lkup_wrk"
		local frlkupb  "_pip_lkupb`_version'"
		frame copy `frlkupb' `frlkupwr', replace
		
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
					local display_this = "{stata pip_info, country(`cccc') clear: `cccc'} "
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
						local stcall "pip, country(`country') year(`ind_y') server(${pip_server}) coverage(`coverage') version(${pip_version}) clear"
						local display_this = `"{stata  `stcall': `ind_y_c' }"'
						if (`current_line' < 7) noi display in y `"`display_this'"' _continue 
						
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
						local display_this = "{stata  pip, region(`i_reg') year(`ind_y') clear: `ind_y'}"		
						if (`current_line' < 7) noi display in y `"`display_this'"' _continue 
						else{
							noi display in y `"`display_this'"' 
							local current_line = 0		
						}
					}
					noi display in y "{stata  pip, region(`i_reg') year(all)  clear: All}"
				} // end of loop 
				
			} // end of frame
			noi display _n ""
			cwf `curframe'
			exit			
			
		}	 // end of condition 
		
	} // end of large quietly
	
end	

*********************************************************************************
* pip_info                                                          		*
*********************************************************************************


program define pip_info, rclass
	
	version 16.0
	
	syntax    [,          ///
	COUntry(string)       ///
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
		local frlkupb  "_pip_fw`_version'"
		frame copy `frlkupb' `frlkupwr', replace
		
		***************************************************
		* 2. Inital listing with countries and regions
		***************************************************
		
		if  ("`country'" == "")  {
			
			noi disp in y  _n "{title:Data Availability}"_n

			frame `frlkupwr' {
				noi pip_utils click, variable(country_code)       /* 
				*/ title("{res}{title:Countries}{txt} (Click to display survey availability)") /* 
				*/ statacode(`"pip_info, country(obsi) clear"') /* 
				*/ width(50)
				
				noi disp _n "{title:Global and Regions}{txt} (Select level of aggregation)" 
				
				levelsof region_code, local(regions)
				
				local cl = "{stata pip cl, clear:Country-level}"
				local wb = "{stata pip wb, clear:Aggregate-level}"
				noi disp  "{ul:Global:}{col 10}`cl' | `wb'"
				foreach i_reg of local regions {
					local cl = "{stata pip cl, region(`i_reg') clear:Country-level}"
					local wb = "{stata pip wb, region(`i_reg') clear:Aggregate-level}"
					noi disp  "{ul:`i_reg':} {col 10}`cl' | `wb'"
				} // end of loop 
			} // end of frame
			
			* noi disp "{stata pip_info, region(region) clear: World Bank regions r}"		
			noi disp _n ""
			
			exit
		} // end of condition
		
		***************************************************
		* 3. Listing of country surveys
		***************************************************
		
		if  ("`country'" != "") {
			
			frame `frlkupwr' {
				
				local country = upper("`country'")
				keep if country_code == "`country'"
				local country_name = country_name[1] 
				noi disp _n "{res}{title:Available Surveys for `country_name' (`country')}{txt}" _n
				
				qui levelsof survey_coverage, local(levels)
				
				foreach l of local levels {
					local all `"{stata  pip, country(`country') year(all) coverage(`l')  clear:All}"'
					noi pip_utils click if survey_coverage == "`l'", /* 
			     */	variable(year)  title("{ul:`l' level} (`all')")      /* 
					 */ statacode(`"pip, country(`country') year(obsi) clear"') /* 
					 */ width(50)
				}
				
				local ld = "https://pip.worldbank.org/country-details/`country'"
				noi disp `"Click {browse "`ld'" :here} for detailed information of  `country_name' (`country')"'
				
			} // end of frame
			
			exit	
		}	 // end of condition 
		
	} // end of large quietly
	
end	

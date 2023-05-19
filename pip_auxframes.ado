/*==================================================
project:       Create auxiliary PIP frames
Author:        R.Andres Castaneda 
----------------------------------------------------
Creation Date:    18 May 2023 - 16:01:20
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_auxframes, rclass
	
	//========================================================
	//  create tables
	//========================================================
	
	//------------ setup 
	if ("${pip_version}" == "") {
		noi disp "{err}No version selected."
		error
	}
	tokenize "${pip_version}", parse("_")
	local _version   = "_`1'_`3'_`9'"
	
	//------------ name of tables and frames
	local tables "countries regions framework"
	local frames "cts regions fw"
	
	//------------ Iterations
	gettoken table tables: tables 
	gettoken frame frames: frames 
	
	while ("`table'" != "") {
		local pframe "_pip_`frame'`_version'"
		pip_auxframes_create, table(`table') frame(`pframe')
		
		//========================================================
		// Format each table
		//========================================================
		if (`r(fexisted)' == 0) { // format if it did not existed
			
			//------------countries
			if ("`frame'" == "cts") frame `pframe': sort country_code
			//------------regions
			if ("`frame'" == "regions") {
				frame `pframe' {
					drop grouping_type
					sort region_code
				}
			}
			//------------framework
			if ("`frame'" == "fw") {
				frame `pframe' {
					rename welfare_type wt
					label define welfare_type 1 "consumption" 2 "income"
					encode wt, gen(welfare_type)
				}
			}
		} // end of previous existence condition
		
		//------------ go to next iteration
		gettoken table tables: tables 
		gettoken frame frames: frames 
	}
	
	//========================================================
	//  Create auxiliary lookup 
	//========================================================
	
	local lkup "_pip_lkupb`_version'"
	local fw   "_pip_fw`_version'"
	pip_auxframes_lkup, lkup("`lkup'") fw("`fw'")
	
end

//========================================================
// Aux programs
//========================================================

//------------ Create auxiliary frame
program define pip_auxframes_create, rclass
	syntax, table(string) frame(string)
	
	pip_utils frameexists, frame("`frame'")
	if (`r(fexists)' == 0) {
		frame create `frame'
		cap frame `frame': pip_tables , table(`table') clear
		if (_rc) {
			frame drop `frame'
			error
		}
		return local fexisted = 0
	}
	else return local fexisted = 1
	
end

//------------ Auxiliary lookup
program define pip_auxframes_lkup
	syntax, lkup(string) fw(string)
	pip_utils frameexists, frame("`lkup'")
	if (`r(fexists)' == 0) {
		
		frame copy `fw' `lkup'
		frame `lkup' {
			
			keep country_code country_name wb_region_code /* 
			 */ pcn_region_code survey_coverage surveyid_year
			
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
			
			reshape wide year, i( wb_region_code pcn_region_code /* 
			  */ country_code coverage_level country_name) /* 
			  */ j(reporting_year) string
			
			egen year    = concat(year*), p(" ")
			replace year = stritrim(year)
			replace year = subinstr(year," ", ",",.)
			
			local kvars country_code country_name wb_region_code /* 
			 */ pcn_region_code coverage_level year
			keep `kvars' 
			order `kvars'
		}
	}
	
end 


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><



scalar scode = `""'
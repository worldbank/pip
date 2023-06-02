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
		pip_timer aux_frames.`table', on
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
					rename wb_region_code region_code 
				}
			}
		} // end of previous existence condition
		
		pip_timer aux_frames.`table', off
		//------------ go to next iteration
		gettoken table tables: tables 
		gettoken frame frames: frames 
	}
	
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

exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><



scalar scode = `""'
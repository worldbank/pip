/*=======================================================
Program Name: pip.ado
Author:
R.Andres Castaneda
acastanedaa@worldbank.org

Contributor:
Tefera Bekele Degefu
tdegefu@worldbank.org

World Bank Group	

project:	  Adaptation Stata package (from povcalnet) to easily query the [PIP API]
Dependencies: The World Bank - DECIS
-----------------------------------------------------------------------
References:          
Output: 
=======================================================*/



program define pip, rclass
	version 16.0
	/*==================================================
	Program set up
	==================================================*/
	pip_setup
	
	//------------ Parsing args
	pip_parseopts `0'
	mata: pip_retlist2locals("`r(optnames)'")
	if ("`subcmd'" == "") local subcmd "cl"  // country-level       
	
	//------------ Print timer`
	if ("`subcmd'" == "print") {
		if ("`timer'" != "") {
			pip_timer, printtimer
			exit
		}
	}
	
	//------------ Start timer
	pip_timer
	pip_timer pip, on
	
	//------------ set server
	* In case global server is specified
	if (`"`server'"' != `""') {
		pip_set_server, `server'
	}
	
	if ("`pause'" == "pause") pause on
	else                      pause off
	set checksum off
	
	
	// ------------------------------------------------------------------------
	// New session procedure
	// ------------------------------------------------------------------------
	
	pip_timer pip.pip_new_session, on
	pip_new_session , `pause'
	pip_timer pip.pip_new_session, off
	
	local curframe = c(frame)
	
	//========================================================
	// Early returns
	//========================================================
	
	
	//------------ setup 
	if ("`subcmd'" == "setup") {
		noi disp "{res:Setup done!}"
		pip_timer pip, off 
		exit
	}
	
	//------------Cleaup
	if regexm("`subcmd'", "^clean") {
		noi pip_cleanup
		exit
	}
	
	
	//------------Drops
	if regexm("`subcmd'", "^dropframe") {
		pip_drop frame, `frame_prefix'
		exit
	}
	
	if regexm("`subcmd'", "^dropglobal") {
		pip_drop global
		exit
	}
	
	
	//------------Install and Uninstall
	if regexm("`subcmd'", "^install") {
		if ( wordcount("`subcmd'") != 2) {
			noi disp "{err}subcommand {it:install} must be use "  /* 
			*/	 "with either {it:ssc} or {it:gh}" _n               /* 
			*/  "E.x., {cmd:pip install ssc} or {cmd:pip install gh}."
			error
		}
		local sscmd: word 2 of `subcmd'
		pip_timer pip.pip_install, on
		noi pip_install `sscmd', `path' `pause'
		pip_timer pip.pip_install, off
		exit
	}
	
	if regexm("`subcmd'", "^uninstall") {
		pip_install uninstall, `path' `pause'
		exit
	}
	
	if regexm("`subcmd'", "^update") {
		noi pip_update, `path' `pause'
		exit
	}
	
	
	//------------Versions
	if regexm("`subcmd'", "^ver") {
		pip_timer pip.pip_versions, on
		noi pip_versions, availability
		pip_timer pip.pip_versions, off
		return add
		exit
	}
	
	//------------Cache
	if regexm("`subcmd'", "cache") {
		if ("`delete'" != "") {
			pip_cache `delete'
		}
		if ("`iscache'" != "") {
			pip_cache `iscache'
			return add
		}
		
		exit
	}
	
	//------------Info
	if regexm("`subcmd'", "^info") {
		noi pip_info, `clear' `pause' `release' `ppp_year' /* 
		 */ `identity' `version'	
		return add 
		exit
	}	
	
	qui {
		
		//========================================================
		// Set up version
		//========================================================
		pip_timer pip.pip_versions, on
		pip_versions, `release' `ppp_year' `identity' `version'
		return add
		pip_timer pip.pip_versions, off
		
		//========================================================
		// Auxiliary tables
		//========================================================
		if regexm("`subcmd'", "^tab") {
			pip_timer pip.pip_tables, on
			noi pip_tables, `pipoptions'
			return add
			pip_timer pip.pip_tables, off
			noi pip_timer pip, off `printtimer'
			exit
		}
		
		//========================================================
		//  Check of arguments
		//========================================================
		
		
		pip_timer pip.pip_pov_check_args, on
		pip_pov_check_args `subcmd', `country' `region' `year'         /*
		*/         `povline' `popshare' `clear' `coverage' `fillgaps'
		local optnames "`r(optnames)'"
		mata: pip_retlist2locals("`optnames'")
		mata: pip_locals2call("`optnames'", "povoptions")
		pip_timer pip.pip_pov_check_args, off
		
		
		//========================================================
		// retrieve and format estimates
		//========================================================
		
		//------------ Coutry lavel
		if ("`subcmd'" == "cl") {
			noi pip_cl, `povoptions' `clear' `n2disp' `povcalnet_format'
			noi pip_timer pip, off `printtimer' 
		}
		//------------ World Bank Aggregate
		else if ("`subcmd'" == "wb") {
			noi pip_wb, `povoptions' `clear' `n2disp' `povcalnet_format'
			noi pip_timer pip, off `printtimer'
		}
		//------------ Country Profile
		else if ("`subcmd'" == "cp") {
			pip_cp, `povoptions' `clear' `n2disp'
			noi pip_timer pip, off `printtimer'
		}
		
		//========================================================
		// closing actions
		//========================================================
		
		//------------Final messages
		noi pip_utils finalmsg
		return add
		
		//----------Drop frames created in the middle of the process
		pip_utils keepframes, `frame_prefix' `keepframes' `efficient'
		
	} // end of qui
end  // end of pip



exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:

Version Control:

*! version 0.9.7            <2023May09>
*! -- several improvements to caching and setup.do 
*! version 0.9.6            <2023May05>
*! -- add caching to aux tables
*! -- add pip_setup.do file... this should be created internally
*! -- add mata functions to edit pip_setup.do
*! --  add pip_setup.ado to run mata and pip_setup.do 
*! -- First attempt of caching... not fully working
*! -- Fix link of country info in pip_info
*! -- Add general troubleshooting to documentation.
*! -- Change some variable labels for clarity
*! -- Update help file with installation instructions.
*! version 0.9.5                 <2023Feb14>
*! -- fix writing error in pip.pkg file that did not allow the installation of pip_update
*! version 0.9.2                 <2023Feb14>
*! -- improve installation and update features
*! version 0.9.0                  <2023Feb09>
*! -- Update help file
*! version 0.3.9                  <2022Dec16>
*! -- BREAKING Change: Fix formating of aux tables. Rename some variables to make it consistent with other PIP outputs
*! -- Drop obs with missing values in poverty line or headcount 
*! -- Fix display of citations
*! -- Improve Help file
*! -- fix bug with PPP_year  and ppp parameters
*! -- Display only one observation
*! -- Fix big with options ppp and ppp_year. Only ppp_year remained.
*! -- Change order of returning variables. 
*! -- change all labels to lower cases
*! -- BREAKING Change: remove distribution estimates from line up estimates. 
*! version 0.3.8             <2022Oct06>
*! -- Testing version change
*! -- Fix bugs
*! version 0.3.7        <2022Oct06>
*! -- Add new routines to install and update pip
*! -- Fix bug in `pip wb, region(WLD)`, which used to return all regions, rather than just WLD.
*! -- Labels for variables `icp` and `ppp` now depend on the PPP year of the data.
*! version 0.3.6        <2022Sep08>
*! -- make it work with new API specifications
*! -- Fix problem with variable name version
*! -- Fix problem with variable name version
*! version 0.3.5        <2022Jul06>
*! -- Add `asdouble` in all calls of `import delimited`
*! version 0.3.4        <2022Jun10>
*! version 0.3.3        <2022may25>
*! version 0.3.2        <2022apr26>
*! version 0.3.1        <2022apr08>
*! version 0.3.0        <2022apr07>
*! version 0.2.2        <2022apr06>
*! version 0.2.1        <2022apr04>
*! version 0.2.0        <2022apr01>
*! version 0.1.7        <2022mar30>
*! version 0.1.6        <2022mar28>
*! version 0.1.5        <2022mar25>
*! version 0.1.4        <2022mar18>
*! version 0.1.3        <2022mar18>
*! version 0.1.2        <2022feb07>
*! version 0.1.1        <2022feb01>
*! version 0.1.0        <2022feb01>
*! version 0.0.2        <2022jan12>
*! version 0.0.1        <2021dec01>



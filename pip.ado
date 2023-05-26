/*=======================================================
Program Name: pip.ado
Author:
R.Andres Castaneda
acastanedaa@worldbank.org

Contributor:
Tefera Bekele Degefu
tdegefu@worldbank.org

World Bank Group	

Dependencies: The World Bank - DECIS
-----------------------------------------------------------------------
References: https://pip.worldbank.org/home  https://pip.worldbank.org/api
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
		if ("`cachedir'" != "") {
			pip_setup cachedir, `cachedir'
		}
		noi disp "{res:Setup done!}"
		pip_timer pip, off 
		exit
	}
	
	//------------Cleaup
	if regexm("`subcmd'", "^clean") {
		noi pip_cleanup
		pip_timer pip, off
		exit
	}
	
	
	//------------Drops
	if regexm("`subcmd'", "^dropframe") {
		pip_drop frame, `frame_prefix'
		noi pip_timer pip, off
		exit
	}
	
	if regexm("`subcmd'", "^dropglobal") {
		pip_drop global
		pip_timer pip, off
		exit
	}
	
	
	//------------Install and Uninstall
	if regexm("`subcmd'", "^install") {
		if ( ("`gh'" == "" & "`ssc'" == "") | /* 
		*/  ("`gh'" != "" & "`ssc'" != "") ) {
			noi disp "{err}subcommand {it:install} must be use "  /* 
			*/	 "with either {it:ssc} or {it:gh}" _n               /* 
			*/  "E.x., {cmd:pip install, ssc} or {cmd:pip install, gh}."
			error
		}
		
		pip_timer pip.pip_install, on
		noi pip_install `gh'`ssc', `path' `pause' `version'
		pip_timer pip.pip_install, off
		pip_timer pip, off
		exit
	}
	
	if regexm("`subcmd'", "^uninstall") {
		pip_install uninstall, `path' `pause'
		noi pip_timer pip, off
		exit
	}
	
	if regexm("`subcmd'", "^update") {
		noi pip_update, `path' `pause'
		pip_timer pip, off
		exit
	}
	
	//========================================================
	//  Print information
	//========================================================
	if ("`subcmd'" == "print") {
		//------------Versions
		if ("`versions'" != "") {
			pip_timer pip.pip_versions, on
			noi pip_versions, availability
			pip_timer pip.pip_versions, off
			pip_timer pip, off
			return add
			exit
		}
		//------------Tables
		if ("`tables'" != "") {
			
			pip_timer pip.pip_versions, on
			pip_versions, `release' `ppp_year' `identity' `version'
			pip_timer pip.pip_versions, off
			
			pip_timer pip.pip_tables, on
			noi pip_tables
			return add
			pip_timer pip.pip_tables, off
			pip_timer pip, off `printtimer'
			exit
		}
		//------------ info or availability
		if ("`info'" != "" | "`available'" != ""| "`availability'" != "") {
			noi pip_info, `clear' `pause' `release' `ppp_year' /* 
			*/ `identity' `version'	
			return add 
			pip_timer pip, off 
			exit
		}	
		if ("`cache'" != "") {
			//------------ Cache info
			pip_cache info
			return add
			pip_timer pip, off 
			exit
		}
		
		noi disp "{err}Options not supported by subcommand {it:print}." _n /* 
		 */ "see {it:{help pip##print_options:print options}}"
		 error
	}
	
	//========================================================
	// Cache 
	//========================================================
	if ("`subcmd'" == "cache") {
		if ("`delete'" != "") {
			pip_cache `delete', `cachedir'
			pip_timer pip, off 
			exit
		}
		if ("`iscache'" != "") {
			pip_cache `iscache'
			return add
			pip_timer pip, off 
			exit
		}
		if ("`info'" != "") {
			pip_cache info
			return add
			pip_timer pip, off 
			exit
		}
		if ("`cachedir'" != "" & "`setup'" != "") {
			pip_setup cachedir, `cachedir'
			pip_timer pip, off 
			exit
		}
		
		pip_timer pip, off
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

*! version 0.10.3       <2023May24>
*! -- Add interactive management of cache info
*! -- add pip_get to pip_versions
*! -- Fix bug in pip_table query
*! -- Create clickable table program
*! -- add version() option to install from GitHub
*! version 0.10.2       <2023May23>
*! -- Hot fix on query
*! version 0.10.1       <2023May22>
*1 -- Fix bug
*! -- Add dialog box for cache directory
*! -- Fix issue with pip_find_src
*! -- Fix circularity when building MATA library.
*! version 0.10.0           <2023May19>
*! -- Complete refactoring of pip. many breaking changes
*! -- All callings of data are done with pip_get
*! -- local Caching is enabled for all calls
*! -- new timer functionality
*! -- new modular structure for future additions
*! -- efficient execution of code
*! -- add MATA functionality 
*! -- add setup of variables for many future uses
*! -- dismiss dependency of {missings} command
*! -- BREAK CHANGE: options names MUST be parsed completely. Partial naming breaks
*! -- Remove old code.
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
*! version 0.9.5        <2023Feb14>
*! version 0.3.8        <2022Oct06>
*! version 0.3.7        <2022Oct06>
*! version 0.3.6        <2022Sep08>
*! version 0.3.5        <2022Jul06>
*! version 0.3.4        <2022Jun10>
*! version 0.3.3        <2022may25>
*! version 0.3.2        <2022apr26>
*! version 0.3.1        <2022apr08>
*! version 0.3.0        <2022apr07>
*! version 0.2.0        <2022apr01>
*! version 0.1.0        <2022feb01>
*! version 0.0.1        <2021dec01>



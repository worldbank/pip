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
	version 16.1
	/*==================================================
	Program set up
	==================================================*/
	pip_setup
	
	//------------ Parsing args
	pip_parseopts `0'   // parse whatever the user gives

	local returnnames "`r(returnnames)'" // name of all returned object
	local optnames    "`r(optnames)'"    // names of options (after the comma)
	mata: pip_retlist2locals("`returnnames'") // convert return to locals

	if ("`subcmd'" == "") local subcmd "cl"  // default country-level 
	
	pip_split_options `optnames'  // get general options and estimation opts

	mata: pip_locals2call("`r(gen_opts)'", "gen_opts")
	mata: pip_locals2call("`r(est_opts)'", "est_opts")

	//------------ Print timer`
	if ("`subcmd'" == "print") {
		if ("`timer'" != "") {
			pip_timer, printtimer
			exit
		}
	}
	
	//------------ Test last query
	if ("`subcmd'" == "test") {
		pip_test
		exit
	}
	
	//------------ Start timer
	pip_timer
	pip_timer pip, on
	
	//------------ set server
	* In case local server is specified
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
	pip_new_session , `pause' `path'
	pip_timer pip.pip_new_session, off
	
	local curframe = c(frame)
	
	//========================================================
	// Early returns
	//========================================================
	
	
	//------------ setup 
	if ("`subcmd'" == "setup") {
		if ("`create'" != "") {
			pip_setup create
			noi disp "{res:Setup done!}"
			pip_timer pip, off 
			exit
		}
		
		if ("`cachedir'" != "") {
			pip_setup cachedir, `cachedir'
			pip_timer pip, off 
			exit
		}
	}
	
	//------------Cleaup
	if regexm("`subcmd'", "^clean") {
		noi pip_cleanup
		pip_timer pip, off
		exit
	}
	
	
	//------------Drops
	if regexm("`subcmd'", "^drop") {
		tokenize `subcmd'
		if "`2'"=="frame" {
			if ("`frame_prefix'" == "") local frame_prefix "frame_prefix(_pip_)"
			pip_drop frame, `frame_prefix'
			noi pip_timer pip, off
		}
		else if "`2'"=="global" {
			pip_drop global
			pip_timer pip, off
		}
		else {
			noi disp "{err}subcommand {it:drop} must be used with {it:frame} or {it:global}." _n /* 
			*/ "E.x., {cmd:pip drop frame} or {cmd:pip drop global}."
			error
		}
		exit
	}

	//------------Install and Uninstall
	if regexm("`subcmd'", "^install") {
		if ( ("`gh'" == "" & "`ssc'" == "") | /* 
		*/  ("`gh'" != "" & "`ssc'" != "") ) {
			noi disp "{err}subcommand {it:install} must be use "    /* 
			*/	 "with either {it:ssc} or {it:gh}" _n               /* 
			*/  "E.x., {cmd:pip install, ssc} or {cmd:pip install, gh}."
			error
		}
		
		pip_timer pip.pip_install, on
		noi pip_install `gh'`ssc', `path' `pause' `version' `username' `replace'
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
			pip_versions, `gen_opts'
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
		if ("`setup'" != "") {
			//------------ Cache info
			pip_setup display
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
		if ("`inventory'" != "" | "`metadata'" != "") {
			pip_cache inventory
			pip_timer pip, off 
			exit
		}
		if ("`setup'" != "") {
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
		noi pip_versions, `gen_opts'
		return add
		pip_timer pip.pip_versions, off
		
		//========================================================
		// Auxiliary tables
		//========================================================
		if regexm("`subcmd'", "^tab") {
			pip_timer pip.pip_tables, on
			noi pip_tables, `est_opts' // `table'  `cachedir' `clear'
			return add
			pip_timer pip.pip_tables, off
			noi pip_timer pip, off `printtimer'
			exit
		}
		
		//========================================================
		//  Check of arguments
		//========================================================

		/*
		pip_timer pip.pip_pov_check_args, on
		noi pip_pov_check_args `subcmd', `est_opts'
		local optnames "`r(optnames)'" 
		mata: pip_retlist2locals("`optnames'")
		mata: pip_locals2call("`optnames'", "est_opts")
		pip_timer pip.pip_pov_check_args, off
		*/
		
		//========================================================
		// retrieve and format estimates
		//========================================================
		
		//------------ Country lavel
		if ("`subcmd'" == "cl") {
			noi pip_cl, `est_opts' `n2disp' `povcalnet_format' `cachedir'
			noi pip_timer pip, off `printtimer' 
		}
		//------------ World Bank Aggregate
		else if ("`subcmd'" == "wb") {
			noi pip_wb, `est_opts' `n2disp' `povcalnet_format' `cachedir'
			noi pip_timer pip, off `printtimer'
		}
		//------------ Country Profile
		else if ("`subcmd'" == "cp") {
			pip_cp, `est_opts' `n2disp' `cachedir'
			noi pip_timer pip, off `printtimer'
		}
		//------------ Grouped data
		else if ("`subcmd'" == "gd") {
			noi pip_gd, `est_opts'  `n2disp' `cachedir'
			return add
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


//========================================================
//  aux programs
//========================================================

program define pip_split_options, rclass
	syntax [anything(name=optnames)], [abblength(integer 3)]
	
	if ("`optnames'" == "") exit
	// current General options (Hard coded)
	local gen_opts "version ppp_year release identity server n2disp cachedir"
	
	// get abbreviation regex
	mata: pip_abb_regex(tokens("`gen_opts'"), `abblength', "patterns")
	
	// loop each options over each abbreviation
	foreach o of local optnames {  // options by the user
		local bsgo 0 // belogs to selected general options
		foreach p of local patterns {  // patterns for general opt abbreviations
			if regexm("`o'", "^`p'") {
				local sgo `"`sgo' `o'"' // selected general options
				local bsgo 1
				continue, break
			}
		}
		if (`bsgo' == 0) local oo `"`oo' `o'"' // estimation options
	}
	
	return local gen_opts = "`sgo'"
	return local est_opts     = "`oo'"
	
end 


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:

Version Control:



*! version 0.0.1        <2021dec01>
*! version 0.1.0        <2022feb01>
*! version 0.2.0        <2022apr01>
*! version 0.3.0        <2022apr07>
*! version 0.3.1        <2022apr08>
*! version 0.3.2        <2022apr26>
*! version 0.3.3        <2022may25>
*! version 0.3.4        <2022Jun10>
*! version 0.3.5        <2022Jul06>
*! version 0.3.6        <2022Sep08>
*! version 0.3.7        <2022Oct06>
*! version 0.3.8        <2022Oct06>
*! version 0.9.5        <2023Feb14> (Stable version)
*! ^^^^^^^^ DEPRECATED DEVELOPMENT^^^^^^^^^^
*! version 0.10.0           <2023May19>
*! -- Update help file with installation instructions.
*! -- Change some variable labels for clarity
*! -- Add general troubleshooting to documentation.
*! -- Fix link of country info in pip_info
*! -- First attempt of caching... not fully working
*! -- add pip_setup.ado to run mata and pip_setup.do 
*! -- add mata functions to edit pip_setup.do
*! -- add pip_setup.do file... this should be created internally
*! -- add caching to aux tables
*! -- several improvements to caching and setup.do 
*! -- Remove old code.
*! -- BREAK CHANGE: options names MUST be parsed completely. Partial naming breaks
*! -- dismiss dependency of {missings} command
*! -- add setup of variables for many future uses
*! -- add MATA functionality 
*! -- efficient execution of code
*! -- new modular structure for future additions
*! -- new timer functionality
*! -- local Caching is enabled for all calls
*! -- All callings of data are done with pip_get
*! -- Complete refactoring of pip. many breaking changes
*! version 0.10.1       <2023May22>
*! -- Fix circularity when building MATA library.
*! -- Fix issue with pip_find_src
*! -- Add dialog box for cache directory
*1 -- Fix bug
*! version 0.10.2       <2023May23>
*! -- Hot fix on query
*! version 0.10.3         <2023May24>
*! -- add version() option to install from GitHub
*! -- Create clickable table program
*! -- Fix bug in pip_table query
*! -- add pip_get to pip_versions
*! -- Add interactive management of cache info
*! version 0.10.4    <2023May31>
*! -- Fix coverage issue
*! -- BREAKING CHANGE: `pip versions` is now `pip print, version`
*! -- Add more print options
*! -- Improve cache manipulation, specially with cachedir() option
*! -- Modular Helpfile (Incomplete)
*! version 0.10.5    <2023Jun06>
*! -- delete pip_clean as we don't need it anymore
*! -- fix issue of building the mata lib all the time
*! -- comment message of repeated timer
*! -- get length of string for formatting in pip_utils_cliackable
*! -- refactor pip_info to pip_utils click
*! -- delete lukup auxiliary frame. We don't need it anymore
*! -- provide table of countries when wrong country is selected
*! -- add fillgaps to check in pov_check_args
*! -- replacre optnames for returnnames and add optnames only for options
*! -- update abbreviation of general and pip_cl help files
*! -- update to version 16.1
*! -- Allow user to see Cache inventory `pip cache, inventory`
*! -- fix issue with `pip cache, iscache` working now
*! -- complete pip_tables help file
*! -- update print and tables help file
*! -- info of cache memory
*! -- add cache info to help file
*! -- add help for pip wb (which points to pip_cl) and for pip setup (init)
*! -- update format
*! -- add cachedir in each pip_get call
*! -- make local cachedir prevail over global pip_cachedir
*! -- add pip_test
*! -- update helpfile with new subcommand test
*! -- Incorporate pip_cp by Tefera
*! version 0.10.6    <2023Jun23>
*! -- Fix big bug about ppp year and wrong url query. 
*! version 0.10.7    <2023Aug17>
*! -- fix issue with ppp_year()
*! -- move pip_check_args to specific functions per subcmd
*! -- fix getting pip_version stick
*! -- change ppp and ppp_year for ppp_version()
*! --fix issue with last and mrv in year()
*! --fix messages when year is out of boundries
*! --fix problem with setting globals and not being able to use the general options.
*! version 0.10.8  <2024jan11>
*! -- Add server to cache info
*! -- fix problem in scmd tables not working with server()
*! -- improve message for setting up cache dir
*! -- force proper formatting.
*! -- fix bug with version in pip_cl.
*! -- fix bug in pip-grp. Now group_by=wb is called explicitly.
*! version 0.10.9  <2024aug28>
*! -- Update help file.
*! -- Add estiamte_type as string variable and leave it optional for now
*! -- add pause message in formating 
*! -- Allow upper case in server option
*! version 0.10.10  <2024sep27>
*! -- implement fillgaps and nowcasts options at both country and regional levels
*! -- Add Datt data
*! -- Add add gd subcommand
*! -- save results of pip_gd in separate frames
*! -- add pip_utils_frame2locals
*! -- add examples
*! -- Update help file
*! version 0.10.11  <2024oct09>
*! -- HOT FIX: parse `clear' option to pip_cp_check_args

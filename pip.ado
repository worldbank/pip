
*! version 0.11.0.9000  <2026mar26>


/*=======================================================
Program Name: pip.ado
Authors:
R.Andres Castaneda
acastanedaa@worldbank.org

Damian Clarke 
dclarke4@worldbank.org, dclarke@fen.uchile.cl

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

	local _default_subcmd "cl"   // country-level is the default subcommand
	if ("`subcmd'" == "") local subcmd "`_default_subcmd'"
	
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
	if ("${pip_checksum_set}" == "") {
		set checksum off
		global pip_checksum_set "1"
	}

	//------------Install, Uninstall, Update (deprecated - GitHub only)
	* Checked here, before pip_new_session, to avoid an unnecessary GitHub API call.
	if regexm("`subcmd'", "^install|^uninstall|^update|^ssc") {
		capture which github
		if (_rc == 0) {
			local install_cmd "github install worldbank/pip, replace"
		}
		else {
			local install_cmd `"net install pip, from("https://raw.githubusercontent.com/worldbank/pip/main/") replace"'
		}
		noi disp as text _n ///
			"{cmd:pip `subcmd'} has been removed. {cmd:pip} is now only available on GitHub." _n ///
			"To update, run: {stata `install_cmd'}"
		pip_timer pip, off
		exit
	}

	// ------------------------------------------------------------------------
	// New session procedure
	// ------------------------------------------------------------------------
	
	pip_timer pip.pip_new_session, on
	pip_new_session
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
		// retrieve and format estimates
		//========================================================
		
		//------------ Country lavel
		if ("`subcmd'" == "cl") {
			noi pip_cl, `est_opts' `n2disp' `povcalnet_format'
			return add
			noi pip_timer pip, off `printtimer' 
		}
		//------------ Aggregate data
		else if ("`subcmd'" == "agg") {
			noi pip_agg, `est_opts'  `n2disp'
			return add
			noi pip_timer pip, off `printtimer'
		}
		//------------ World Bank Aggregate
		else if ("`subcmd'" == "wb") {
			noi pip_wb, `est_opts' `n2disp' `povcalnet_format'
			return add
			noi pip_timer pip, off `printtimer'
		}
		//------------ Country Profile
		else if ("`subcmd'" == "cp") {
			pip_cp, `est_opts' `n2disp'
			return add
			noi pip_timer pip, off `printtimer'
		}
		//------------ Grouped data
		else if ("`subcmd'" == "gd") {
			noi pip_gd, `est_opts'  `n2disp'
			return add
			noi pip_timer pip, off `printtimer'
		}
		//------------ Subcommand not recognized
		else {
			noi disp "{err}Subcommand {it:`subcmd'} is not recognized." _n /* 
			*/ "see {it:{help pip}}"
			error
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


// pip_split_options is defined in pip_split_options.ado
// (Stata's ado auto-loader only retains the first program per file)

exit
/* End of do-file */

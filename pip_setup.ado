*! version 0.11.0  <2026mar23>
/*==================================================
project:       Run globals and setup env for pip
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     6 May 2023 - 06:57:11
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_setup, rclass
	version 16.1
	
	syntax [anything(name=subcmd)]  [, * ] 
	
	pip_setup_dates
	
	//========================================================
	//  Subcommands
	//========================================================
	
	// create
	if ("`subcmd'" == "create") {
		pip_setup_create
		return add
		exit
	}
	
	// Replace in pattern
	
	if ("`subcmd'" == "replace") {
		pip_setup_replace, `options'
		return add
		exit
	}
	
	// run pip_setup.do
	if ("`subcmd'" == "run") {
		pip_setup_ensure
		local _setup_fn "`r(fn)'"
		if ("`options'" == "display") type "`_setup_fn'"
		run  "`_setup_fn'"
		exit
	}
	// display pip_setup.do
	if ("`subcmd'" == "display") {
		pip_setup_ensure
		type "`r(fn)'"
		exit
	}
	
	
	// cache dir
	if ("`subcmd'" == "cachedir") {
		noi pip_setup_cachedir, `options'
		exit
	}
	
	
	// server
	if ("`subcmd'" == "server") {
		pip_set_server, `options'
		exit
	}

	qui {
		
		//========================================================
		//  One-time session initialisation
		//  Gate: skip all expensive I/O after the first pip call.
		//  pip drop global clears pip_session_initialized, so a
		//  forced re-init is always available via that route.
		//========================================================
		if ("${pip_session_initialized}" == "") {

		//========================================================
		//  compile mata code
		//========================================================
		global pip_version ""
		findfile "pip_fun.mata"
		local pip_funmata_file = "`r(fn)'"
		tempname spipmata
		scalar `spipmata' = fileread("`pip_funmata_file'")
		
		pip_setup_gethash, query(`"`: disp `spipmata''"')
		local pipmata_hash = "`r(piphash)'"
		
		// To avoid MATA library to be  built each time. 
		if ("${pip_pipmata_hash}" == "") {
			cap findfile "pip_setup.do"
			if (_rc) global pip_pipmata_hash "000" // if setup.do is not found
			else      run  "`r(fn)'"
		}
		
		// If mata functions have changed, saved them again. 
		if ("${pip_pipmata_hash}" != "`pipmata_hash'") {
			run "`pip_funmata_file'"
			lmbuild lpip_fun.mlib, replace
			noi disp "{res}Mata {txt}lpip_fun {res}library has been updated"
			
			local pattern = "pip_pipmata_hash"
			local newline = `"global pip_pipmata_hash  = "`pipmata_hash'""'
			
			pip_setup_ensure
			pip_setup replace, pattern(`"`pattern'"') new(`"`newline'"')
		}
		
		//------------Run globals (loads pip_pipmata_hash + pip_lastupdate)
		pip_setup run 			

		//========================================================
		// Set global for server
		//========================================================
		if ("${pip_host}" == "") {
			pip_set_server
		}
		
		//========================================================
		// Set details in help file (once per session only)
		//========================================================
		local d1 = "www.pip.worldbank.org. Accessed"
		local d2 = "[Data set]. World Bank Group. www.pip.worldbank.org. Accessed `c(current_date)'.{p_end}"
		pip_get_version
		local v1 = "Poverty and Inequality Platform \(version"
		local v2 = "{p 4 8 2} World Bank. (2023). Poverty and Inequality Platform (version $pip_ado_version)"
		cap findfile "pip.sthlp"
		if _rc==0 {
			local help_file = "`r(fn)'"
			mata: pip_replace_in_pattern("`help_file'", `"`d1'"', `"`d2'"')
			if (`"`tempf'"' != `""') cap copy `tempf' "`origf'" , replace

			mata: pip_replace_in_pattern("`help_file'", `"`v1'"', `"`v2'"')
			if (`"`tempf'"' != `""') cap copy `tempf' "`origf'" , replace
		}
		
		global pip_session_initialized "1"
		} // end: session initialisation gate
		
		//========================================================
		// Server check: always ensure pip_host is set
		// (user may have called pip_set_server manually)
		//========================================================
		if ("${pip_host}" == "") {
			pip_set_server
		}
		
	}
	
end

//========================================================
//  Program to create pip_setup.do
//========================================================

program define pip_setup_create, rclass
	
	qui {
		
		// find folder to store setup.do
		local pdirs `" "`c(sysdir_personal)'" "`c(sysdir_plus)'" "`c(pwd)'" "`c(sysdir_site)'" "'
		
		tokenize `"`pdirs'"'
		while ("`1'" != "") {
			mata: st_local("setup_dir", pathjoin("`1'", "p"))
			mata: st_numscalar("direxist", pip_check_folder("`setup_dir'"))
			if (direxist == 1 )  {
				mata: st_local("setup_file", pathjoin("`setup_dir'", "pip_setup.do"))
				continue, break
			}
			macro shift
		}
		
		// it assumes that pip_setup.do does not exist
		// because this program is called in a condition
		
		
		tempfile dofile
		tempname do
		file open `do' using `dofile', write `replace'
		
		file write `do' `"//"' _dup(50) "=" _n 	
		file write `do' `"// Globals"' _n 	
		file write `do' `"//"' _dup(50) "=" _n 	
		file write `do' `""' _dup(2) _n    
		file write `do' `"global pip_pipmata_hash = """' _dup(3) _n 
		file write `do' `"global pip_lastupdate = """' _dup(3) _n 
		file write `do' _dup(5) _n 
		file write `do' `"exit"' _n 
		file write `do' `"/* End of do-file */"' _n 
		
		file close `do'
		
		// save file in dir
		
		copy `dofile' "`setup_file'", replace
		
		return local fn = "`setup_file'"
		
		
	}
	
end

//========================================================
// Replace setup lines in pip_setup.do
//========================================================

program define pip_setup_replace, rclass
	version 16.1
	
	syntax [anything(name=subcmd)],  [ ///
	pattern(string)                    ///
	NEWline(string)                    ///
	]
	
	qui {
		// Use pip_setup_ensure to leverage the ${pip_setup_fn} cache
		// (avoids repeated findfile on slow OneDrive/network paths).
		pip_setup_ensure
		local setup_file = "`r(fn)'"
		mata: pip_replace_in_pattern("`setup_file'", `"`pattern'"', `"`newline'"')
		// tempf and origf are set by pip_replace_in_pattern via st_local().
		// Guard against Mata early-exit (pattern not found / file read error).
		if (`"`tempf'"' == `""') {
			noi disp as error "pip_setup_replace: pattern not found or file unreadable: `setup_file'"
			error 198
		}
		copy `tempf' "`origf'" , replace
		
		return local fn = "`setup_file'"
	}
	
end


//========================================================
//  Ensure pip_setup.do exists; create it if missing
//========================================================
program define pip_setup_ensure, rclass
/*
Purpose : Find pip_setup.do on the ado path. If not found,
          call pip_setup_create to write a blank one to the
          first writable Stata personal directory.
          Caches the resolved path in ${pip_setup_fn} to avoid
          repeated disk I/O on network/OneDrive paths (slow).
Args    : None
Returns : r(fn) — absolute path to pip_setup.do
Errors  : 198 if the file cannot be found and cannot be created
          (e.g., no writable personal directory).
*/
	version 16.1

	qui {
		// Fast path: path already resolved this session (avoids repeated
		// disk I/O on network/OneDrive paths where findfile is slow).
		if (`"${pip_setup_fn}"' != `""') {
			return local fn = "${pip_setup_fn}"
			exit
		}

		cap findfile "pip_setup.do"
		if (_rc) {
			// Not found on ado path — attempt to create it.
			cap pip_setup_create
			if (_rc) {
				noi disp as error "pip_setup_ensure: " ///
					"could not find or create pip_setup.do." _n ///
					"Check that at least one of the following " ///
					"directories is writable:" _n ///
					"  `c(sysdir_personal)'  `c(sysdir_plus)'" _n ///
					"  `c(pwd)'  `c(sysdir_site)'"
				error 198
			}
		}
		// r(fn) is set by whichever call succeeded (findfile or pip_setup_create).
		local fn = "`r(fn)'"
		global pip_setup_fn = "`fn'"  // cache for subsequent calls this session
		return local fn = "`fn'"
	}
end


//========================================================
//  Get Hash based on string 
//========================================================
// -- DC: This permits removal of pip_cache.ado
program define pip_setup_gethash, rclass
	syntax [anything(name=subcmd)], [   ///
	query(string)               ///
	PREfix(string)              ///
	]
	
	version 16.1
	
	qui {
		if ("`prefix'" == "") local prefix = "pip"
		tempname spiphash
		
		mata:  st_numscalar("`spiphash'", hash1(`"`prefix'`query'"', ., 2)) 
		// %15.0f forces integer format; %12.0g could produce scientific notation
		// for values ≥ 1e12 (unlikely for CRC32 but fragile by design).
		local piphash = "_pip" + strofreal(`spiphash', "%15.0f")
		return local piphash = "`piphash'"
	}
	
end


//========================================================
//  Program to create dates that will be used across PIP
//========================================================

program define pip_setup_dates
	
	version 16.1
	
	
	local date        = date("`c(current_date)'", "DMY")  // %tdDDmonCCYY
	local time        = clock("`c(current_time)'", "hms") // %tcHH:MM:SS
	local date_time   = `date'*24*60*60*1000 + `time'  // %tcDDmonCCYY_HH:MM:SS
	local datetimeHRF:  disp %tcDDmonCCYY_HH:MM:SS `date_time'
	local datetimeHRF = trim("`datetimeHRF'")
	local dateHRF:      disp %tdDDmonCCYY `date'
	local dateHRF     = trim("`dateHRF'")
	
	local date_file:   disp %tdCCYYNNDD `date'
	local date_file   = trim("`date_file'")
	
	
	global pip_date_file = "`date_file'"
	global pip_date_file_format = "%tdDDmonCCYY"
	
	global pip_dateHRF = "`dateHRF'"
	global pip_date_format = "%tdDDmonCCYY"
	
	global pip_datetimeHRF = "`datetimeHRF'"
	global pip_datetime_format = "%tcDDmonCCYY_HH:MM:SS"
	
end

//========================================================
//  Auxiliary program to find version
//========================================================
program define pip_get_version, rclass
	findfile pip.ado
	scalar pipado = fileread("`r(fn)'")

	//Find version as last occurrence of version X.XX.XX <YYYYMMMDD> in pip.ado
	mata: lines  = st_strscalar("pipado")
	mata: lines  = ustrsplit(lines, "`=char(10)'")'
	mata: pipdates = select(lines, regexm(lines, `"^\*!"'))
	mata: pipver = select(pipdates, regexm(pipdates, `"<2[0-9]+[a-zA-Z]+[0-9]+"'))
	mata: pipver = pipver[rows(pipver)]
	mata: regexm(pipver, "version[ ]+([0-9\.]+)[ ]+(<.+>)")
	mata: st_local("pipver", regexs(1))

	// save pipver as global pip_version
	global pip_ado_version `pipver'
end

exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control or old (new) ideas:




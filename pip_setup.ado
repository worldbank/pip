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
	version 16
	
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
		cap findfile "pip_setup.do"
		if (_rc)  pip_setup_create // if setup.do is not found
		
		if ("`options'" == "display") type "`r(fn)'"
		run  "`r(fn)'"
		exit
	}
	// run pip_setup.do
	if ("`subcmd'" == "display") {
		cap findfile "pip_setup.do"
		if (_rc)  pip_setup_create // if setup.do is not found
		
		type "`r(fn)'"
		exit
	}
	
	
	// cche dir
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
		//  compile mata code
		//========================================================
		
		findfile "pip_fun.mata"
		local pip_funmata_file = "`r(fn)'"
		tempname spipmata
		scalar `spipmata' = fileread("`pip_funmata_file'")
		
		pip_cache gethash, query(`"`: disp `spipmata''"')
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
			* local newline = `"global pip_pipmata_hash  = "1959982309""'
			
			cap findfile "pip_setup.do"
			if (_rc)  pip_setup_create // if setup.do is not found
			pip_setup replace, pattern(`"`pattern'"') new(`"`newline'"')
		}
		
		//------------Run globals 
		pip_setup run 			
		
		//========================================================
		// PIP cache directory
		//========================================================
		mata: st_local("ex_cachedir", strofreal(direxists("${pip_cachedir}")))
		if ("${pip_cachedir}" == "" | `ex_cachedir' == 0) {
			noi pip_setup_cachedir, cachedir("${pip_cachedir}") 
		}
		
		//========================================================
		// Set global for server
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
		file write `do' `"global pip_source   = """' _dup(3) _n 
		file write `do' `"global pip_cachedir = """' _dup(3) _n 
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
	version 16
	
	syntax [anything(name=subcmd)],  [ ///
	pattern(string)                    ///
	NEWline(string)                    ///
	]
	
	qui {
		
		findfile "pip_setup.do"
		local setup_file = "`r(fn)'"
		mata: pip_replace_in_pattern("`setup_file'", `"`pattern'"', `"`newline'"')
		copy `tempf' "`origf'" , replace // locals tempf and origf are created in MATA routine
		
		return local fn = "`setup_file'"
	}
	
end


program define pip_setup_cachedir, rclass
	version 16
	
	syntax [anything(name=subcmd)] , [ ///
	cachedir(string)                   ///  
	]
	
	qui {
		
		tempname direxist
		if ("`cachedir'" == "") {
			// find folder to store setup.do
			if !inlist("${pip_cachedir}", "no", "") local oldcachedir `""${pip_cachedir}""'
			else                                    local oldcachedir ""
			
			local pdirs `" `oldcachedir' "`c(sysdir_personal)'" "`c(sysdir_plus)'" "`c(pwd)'" "`c(sysdir_site)'" "'
			
			tokenize `"`pdirs'"'
			scalar `direxist' = 0
			while ("`1'" != "") {
				mata: st_local("cachedir", pathjoin("`1'", "pip_cache"))
				mata: st_numscalar("`direxist'", pip_check_folder("`cachedir'"))
				if (`direxist' == 1 )  {
					cap window stopbox rusure ///
					`"Do you want to use directory "`cachedir'" to store PIP cache data?"' ///
					`"If you don't, click "No" and provide an alternative directory path in the console."'
					
					if (_rc) {
						db pip_setup_cachedir
						noi disp "{err}NOTE: {res}Abort operation until cache directory is either set up or disabled"
						error
					}
					
					continue, break // exit while
				}
				macro shift
			} // end of while
			
		} // if cache dir is empty
		
		
		if ("`cachedir'" != "") {
			if inlist(lower("`cachedir'"), "0", "no") {
				local cachedir    = 0
				scalar `direxist' = 1 // bypass condition
			}
			else mata: st_numscalar("`direxist'", pip_check_folder("`cachedir'"))
			
			if (`direxist' == 1 )  {
				local pattern "pip_cachedir"
				local newline `"global pip_cachedir = "`cachedir'""'
				pip_setup replace, pattern(`"`pattern'"') new(`"`newline'"')
				pip_setup run
				if ("`cachedir'" != "0") {
					noi disp "{res}Cache directory has been set up. If you want to change it, type {cmd:pip_setup cachedir}"
				}
				else {
					noi disp "{res}Cache has been {err}disabled{res}. If you want to change it, type {cmd:pip_setup cachedir}"
				}
			}
		}
		
		
	}
	
end



//========================================================
//  Program to create dates that will be used across PIP
			//========================================================
			
			program define pip_setup_dates
			
			version 16
			
			
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


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control or old (new) ideas:




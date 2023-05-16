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


/*==================================================
0: Program set up
==================================================*/

program define pip, rclass
version 16.0
pip_setup

pip_parseopts `0'
mata: pip_retlist2locals("`r(optnames)'")
if ("`subcmd'" == "") local subcmd "cl"  // country-level       

pip_timer
pip_timer pip, on

/* 

disp `"country: `country'"'
disp `"year: `year'"'
disp `"clear: `clear'"'
disp `"povline: `povline'"'
disp `"cache: `cache'"'
disp `"subcmd: `subcmd'"'
disp `"pipoptions: `pipoptions'"'

exit 
*/


if ("`pause'" == "pause") pause on
else                      pause off
set checksum off


//========================================================
// Early returns
//========================================================


//------------ setup 
if ("`subcmd'" == "setup") {
	noi disp "{res:Setup done!}"
	pip_timer pip, off `printtimer'
	exit
}

local curframe = c(frame)


//------------Cleaup
if regexm("`subcmd'", "^clean") {
	noi pip_cleanup
	exit
}


//------------Drops
if regexm("`subcmd'", "^dropframe") {
	pip_drop frame, frame_prefix(`frame_prefix')
	exit
}

if regexm("`subcmd'", "^dropglobal") {
	pip_drop global
	exit
}


//------------Install and Uninstall
if regexm("`subcmd'", "^install") {
	if ( wordcount("`subcmd'") != 2) {
		noi disp "{err}subcommand {it:install} must be use with either {it:ssc} " /* 
		*/	"or {it:gh}" _n "E.x., {cmd:pip install ssc} or {cmd:pip install gh}."
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
	noi pip_versions, `server' availability
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

// ------------------------------------------------------------------------
// New session procedure
// ------------------------------------------------------------------------

pip_timer pip.pip_new_session, on
pip_new_session , `pause'
pip_timer pip.pip_new_session, off

//------------Info
if regexm("`subcmd'", "^info") {
	noi pip_info, `clear' `pause' `server' `version'
	return add 
	exit
}	



qui {
	
	//========================================================
	// setup defaults
	//========================================================
	
	* In case global server is specified
	if ("${pip_server}" != "" & "`server'" == "") {
		* noi disp in red "warning:" in y "Global {it:pip_server} (${pip_server}) is in use"
		local server = "server(${pip_server})"
	}
	
	
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
	//  Poverty estimates defaults
	//========================================================
	
	if ("`frame_prefix'" == "") {
		local frame_prefix "pip_"
	}
	
	
	//========================================================
	// Conditions (Defenses)
	//========================================================
	
	pip_timer pip.pip_pov_check_args, on
	pip_pov_check_args `subcmd', `country' `region' `year'         /*
	*/         `povline' `popshare' `ppp_year' `clear' `coverage'  /*
  */          `server' `version' `identity' `release' `fillgaps'
	local optnames "`r(optnames)'"
	mata: pip_retlist2locals("`optnames'")
	mata: pip_locals2call("`optnames'", "povoptions")
	pip_timer pip.pip_pov_check_args, off
	
	/*
  noi {
	disp `"country: `country'"'
	disp `"year: `year'"'
	disp `"clear: `clear'"'
	disp `"povline: `povline'"'
	disp `"popshare: `cache'"'
	disp `"subcmd: `subcmd'"'
	disp `"povoptions: `povoptions'"'	
	}
	exit  
	*/
	
	
	//========================================================
	// Country level estimates 
	//========================================================
	
	
	if ("`subcmd'" == "cl") {
		pip_cl, `povoptions' `clear'
		noi pip_timer pip, off `printtimer'
		exit
	}
	
	if ("`subcmd'" == "wb") {
		pip_wb, `povoptions' `clear'
		noi pip_timer pip, off `printtimer'
		exit
	}
	
	
	
	// ------------------------------
	//  display results 
	// ------------------------------
	
	if ("`n2disp'" == "") local n2disp 1
	local n2disp = min(`c(N)', `n2disp')
	
	if (`n2disp' > 1) {
		noi di as res _n "{ul: first `n2disp' observations}"
	} 
	else	if (`n2disp' == 1) {
		noi di as res _n "{ul: first observation}"
	}
	else {
		noi di as res _n "{ul: No observations available}"
	}	
	
	
	if ("`subcmd'" == "wb") {
		sort region_code year 
		
		tempname tolist
		frame copy `c(frame)' `tolist'
		frame `tolist' {
			gsort region_code -year 
			
			count if (region_code == "WLD")
			local cwld = r(N)
			if (`cwld' >= `n2disp') {
				keep if (region_code == "WLD")			
			}
			noi list region_code year poverty_line headcount mean ///
			in 1/`n2disp',  abbreviate(12) noobs
		}
		
	}
	else {
		
		sort country_code year
		local varstodisp "country_code year poverty_line headcount mean median welfare_type"
		local sepby "country_code"
		
		foreach v of local varstodisp {
			cap confirm var `v', exact
			if _rc continue 
			local v2d "`v2d' `v'"
		}
		
		noi list `v2d' in 1/`n2disp',  abbreviate(12)  sepby(`sepby') noobs
		
	}
	
	
	
	//========================================================
	//  Create notes
	//========================================================
	
	local pllabel ""
	foreach p of local povline {
		local pllabel "`pllabel' \$`p'"
	}
	local pllabel = trim("`pllabel'")
	local pllabel: subinstr local pllabel " " ", ", all
	
	
	if ("`wb'" == "")   {
		if ("`fillgaps'" == "") local lvlabel "country level"	 
		else local lvlabel "Country level (lined up)"
	}
	else {
		local lvlabel "regional and global level"
	}
	
	
	local datalabel "WB poverty at `lvlabel' using `pllabel'"
	local datalabel = substr("`datalabel'", 1, 80)
	
	label data "`datalabel' (`c(current_date)')"
	
	//========================================================
	// Final messages
	//========================================================
	
	* citations
	if ("${pip_old_session}" == "1") {
		local cnoi "noi"
		global pip_old_session = ${pip_old_session} + 1
	}
	else {
		local cnoi "qui"
		noi disp `"Click {stata "pip_cite, reg_cite":here} to display how to cite"'
	}
	`cnoi' pip_cite, reg_cite
	notes: `r(cite_data)'
	
	noi disp in y _n `"`cite'"'
	
	return local cite `"`cite'"'
	
	* Install alternative version
	if ("${pip_old_session}" == "") {
		noi pip_${pip_source} msg
	}
	
	
	
	//========================================================
	// Convert to povcalnet format
	//========================================================
	
	if ("`timer'" != "") {
		local i_on = `i'
		scalar tt = tt + "`crlf' `i': formating to povcalnet"
		local i_off = `i++'
	}	
	// --- timer
	
	// --- timer
	if ("`timer'" != "") timer on `i_on'
	// --- timer
	
	if ("`povcalnet_format'" != "") {
		pause before povcalnet format
		pip_povcalnet_format  `rtype', `pause'
	}
	
	// --- timer
	if ("`timer'" != "") timer off `i_off'
	// --- timer
	
	//========================================================
	//  Drop frames created in the middle of the process
	//========================================================
	
	if ("`timer'" != "") {
		local i_on = `i'
		scalar tt = tt + "`crlf' `i': remove frames"
		local i_off = `i++'
	}	
	// --- timer
	
	// --- timer
	if ("`timer'" != "") timer on `i_on'
	// --- timer
	
	frame dir
	local av_frames "`r(frames)'"
	
	* set trace on 
	foreach fr of local av_frames {
		
		if (regexm("`fr'", "(^_pip_)(.+)")) {
			
			// If users wants to keep frames
			if ("`keepframes'" != "") {
				local frname = "`frame_prefix'" + regexs(2)
				frame copy `fr' `frname', `replace'
			}
			// if user wants to drop them
			if ("`efficient'" == "noefficient") {
				frame drop `fr'
			}
		}
		
	} // condition to keep frames
	
	// --- timer
	if ("`timer'" != "") timer off `i_on'
	// --- timer
	
	
	* set trace off
	
	
	
	// --- timer
	if ("`timer'" != "") {
		noi disp tt
		noi timer list
	}
	// --- timer
	
} // end of qui
end



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



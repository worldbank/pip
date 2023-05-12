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
// housekeeping
//========================================================


if ("`subcmd'" == "setup") {
	noi disp "{res:Setup done!}"
	exit
}

local curframe = c(frame)

if regexm("`subcmd'", "^clean") {
	noi pip_cleanup
	exit
}


if regexm("`subcmd'", "^dropframe") {
	pip_drop frame, frame_prefix(`frame_prefix')
	exit
}

if regexm("`subcmd'", "^dropglobal") {
	pip_drop global
	exit
}

if regexm("`subcmd'", "^install") {
	if ( wordcount("`subcmd'") != 2) {
		noi disp "{err}subcommand {it:install} must be use with either {it:ssc} " /* 
		*/	"or {it:gh}" _n "E.x., {cmd:pip install ssc} or {cmd:pip install gh}."
		error
	}
	local sscmd: word 2 of `subcmd'
	noi pip_install `sscmd', `path' `pause'
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

if regexm("`subcmd'", "^ver") {	
	noi pip_versions, `server' availability
	return add
	exit
}


// Cache
if regexm("`subcmd'", "cache") {
	if ("`delete'" != "") {
		pip_cache `delete'
	}
	exit
}

if ("`cacheforce'" != "") 	{
	global pip_cacheforce `cacheforce'
	local replace replace
}
else global pip_cacheforce `cacheforce'

// ------------------------------------------------------------------------
// New session procedure
// ------------------------------------------------------------------------

pip_new_session , `pause'

qui {
	
	//========================================================
	// setup defaults
	//========================================================
	
	* In case global server is specified
	if ("${pip_server}" != "" & "`server'" == "") {
		noi disp in red "warning:" in y "Global {it:pip_server} (${pip_server}) is in use"
		local server = "server(${pip_server})"
	}
	
	
	//========================================================
	// Auxiliary tables
	//========================================================
	if regexm("`subcmd'", "^tab") {
		noi pip_tables, `pipoptions'
		return add
		exit
	}
	
	
	//========================================================
	//  Timer
	//========================================================
	
	local i = 0
	local crlf "`=char(10)'`=char(13)'"
	scalar tt = ""
	
	if ("`timer'" != "") {
		timer clear
		local i = 1
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
	
	pip_pov_check_args `subcmd', `country' `region' `year' ///
	`povline' `popshare' `ppp_year' `clear' `coverage'  ///
  `server' `version' `identity' `release'
	local optnames "`r(optnames)'"
	mata: pip_retlist2locals("`optnames'")
	mata: pip_locals2call("`optnames'", "povoptions")
	
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
		exit
	}
	
	// --- timer
	if ("`timer'" != "") {
		local i_on = `i'
		scalar tt = tt + "`crlf' `i': Set server"
		local i_off = `i++'
	}	
	// --- timer
	
	// --- timer
	if ("`timer'" != "") timer on `i_on'
	// --- timer
	
	*---------- API defaults
	pip_set_server, `server'
	*return add
	local url       = "`r(url)'"
	local server    = "`r(server)'"
	local base      = "`r(base)'"
	local base_grp  = "`r(base_grp)'"
	
	// --- timer
	if ("`timer'" != "") timer off `i_off'
	// --- timer
	
	//========================================================
	// versions
	//========================================================
	
	// --- timer
	if ("`timer'" != "") {
		local i_on = `i'
		scalar tt = tt + "`crlf' `i': Get version"
		local i_off = `i++'
	}	
	// --- timer
	
	// --- timer
	if ("`timer'" != "") timer on `i_on'
	// --- timer
	
	
	
	noi pip_versions, server(`server') ///
	version(`version')                ///
	release(`release')               ///
	ppp_year(`ppp_year')             ///
	identity(`identity')    
	
	local version_qr = "`r(version_qr)'"
	local version    = "`r(version)'"
	local release    = "`r(release)'"
	local ppp_year   = "`r(ppp_year)'"
	local identity   = "`r(identity)'"
	
	return local pip_version = "`version'"
	
	// --- timer
	if ("`timer'" != "") timer off `i_off'
	// --- timer
	
	
	//========================================================
	// conditions
	//========================================================
	*---------- lower case subcommand
	local subcmd = lower("`subcmd'")
	
	*---------- Test
	if ("`subcmd'" == "test") {
		if ("${pip_query}" == "") {
			noi di as err "global pip_query does not exist. You cannot test the query."
			error
		}
		local fq = "`base'?${pip_query}"
		noi disp in y "querying" in w _n "`fq'"
		noi view browse "`fq'"
		exit
	}
	
	
	*---------- Poverty line/population share
	
	// blank popshare and defined povline
	else if ("`popshare'" == "" & "`povline'" != "")  {
		local pcall = "povline"
	}
	
	// defined popshare and blank povline
	else {
		local pcall = "popshare"
	}
	
	*---------- Info
	if regexm("`subcmd'", "^info")	{
		local information = "information"
		local subcmd  = "information"
	}
	
	
	
	/*==================================================
	Execution 
	==================================================*/
	pause pip - before execution
	
	*---------- Information
	// --- timer
	if ("`timer'" != "") {
		local i_on = `i'
		scalar tt = tt + "`crlf' `i': Get info"
		local i_off = `i++'
	}	
	// --- timer
	
	// --- timer
	if ("`timer'" != "") timer on `i_on'
	// --- timer
	
	
	if ("`information'" != ""){
		noi pip_info, `clear' `pause' server(`server') version(`version')
		return add 
		exit
	}	
	
	// --- timer
	if ("`timer'" != "") timer off `i_off'
	// --- timer
	
	*---------- Regular query and Aggregate Query
	if ("`subcmd'" == "wb") {
		local wb "wb"
	}
	else local wb ""
	
	
	tempfile povcalf
	save `povcalf', empty 
	
	local f = 0
	
	if ("`pcall'" == "povline") 	loc i_call "i_povline"
	else 							loc i_call "i_popshare"
	
	
	// --- timer
	if ("`timer'" != "") {
		local j = `i++'
		local k = `i++'
		local h = `i++'
		scalar tt = tt + "`crlf' `j': building query"
		scalar tt = tt + "`crlf' `k': downloading data"
		scalar tt = tt + "`crlf' `h': cleaning data"
	}	
	// --- timer		
	
	foreach `i_call' of local `pcall' {	
		
		// --- timer
		if ("`timer'" != "") timer on `j'
		// --- timer
		
		local ++f 
		
		/*==================================================
		Create Query
		==================================================*/
		pip_query,   country("`country'")       ///
		region("`region'")                      ///
		year("`year'")                          ///
		povline("`i_povline'")                  ///
		popshare("`i_popshare'")	   					  ///
		ppp("`ppp_year'")                            ///
		coverage(`coverage')                    ///
		server(`server')                        ///
		version(`version')                      ///
		`clear'                                 ///
		`information'                           ///
		`iso'                                   ///
		`fillgaps'                              ///
		`wb'                                    ///
		`pause'                                 ///
		`groupedby'                             //
		
		local query_ys = "`r(query_ys)'"
		local query_ct = "`r(query_ct)'"
		local query_pl = "`r(query_pl)'"
		local query_ds = "`r(query_ds)'"
		local query_pp = "`r(query_pp)'"
		local query_ps = "`r(query_ps)'"
		
		local query_cv = "`r(query_cv)'"
		
		return local query_ys_`f' = "`query_ys'"
		return local query_ct_`f' = "`query_ct'"
		return local query_pl_`f' = "`query_pl'"
		return local query_ds_`f' = "`query_ds'"
		return local query_pp_`f' = "`query_pp'"
		return local query_ps_`f' = "`query_ps'"
		
		return local query_cv_`f' = "`query_cv'"
		
		return local base      = "`base'"
		
		*---------- Query
		if ("`popshare'" == ""){
			local query = "`query_ys'&`query_ct'&`query_cv'&`query_pl'`query_pp'`query_ds'&`version_qr'"
		}
		else{
			local query = "`query_ys'&`query_ct'&`query_cv'&`query_ps'`query_pp'`query_ds'&`version_qr'"
		}
		return local query_`f' "`query'"
		global pip_query = "`query'&format=csv"
		
		*---------- Base + query
		if ("`subcmd'" == "wb"){
			local queryfull "`base_grp'?`query'"
		}
		else{
			local queryfull "`base'?`query'"
		}
		
		return local queryfull_`f' = "`queryfull'"
		
		// --- timer
		if ("`timer'" != "") timer off `j'
		// --- timer
		
		/*==================================================
		Download  and clean data
		==================================================*/
		
		
		// --- timer
		if ("`timer'" != "") timer on `k'
		// --- timer
		
		*---------- download data
		
		pip_cache load, query("`queryfull'") `cacheforce' `clear'
		local pc_exists = "`r(pc_exists)'"
		local piphash   = "`r(piphash)'"
		
		// if not cached because it war forced or because user does not want to
		if ("`pc_exists'" == "0" | "`${pip_cachedir}'" == "0") {
			
			cap import delimited  "`queryfull'&format=csv", `clear' varn(1) asdouble
			if (_rc) {
				noi dis ""
				noi dis in red "It was not possible to download data from the PIP API."
				noi dis ""
				noi dis in white `"(1) Please check your Internet connection by "' _c 
				noi dis in white  `"{browse "${pip_host}/health-check" :clicking here}"'
				noi dis in white `"(2) Test that the data is retrievable. By"' _c
				noi dis in white  `"{stata pip test, server(`server'): clicking here }"' _c
				noi dis in white  "you should be able to download the data."
				noi dis in white `"(3) Please consider adjusting your Stata timeout parameters. For more details see {help netio}"'
				noi dis in white `"(4) Please send us an email to:"'
				noi dis in white _col(8) `"email: pip@worldbank.org"'
				noi dis in white _col(8) `"subject: pip query error on `c(current_date)' `c(current_time)'"'
				noi di ""
				error 673
			}
			
			// --- timer
			if ("`timer'" != "") timer off `k'
			// --- timer
			
			* global qr = `qr'
			
			if ("`wb'" == "") {
				local rtype 1
			}
			else {
				local rtype 2
			}
			
			pause after download
			
			// --- timer
			if ("`timer'" != "") timer on `h'
			// --- timer
			
			*---------- Clean data
			noi pip_clean `rtype', year("`year'") `iso' server(`server') /* 
			*/ region(`region') `pause' `fillgaps' version(`version')
			
			pause after cleaning
			// --- timer
			if ("`timer'" != "") timer off `h'
			// --- timer
			
			//========================================================
			// Caching
			//========================================================
			pip_cache save, piphash("`piphash'") `replace' ///
			query("`queryfull'") `cacheforce'
		}  // end of regular Download
		
		/*==================================================
		Display Query
		==================================================*/
		
		if ("`dispquery'" != "") {
			noi di as res _n "{ul: Query at \$`i_povline' poverty line}"
			noi di as res "{hline}"
			
			
			if ("`query_ys'" != "") {
				noi di as res "Year:" as txt "{p 4 6 2} `query_ys' {p_end}"
			}
			
			if ("`query_ct'" != "") {
				noi di as res "Country:" as txt "{p 4 6 2} `query_ct' {p_end}"
			}
			
			if ("`query_pl'" != "") {
				noi di as res "Poverty line:" as txt "{p 4 6 2} `query_pl' {p_end}"
			}
			
			if ("`query_ps'" != "") {
				noi di as res "Population share:" as txt "{p 4 6 2} `query_ps' {p_end}"
			}
			
			if ("`query_ds'" != "") {
				noi di as res "Aggregation:" as txt "{p 4 6 2} `query_ds' {p_end}"
			}
			
			if ("`query_pp'" != "") {
				noi di as res "PPP:" as txt "{p 4 6 2} `query_pp' {p_end}"
			}
			
			if ("`'&`version_qr''" != "") {
				noi di as res "Version:" as txt "{p 4 6 2} `version_qr' {p_end}"
			}
			
			noi di as res "full query:" as txt "{p 4 6 2} `queryfull' {p_end}" _n
			noi di as res "See in browser: "  `"{browse "`queryfull'":here}"'  _n 
			noi di as res "Download .csv: "  `"{browse "`queryfull'&format=csv":here}"' 
			
			noi di as res _dup(20) "-"
			noi di as res "No. Obs:"      as txt _col(20) c(N)
			noi di as res "{hline}"
		}
		
		/*==================================================
		Append data
		==================================================*/			
		append using `povcalf'
		save `povcalf', replace
		
	} // end of povline loop
	
	return local npl = `f'
	
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
	if ("${pip_cmds_ssc}" == "1") {
		local cnoi "noi"
		global pip_cmds_ssc = ${pip_cmds_ssc} + 1
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
	if ("${pip_cmds_ssc}" == "") {
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


*##s
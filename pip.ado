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

syntax [anything(name=subcommand)]  ///
[,                             	   /// 
COUntry(string)                /// 
REGion(string)                 /// 
YEAR(string)                   /// 
POVLine(numlist)               /// 
POPShare(numlist)	   		       /// 
PPP_year(numlist)              ///
AGGregate                      /// 
CLEAR                          /// 
INFOrmation                    /// 
COVerage(string)               /// 
ISO                            /// 
SERver(string)                 /// 
pause                          /// 
FILLgaps                       /// 
N2disp(integer 1)             /// 
DISPQuery                      ///
querytimes(integer 5)          ///
TIMEr                          ///
POVCALNET_format               ///
noEFFICIENT                    ///
KEEPFrames                     ///
frame_prefix(string)           ///
replace                        ///
VERsion(string)                ///
IDEntity(string)               ///
RELease(numlist)               ///
TABle(string)                  ///
] 

if ("`pause'" == "pause") pause on
else                      pause off
set checksum off

qui {
	//========================================================
	// Frames
	//========================================================
	local curframe = c(frame)
	
	if regexm("`subcommand'", "^clean") {
		noi pip_cleanup
		exit
	}
	
	
	if regexm("`subcommand'", "^dropframe") {
		pip_drop frame, frame_prefix(`frame_prefix')
		exit
	}
	
	if regexm("`subcommand'", "^dropglobal") {
		pip_drop global
		exit
	}
	
	// ------------------------------------------------------------------------
	// New session procedure
	// ------------------------------------------------------------------------
	
	if ("${pip_cmds_ssc}" == "") {
		pip_new_session , `pause'
	}
	
	//========================================================
	// setup defaults
	//========================================================
	
	local server     = lower("`server'")
	local identity   = upper("`identity'")
	local country    = upper("`country'")
	local coverage   = lower("`coverage'")
	local table      = lower("`table'")
	
	* In case global server is specified
	if ("${pip_server}" != "" & "`server'" == "") {
		noi disp in red "warning:" in y "Global {it:pip_server} (${pip_server}) is in use"
		local server = "${pip_server}"
	}
	
	
	//========================================================
	// Auxiliary tables
	//========================================================
	if regexm("`subcommand'", "^table") {
		noi pip_tables `table', server(`server')        ///
		version(`version')                ///
		release(`release')                ///
		ppp_year(`ppp_year')              ///
		identity(`identity')              ///
		`clear' 
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
	// Conditions (Defenses)
	//========================================================
	if ("`aggregate'" != "") {
		noi disp in red "Option {it:aggregate} is disable for now."
		exit
	}
	if ("`aggregate'" != "" & "`fillgaps'" != "") {
		noi disp in red "options {it:aggregate} and {it:fillgaps} are mutually exclusive." _n /* 
		*/ "Please select only one."
		error
	}
	
	if ("`popshare'" != "" &  (lower("`subcommand'") == "wb" | "`aggregate'" != "")) {
		noi disp in red "option {it:popshare} can't be combined with option {it:aggregate} or with subcommand {it:wb}" _n
		error
	}
	
	if ("`frame_prefix'" == "") {
		local frame_prefix "pip_"
	}
	
	
	/*==================================================
	Defaults
	==================================================*/
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
	pip_set_server  `server', `pause'
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
	
	
	if regexm("`subcommand'", "^version") {
		noi pip_versions, server(`server') availability
		return add
		exit
	}
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
	local subcommand = lower("`subcommand'")
	
	*---------- Test
	if ("`subcommand'" == "test") {
		if ("${pip_query}" == "") {
			noi di as err "global pip_query does not exist. You cannot test the query."
			error
		}
		local fq = "`base'?${pip_query}"
		noi disp in y "querying" in w _n "`fq'"
		noi view browse "`fq'"
		exit
	}
	
	*---------- Modify country(all) with aggregate
	if (lower("`country'") == "all" & "`aggregate'" != "") {
		local country    ""
		local aggregate  ""
		local subcommand "wb"
		local wb_change  1
		noi disp as err "Warning: " as text " {cmd:pip, country(all) aggregate} " /* 
	  */	"is equivalent to {cmd:pip wb}. " _n /* 
	  */  " if you want to aggregate all countries by survey years, " /* 
	  */  "you need to parse the list of countries in {it:country()} option. See " /*
	  */  "{help pip##options:aggregate option description} for an example on how to do it"
	}
	else {
		local wb_change 0
	}
	
	if ("`year'" == "") local year "all"
	
	if ("`year'" != "" & "`year'" != "all") {
		local yrtemp
		foreach yr of local year {
			local tt = substr("`yr'", 1, 4) 
			local yrtemp `yrtemp' `tt'
		}
		local year "`yrtemp'"
	} 
	* 
	
	*---------- Coverage
	if ("`coverage'" == "") local coverage = "all"
	local coverage = lower("`coverage'")
	
	foreach c of local coverage {	
		
		if !inlist(lower("`c'"), "national", "rural", "urban", "all") {
			noi disp in red `"option {it:coverage()} must be "national", "rural",  "urban" or "all" "'
			error
		}
		
	}
	
	*---------- Poverty line/population share
	
	// Blank popshare and blank povline = default povline 1.9
	if ("`popshare'" == "" & "`povline'" == "")  {
		
		if ("`ppp_year'" == "2005") local povline = 1.25
		if ("`ppp_year'" == "2011") local povline = 1.9
		if ("`ppp_year'" == "2017") local povline = 2.15
		
		local pcall = "povline"
	}
	
	// defined popshare and defined povline = error
	else if ("`popshare'" != "" & "`povline'" != "")  {
		noi disp as err "povline and popshare cannot be used at the same time"
		error
	}
	
	// blank popshare and defined povline
	else if ("`popshare'" == "" & "`povline'" != "")  {
		local pcall = "povline"
	}
	
	// defined popshare and blank povline
	else {
		local pcall = "popshare"
	}
	
	*---------- Info
	if regexm("`subcommand'", "^info")	{
		local information = "information"
		local subcommand  = "information"
	}
	
	*---------- Subcommand consistency 
	if !inlist("`subcommand'", "wb", "information", "cl", "") {
		noi disp as err "subcommand must be either {it:wb}, {it:cl}, or {it:info}"
		error 
	}
	
	//------------ Region
	
	if ("`region'" != "") {
		local region = upper("`region'")
		
		if ("`country'" != "") {
			noi disp in red "You must use either {it:country()} or {it:region()}."
			error
		}
		
		if (regexm("`region'", "SAR")) {
			noi disp in red "Note: " in y "The official code of South Asia is" ///
			"{it: SAS}, not {it:SAR}. We'll make the change for you"
			local region: subinstr local region "SAR" "SAS", word
		}
	
		tokenize "`version'", parse("_")
		local _version   = "_`1'_`3'_`9'"
		
		frame dir 
		local av_frames "`r(frames)'"
		local av_frames: subinstr local  av_frames " " "|", all
		local av_frames = "^(" + "`av_frames'" + ")"
		
		//------------ Regions frame
		local frpiprgn "_pip_regions`_version'"
		if (!regexm("`frpiprgn'", "`av_frames'")) {
			pip_info, clear justdata `pause' server(`server') version(`version')
		} 
		frame `frpiprgn' {
			levelsof region_code, local(av_regions)  clean
		}
		
		// Add all to have the same functionality as in country(all)
		local av_regions = "`av_regions'" + " ALL"
		
		local inregion: list region in av_regions
		if (`inregion' == 0) {
			
			noi disp in red "region `region' is not available." _n ///
			"Only the following are available:" _n "`av_regions'"
			
			error
		}
		
	}
	
	
	
	*---------- One-on-one execution
	if ("`subcommand'" == "cl" & lower("`country'") == "all") {
		noi disp in red "you cannot use option {it:countr(all)} with subcommand {it:cl}"
		error 197
	}
	
	*---------- WB aggregate
	
	if ("`subcommand'" == "wb") {
		if ("`country'" != "") {
			noi disp as err "option {it:country()} is not allowed with subcommand {it:wb}"
			error
		}
		noi disp as res "Note: " as txt "subcommand {it:wb} only accepts options " _n  /* 
		*/ "{it:region()} and {it:year()}"
	}
	
	
	*---------- Country
	if ("`country'" == "" & "`region'" == "") local country "ALL" // to modify
	if ("`country'" != "") {
		if (lower("`country'") != "all") local country = upper("`country'")
		else                             local country "ALL" // to modify
	}
	
	
	/*==================================================
	Main conditions
	==================================================*/
	
	if ("`information'" == "") {
		
		if (c(N) != 0 & "`clear'" == "" & "`information'" == "") {
			
			noi di as err "You must start with an empty dataset; or enable the option {it:clear}."
			error 4
		}
		
		drop _all
	}
	
	
	if ("`aggregate'" != "") {
		noi disp as res "Note: " as text "Aggregation is only possible over reference years."
		local agg_display = "Aggregation in base year(s) `year'"
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
	
	
	
	*---------- Country Level (one-on-one query)
	if ("`subcommand'" == "cl") {
		
		noi disp in red "Subcommand {it:cl} is temporary out of service."
		exit
		
		noi pip_cl, country("`country'")  /// this needs to accommodate to new structure
		year("`year'")                    ///
		povline("`povline'")              ///
		ppp_year("`ppp_year'")            ///
		server("`server'")                ///
		handle("`handle'")                ///
		coverage(`coverage')              /// 
		`clear'                           ///
		`iso'                             ///
		`pause'
		return add
		
		pip_clean 1, year("`year'") `iso' //rc(`rc')
		
		//========================================================
		// Convert to povcalnet format
		//========================================================
		if ("`povcalnet_format'" != "") {
			pip_povcalnet_format 1, `pause'
		}
		
		exit
	}
	
	
	*---------- Regular query and Aggregate Query
	if ("`subcommand'" == "wb") {
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
		scalar tt = tt + "`crlf' `j': bulding query"
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
		`aggregate'                             ///
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
		if ("`aggregate'" != "" | "`subcommand'" == "wb"){
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
		cap import delimited  "`queryfull'&format=csv", `clear' varn(1) asdouble
		if (_rc) {
			noi dis ""
			noi dis in red "It was not possible to download data from the PIP API."
			noi dis ""
			noi dis in white `"(1) Please check your Internet connection by "' _c 
			noi dis in white  `"{browse "`url'/health-check" :clicking here}"'
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
		* noi disp "`queryfull'&format=csv"
		* exit 
		
		
		// --- timer
		if ("`timer'" != "") timer off `k'
		// --- timer
		
		* global qr = `qr'
		
		if ("`aggregate'" == "" & "`wb'" == "") {
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
		pip_clean `rtype', year("`year'") `iso' server(`server') /* 
		*/ region(`region') `pause' `fillgaps' version(`version')
		
		pause after cleaning
		// --- timer
		if ("`timer'" != "") timer off `h'
		// --- timer
		
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
		if (`wb_change' == 1) {
			keep if regioncode == "WLD"
		}
		append using `povcalf'
		save `povcalf', replace
		
	} // end of povline loop
	
	return local npl = `f'
	
	// ------------------------------
	//  display results 
	// ------------------------------
	
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
	
	if ("`subcommand'" == "wb") {
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
			in 1/`n2disp',  abbreviate(12) 
		}
		
	}
	
	else {
		if ("`aggregate'" == "") {
			sort country_code year
			local varstodisp "country_code year poverty_line headcount mean median welfare_type"
			local sepby "country_code"
		}
		else {
			sort year
			local varstodisp "year poverty_line headcount mean"
			local sepby "poverty_line"
		}
		
		foreach v of local varstodisp {
			cap confirm var `v', exact
			if _rc continue 
			local v2d "`v2d' `v'"
		}
		
		noi list `v2d' in 1/`n2disp',  abbreviate(12)  sepby(`sepby')
		
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
		if ("`aggregate'" == "" & "`fillgaps'" == "") {
			local lvlabel "country level"
		} 
		else if ("`aggregate'" != "" & "`fillgaps'" == "") {
			local lvlabel "aggregated level"
		} 
		else if ("`aggregate'" == "" & "`fillgaps'" != "") {
			local lvlabel "Country level (lined up)"
		} 
		else {
			local lvlabel ""
		}
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
	noi pip_cite, reg_cite
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

* version 0.3.9             <2022Dec01>
*! version 0.3.8.9004        <2022Dec01>
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
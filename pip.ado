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
COUNtry(string)                /// 
REGion(string)                 /// 
YEAR(string)                   /// 
POVline(numlist)               /// 
POPShare(numlist)	   		       /// 
PPP(numlist)                   /// 
AGGregate                      /// 
CLEAR                          /// 
INFOrmation                    /// 
coverage(string)               /// 
ISO                            /// 
SERVER(string)                 /// 
pause                          /// 
FILLgaps                       /// 
N2disp(integer 15)             /// 
noDIPSQuery                    ///
querytimes(integer 5)          ///
TIMEr                          ///
POVCALNET_format               ///
noEFFICIENT                    ///
KEEPFrames                     ///
frame_prefix(string)           ///
replace                        ///
version(string)                ///
PPP_year(numlist)              ///
identity(string)               ///
release(numlist)               ///
table(string)                  ///
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
	// Auxiliary tables
	//========================================================
	if regexm("`subcommand'", "^table") {
		noi pip_tables `table', server(`server')        ///
	     		version(`version')                ///
	     		release(`release')                ///
	     		ppp_year(`ppp_year')              ///
	     		identity(`identity')              ///
	     		`clear' 
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
	// Conditions
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
		noi disp in red "option {it:popshare} can't be combined with option {it:aggregate}" _c /* 
		*/ " or with subcommand {it:wb}" _n
		error
	}
	
	if ("`frame_prefix'" == "") {
		local frame_prefix "pip_"
	}
	
	/*==================================================
	Defaults           
	==================================================*/
	
	*---------- API defaults
	pip_set_server  `server', `pause'
	*return add
	local url       = "`r(url)'"
	local server    = "`r(server)'"
	local base      = "`r(base)'"
	local base_grp  = "`r(base_grp)'"
	
	
	//========================================================
	// versions
	//========================================================
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
	
	
	*---------- One-on-one execution
	if ("`subcommand'" == "cl" & lower("`country'") == "all") {
		noi disp in red "you cannot use option {it:countr(all)} with subcommand {it:cl}"
		error 197
	}
	
	*---------- PPP
	if (lower("`country'") == "all" & "`ppp'" != "") {
		noi disp as err "Option {it:ppp()} is not allowed with {it:country(all)}"
		error
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
	if ("`country'" == "" & "`region'" == "") local country "all"
	if ("`country'" != "") {
		if (lower("`country'") != "all") local country = upper("`country'")
		else                             local country "all"
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
	
	*---------- Country and region
	if  ("`country'" != "") & ("`region'" != "") {
		noi disp in r "options {it:country()} and {it:region()} are mutually exclusive"
		error
	}
	
	if ("`aggregate'" != "") {
		if ("`ppp'" != ""){
			noi di  as err "Option PPP cannot be combined with aggregate."
			error 198
		}
		noi disp as res "Note: " as text "Aggregation is only possible over reference years."
		local agg_display = "Aggregation in base year(s) `year'"
	}
	
	if (wordcount("`country'")>2) {
		if ("`ppp'" != ""){
			noi di as err "Option PPP can only be used with one country."
			error 198
		}
	}
	
	
	/*==================================================
	Execution 
	==================================================*/
	pause pip - before execution
	
	*---------- Information
	if ("`information'" != ""){
		noi pip_info, `clear' `pause' server(`server') version(`version')
		return add 
		exit
	}	
	
	*---------- Country Level (one-on-one query)
	if ("`subcommand'" == "cl") {
		
		noi disp in red "Subcommand {it:cl} is temporary out of service."
		exit
		
		noi pip_cl, country("`country'")  /// this needs to accommodate to new structure
		year("`year'")                    ///
		povline("`povline'")              ///
		ppp("`ppp'")                      ///
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
	
	foreach `i_call' of local `pcall' {	
		
		// --- timer
		if ("`timer'" != "") {
			local i_on = `i'
			scalar tt = tt + "`crlf' `i': pip_query loop"
			local i_off = `i++'
		}	
		// --- timer
		
		// --- timer
		if ("`timer'" != "") timer on `i_on'
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
		ppp("`ppp'")                            ///
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
			local query = "`query_ys'&`query_ct'&`query_cv'&`query_pl'`query_pp'`query_ds'&`version_qr'&format=csv"
		}
		else{
			local query = "`query_ys'&`query_ct'&`query_cv'&`query_ps'`query_pp'`query_ds'&`version_qr'&format=csv"
		}
		return local query_`f' "`query'"
		global pip_query = "`query'"
		
		*---------- Base + query
		if ("`aggregate'" != "" | "`subcommand'" == "wb"){
			local queryfull "`base_grp'?`query'"
		}
		else{
			local queryfull "`base'?`query'"
		}
		
		return local queryfull_`f' = "`queryfull'"
		
		// --- timer
		if ("`timer'" != "") timer off `i_off'
		// --- timer
		
		// --- timer
		if ("`timer'" != "") {
			local i_on = `i'
			scalar tt = tt + "`crlf' `i': download loop"
			local i_off = `i++'
		}	
		// --- timer
		
		// --- timer
		if ("`timer'" != "") timer on `i_on'
		// --- timer
		
		
		/*==================================================
		Download  and clean data
		==================================================*/
		
		*---------- download data
		cap import delimited  "`queryfull'", `clear' varn(1)
		if (_rc) {
			noi dis ""
			noi dis in red "It was not possible to download data from the PIP API."
			noi dis ""
			noi dis in white `"(1) Please check your Internet connection by "' _c 
			noi dis in white  `"{browse "`url'/health-check" :clicking here}"'
			noi dis in white `"(2) Test that the data is retrievable. By"' _c
		  noi dis in white  `"{stata pip test: clicking here }"' _c
			noi dis in white  "you should be able to download the data."
			noi dis in white `"(3) Please consider adjusting your Stata timeout parameters. For more details see {help netio}"'
			noi dis in white `"(4) Please send us an email to:"'
			noi dis in white _col(8) `"email: data@worldbank.org"'
			noi dis in white _col(8) `"subject: pip query error on `c(current_date)' `c(current_time)'"'
			noi di ""
			error 673
		}
		
		
		// --- timer
		if ("`timer'" != "") timer off `i_off'
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
		if ("`timer'" != "") {
			local i_on = `i'
			scalar tt = tt + "`crlf' `i': data clean loop"
			local i_off = `i++'
		}	
		// --- timer
		
		// --- timer
		if ("`timer'" != "") timer on `i_on'
		// --- timer
		
		*---------- Clean data
		pip_clean `rtype', year("`year'") `iso' /* 
		*/ region(`region') `pause' `wb' version(`version')
		
		pause after cleaning
		// --- timer
		if ("`timer'" != "") timer off `i_off'
		// --- timer
		
		/*==================================================
		Display Query
		==================================================*/
		
		if ("`dipsquery'" == "" & "`rc'" == "0") {
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
	
	// --- timer
	if ("`timer'" != "") {
		noi disp tt
		noi timer list
	}
	// --- timer
	
	return local npl = `f'
	
	// ------------------------------
	//  display results 
	// ------------------------------
	
	local n2disp = min(`c(N)', `n2disp')
	noi di as res _n "{ul: first `n2disp' observations}"
	
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
			noi list country_code year poverty_line headcount  /*
			*/  mean median welfare_type in 1/`n2disp',  /* 
			*/  abbreviate(12)  sepby(country_code)
		}
		else {
			sort year 
			noi list year poverty_line headcount mean , /*
			*/ abbreviate(12) sepby(poverty_line)
		}		
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
	
	* citations
	local cite `"Please cite as: XXXXX (2021) "pip: Stata module to access World Bank’s Global Poverty and Inequality data," Statistical Software Components 2022, Boston College Department of Economics."'
	notes: `cite'
	
	noi disp in y _n `"`cite'"'
	
	return local cite `"`cite'"'
	
	
	//========================================================
	// Convert to povcalnet format
	//========================================================
	
	
	if ("`povcalnet_format'" != "") {
		pause before povcalnet format
		pip_povcalnet_format  `rtype', `pause'
	}
	
	//========================================================
	//  Drop frames created in the middle of the process
	//========================================================
	
	
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
	* set trace off
	
} // end of qui
end


// ------------------------------------------------------------------------
// MATA functions
// ------------------------------------------------------------------------


* findfile stata.trk
* local fn = "`r(fn)'"

cap mata: mata drop pip_*()
mata:

// function to look for source of code
void pip_source(string scalar cmd) {
	
	cmd =  cmd :+ "\.pkg"
	
	fh = _fopen("`fn'", "r")
	
	pos_a = ftell(fh)
	pos_b = 0
	while ((line=strtrim(fget(fh)))!=J(0,0,"")) {
		if (regexm(strtrim(line), cmd)) {
			fseek(fh, pos_b, -1)
			break
		}
		pos_b = pos_a
		pos_a = ftell(fh)
	}
	
	src = strtrim(fget(fh))
	if (rows(src) > 0) {
		src = substr(src, 3)
		st_local("src", src)
	} 
	else {
		st_local("src", "NotFound")
	}
	
	fclose(fh)
}

end 



exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:

Version Control:

*! version 0.2.0.9002   <2022apr04>
*! version 0.2.0        <2022apr01>
*! version 0.1.7        <2022mar30>
*! version 0.1.6        <2022mar28>
*! version 0.1.5.9001   <2022mar28>
*! version 0.1.5        <2022mar25>
*! version 0.1.4        <2022mar18>
*! version 0.1.3        <2022mar18>
*! version 0.1.2.9000   <2022mar17>
*! version 0.1.2        <2022feb07>
*! version 0.1.1        <2022feb01>
*! version 0.1.0.9010   <2022feb01>
*! version 0.1.0        <2022feb01>
*! version 0.0.2.9000   <2022jan19>
*! version 0.0.2        <2022jan12>
*! version 0.0.1        <2021dec01>


*##s
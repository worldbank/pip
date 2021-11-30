*! version 1.0.0  	<sept2018>
/*=======================================================
Program Name: pip.ado
Author:		  
R.Andres Castaneda Aguilar
Jorge Soler Lopez
Espen Beer Prydz	
Christoph Lakner	
Ruoxuan Wu				
Qinghua Zhao			
World Bank Group	

project:	  Adoptation Stata package (from povcalnet) to easily query the [PIP API]
Dependencies: The World Bank - DEC
-----------------------------------------------------------------------
Creation Date:    Sept 2018
Modification Date:   23 Aug 2021 - 18:24:22
Do-file version:    02
References:          
Output: 
=======================================================*/

/*==================================================
              0: Program set up
==================================================*/
program define pip, rclass
version 16.1

syntax [anything(name=subcommand)]  ///
[,                             	   /// 
	COUNtry(string)                /// 
	REGion(string)                 /// 
	YEAR(string)                   /// 
	POVline(numlist)               /// 
	POPShare(numlist)	   		   /// 
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
] 

if ("`pause'" == "pause") pause on
else                      pause off

qui {
	// --- timer
	local timer = "GIsj"
	local crlf "`=char(10)'`=char(13)'"
	scalar tt = ""
	
	if ("`timer'" != "") {
		timer clear
		local i = 1
	}
	// --- timer
	
	//========================================================
	// Conditions
	//========================================================
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
	
	// ------------------------------------------------------------------------
	// New session procedure
	// ------------------------------------------------------------------------
	
	if ("${pip_cmds_ssc}" == "") {
		
		// ---------------------------------------------------------------
		// Update PIP 
		// ---------------------------------------------------------------
		
		* mata: povcalnet_source("povcalnet") // creates local src
		_pip_find_src pip
		local src = "`r(src)'"
		
		* If PIP was installed from github
		if (regexm("`src'", "github")) {
			local git_cmds pip
			
			foreach cmd of local git_cmds {
				
				* Check repository of files 
				* mata: povcalnet_source("`cmd'")
				_pip_find_src `cmd'
				local src = "`r(src)'"
				
				if regexm("`src'", "\.io/") {  // if site
					if regexm("`src'", "://([^ ]+)\.github") {
						local repo = regexs(1) + "/`cmd'"
					}
				}
				else {  // if branch
					if regexm("`src'", "\.com/([^ ]+)(/`cmd')") {
						local repo = regexs(1) + regexs(2) 
					}
				}
						
				qui github query `repo'
				local latestversion = "`r(latestversion)'"
				if regexm("`r(latestversion)'", "v([0-9]+)\.([0-9]+)\.([0-9]+)"){
					local lastMajor = regexs(1)
					local lastMinor = regexs(2)
					local lastPatch = regexs(3)		 
				}
					
				qui github version `cmd'
				local crrtversion =  "`r(version)'"
				if regexm("`r(version)'", "v([0-9]+)\.([0-9]+)\.([0-9]+)"){
					local crrMajor = regexs(1)
					local crrMinor = regexs(2)
					local crrPatch = regexs(3)
				}
				foreach x in repo cmd {
					local `x' : subinstr local `x' "." "", all 
					local `x' : subinstr local `x' "-" ".", all 
					if regexm("``x''", "v([0-9]+)(\.)?([a-z]+)?([0-9]?)") {
					 disp regexs(1) regexs(2) regexs(4)
				  }
					
				}

				* force installation 
				if ("`crrtversion'" == "") {
					github install `repo', replace
					cap window stopbox note "github command has been reinstalled to " ///
					"keep record of new updates. Please type discard and retry."
					global pip_cmds_ssc = ""
					exit 
				}
				
				if (`lastMajor' > `crrMajor' | `lastMinor' > `crrMinor' | `lastPatch' > `crrPatch') {
				* if (`lastMajor'`lastMinor'`lastPatch' > `crrMajor'`crrMinor'`crrPatch') {
					cap window stopbox rusure "There is a new version of `cmd' in Github (`latestversion')." ///
					"Would you like to install it now?"
					
					if (_rc == 0) {
						cap github install `repo', replace
						if (_rc == 0) {
							cap window stopbox note "Installation complete. please type" ///
							"discard in your command window to finish"
							local bye "exit"
						}
						else {
							noi disp as err "there was an error in the installation. " _n ///
							"please run the following to retry, " _n(2) ///
							"{stata github install `repo', replace}"
							local bye "error"
						}
					}	
					else local bye ""
					
				}  // end of checking github update
				
				else {
					noi disp as result "Github version of {cmd:`cmd'} is up to date."
					local bye ""
				}
				
			} // end of loop
			
		} // end if installed from github 
		
		else if (regexm("`src'", "repec")) {  // if pip was installed from SSC
			qui adoupdate pip, ssconly
			if ("`r(pkglist)'" == "pip") {
				cap window stopbox rusure "There is a new version of pip in SSC." ///
				"Would you like to install it now?"
				
				if (_rc == 0) {
					cap ado update pip, ssconly update
					if (_rc == 0) {
						cap window stopbox note "Installation complete. please type" ///
						"discard in your command window to finish"
						local bye "exit"
					}
					else {
						noi disp as err "there was an error in the installation. " _n ///
						"please run the following to retry, " _n(2) ///
						"{stata ado update pip, ssconly update}"
						local bye "error"
					}
				}
				else local bye ""
			}  // end of checking SSC update
			else {
				noi disp as result "SSC version of {cmd:pip} is up to date."
				local bye ""
			}
		}  // Finish checking pip update 
		else {
			noi disp as result "Source of {cmd:pip} package not found." _n ///
			"You won't be able to benefit from latest updates."
			local bye ""
		}
		
		/*==================================================
		Dependencies         
		==================================================*/
		*---------- check SSC commands
		
		local ssc_cmds missings 
		
		noi disp in y "Note: " in w "{cmd:pip} requires the packages " ///
		"below from SSC: " _n in g "`ssc_cmds'"
		
		foreach cmd of local ssc_cmds {
			capture which `cmd'
			if (_rc != 0) {
				ssc install `cmd'
				noi disp in g "{cmd:`cmd'} " in w _col(15) "installed"
			}
		}
		
		adoupdate `ssc_cmds', ssconly
		if ("`r(pkglist)'" != "") adoupdate `r(pkglist)', update ssconly
		
		global pip_cmds_ssc = 1  // make sure it does not execute again per session
		`bye'
	}
	
	
	/*==================================================
	Defaults           
	==================================================*/
	
	*---------- API defaults
	
	if "`server'"!=""  {
		
		if !inlist(lower("`server'"), "int", "testing", "ar") {
			noi disp in red "the server requested does not exist" 
			error
		}
	
		if (lower("`server'") == "int")     {
			local server "${pip_svr_in}"
		}
		if (lower("`server'") == "testing") {
			local server "${pip_svr_ts}"
		}
		if (upper("`server'") == "AR") {
			local server "${pip_svr_ar}"
		}
		
		if ("`server'" == "") {
			noi disp in red "You don't have access to internal servers" _n /* 
					*/ "You're being redirected to public server"
			local server "https://pipscoreapiqa.worldbank.org"
			*local server "http://wzlxqpip01.worldbank.org"
		}
		
	}
	else {
		local server "https://pipscoreapiqa.worldbank.org"
		*local server "http://wzlxqpip01.worldbank.org"
	}
		
	local base             = "`server'/api/v1/pip"	
	*local base2             = "`server'/api/v1/pip-grp" // to exteract aggregated result 
	local base2             = "http://wzlxqpip01.worldbank.org/api/v1/pip-grp"
	return local server    = "`server'"
	
	//------------ Check internet connection
	// --- timer
	if ("`timer'" != "") {
		timer on `i'
		scalar tt = tt + "`crlf' `i': Check internet connection"
	}
	// --- timer
		
	scalar tpage = fileread(`"`server'/api/v1/pip?format=csv"')
	
	if regexm(tpage, "error") {
		noi disp in red "You may not have Internet connections. Please verify"
		error
	}
	// --- timer	
	if ("`timer'" != "") timer off `i++'
	// --- timer

	
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
		local country ""
		local aggregate ""
		local subcommand "wb"
		local wb_change 1
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
		local povline = 1.9
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
		if (c(N) != 0 & "`clear'" == "" & /* 
		*/ "`information'" == "") {
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
		noi pip_info, `clear' `pause' server(`server')
		return add 
		exit
	}	
	
	*---------- Country Level (one-on-one query)
	if ("`subcommand'" == "cl") {
		noi pip_cl, country("`country'")  ///
		year("`year'")                   ///
		povline("`povline'")             ///
		ppp("`ppp'")                     ///
		server("`server'")               ///
		coverage(`coverage')             /// 
		`clear'                          ///
		`iso'                            ///
		`pause'
		return add
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
		pip_query,   country("`country'")  ///
		region("`region'")                     ///
		year("`year'")                         ///
		povline("`i_povline'")                 ///
		popshare("`i_popshare'")	   					  ///
		ppp("`ppp'")                         ///
		coverage(`coverage')                   ///
		server(`server')                       ///
		`clear'                                ///
		`information'                          ///
		`iso'                                  ///
		`fillgaps'                             ///
		`aggregate'                            ///
		`wb'                                   ///
		`pause'                                ///
		`groupedby'                            //
		
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
			local query = "`query_ys'&`query_ct'&`query_cv'&`query_pl'`query_pp'`query_ds'&format=csv"
		}
		else{
			local query = "`query_ys'&`query_ct'&`query_cv'&`query_ps'`query_pp'`query_ds'&format=csv"
		}
		return local query_`f' "`query'"
		global pip_query = "`query'"
		
		*---------- Base + query
		if ("`aggregate'" != ""){
		    local queryfull "`base2'?`query'"
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
		local rc = 0
		
		local qr = 1 // query round		
		while (`qr' <= `querytimes') {
			
			tempfile clfile
			cap copy "`queryfull'" `clfile'
			if (_rc == 0) {
				cap insheet using `clfile', clear name
				if (_rc != 0) local rc "in"
				continue, break
			} 
			else {
				local rc "copy"
				local ++qr
			} 
		}
		
		pause tefera 1 check time taken to excute the following processes - to be removed
		
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
		*/ rc(`rc') region(`region') `pause' `wb'
		
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
			if ("`query_ys'" != "") noi di as res "Year:"         as txt "{p 4 6 2} `query_ys' {p_end}"
			if ("`query_ct'" != "") noi di as res "Country:"      as txt "{p 4 6 2} `query_ct' {p_end}"
			if ("`query_pl'" != "") noi di as res "Poverty line:" as txt "{p 4 6 2} `query_pl' {p_end}"
			if ("`query_ps'" != "") noi di as res "Population share:" as txt "{p 4 6 2} `query_ps' {p_end}"
			if ("`query_ds'" != "") noi di as res "Aggregation:"  as txt "{p 4 6 2} `query_ds' {p_end}"
			if ("`query_pp'" != "") noi di as res "PPP:"          as txt "{p 4 6 2} `query_pp' {p_end}"
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
		sort  year regioncode
		noi list region year povertyline headcount mean in 1/`n2disp', /*
		*/ abbreviate(12)  sepby(year)
	}
	
	else {
		if ("`aggregate'" == "") {
			sort countrycode year regioncode
			noi list countrycode year povertyline headcount mean median datatype /*
			*/ in 1/`n2disp',  abbreviate(12)  sepby(countrycode)
		}
		else {
			sort year
			noi list year povertyline headcount mean , /*
			*/ abbreviate(12) sepby(povertyline)
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
	local cite `"Please cite as: Castaneda Aguilar, R. A., C. Lakner, E. B. Prydz, J. S. Lopez, R. Wu and Q. Zhao (2019) "pip: Stata module to access World Bank’s Global Poverty and Inequality data," Statistical Software Components 2019, Boston College Department of Economics."'
	notes: `cite'
	
	noi disp in y _n `"`cite'"'
	
	return local cite `"`cite'"'
	
} // end of qui
end

//========================================================
// Aux programs
//========================================================

program define _pip_find_src, rclass 
syntax anything(name=cmd id="Package name")

qui {
	preserve
	drop _all
	
	// find stata.trk file 
	findfile stata.trk
	local fn = "`r(fn)'"
	
	// create copy
	tempfile statatrk
	copy "`r(fn)'" "`statatrk'"
	
	// import copy into stata
	import delimited using `statatrk',  bindquote(nobind)
	
	gen n = _n    // line number
	
	// find line where the package is used
	levelsof n if regexm(v1, "`cmd'.pkg"), sep(,) loca(pklines)
	
	if (`"`pklines'"' == `""') local src = "NotInstalled"
	else {
	
		// the latest source and subtract which refers to the source 
		local sourceline = max(0, `pklines') - 1 
		
		// get the source without the initial S
		if regexm(v1[`sourceline'], "S (.*)") local src = regexs(1)
	}
	
	// return info 
	return local src = "`src'"
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


*##s

findfile stata.trk
local fn = "`r(fn)'"

mata:
cmd = "pip"
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
	src
	
end 


*##e
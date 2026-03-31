*!version 0.11.0  <2026mar19>
/*==================================================
project:       Useful function to use across pip
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    16 May 2023 - 18:14:47
Modification Date:   19 Mar 2026
Do-file version:    02
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_utils, rclass
	version 16.1
	
	//========================================================
	//  SET UP
	//========================================================
	
	pip_parseopts `0'
	mata: pip_retlist2locals("`r(returnnames)'")
	
	if (ustrregexm(`"`subcmd'"', "(.+) (if .+)")) {
		local subcmd = trim(ustrregexs(1))
		local if = trim(ustrregexs(2))
	}
	//========================================================
	// Execute 
	//========================================================
	
	if ("`subcmd'" == "dropvars") {
		pip_utils_dropvars
		exit
	}
	
	//------------ display query
	
	if ("`subcmd'" == "dispquery") {
		pip_utils_disp_query
		exit
	}

	//  -------------- frame to locals
	if ("`subcmd'" == "frame2locals") {
		pip_utils_frame2locals
		return add
		exit
	}
	
	
	// frame exists
	if ustrregexm("`subcmd'", "^frame") {
		pip_utils_frameexists, `frame'
		return add
		exit
	}
	
	if ("`subcmd'" == "finalmsg") {
		noi pip_utils_final_msg
		return add
		exit
	}
	
	if ("`subcmd'" == "keepframes") {
		pip_utils_keep_frame, `frame_prefix' `keepframes' `efficient'
		exit
	}
	if ustrregexm("`subcmd'", "^click"){
		pip_utils_clicktable `if', `variable' `title' `statacode' `length' `width'
		exit
	}
	//------------ Output result display
	if ("`subcmd'" == "output") {
		noi pip_utils_output, `n2disp' `sortvars' `dispvars' `sepvar' `worldcheck'
		exit
	}
	
	
end

//========================================================
//  Programs
//========================================================
//------------ display query

program define pip_utils_disp_query
/*
Purpose: Print each query in ${pip_last_queries} to the console in
         human-readable key=value format.
Syntax:  pip_utils_disp_query  (no arguments)
Returns: None (display only)
*/
	
	foreach q of global pip_last_queries {
		disp "{res}{hline}"
		disp "{res}full query:" _n"{txt}`q'" _n
		
		gettoken endpoint q : q, parse("?")
		gettoken par q : q, parse("&")
		
		while ("`par'" != "") {
			if ("`par'" == "&") {
				gettoken par q : q, parse("&")
				continue
			}
			
			gettoken par_name par_value: par , parse("=")
			local par_value: subinstr local par_value "=" ""
			if (ustrregexm("`par_name'", "\?")) {
				local par_name: subinstr local par_name "?" ""
			}
			disp "{res}`par_name':{col 20}{txt}`par_value'"
			gettoken par q : q, parse("&")
		}	
	}
	
	disp "{res}endpoint:{col 20}{txt}`endpoint'"
	disp "{res}host:{col 20}{txt}${pip_host}"
	disp "{res}{hline}"
	
	
end

//------------ drop missing vars

program define pip_utils_dropvars
/*
Purpose: Drop variables that are entirely missing or empty-string.
         Numeric vars are dropped if r(N)==0 after sum.
         String vars are dropped if all values are "." or "".
         Note: misstable summarize would do this in a single pass;
         the current per-variable approach is sufficient for the
         narrow pip variable set (typically <100 vars).
Syntax:  pip_utils_dropvars  (no arguments; operates on current dataset)
Returns: None (modifies dataset in place; emits a note if vars dropped)
*/

	ds, has(type numeric)
	local numvars `r(varlist)'
	ds, not(type numeric)
	local strvars `r(varlist)'

	foreach v of local numvars {
		qui sum `v'
		if (`r(N)' == 0) local droplist `droplist' `v'
	}
	foreach v of local strvars {
		qui count if missing(`v') | `v' == "."
		if (`r(N)' == c(N)) local droplist `droplist' `v'
	}

	if "`droplist'" != "" { 
		drop `droplist' 
		di "{p}note: `droplist' dropped{p_end}" // from missings.ado
	}
	
end


program define pip_utils_frameexists, rclass
/*
Purpose: Test whether a named Stata frame exists.
Syntax:  pip_utils_frameexists, frame(name)
Returns: r(fexists) — 1 if frame exists, 0 otherwise
*/
	syntax, frame(string)
	
	mata: st_local("fexists", strofreal(st_frameexists("`frame'")))
	return local fexists = `fexists'
end 


program define pip_utils_final_msg, rclass
/*
Purpose: Display the standard pip citation prompt after each query.
         First call in a session displays interactively (noi pip_cite);
         subsequent calls within the same old session are quiet.
Syntax:  pip_utils_final_msg  (no arguments)
Returns: r(cite_data) — citation string (from pip_cite)
*/
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
	return add

end

//------------ Keep or drop frames
program define pip_utils_keep_frame
/*
Purpose: After a pip query, optionally copy internal _pip_* frames to
         user-visible frames (with a user-chosen prefix) and optionally
         drop the internal frames to free memory.
Syntax:  pip_utils_keep_frame, [frame_prefix(string)] [keepframes] [noEFFICIENT]
Returns: None (modifies frame environment)
*/
	syntax , [ frame_prefix(string) keepframes noEFFICIENT]
	if ("`frame_prefix'" == "") {
		local frame_prefix "pip_"
	}
	
	frame dir
	local av_frames "`r(frames)'"
	
	foreach fr of local av_frames {
		// Only process internal frames with _pip_ prefix
		if (substr("`fr'", 1, 5) != "_pip_") continue
		local frbase = substr("`fr'", 6, .)
		// If user wants to keep frames
		if ("`keepframes'" != "") {
			local frname = "`frame_prefix'" + "`frbase'"
			frame copy `fr' `frname', replace
		}
		// If user wants to drop them
		if ("`efficient'" == "noefficient") {
			frame drop `fr'
		}
	} // end frame loop
end

program define pip_utils_clicktable
/*
Purpose: Display a compact clickable table of variable levels.
         Each level is rendered as a Stata {stata ...} link.
Syntax:  pip_utils_clicktable [if], variable(varname) [title(str)]
         [statacode(str)] [length(numlist)] [width(integer)]
Returns: None (display only)
*/
	syntax [if] , VARiable(varname) ///
	[                     ///
	title(string)         ///
	STATAcode(string)     ///
	length(numlist)     /// number of elements per row
	width(integer 36)      ///
	]
	
	quietly levelsof `variable' `if', local(tmp) clean
	if (`"`tmp'"' == `""') exit
	
	//------------ get length of string for formatting
	qui if ("`length'" == "") {
		tempvar tvar
		cap confirm string var `variable'
		if (_rc) {
			tostring `variable', gen(`tvar')
		}
		else clonevar `tvar' = `variable'
	
		local vtype: type `tvar'
		local vtype: subinstr local vtype "str" ""
		// 36 is a nice display length ()
		local length = floor(`width'/(`vtype'+2))
	}
	
	noi disp in y `"`title'"'
	local statacode: subinstr local statacode "obsi" "`=uchar(96)'obsi`=uchar(39)'", all
	
	local current_line = 0
	foreach obsi of local tmp {
		local current_line = `current_line' + 1 
		local display_this = `"{stata `statacode': `obsi'}"'
		if (`current_line' < `length') noi display in y `"`display_this'"' _continue 
		else{
			noi display in y `"`display_this'"' 
			local current_line = 0
		}
	}
	
	disp _n
	
end

//------------ Final display message
program define pip_utils_output
/*
Purpose: Display the first n2disp rows of the query result.
         When worldcheck is set and WLD rows exist, shows WLD rows only.
Syntax:  pip_utils_output, [n2disp(int)] [sortvars(varlist)]
         [dispvars(varlist)] [sepvar(varlist)] [worldcheck]
Returns: None (display only)
Notes:   Uses preserve/restore for the worldcheck path; restore is
         unconditional even on list error to prevent dataset corruption.
*/
	syntax  [, ///
		n2disp(integer 1) ///
		sortvars(varlist) ///
		dispvars(varlist) ///
		sepvar(varlist)   ///
		worldcheck        ///
	]
	local n2disp = min(`c(N)', `n2disp')
	
	//Display header
	if      `n2disp'==1 local MSG "first observation"
	else if `n2disp' >1 local MSG "first `n2disp' observations"
	else                local MSG "No observations available"
	noi dis as result _n "{ul:`MSG'}"

	//Worldcheck checks if observations should be displayed only for WLD region
	local rflag=0
	if "`worldcheck'"!="" {
		qui count if region_code=="WLD"
		if `r(N)'>=`n2disp' {
            preserve
            qui keep if region_code=="WLD"
            local rflag=1
        }
	}
	
	//DISPLAY OUTPUT
	//Arguments below could be generalised to argument if desired
	local dispopts abbreviate(12) noobs
	//Sort if specified [could also use gsort if and remove varlist]
	if "`sortvars'"!="" sort `sortvars'
	//Print output; restore is unconditional to prevent dataset corruption
	//if list errors (e.g., a variable in dispvars no longer exists).
	if `rflag'==1 {
		capture {
			if `n2disp'!=0 noi list `dispvars' in 1/`n2disp', `dispopts' sepby(`sepvar')
		}
		local _list_rc = _rc
		restore
		if `_list_rc' error `_list_rc'
	}
	else {
		if `n2disp'!=0 noi list `dispvars' in 1/`n2disp', `dispopts' sepby(`sepvar')
	}

end

//  -------------- frame to locals
program define pip_utils_frame2locals, rclass
/*
Purpose: Return every cell of the current dataset as an r() macro.
         Intended for SMALL reference tables only (e.g., pip version
         metadata frames with < 20 rows).
         Each cell is returned as r(<varname>_<row_number>).
Syntax:  pip_utils_frame2locals  (no arguments; operates on c. frame)
Returns: r(<var>_<n>) for each variable and row
Notes:   Hard limit: max 50 rows. Stata r() is not designed for hundreds
         of macros; callers iterating large frames should use frameput.
*/
	if `c(N)' > 50 {
		noi disp as error "pip_utils frame2locals: frame has `c(N)' rows " ///
			"(max 50). Use a different approach for large frames."
		error 198
	}
	qui ds
	local vars = "`r(varlist)'"
	forvalues ob = 1/`c(N)' {
		foreach var of local vars {
			return local `var'_`ob' = `var'[`ob']
		}
	}
end 

exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


* For dispquery 


noi di as res "full query:" as txt "{p 4 6 2} `queryfull' {p_end}" _n
noi di as res "See in browser: "  `"{browse "`queryfull'":here}"'  _n 
noi di as res "Download .csv: "  `"{browse "`queryfull'&format=csv":here}"' 

noi di as res _dup(20) "-"
noi di as res "No. Obs:"      as txt _col(20) c(N)
noi di as res "{hline}"

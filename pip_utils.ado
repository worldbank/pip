/*==================================================
project:       Useful function to use across pip
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    16 May 2023 - 18:14:47
Modification Date:   21 Jul 2024 - 20:39:11 (DClarke)
Do-file version:    01
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
	
	if ustrregexm(`"`subcmd'"', "(.+) (if .+)") {
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
		pip_uitls_disp_query
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

program define pip_uitls_disp_query
	
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
	
	ds
	local varlist `r(varlist)'
	foreach v of local varlist {

        cap confirm numeric variable `v'
        if (_rc) {
            count if `v' == "."
            local Ndots = r(N)
        }
        else local Ndots = 0
		count if missing(`v')
        local Nmiss = r(N)
        local Tmiss = `Nmiss' + `Ndots'

		if (`Tmiss' == c(N)) { 
			local droplist `droplist' `v' 
		} 
	}
	if "`droplist'" != "" { 
		drop `droplist' 
		di "{p}note: `droplist' dropped{p_end}" // from missings.ado
	}
	
end


program define pip_utils_frameexists, rclass
	syntax, frame(string)
	
	mata: st_local("fexists", strofreal(st_frameexists("`frame'")))
	return local fexists = `fexists'
end 


program define pip_utils_final_msg, rclass
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
	
	* Install alternative version
	if ("${pip_old_session}" == "") {
		noi pip_${pip_source} msg
	}
end

//------------ Keep or drop frames
program define pip_utils_keep_frame
	syntax , [ frame_prefix(string) keepframes noEFFICIENT]
	if ("`frame_prefix'" == "") {
		local frame_prefix "pip_"
	}
	
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
end

program define pip_utils_clicktable
	
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
	//Print output
	if `n2disp'!=0 noi list `dispvars' in 1/`n2disp', `dispopts' sepby(`sepvars')
	if `rflag'==1 restore

end

//  -------------- frame to locals
program define pip_utils_frame2locals, rclass
	qui ds
	local vars = "`r(varlist)'"
	numlist "1/`c(N)'"
	local obs = r(numlist)
	foreach var of local vars {
		foreach ob of local obs {
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

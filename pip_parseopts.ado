*! version 0.11.0  <2026mar23>
/*==================================================
project:       Parse options of pip command to be use by mata
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    10 May 2023 - 17:45:53
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_parseopts, rclass
	version 16.1
	
	
	/*==================================================
	1: parse subcommand
	==================================================*/
	
	gettoken subcmd opts: 0, parse(",")
	if ("`subcmd'" == ",") {
		local subcmd ""
	}
	else gettoken comma opts: opts, parse(",")
	
	if (`"`subcmd'"' != `""') {
		local returnnames "subcmd"
		return local subcmd = trim(`"`subcmd'"')
	}
	
	
	/*==================================================
	Parse options
	==================================================*/
	if (`"`opts'"' != "") {
		return local pipoptions = `"`opts'"'
		local returnnames "`returnnames' pipoptions"
	}
	
	gettoken opt opts: opts, bind
	
	while (`"`opt'"' != `""') {
		// identify type of option
		if ustrregexm(`"`opt'"', "([a-zA-Z0-9_]+)\(.*") {
			local optname = lower(ustrregexs(1))
		}
		else {
			if ustrregexm(lower("`opt'"), "(^no)(.+)") {
				local optname = ustrregexs(2)
			}
			else local optname = "`opt'"
		}
		// guard: derived optname must be a legal Stata name
		if ("`optname'" == "" | !regexm("`optname'", "^[a-zA-Z_][a-zA-Z0-9_]*$")) {
			di as error "pip_parseopts: invalid option name '`optname'' derived from '`opt''"
			error 198
		}
		// warn on duplicates (second value silently overwrites the first)
		if strpos(" `optnames' ", " `optname' ") {
			di as text "pip_parseopts: option '`optname'' specified more than once; last value used"
		}
		// return option as local
		return local `optname' = `"`opt'"'
		local returnnames "`returnnames' `optname'"
		local optnames "`optnames' `optname'"
		
		// next iteration
		gettoken opt opts: opts, bind
	}
	
	return local returnnames = ustrtrim("`returnnames'")
	return local optnames    = ustrtrim("`optnames'")
	
end

// pip_split_options is now in its own pip_split_options.ado file because
// Stata's ado auto-loader only retains the first program definition (matching
// the filename); sub-programs defined after the first `end` are discarded
// on auto-load and unavailable unless explicitly sourced.

exit
/* End of do-file */

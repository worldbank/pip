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

//========================================================
//  Split option names into general vs estimation options
//  (moved from pip.ado so tests can load this alone)
//========================================================
program define pip_split_options, rclass
/*
Purpose: Classify a list of raw option names into general options
         (version, release, ppp_year, identity, server, n2disp, cachedir)
         and estimation options (everything else).
         Supports prefix abbreviations down to abblength characters.
Syntax:  pip_split_options [optnames], [abblength(integer)]
Returns: r(gen_opts) — space-separated list of general option tokens
         r(est_opts) — space-separated list of estimation option tokens
*/
	syntax [anything(name=optnames)], [abblength(integer 3)]
	
	if ("`optnames'" == "") exit
	// current General options (Hard coded)
	local gen_opts "version ppp_year release identity server n2disp cachedir"
	
	// get abbreviation regex
	mata: pip_abb_regex(tokens("`gen_opts'"), `abblength', "patterns")
	
	// loop each options over each abbreviation
	foreach o of local optnames {  // options by the user
		local bsgo 0 // belongs to selected general options
		foreach p of local patterns {  // patterns for general opt abbreviations
			if regexm("`o'", "^`p'") {
				local sgo `"`sgo' `o'"' // selected general options
				local bsgo 1
				continue, break
			}
		}
		if (`bsgo' == 0) local oo `"`oo' `o'"' // estimation options
	}
	
	return local gen_opts = "`sgo'"
	return local est_opts = "`oo'"
	
end

exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



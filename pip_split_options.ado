*! version 0.11.0  <2026mar23>
/*==================================================
project:       Split option names into general vs estimation options
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    23 Mar 2026
Note:             Extracted from pip_parseopts.ado so Stata's
                  ado auto-loader can discover it independently.
                  (Sub-programs defined after the first `end` in
                  an ado file are NOT retained by the auto-loader.)
==================================================*/

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

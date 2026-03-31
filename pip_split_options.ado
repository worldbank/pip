*! version 0.11.0  <2026mar23>
/*==================================================
project:       Split option names into general vs estimation options
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    23 Mar 2026
Note:             INTERNAL HELPER — no stability guarantee.
                  Extracted from pip_parseopts.ado so Stata's
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
Args:    optnames:    space-separated list of option names to classify
         abblength(): minimum prefix length for abbreviation matching
                      (default: 3, range: 1–5)
Returns: r(gen_opts) — space-separated list of general option tokens
         r(est_opts) — space-separated list of estimation option tokens
*/
	version 16.1
	syntax [anything(name=optnames)], [abblength(integer 3)]
	
	// validate abblength range (shortest gen-opt name is 6 chars; x=abblength-1 must be < that)
	if `abblength' < 1 | `abblength' > 5 {
		di as error "pip_split_options: abblength() must be between 1 and 5"
		error 125
	}
	
	// explicit empty return contract — avoids stale r() from prior rclass calls
	if ("`optnames'" == "") {
		return local gen_opts ""
		return local est_opts ""
		exit
	}
	
	// General options canonical list (must match pip_split_options.ado)
	local gen_opts_src "version ppp_year release identity server n2disp cachedir"
	
	// build abbreviation regex patterns
	mata: pip_abb_regex(tokens("`gen_opts_src'"), `abblength', "gen_patterns")
	
	// classify each option; $ end-anchor prevents prefix false-matches
	// (e.g. "verbosity" must not match the "version" pattern)
	foreach o of local optnames {
		local bsgo 0 // belongs to selected general options
		foreach p of local gen_patterns {
			if regexm("`o'", "^`p'$") {
				local gen_opt_tokens `"`gen_opt_tokens' `o'"'
				local bsgo 1
				continue, break
			}
		}
		if (`bsgo' == 0) local est_opt_tokens `"`est_opt_tokens' `o'"'
	}
	
	return local gen_opts = ustrtrim("`gen_opt_tokens'")
	return local est_opts = ustrtrim("`est_opt_tokens'")
	
end

exit
/* End of do-file */

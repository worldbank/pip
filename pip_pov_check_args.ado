/*==================================================
project:       Evaluate the logical consistency of arguments for poverty estimation
Author:        R.Andres Castaneda 
----------------------------------------------------
Creation Date:    11 May 2023 - 17:45:06
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_pov_check_args, rclass
	syntax [anything(name=subcmd)] ///
	[ ,                             /// 
	COUntry(string)                 /// 
	REGion(string)                  /// 
	YEAR(string)                    /// 
	POVLine(numlist)                /// 
	POPShare(numlist)	   	          /// 
	CLEAR                           /// 
	COVerage(string)                /// 
	] 
	
	version 16
	
	
	//========================================================
	// setup
	//========================================================
	
	
	local version    = "${pip_version}"		
	tokenize "`version'", parse("_")
	local ppp_year = `3'
	
	return local ppp_year = "ppp_year(`ppp_year')"
	local optnames "`optnames' ppp_year"
	
	//------------ Get auxiliary data
	pip_timer pov_check_args.info, on
	pip_auxframes
	pip_timer pov_check_args.info, off
	
	//========================================================
	// General checks
	//========================================================
	
	
	//------------ year
	if ("`year'" == "") local year "all"
	else if (lower("`year'") == "all") local year "all"
	else if (lower("`year'") == "last") local year "last"
	else if (ustrregexm("`year'"), "[a-zA-Z]+") {
		noi disp "{err} `year' is not a valid {it:year} value" _n /* 
		*/  "only numeric values are accepted{txt}" _n
		error
	}
	else {
		numlist "`year'"
		local year = r(numlist)
	}
	
	return local year = "year(`year')"
	local optnames "`optnames' year"
	
	
	*---------- Coverage
	if ("`coverage'" == "") local coverage = "all"
	local coverage = lower("`coverage'")
	
	foreach c of local coverage {	
		
		if !inlist(lower("`c'"), "national", "rural", "urban", "all") {
			noi disp in red `"option {it:coverage()} must be "national", "rural",  "urban" or "all" "'
			error
		}	
	}
	return local coverage = "coverage(`coverage')"
	local optnames "`optnames' coverage"
	
	
	//------------ Region
	if ("`region'" != "") {
		local region = upper("`region'")
		
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
		pip_auxframes
		local frpiprgn "_pip_regions`_version'" 
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
	
	//------------empty data
	if !ustrregexm("`subcmd'", "^info") {
		if (c(changed) != 0 & "`clear'" == "") {	
			noi di as err "You must start with an empty dataset; or enable the option {it:clear}."
			error 4
		}	
		drop _all
	}
	
	//========================================================
	//  Country Level (cl)
	//========================================================
	
	if ("`subcmd'" == "cl") {
		//------------ Poverty line 
		// defined popshare and defined povline = error
		if ("`popshare'" != "" & "`povline'" != "")  {
			noi disp as err "povline and popshare cannot be used at the same time"
			error
		}
		// Blank popshare and blank povline = default povline 1.9
		else if ("`popshare'" == "" & "`povline'" == "")  {
			
			if ("`ppp_year'" == "2005") local povline = 1.25
			if ("`ppp_year'" == "2011") local povline = 1.9
			if ("`ppp_year'" == "2017") local povline = 2.15
		}
		return local povline  = "povline(`povline')"
		return local popshare = "popshare(`popshare')"
		local optnames "`optnames' povline popshare"
		
		//------------ fillgaps
		
		return local fillgaps = "`fillgaps'"
		local optnames "`optnames' fillgaps"
		
		
		*---------- Country
		local country = stritrim(ustrtrim("`country' `region'"))
		if (lower("`country'") != "all") local country = upper("`country'")
		if ("`country'" == "") local country "all" // to modify
		return local country = "country(`country')"
		local optnames "`optnames' country"
		
	}
	
	
	//========================================================
	// Aggregate level (wb)
	//========================================================
	
	
	if ("`subcmd'" == "wb") {
		if ("`country'" != "") {
			noi disp as err "option {it:country()} is not allowed with subcommand {it:wb}"
			noi disp as res "Note: " as txt "subcommand {it:wb} only accepts options {it:region()} and {it:year()}"
			error
		}
		
		if ("`fillgaps'" != "") {
			noi disp "{res}Note:{txt} option {it:fillgaps} not allowed with " /* 
			*/  "subcommand {cmd:wb}."
			error
		}
		
		// poshare
		if ("`popshare'" != "") {
			noi disp in red "option {it:popshare()} can't be combined " /* 
			*/ "with subcommand {it:wb}" _n
			error
		}
		
		if ("`region'" != "") {
			return local region = "region(`region')"
			local optnames "`optnames' region"
		}
		
		// poverty line 
		
		if ("`povline'" == "")  {
			
			if ("`ppp_year'" == "2005") local povline = 1.25
			if ("`ppp_year'" == "2011") local povline = 1.9
			if ("`ppp_year'" == "2017") local povline = 2.15
		}
		return local povline  = "povline(`povline')"
		local optnames "`optnames' povline"
		
	}
	
	//========================================================
	//  Country profiles (cp)
	//========================================================
	
	//========================================================
	// Return options names
	//========================================================
	
	
	return local optnames "`optnames'"
	
end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
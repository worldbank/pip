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
PPP_year(numlist)          /// to change with new round
CLEAR                           /// 
COVerage(string)                /// 
SERver(string)                  /// 
VERsion(string)                 ///
IDEntity(string)                ///
RELease(numlist)                ///
] 

version 16


//========================================================
// setup
//========================================================
//------------ get server url
if ("${pip_host}" == "" | "`server'" != "") {
	pip_set_server,  server(`server')
}

//------------ Set versions
noi pip_versions, server(`server') ///
version(`version')                ///
release(`release')               ///
ppp_year(`ppp_year')             ///
identity(`identity')  

local version    = "`r(version)'"
local ppp_year   = "`r(ppp_year)'"

return local version = "version(`version')"
return local ppp_year = "ppp_year(`ppp_year')"
local optnames "`optnames' version ppp_year"


//------------ Get auxiliary data
pip_info, clear justdata `pause' server(`server') version(`version')

//========================================================
// Checks
//========================================================

// poshare
if ("`popshare'" != "" &  lower("`subcmd'") == "wb") {
	noi disp in red "option {it:popshare()} can't be combined " /* 
	*/ "with subcommand {it:wb}" _n
	error
}

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


*---------- WB aggregate

if ("`subcmd'" == "wb") {
	if ("`country'" != "") {
		noi disp as err "option {it:country()} is not allowed with subcommand {it:wb}"
		noi disp as res "Note: " as txt "subcommand {it:wb} only accepts options {it:region()} and {it:year()}"
		error
	}
}

// empty data
if !ustrregexm("`subcmd'", "^info") {
	if (c(changed) != 0 & "`clear'" == "") {	
		noi di as err "You must start with an empty dataset; or enable the option {it:clear}."
		error 4
	}	
	drop _all
}

//------------ year
if ("`year'" != "") {
	numlist "`year'"
	local year = r(numlist)
}
if ("`year'" == "") local year "all"
return local year = "year(`year')"
local optnames "`optnames' year"

*---------- Country
local country = stritrim(ustrtrim("`country' `region'"))
if (lower("`country'") != "all") local country = upper("`country'")
if ("`country'" == "") local country "all" // to modify
return local country = "country(`country')"
local optnames "`optnames' country"



//========================================================
// Return options names
//========================================================


return local optnames "`optnames'"

end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

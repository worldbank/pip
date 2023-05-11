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
PPP_year(numlist)               ///
CLEAR                           /// 
INFOrmation                     /// 
COVerage(string)                /// 
ISO                             /// 
SERver(string)                  /// 
pause                           /// 
FILLgaps                        /// 
N2disp(integer 1)               /// 
DISPQuery                       ///
querytimes(integer 5)           ///
TIMEr                           ///
POVCALNET_format                ///
noEFFICIENT                     ///
KEEPFrames                      ///
frame_prefix(string)            ///
replace                         ///
VERsion(string)                 ///
IDEntity(string)                ///
RELease(numlist)                ///
TABle(string)                   ///
path(string)                    ///
noCACHE                         ///
cachedir(string)                ///
cachedelete                     ///
cacheforce                      ///
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

local version_qr = "`r(version_qr)'"
local version    = "`r(version)'"
local release    = "`r(release)'"
local ppp_year   = "`r(ppp_year)'"
local identity   = "`r(identity)'"


//------------ Get auxiliary data
pip_info, clear justdata `pause' server(`server') version(`version')

//========================================================
// Checks
//========================================================

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

// defined popshare and defined povline = error
else if ("`popshare'" != "" & "`povline'" != "")  {
	noi disp as err "povline and popshare cannot be used at the same time"
	error
}

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
		return local region = "region(`region')" 
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
	
	if (c(N) != 0 & "`clear'" == "") {
		
		noi di as err "You must start with an empty dataset; or enable the option {it:clear}."
		error 4
	}	
	drop _all
}




end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

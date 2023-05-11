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




end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

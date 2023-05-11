/*==================================================
project:       Interaction with the PIP API at the country level
Author:        R.Andres Castaneda 
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     5 Jun 2019 - 15:12:13
Modification Date:  October, 2021 
Do-file version:    01
References:          
Output:             dta
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_cl, rclass
syntax ///
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

version 16.0

if ("`pause'" == "pause") pause on
else                      pause off

qui {
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




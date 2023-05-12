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
FILLgaps                        /// 
COVerage(string)                /// 
CLEAR                           /// 
ISO                             /// 
SERver(string)                  /// 
pause                           /// 
POVCALNET_format                ///
replace                         ///
VERsion(string)                 ///
IDEntity(string)                ///
RELease(numlist)                ///
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
	if ("`version'" == "") {  // this should never be true
		noi pip_versions, server(`server') ///
		version(`version')                ///
		release(`release')               ///
		ppp_year(`ppp_year')             ///
		identity(`identity')  
		local version    = "`r(version)'"		
	}
	//------------ Get auxiliary data
	pip_info, clear justdata `pause' server(`server') version(`version')
	
	//========================================================
	// Build query (queries returned in ${pip_last_queries}) 
	//========================================================
	pip_cl_query, country(`country') region(`region') year(`year') ///
	              povline(`povline') popshare(`popshare')  `fillgaps' ///
								ppp(`ppp_year') coverage(`coverage') ///
								version(`version')
								
	
	
	//========================================================
	// download data
	//========================================================
	pip_get, `clear' `cacheforce'
	
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




/*==================================================
project:       Cache previous results of pip command
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     3 May 2023 - 11:06:35
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_cache, rclass
syntax [anything(name=subcmd)], [   ///
query(string)               ///
PREfix(string)              ///
cachedir(string)            ///
piphash(string)             ///
clear                       ///
cacheforce                  ///
]

version 16.0

/*++++++++++++++++++++++++++++++++++++++++++++++++++
SET UP
++++++++++++++++++++++++++++++++++++++++++++++++++*/


if ("${pip_cachedir}" == "0") {
	return local piphash = "0"
	return local pc_exists = 0 
	exit
}


if ("`subcmd'" == "gethash") {
	pip_cache_gethash, query(`"`query'"')
	return add
	exit
}



/*==================================================
1:load
==================================================*/

if ("`subcmd'" == "load") {
	pip_cache gethash, query(`query')
	local piphash = "`r(piphash)'"
	return local piphash = "`piphash'"
	
	if ("`cacheforce'" != "") {
		return local pc_exists = 0 
		exit
	}
	
	// check if cache already pc_exists
	mata: st_local("pc_file", pathjoin("${pip_cachedir}", "`piphash'.dta"))
	cap confirm file "`pc_file'"
	if _rc {        
		return local pc_exists = 0 
		exit
	} 
	else {
		return local pc_exists = 1
		use "`pc_file'", `clear'
		exit
	}
}

/*==================================================
3: saves
==================================================*/

if ("`subcmd'" == "save") {
	mata: st_local("pc_file", pathjoin("${pip_cachedir}", "`piphash'.dta"))
	cap confirm new file "`pc_file'"
	if (_rc == 0 | "`cacheforce'" != "") {
		char _dta[piphash] `piphash'
		char _dta[pipquery] `query'
		qui save "`pc_file'", replace
	}
	exit
}

//========================================================
// Delete cache
//========================================================

if ("`subcmd'" == "delete") {
	local pc_files: dir "${pip_cachedir}" files  "_pc*"
	local nfiles: word count `pc_files'
	
	noi disp "{err:Warning:} you will delete `nfiles' cache files." _n ///
	"Do you want to continue? (Y/n)", _request(_confirm)
	
	if (lower("`confirm'") == "y") {
		foreach f of local pc_files {
			erase "${pip_cachedir}/`f'"
		}
	}
	
}


if (ustrregexm("`subcmd'","^iscache")) {
	noi pip_cache_iscache
	return add
	exit
}


end


program define pip_cache_gethash, rclass
syntax [anything(name=subcmd)], [   ///
query(string)               ///
PREfix(string)              ///
]

version 16.0

qui {
	if ("`prefix'" == "") local prefix = "pip"
	tempname spiphash
	
	mata:  st_numscalar("`spiphash'", hash1(`"`prefix'`query'"', ., 2)) 
	local piphash = "_pip" + strofreal(`spiphash', "%12.0g")
	return local piphash = "`piphash'"
}

end


program define pip_cache_iscache, rclass

local iscache: char _dta[piphash]
if ("`iscache'" != "") {
	disp "{res}Yes! {txt}this is cached data :)"
	local query: char _dta[pipquery]
	return local query = "`query'"	
}
else {
	disp "{err}No. {txt} this is not cached data :("
}

return local hash = "`iscache'"
end


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



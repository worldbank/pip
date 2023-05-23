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
	syntax [anything(name=subcmd)], ///
	[                               ///
	query(string)                   ///
	PREfix(string)                  ///
	cachedir(string)                ///
	piphash(string)                 ///
	clear                           ///
	cacheforce                      ///
	*                               ///
	]
	
	version 16.0
	
	/*++++++++++++++++++++++++++++++++++++++++++++++++++
	SET UP
	++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	if ("`subcmd'" == "info") {
		noi pip_cache_info, `options'
		exit
	}
	
	
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
	3: save
	==================================================*/
	
	if ("`subcmd'" == "save") {
		mata: st_local("pc_file", pathjoin("${pip_cachedir}", "`piphash'.dta"))
		cap confirm new file "`pc_file'"
		if (_rc == 0 | "`cacheforce'" != "") {
			char _dta[piphash] `piphash'
			char _dta[pipquery] `query'
			qui save "`pc_file'", replace
			
			//------------ write cache infor file
			
			tempname hd
			file open `hd' using "${pip_cachedir}/pip_cache_info.txt", write append
			file write `hd' "`piphash' , `query'" _n
			file close `hd'
			
		}
		exit
	}
	
	//========================================================
	// Delete cache
	//========================================================
	
	if ("`subcmd'" == "delete") {
		local pc_files: dir "${pip_cachedir}" files  "_pip*"
		local nfiles: word count `pc_files'
		
		noi disp "{err:Warning:} you will delete `nfiles' cache files." _n ///
		"Do you want to continue? (Y/n)", _n(2)  _request(_confirm)
		
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



//========================================================
// Cache info
//========================================================

program define pip_cache_info, rclass
	
	local rname = floor(runiform(1e4, 99999))
	tempname cache_txt 
	local hnd "cache_info_`rname'"
	
	frame create `hnd'
	frame create `cache_txt'
	
	//========================================================
	//  Call original Date
	//========================================================
	qui frame `cache_txt' {
		import delimit "${pip_cachedir}/pip_cache_info.txt", clear
		split v2, gen(ep) parse(?)
		split ep2, gen(par) parse(&)
		qui ds par*
		local level1 = "`r(varlist)'"
		qui foreach v of local level1 {
			split `v', gen(`v'_) parse(=)
		}
		
		local cN = `c(N)'
	}
	
	
	//========================================================
	// Organize data into  readable format
	//========================================================
	
	// Create a frame whose vars are each available parameter
	// associated with a particular hash. 
	
	qui frame `hnd' {
		set obs `cN'
		gen hash = ""
		gen query = ""
		
		forvalues i = 1/`cN' {  // for each observation
			
			foreach v of loca level1 {  // forech parameter
				local vname  = _frval(`cache_txt', `v'_1, `i')
				local vvalue = _frval(`cache_txt', `v'_2, `i')
				
				// if par does not exists of is format
				if inlist("`vname'", "", "format") continue 
				cap confirm var `vname'
				if (_rc) gen     `vname' = "`vvalue'" in `i'
				else     replace `vname' = "`vvalue'" in `i'
			}
			
			replace hash  = _frval(`cache_txt', v1, `i') in `i'
			replace query = _frval(`cache_txt', v2, `i') in `i'
		}
	}  // end of frame
	
	noi disp "{title:Cache data available}"
	noi disp "{res}Filter your data per parameter"
	qui frame `hnd' {
		local novars "hash query"
		qui ds
		local vars = "`r(varlist)'"
		local vars: list vars - novars
	
		foreach v of local vars {
			local vtype: type `v'
			local vtype: subinstr local vtype "str" ""
			// 36 is a nice display length ()
			local l = floor(36/(`vtype'+2))
			
			noi pip_utils click, variable(`v') title("{title:`v'} {col 10}{hline 20}") /* 
			 */ statacode("pip_cache_info, `v'(obsi) frame(`hnd')") length(`l')
		}
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



/*==================================================
project:       Cache previous results of pip command
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     3 May 2023 - 11:06:35
Modification Date:          
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
		return add
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
			
			mata: st_local("fuse", pathjoin("${pip_cachedir}", "pip_cache_info.txt"))
			tempname hd
			file open `hd' using "`fuse'", write append
			file write `hd' "`piphash' , `query'" _n
			file close `hd'
			
		}
		exit
	}
	
	//========================================================
	// Delete cache
	//========================================================
	
	if ("`subcmd'" == "delete") {
		noi pip_cache_delete, piphash(`piphash') cachedir(`cachedir')
		
	}
	
	
	if (ustrregexm("`subcmd'","^iscache")) {
		noi pip_cache_iscache
		return add
		exit
	}
	
	
end


//------------ Get Hash based on string 
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

//------------ Check if it is cached

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

//------------ Delete

program define pip_cache_delete, rclass
	syntax [, piphash(string) cachedir(string)]
		
	if ("`cachedir'" == "") local cachedir "${pip_cachedir}"
	if ("`piphash'" == "") {
		local pc_files: dir "`cachedir'" files  "_pip*"
		local nfiles: word count `pc_files'
		
		noi disp "{err:Warning:} you will delete `nfiles' cache files." _n ///
		"Do you want to continue? (Y/n)", _n(2)  _request(_confirm)
		
		if (lower("`confirm'") == "y") {
			foreach f of local pc_files {
				erase "`cachedir'/`f'"
				}
			erase "`cachedir'/pip_cache_info.txt"
		}
	}
	else {
		local piphash = ustrtrim("`piphash'")
		local f2delete "`cachedir'/`piphash'.dta"
		
		cap confirm file "`f2delete'"
		if (_rc) {
			noi disp "{err:Cache file }{cmd:`piphash'.dta }{err:not found}"
		}
		else {
			erase "`f2delete'"
		}
		// locals tempf and origf are created in MATA routine
		local cfile "`cachedir'/pip_cache_info.txt"
		mata: pip_replace_in_pattern("`cfile'", `"`piphash'"', `""')
		copy `tempf' "`origf'" , replace 
		
		noi disp "cache {res:`piphash'} deleted"
		
	}
	
end

//========================================================
// Cache info
//========================================================

program define pip_cache_info, rclass
	syntax [, condition(string) frame(string)]
	
	local rname = floor(runiform(1e4, 99999))
	
	// Make sure name is not repeated (very rare)
	if ("`frame'" != "") {
		if ustrregexm("`frame'", "(.*)([0-9]{5}$)") local fname = ustrregexs(2)
		while ("`rname'" == "`fname'") {
	local rname = floor(runiform(1e4, 99999))
	}
	}
	
	if (`"`condition'"' == `""') {
		mata: pip_drop_cache_info_frames()
		
		tempname cache_txt 
		local frame "cache_info_`rname'"
		frame create `frame'	
		frame create `cache_txt'
		
		//========================================================
		//  Call original Date
		//========================================================
		qui frame `cache_txt' {
			import delimited hash query using "${pip_cachedir}/pip_cache_info.txt", /* 
			*/ clear delimiters(",")
			* pause on 
			* pause cache_txt
			split query, gen(ep) parse(?)
			gen endpoint = ustrregexs(2) if ustrregexm(ep1, "(.*)/([^/]+)$")
			split ep2, gen(par) parse(&)
			qui ds par*
			local level1 = "`r(varlist)'"
			qui foreach v of local level1 {
				split `v', gen(`v'_) parse(=)
			}
			
			//------------Key for linking frames
			gen n = _n
			local cN = _N
		}
		
		//========================================================
		// Organize data into  readable format
		//========================================================
		
		// Create a frame whose vars are each available parameter
		// associated with a particular hash. 
		
		qui frame `frame' {
			set obs `cN'
			gen n = _n
			frlink 1:1 n, frame(`cache_txt')
			
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
				
				* replace hash  = _frval(`cache_txt', hash, `i') in `i'
				* replace query = _frval(`cache_txt', query, `i') in `i'
			}
			
			frget hash query endpoint, from(`cache_txt')
		}  // end of frame
		
	}  // end of condition == ""
	
	
	//========================================================
	// Treat frames for new stage 
	//========================================================
	local frame2 "cache_info_`rname'"
	if ("`frame'" != "`frame2'") frame copy `frame' `frame2'
	
	if (`"`condition'"' != `""') {
		qui frame `frame2': keep if `condition'
	}
	
	//========================================================
	// Display initial conditions
	//========================================================
	// sleep number 18007179503
	frame `frame2' {
		local nobs = _N
		
		if (`nobs' > 1) {
			
			noi disp "{break}{title:{res:Cache data available}} " /* 
			*/ "{txt:{it:(Filter your data by parameter)}}" _n
			
			
			local novars "hash query n"
			qui ds, has(type string)
			local vars = "`r(varlist)'"
			local vars: list vars - novars
			
			foreach v of local vars {				
				//------------ Unique values
				tempvar uniq
				qui bysort `v': gen byte `uniq' = (_n==_N) if `v' != ""
				qui summ `uniq', meanonly
				if (r(sum) > 1) local filterable = "{txt:{it:(filterable)}}"
				else            local filterable = ""
				
				//------------ build call of pip_utils click
				local condition = `"condition(`"`v' == "obsi""')"'
				noi pip_utils click, variable(`v') title("{title:`v'} `filterable'") /* 
				*/ statacode(`"pip_cache info, `condition' frame(`frame2')"')
				
			} // end for parameters loop
			disp _n
			
		} // end if more than one data available
		else {
			*##s
			local incsv = ustrtrim(query[1])
			local injson: subinstr local incsv "&format=csv" ""
			if ustrregexm("`incsv'","(.+)/(.+)\?(.+)") {
				local host       = ustrregexs(1)
				local endpoint   = ustrregexs(2)
				local parameters = ustrregexs(3)
			}
			local hash =  ustrtrim(hash[1])
			
			noi disp _n "{title:Cache information for selected query}" _n
			noi disp "{p2col 10 36 36 30:attribute}{dup 8: }value{p_end}" /*  
			*/   "{p2colset 10 30 32 30}" /* 
			*/   "{p2line}" /* 
			*/   "{p2col :{res:hash}}{txt:`hash'}{p_end}"  /* 
			*/   "{p2col :{res:host}} {txt:`host'}{p_end}" /* 
			*/   "{p2col :{res:endpoint}} {txt:`endpoint'}{p_end}" 
			
			tokenize "`parameters'", parse("&")
			local i = 1
			while ("`1'" != "") {
				if ("`1'" == "&") {
					macro shift
					continue
				}
				if (`i' == 1) {
					local aname "parameters"
					local i = `i' + 1
				}
				else          local aname "."
				noi disp "{p2col :{res:`aname'}} `1'{p_end}" 
				macro shift
			}
			noi disp "{p2line}" 
			
			//------------ Build  Stata calls
			mata: st_local("fuse", pathjoin("${pip_cachedir}", "`hash'.dta"))
			local duse    `"use "`fuse'", clear "'
			local ddelete `"pip_cache delete,  piphash(`hash')"'
			
			noi disp "{break}{pstd}{ul:{res:ACTION}}{p_end}"        _n /* 
			*/ `"{pmore}{stata `"`duse'"':use}{p_end}"'             _n /* 
			*/ `"{pmore}{browse "`injson'":see in browser}{p_end}"' _n /* 
			*/ `"{pmore}{browse "`incsv'":download .csv}{p_end}"'   _n /* 
			*/ `"{pmore}{stata `"`ddelete'"':delete}{err: {it: (use with caution)}}{p_end}"' 
			
			*##e
		} // end of else 
	} // end of frame2
	
	return local cache_file = "`fuse'"
	return local piphash    = "`hash'"
	return local f_json     = "`injson'"
	return local f_csv      = "`incsv'"
	return local host       = "`host'"
	return local endpoint   = "`endpoint'"
	
end


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



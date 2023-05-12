/*==================================================
project:       Get data from API of from cache
Author:        R.Andres Castaneda 
----------------------------------------------------
Creation Date:    12 May 2023 - 11:32:30
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_get, rclass
syntax , [ clear cacheforce]

if (c(changed) != 1 & "`clear'" == "") error 4

tempname tempframe
frame create `tempframe'
frame `tempframe' {
	tempfile fpip_get
	save `fpip_get', empty
	
	foreach query of global pip_last_queries {
		local queryfull "${pip_host}/`query'"
		
		pip_cache load, query("`queryfull'") `cacheforce' `clear'
		local pc_exists = "`r(pc_exists)'"
		local piphash   = "`r(piphash)'"
		
		if ("`pc_exists'" == "0" | "`${pip_cachedir}'" == "0") {	
			import delimited  "`queryfull'", `clear' varn(1) asdouble
			pip_cache save, piphash("`piphash'") query("`queryfull'") /* 
			             */  `cacheforce'
		}
		append using `fpip_get'
		save `fpip_get', replace
	}	
}

frame copy `tempframe' `c(frame)', replace


end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

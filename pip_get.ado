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
			cap import delimited  "`queryfull'", `clear' varn(1) asdouble
			if  (_rc) pip_download_err_msg
			pip_cache save, piphash("`piphash'") query("`queryfull'") /* 
			*/  `cacheforce'
		}
		append using `fpip_get'
		save `fpip_get', replace
	}	
}

frame copy `tempframe' `c(frame)', replace

end


//========================================================
// auxiliary Programs
//========================================================

//------------ Error messages when downloading

program define pip_download_err_msg
noi {
	dis ""
	dis in red "It was not possible to download data from the PIP API."
	dis ""
	dis in white `"(1) Please check your Internet connection by "' _c 
	dis in white  `"{browse "${pip_host}/health-check" :clicking here}"'
	dis in white `"(2) Test that the data is retrievable. By"' _c
	dis in white  `"{stata pip test, server(`server'): clicking here }"' _c
	dis in white  "you should be able to download the data."
	dis in white `"(3) Please consider adjusting your Stata timeout parameters. For more details see {help netio}"'
	dis in white `"(4) Please send us an email to:"'
	dis in white _col(8) `"email: pip@worldbank.org"'
	dis in white _col(8) `"subject: pip query error on `c(current_date)' `c(current_time)'"'
	di ""
	error 673
}
end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

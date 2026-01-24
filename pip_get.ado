/*==================================================
project:       Get data from API
Author:        R.Andres Castaneda 
----------------------------------------------------
Creation Date:    12 May 2023 - 11:32:30
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_get, rclass
	version 16.1
	syntax , [         ///
	clear              ///
	gname(string)      ///
	]
	
	if (c(changed) != 1 & "`clear'" == "") error 4
	
	if ("`gname'" == "") local gname pip_last_queries
	
	tempname tempframe
	frame create `tempframe'
	qui frame `tempframe' {
		tempfile fpip_get
		save `fpip_get', empty
		
		foreach query of global `gname' {
			local queryfull "${pip_host}/`query'"
			
			cap import delimited  "`queryfull'", `clear' varn(1) asdouble
			if  (_rc) noi pip_download_err_msg "`queryfull'"
				
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
	args query
	local json: subinstr local query "&format=csv" ""
	local trouble "https://github.com/worldbank/pip#troubleshooting"
	
	noi {
		dis "{pstd}{err}It was not possible to download data from the PIP API.{p_end}"
		dis "{pstd}{err}Please, troubleshoot in the following order:{p_end}"
		dis "{phang2}{res}(1) {txt}Check your Internet connection by "  /*   
		*/ `"{browse "${pip_host}/health-check" :clicking here}"' "{p_end}"
		dis "{phang2}{res}(2) {txt}Check that you can see the data in " /* 
	  */	  `"{browse "`json'" :JSON }"' "format in your browser and " /* 
	  */  "that you can download the data in " `"{browse "`query'" :csv }"' "{p_end}"
		dis "{phang2}{res}(3) {txt}Consider adjusting your Stata timeout parameters. For more details see {help netio}{p_end}"
		dis "{phang2}{res}(4) {txt}Follow the instructions " /* 
		 */ `"{browse "`trouble'" :here}"' ".{p_end}"
		di ""
	}
	error 673
end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

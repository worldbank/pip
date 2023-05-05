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
        cachedir(string)            ///
        piphash(string)             ///
        clear                       ///
				replace                     ///
				cacheforce                  ///
        ]
version 16.0


/*++++++++++++++++++++++++++++++++++++++++++++++++++
SET UP
++++++++++++++++++++++++++++++++++++++++++++++++++*/

if ("`cachedir'" == "") {
    local cachedir "./_pip_cache"
    cap mkdir "`cachedir'"
}


/*==================================================
              1:load
							==================================================*/

if ("`subcmd'" == "load") {
    mata:  st_numscalar("piphash", hash1(`"pip `query'"', ., 2)) 
    local piphash = "_pc" + strofreal(piphash, "%12.0g")
		
		if ("`cacheforce'" != "") {
			return local piphash = "`piphash'"
      return local pc_exists = 0 
      exit
		}

    // check if cache already pc_exists
    local pc_file "`cachedir'/`piphash'.dta"
    cap confirm file "`pc_file'"
    if _rc {
        return local piphash = "`piphash'"
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
    local pc_file "`cachedir'/`piphash'.dta"
    char _dta[piphash] `piphash'
    char _dta[pipquery] `query'
    save "`pc_file'", `replace'
}

//========================================================
// Delete cache
//========================================================

if ("`subcmd'" == "delete") {
		local pc_files: dir "`cachedir'" files  "_pc*"
		local nfiles: word count `pc_files'
		
		noi disp "{err:Warning:} you will delete `nfiles' cache files." _n ///
		"Do you want to continue? (Y/n)", _request(_confirm)
		
		if (lower("`confirm'") == "y") {
			foreach f of local pc_files {
				erase "`cachedir'/`f'"
			}
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



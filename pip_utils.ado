/*==================================================
project:       Useful function to use across pip
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    16 May 2023 - 18:14:47
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
program define pip_utils, rclass
version 16

pip_parseopts `0'
mata: pip_retlist2locals("`r(optnames)'")

/*==================================================
          1: drop obs 
==================================================*/

if ("`subcmd'" == "dropvars") {
	ds
	local varlist `r(varlist)'
	foreach v of local varlist { 
		count if missing(`v') 
		if r(N) == c(N) { 
			local droplist `droplist' `v' 
		} 
	}
	if "`droplist'" != "" { 
		drop `droplist' 
		di "{p}note: `droplist' dropped{p_end}" // from missings.ado
	}
	exit
}


/*==================================================
              2: 
==================================================*/





end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



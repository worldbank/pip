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

//========================================================
//  SET UP
//========================================================

pip_parseopts `0'
mata: pip_retlist2locals("`r(optnames)'")


//========================================================
// Execute 
//========================================================

if ("`subcmd'" == "dropvars") {
	pip_utils_dropvars
	exit
}

//------------ display query

if ("`subcmd'" == "dispquery") {
	pip_uitls_disp_query
}


end

//========================================================
//  Programs
//========================================================
//------------ display query

program define pip_uitls_disp_query

foreach q of global pip_last_queries {
	disp "{res}{hline}"
	disp "{res}full query:" _n"{txt}`q'" _n
	
	gettoken endpoint q : q, parse("?")
	gettoken par q : q, parse("&")
	
	while ("`par'" != "") {
		if ("`par'" == "&") {
			gettoken par q : q, parse("&")
			continue
		}
		
		gettoken par_name par_value: par , parse("=")
		local par_value: subinstr local par_value "=" ""
		if (ustrregexm("`par_name'", "\?")) {
			local par_name: subinstr local par_name "?" ""
		}
		disp "{res}`par_name':{col 20}{txt}`par_value'"
		gettoken par q : q, parse("&")
	}	
}

disp "{res}endpoint:{col 20}{txt}`endpoint'"
disp "{res}host:{col 20}{txt}${pip_host}"
disp "{res}{hline}"


end

//------------ drop missing vars

program define pip_utils_dropvars

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

end


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


* For dispquery 


noi di as res "full query:" as txt "{p 4 6 2} `queryfull' {p_end}" _n
	noi di as res "See in browser: "  `"{browse "`queryfull'":here}"'  _n 
	noi di as res "Download .csv: "  `"{browse "`queryfull'&format=csv":here}"' 
	
	noi di as res _dup(20) "-"
	noi di as res "No. Obs:"      as txt _col(20) c(N)
	noi di as res "{hline}"
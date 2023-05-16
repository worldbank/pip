/*==================================================
project:       Display quries components
Author:        R.Andres Castaneda 
----------------------------------------------------
Creation Date:    16 May 2023 - 10:29:26
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
program define pip_disp_query

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
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><


noi di as res "full query:" as txt "{p 4 6 2} `queryfull' {p_end}" _n
	noi di as res "See in browser: "  `"{browse "`queryfull'":here}"'  _n 
	noi di as res "Download .csv: "  `"{browse "`queryfull'&format=csv":here}"' 
	
	noi di as res _dup(20) "-"
	noi di as res "No. Obs:"      as txt _col(20) c(N)
	noi di as res "{hline}"
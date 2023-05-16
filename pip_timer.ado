/*==================================================
project:       Time different PIP processes
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    15 May 2023 - 22:12:27
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_timer, rclass
syntax [anything(name=label)], [on off PRINTtimer]
version 16


//========================================================
// set up
//========================================================
if ("`on'" != "" & "`off'" != "") {
	noi disp "{err}Options {it:on} and {it:off} are mutually exclusive{txt}"
	error
}

if (`"`label'"' == `""' & "`printtimer'" == "") {
	mata: r = pip_timeset()
	exit
}

//========================================================
// add timer
//========================================================

if (`"`label'"' != `""') {
	if ("`on'" == "" & "`off'" == "") {
		noi disp "{err}you must select either {it:on} off {it:off}{txt}"
		error
	}
}

if ("`on'" != "") {
	mata: r = pip_timer_on("`label'", r)
	exit
}


if ("`off'" != "") {
	mata: pip_timer_off("`label'", r)
		
	if ("`printtimer'" != "") {
		mata: pip_time_print_info(r)
	}
	exit
}

//========================================================
// Print
//========================================================

if ("`printtimer'" != "") {
	mata: pip_time_print_info(r)
	exit
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



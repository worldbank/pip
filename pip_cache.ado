/*==================================================
project:       submit the most popular queries
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     2 Feb 2022 - 11:05:15
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_cache, rclass
syntax [anything(name=subcmd)],         [ ///
STime(integer 100) /// Sleep Time
]
version 16


/*==================================================
1: 
==================================================*/

qui {
	
	*----------1.1:
	global pip_cmds_ssc = 1  // make sure it does not execute again per session
	local pp = round(runiform()*100, .01)  // random poverty line
	local stime 100
	
	if ("`subcmd'" == "") local subcmd "all"
	
	*----------1.2:
	
	if (inlist("`subcmd'"), "all", "global") {
		timer clear 1
		timer on 1
		pip, povline(`pp') clear
		pip wb, povline(`pp') clear
		timer off 1
		timer list 1
		
		local first_time = r(t1)
		disp `first_time'
		
		numlist "0.1(0.1)10"
		local pvcents = "`r(numlist)'"
		local npvc: word count `pvcents'
		
		
		numlist "10(1)50"
		local pvdollar = "`r(numlist)'"
		local npvd: word count `pvdollar'
		
		local est_time = `first_time'*`npvc' + ///   time on cents loop
		`first_time'*`npvd' + ///   time on dollars loop 
		(`npvd'+`npvc') * (`stime'/1000) // extra time if leep between calls
		
		
		/*=============================
		// Loop over poverty lines by cents
		=============================*/
		
		noi disp as txt ". " in y "= saved successfully"
		noi disp as txt "s " in y "= skipped - already exists (unchanged)"
		noi disp as err "x " in y "= skipped - already exists (changed)"
		noi disp as err "e " in y "= error"
		noi disp ""
		
		local i = 0
		noi _dots 0, title(Caching all countries and WB request from \$0.1 to \$10 by increments of 10 cents) reps(`npvc')	
		
		
		noi pip_time_convertor `est_time', type(Estimated)
		
		timer clear 2
		timer on 2
		foreach pv of local pvcents {
			local ++i
			
			cap {
				pip wb,  povline(`pv') clear 
				sleep `stime'
				pip,  povline(`pv') clear 
				sleep `stime'
			}
			if (_rc) {
				noi _dots `i' 2
			}
			else {
				noi _dots `i' 0
			}
		}
		
		//========================================================
		//  loop over poverty lines by dollars
		//========================================================
		
		
		local i = 0
		noi _dots 0, title(Caching all countries and WB request from \$10 to \$50 by dollar) reps(`npvd')	
		
		foreach pv of local pvdollar {
			local ++i
			cap {
				pip wb,  povline(`pv') clear 
				sleep `stime'
				pip,  povline(`pv') clear 
				sleep `stime'
			}
			if (_rc) {
				noi _dots `i' 2
			}
			else {
				noi _dots `i' 0
			}
			
		}
		
		timer off 2
		timer list 2
		local act_time = r(t2)
		
		noi pip_time_convertor `act_time', type(Actual)
		
	} // end of global condition
	
	if (inlist("`subcmd'"), "all", "country", "countries") {
		
		
		timer clear 3
		timer on 3
		pip, countr(COL) povline(`pp') clear // to initiate 
		pip, countr(COL) povline(`=`pp'+.01') clear // to initiate 
		pip, countr(COL) povline(`=`pp'+.01') clear // to initiate 
		timer off 3
		timer list 3
		
		local cty_time = r(t3)
		
		
		
		frame _pip_cts {
			levelsof country_code, local(countries) clean 
		}
		
		local ncty: word count `countries'
		
		* seconds of number of queries per country and poverty lines
		local cty_n_queries = `cty_time'*`ncty'*3  + ///   
		(`ncty'*3) * (`stime'/1000) // extra time if sleep between calls
		
		
		
		noi disp as txt ". " in y "= saved successfully"
		noi disp as txt "s " in y "= skipped - already exists (unchanged)"
		noi disp as err "x " in y "= skipped - already exists (changed)"
		noi disp as err "e " in y "= error"
		noi disp ""
		
		local i = 0
		noi _dots 0, title(caching country queries with basic poverty liens 1.90, 3.20, and 5.50) reps(`ncty')	
		
		
		noi pip_time_convertor `cty_n_queries', type(Estimated)
		
		timer clear 4
		timer on 4
		
		foreach country of local countries {
			local ++i
			
			cap {
				pip, countr(`country') clear
				sleep `stime'
				pip, countr(`country') povline(3.2)  clear
				sleep `stime'
				pip, countr(`country') povline(5.5)  clear
				sleep `stime'
			}
			if (_rc) {
				
				local cty_err "`cty_err' `country'"
			
				noi _dots `i' 2
			}
			else {
				noi _dots `i' 0
			}
			
		}
		
		
		timer off 4
		timer list 4
		
		local cty_actual = r(t4)
		noi pip_time_convertor `cty_actual', type(Actual)
		
		if ("`cty_err'" != "") {
			noi disp in red "countries with errors:" _n "`cty_err'"
		}
		
	} // end of countries condition
	
}

/*==================================================
2: 
==================================================*/


*----------2.1:


*----------2.2:





end


//========================================================
// Extra programs
//========================================================


program define pip_time_convertor , rclass
syntax anything(name=time id="time in seconds"), ///
type(string)                                     ///
[                                                ///
noPRINT                                          ///
]


if (mod(`time'/(3600), 2) >= 1) {
	
	local hour   = `time'/3600 - mod(`time'/3600,2) + 1
	local min_dec = 60*(mod(`time'/3600,2) - 1)
	local minute = round(`min_dec')
	local second = round(60*mod(`min_dec',1))
} 

else if (mod(`time'/60, 2) >= 1) {
	local hour     = 0
	local minute   = `time'/60 - mod(`time'/60,2) + 1
	local second   = round(60*(mod(`time'/60,2) - 1))		
} 
else {
	local hour     = 0
	local minute   = `time'/60 - mod(`time'/60,2) 
	local second = round(60*mod(`time'/60,2))
}

if ("`print'" == "") {
	disp _n "`type' time"
	disp in y "hours: `hour'" _n "minutes: `minute'" _n "seconds: `second'"
}

return local hours   = `hour'
return local minutes = `minute'
return local seconds = `second'


end


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



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
	pip, countr(COL) povline(51) clear // to initiate 
	*----------1.2:
	local stime 100
	timer clear 1
	timer on 1
	pip, clear
	pip wb, clear
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
  noi _dots 0, title(Caching all countries and WB request from \$0.1 to \$10 by cents) reps(`npvc')	
	
	
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
			noi disp in red "error in `x'" 
		}
		
	}
	
	timer off 2
	timer list 2
	local act_time = r(t2)
	
	noi pip_time_convertor `act_time', type(Actual)
	
	
	* frame _pip_countries {
		* levelsof country_code, local(countries) clean 
	* }
	
	* foreach country of local countries {
		
		* cap {
			* pip, countr(`country') clear
			* sleep `stime'
			* pip, countr(`country') povline(3.2)  clear
			* sleep `stime'
			* pip, countr(`country') povline(5.5)  clear
			* sleep `stime'
		* }
		* if (_rc) {
			* noi disp in red "error in `country'" 
		* }
		
	* }
	
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

		
	if (mod(`time'/60, 2) >= 1) {
		
		local minute   = `time'/60 - mod(`time'/60,2) + 1
		local second   = round(60*(mod(`time'/60,2) - 1))		
	} 
	else {
		local minute   = `time'/60 - mod(`time'/60,2) 
		local second = round(60*mod(`time'/60,2))
	}
	
	if ("`print'" == "") {
		disp in y "`type' time is `minute' minutes and `second' seconds"
	}
	
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



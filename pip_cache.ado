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
syntax [],         [ ///
STime(integer 1000) /// Sleep Time
]
version 16


/*==================================================
              1: 
==================================================*/


*----------1.1:


*----------1.2:
global stime 1000

pip, clear
sleep `stime'

forvalues x = 0.1(0.1)10 {
	
	cap {
		pip wb,  povline(`x') clear 
		sleep `stime'
		pip,  povline(`x') clear 
		sleep `stime'
	}
	if (_rc) {
		noi disp in red "error in `x'" 
	}
}


forvalues x = 10(1)50 {
	cap {
		pip wb,  povline(`x') clear 
		sleep `stime'
		pip,  povline(`x') clear 
		sleep `stime'
	}
	if (_rc) {
		noi disp in red "error in `x'" 
	}
	
}

frame _pip_countries {
	levelsof country_code, local(countries) clean 
}

foreach country of local countries {
	
	cap {
		pip, countr(`country') clear
		sleep `stime'
		pip, countr(`country') povline(3.2)  clear
		sleep `stime'
		pip, countr(`country') povline(5.5)  clear
		sleep `stime'
	}
	if (_rc) {
		noi disp in red "error in `country'" 
	}
}








/*==================================================
              2: 
==================================================*/


*----------2.1:


*----------2.2:





end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



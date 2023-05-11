/*==================================================
project:       Generate country profile data
Author:        Tefera 
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     9 Jun 2023
Modification Date:  
Do-file version:    01
References:          
Output:             dta
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_cp, rclass
version 16.0

syntax    [,       ///
country(string)       ///
povline(numlist)      ///
ppp_year(numlist)     ///
clear              ///
pause              ///
server(string)     ///
version(string)    ///
] 

if ("`pause'" == "pause") pause on
else                      pause off

qui {

	local country_q = "?country=`country'"
	local povline_q = "povline=`povline'"
	local ppp_year_q   = "ppp_version=`ppp_year'"
	local query_cp = "`country_q'&`povline_q'&`ppp_year_q'&format=csv"
	return local query_cp = "`query_cp'"
	
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
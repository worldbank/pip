/*==================================================
project:       display and load auxiliary tables in PIP
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    25 Mar 2022 - 14:38:22
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_tables, rclass
syntax [anything(name=table)], [ ///
server(string)                   ///
version(string)                  ///
release(numlist)                 ///
PPP_year(numlist)                ///
identity(string)                 ///
clear                            ///
]

version 16


/*==================================================
1: SET UP
==================================================*/
qui {
	
	*---------- API defaults
	local server "dev"
	qui pip_versions,                      ///
	      server(`server')                 ///
	      version(`version')               ///
	      release(`release')               ///
	      ppp_year(`ppp_year')             ///
	      identity(`identity')             
	
	local server     = "`r(server)'"
	local url        = "`r(url)'"
	local version    = "`r(version)'"
	local version_qr = "`r(version_qr)'"
	
	/*==================================================
	2: If table is selected
	==================================================*/
	
	if ("`table'" != "") {
		local table_call = "`url'/aux?table=`table'&`version_qr'&format=csv"
		import delimit "`table_call'", varn(1) `clear'
		return local table_call = "`table_call'"
		exit
	}
	
	/*==================================================
	3: If table is selected
	==================================================*/
	if ("`table'" == "") {
		preserve
		local table_call = "`url'/aux?`version_qr'&format=csv"
		import delimit "`table_call'", varn(1) clear
		return local table_call = "`table_call'"
		
		noi disp in y "Auxiliary tables available for `version':"
		local _N = _N
		forvalues i = 1/`_N' {
			if (length("`i'") == 1)  local j = "0" + "`i'"
			else                     local j = "`i'"
			
			local table = tables[`i']
			local pip_code "pip tables, table(`table') server(`server') version(`version') clear"
			
			noi disp _col(6) `"`j' {c |} {stata `pip_code':`table'}"'
		}
	}
} // end qui

end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



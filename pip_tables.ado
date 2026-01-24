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
	syntax , [                       ///
	table(string)                    ///
	clear                            ///
	]
	
	version 16.1
	
	
	/*==================================================
	1: SET UP
	==================================================*/
	
	*---------- API defaults
	local version_qr = "version=${pip_version}"
	tokenize "${pip_version}", parse("_")
	local _version   = "_`1'_`3'_`9'"
	
	/*==================================================
	get table
	==================================================*/
	
	//------------ get query
	if ("`table'" != "") {
		global pip_last_queries = "aux?table=`table'&`version_qr'&format=csv"
		local gname ""
	}
	else {
		preserve  // to return users original frame
		global pip_tables_call = "aux?`version_qr'&format=csv"
		local gname pip_tables_call
		local clear clear
	}
	
	//------------Get table
	
	pip_timer pip_tables.pip_get, on
	pip_get, `clear' gname(`gname')
	pip_timer pip_tables.pip_get, off
	
	return local table_call = "`table_call'"
	
	//========================================================
	// Formatting table
	//========================================================
	
	if ("`table'" != "") {
		
		* rename vars. Modify the following locals
		local oldvars "reporting_year survey_year"
		local newvars "year welfare_time"
		
		gettoken old oldvars : oldvars
		gettoken new newvars : newvars
		qui while ("`old'" != "") {
			cap confirm new var `old', exact
			if (_rc) cap confirm var `new', exact
			if (_rc) rename `old' `new' 
			
			gettoken old oldvars : oldvars
			gettoken new newvars : newvars
		}
		
		* to lower cases
		local tolvars "welfare_type"
		qui foreach t of local tolvars {
			cap confirm new var `t', exact
			if (_rc) replace `t' = lower(`t')		
		}
		
		exit
	}
	
	/*==================================================
	If table is NOT selected
	==================================================*/
	if ("`table'" == "") {
		noi disp in y "Auxiliary tables available for `version':"
		local _N = _N
		forvalues i = 1/`_N' {
			if (length("`i'") == 1)  local j = "0" + "`i'"
			else                     local j = "`i'"
			
			local table = tables[`i']
			local pip_code "pip tables, table(`table') clear"
			
			noi disp _col(6) `"`j' {c |} {stata `pip_code':`table'}"'
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



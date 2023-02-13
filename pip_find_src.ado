/*==================================================
project:       Find source of PIP installation
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    13 Feb 2023 - 17:27:32
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
program define pip_find_src, rclass
syntax [anything(name=scmd)]  ///
[,                             	    ///
path(string) ///
]
version 16.0


/*==================================================
              1: 
==================================================*/

* This ado-file is inspired by the command `dependencies` by Diana Gold

if ("`path'" == "") {
	local path = "PLUS"
}
capture findfile "stata.trk", path(`"`path'"') all
local stata_trk_list `"`r(fn)'"'

if _rc != 0 {
	noi dis as text "{cmd: pip} has not been installed from either SSC or " ///
	"GitHub in directory `path'. You could," ///
	"{p 6 6 2} 1. Search for {cmd:pip} in a different directory using {it:path()} option {p_end}" ///
	"{p 6 6 2} 2. Install stable version from SSC, {stata pip install ssc} {p_end}" ///
	"{p 6 6 2} 3. Install development version from  Github {stata pip install gh} {p_end}"
		// return info 
	noi disp in red "Return {it:NotInstalled} in r(src)"
	return local src = "NotInstalled"
	exit
}

qui else {
	
	* Reverse the list of all stata.trk found in adopath
	* because if a command exists in two places (ie: PLUS & PERSONAL),
	local n_stata_trk : list sizeof stata_trk_list
	local statatrk: word `n_stata_trk' of `stata_trk_list'

	* Each line is considered a single observation - then parsed later
	import delimited using `"`statatrk'"', delimiter(`"`=char(10)'"') clear
	
	* First character marks: S (source) N (name) D (installation date) d (description) f (files) U(stata tracker) e(end)
	gen marker = substr(v1, 1, 1)
	drop if inlist(marker, "*", " ", "U", "d") // not useful at all
	
	* Making sense of stata.trk means tagging which lines refer to which pkg (N)
	gen pkg_name = substr(v1, 3, .) if marker == "N"
	
	local p = 0
	gen pkg_code = `p'
	forvalues i = 1/`=_N' {
		if (marker[`i'] == "S")  {
			local p = `p' + 1
			replace    pkg_name = pkg_name[`i' + 1] in `i'
		}
		else if (marker[`i'] == "N" ) {
			local last_pkg_name = pkg_name[`i']
		}
		else {
			replace pkg_name = "`last_pkg_name'" in `i'
		}
		replace pkg_code = `p' in `i'
	} // end of for loop by obs
	
	keep if regexm(pkg_name, "^pip") & marker == "S"
	if regexm(v1[_N], "repec") local src = "ssc"
	else local src "gh"
	noi disp "`src'"
	
}	// end of condition


*----------1.1:


*----------1.2:


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



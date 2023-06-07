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
	pause        ///
	]
	version 16.1
	
	
	if ("`pause'" == "pause") pause on
	else                      pause off
	
	
	/*==================================================
	1:  if not found
	==================================================*/
	
	* This ado-file is inspired by the command `dependencies` by Diana Gold
	
	if ("`path'" == "") {
		local path = "PLUS"
	}
	return local path = "`path'"
	capture findfile "stata.trk", path(`"`path'"') all
	local stata_trk_list `"`r(fn)'"'
	
	if _rc != 0 {
		noi dis as res "{cmd: pip} has not been installed from either SSC or " ///
		"GitHub in directory `path'. You could," as text ///
		"{p 6 6 2} 1. Search for {cmd:pip} in a different directory using {it:path()} option {p_end}" ///
		"{p 6 6 2} 2. Install stable version from SSC, {stata pip install ssc} {p_end}" ///
		"{p 6 6 2} 3. Install development version from  Github {stata pip install gh} {p_end}"
		// return info 
		noi disp in res "Return {it:NotInstalled} in r(src)"
		return local src = "NotInstalled"
		exit
	}
	
	/*==================================================
	2:  If found
	==================================================*/
	
	qui else {
		
		* Reverse the list of all stata.trk found in adopath
		* because if a command exists in two places (ie: PLUS & PERSONAL),
		local n_stata_trk : list sizeof stata_trk_list
		local statatrk: word `n_stata_trk' of `stata_trk_list'
		
		
		tempname trk
		frame create `trk'
		frame `trk' {
			* Each line is considered a single observation - then parsed later
			import delimited using `"`statatrk'"', delimiter(`"`=char(10)'"')
			
			* First character marks: S (source) N (name) D (installation date) d (description) f (files) U(stata tracker) e(end)
			gen marker = substr(v1, 1, 1)
			keep if inlist(marker, "S", "N") 
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
			
			// get those lines with pip package
			keep if regexm(pkg_name, "^pip") & marker == "S"
			levelsof pkg_code, clean local(trk_code)
			return local trk_code = "`trk_code'"
			
			levelsof v1 if marker == "S",  local(trk_sources)
			local trk_sources: subinstr local trk_sources "S " "", all
			
			return local trk_sources = `"`trk_sources'"'
			
			// get last source
			if regexm(v1[_N], "repec") local src = "ssc" 
			else if (v1[_N] == "") local src = "NotInstalled"
			else local src "gh"
			
		}
		
		return local src = "`src'"
	}	// end of condition
	
	
end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



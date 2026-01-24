/*==================================================
project:       message to the user if file is installed from SSC
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     6 Oct 2022 - 16:08:28
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
program define pip_ssc, rclass
version 16.1

syntax [anything(name=subcommand)]  ///
[,                             	    ///
pause                               /// 
check                               /// 
] 

if ("`pause'" == "pause") pause on
else                      pause off


/*==================================================
              1: Update
==================================================*/
if ("`subcommand'" == "update") {
	qui adoupdate pip, ssconly
	if ("`r(pkglist)'" == "pip") {
		if ("`check'" == "check") {
			di "There is a new version of pip in SSC."
			di "If you wish to proceed, run {cmd:pip update} without the check argument."
			exit
		}
		cap window stopbox rusure "There is a new version of pip in SSC." ///
		"Would you like to install it now?"
		
		if (_rc == 0) {
			cap ado update pip, ssconly update
			if (_rc == 0) {
				cap window stopbox note "Installation complete. please type" ///
				"discard in your command window to finish"
				local bye "exit"
			}
			else {
				noi disp as err "there was an error in the installation. " _n ///
				"please run the following to retry, " _n(2) ///
				"{stata ado update pip, ssconly update}"
				local bye "error"
			}
		}
		else local bye ""
	}  // end of checking SSC update
	else {
		noi disp as result "SSC version of {cmd:pip} is up to date."
		local bye ""
	}
	
	return local bye = "`bye'"
}


/*==================================================
              2: Message
==================================================*/
if (inlist("`subcommand'", "msg", "message")) {
	noi disp "You're using SSC as the host of the {cmd:pip} Stata package." 
	noi disp "If you want to install the GitHub version type {stata pip_install gh}" 
}

//========================================================
// Install
//========================================================

if (inlist("`subcommand'", "install")) {
	pip_install ssc, replace
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



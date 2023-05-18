/*==================================================
project:       Parse options of pip command to be use by mata
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    10 May 2023 - 17:45:53
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
program define pip_parseopts, rclass
version 16


/*==================================================
1: parse subcommand
==================================================*/

gettoken subcmd opts: 0, parse(",")
if ("`subcmd'" == ",") {
	local subcmd ""
}
else gettoken comma opts: opts, parse(",")

if ("`subcmd'" != "") {
	local optnames "subcmd"
	return local subcmd = "`subcmd'"
}


/*==================================================
Parse options
==================================================*/
if (`"`opts'"' != "") {
	return local pipoptions = `"`opts'"'
	local optnames "`optnames' pipoptions"
}

gettoken opt opts: opts, bind

while (`"`opt'"' != `""') {
	// identify type of option
	if ustrregexm(`"`opt'"', "([a-zA-Z0-9]+)\(.*") {
		local optname = lower(ustrregexs(1))
	}
	else {
		if ustrregexm(lower("`opt'"), "(^no)(.+)") {
			local optname = ustrregexs(2)
		}
		else local optname = "`opt'"
	}
	// return option as local
	return local `optname' = `"`opt'"'
	local optnames "`optnames' `optname'"
	
	// next iteration
	gettoken opt opts: opts, bind
}

return local optnames = "`optnames'"

end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


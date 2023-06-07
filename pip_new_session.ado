/*==================================================
project:       Execute in each new Stata session
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World bank
----------------------------------------------------
Creation Date:    30 Nov 2021 - 16:05:24
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_new_session, rclass
version 16.1

syntax [anything(name=subcommand)]  ///
[,                             	    /// 
path(string)                        ///
pause                             /// 
] 

if ("`pause'" == "pause") pause on
else                      pause off

*##s
* ---- Initial time parameters

if ("${pip_old_session}" != "") exit

if ("${pip_lastupdate}" != "") {
	local day_diff = date("${pip_date_file}","YMD") - ///
	                 date("${pip_lastupdate}","YMD")
	if (`day_diff' <= 31) {
		noi disp "Check for updates will be done in `=31-`day_diff'' days"
		global pip_old_session "1"
		exit
	}
}


*##e

/*==================================================
1: Update PIP
==================================================*/

pip_update, path(`path')
local pip_source = "`r(src)'"
local bye        = "`r(bye)'"

/*==================================================
2: Dependencies         
==================================================*/

*---------- check SSC commands
/* 
local ssc_cmds missings 

noi disp in y "Note: " in w "{cmd:pip} requires the packages " ///
"below from SSC: " _n in g "`ssc_cmds'"

foreach cmd of local ssc_cmds {
	capture which `cmd'
	if (_rc != 0) {
		ssc install `cmd'
		noi disp in g "{cmd:`cmd'} " in w _col(15) "installed"
	}
}

adoupdate `ssc_cmds', ssconly
if ("`r(pkglist)'" != "") adoupdate `r(pkglist)', update ssconly
 */

* ----- Globals

local tgl = `"global pip_source   = "`pip_source'""'
pip_setup replace, pattern("pip_lastupdate") /* 
 */ new(`"global pip_lastupdate "${pip_date_file}""')
pip_setup replace, pattern("pip_source") new(`"`tgl'"')

pip_setup run 

`bye'

end 

exit

/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



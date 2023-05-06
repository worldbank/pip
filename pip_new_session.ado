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
version 16.0

syntax [anything(name=subcommand)]  ///
[,                             	    /// 
path(string)                        ///
pause                             /// 
] 

if ("`pause'" == "pause") pause on
else                      pause off

*##s
* ---- Initial time parameters
local date        = date("`c(current_date)'", "DMY")  // %tdDDmonCCYY
local time        = clock("`c(current_time)'", "hms") // %tcHH:MM:SS
local date_time   = `date'*24*60*60*1000 + `time'  // %tcDDmonCCYY_HH:MM:SS
local datetimeHRF:  disp %tcDDmonCCYY_HH:MM:SS `date_time'
local datetimeHRF = trim("`datetimeHRF'")
local dateHRF:      disp %tdDDmonCCYY `date'
local dateHRF     = trim("`dateHRF'")

local date_file:   disp %tdCCYYNNDD `date'
local date_file   = trim("`date_file'")

global pip_cmds_ssc 1
if ("${pip_lastupdate}" != "") {
	local day_diff = date("`date_file'","YMD") - date("${pip_lastupdate}","YMD")
	if (`day_diff' <= 31) {
		noi disp "Check for updates will be done in `=31-`day_diff'' days"
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


* ----- Globals

local tgl = `"global pip_source   = "`pip_source'""'
`tgl'


mata {

	filetoread = findfile("pip_setup.do")
	
	// Last update found
	pattern   = "pip_lastupdate"
	pip_replace_in_pattern(filetoread, pattern, 
	`"global pip_lastupdate "`date_file'""')
	
	pattern   = "pip_source"
	pip_replace_in_pattern(filetoread, pattern, `"`tgl'"')
	
}


* global pip_cmds_ssc = 1  // make sure it does not execute again per session

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



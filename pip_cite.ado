/*==================================================
project:       Citation protocol for PIP wrapper and PIP database
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    13 Jun 2022 - 16:36:52
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_cite, rclass
syntax [anything(name=subcommand)], [ ///
version(string) ///
data_bibtext ///
ado_bibtext ///
reg_cite    ///
]

version 16.1


/*==================================================
1: SET UP
==================================================*/
*------------------ Initial Parameters  ------------------

qui {
	if ("${pip_ado_version}" == "") {
		
		findfile pip.ado
		scalar pipado = fileread("`r(fn)'")
		
		mata: pip_ado()
		
		if regexm("`pipver'", "version +([0-9\.]+) +<([a-zA-Z0-9]+)>") {
			global pip_ado_version = regexs(1)
			global pip_ado_date    = regexs(2)
		}
		
	} // if global is not found 
	
	global pip_adoyear = substr("${pip_ado_date}", 1, 4)
	
	
	/*==================================================
	2: Regular citation
	==================================================*/
	*##s
	if ("`version'" == "") {
		qui cap pip_versions
		local version = "`r(version)'"
	}
	
	
	//------------ display data bibtext
	local data_date = substr("`version'", 1, 8)
	local data_year = substr("`version'", 1, 4)
	local data_date = date("`data_date'", "YMD")
	local data_date: disp %tdCCYY-NN-DD `data_date'
	local data_date = trim("`data_date'")
	
	local _version: subinstr local version "_" "\_", all 
}

if ("`reg_cite'" != "") {
	local cite_ado = `"Castañeda, R.Andrés and Damian Clarke. (${pip_adoyear}) "pip: Stata Module to Access World Bank’s Global Poverty and Inequality Data" (version ${pip_ado_version}). Stata. Washington, DC: World Bank Group. https://worldbank.github.io/pip/"'
	noi disp _n "{hline 90}" ///
	as res in  smcl "{p 2 8 2}Please cite this Stata tool as:{p_end}" /// 
	as text `"{p 6 10 4 90}`cite_ado'{p_end}"' /// 
	"{p 75 0 4}{stata pip_cite, ado_bibtext:bibtex}{p_end}"
	
	
	local cite_data = `"World Bank. (`data_year'). Poverty and Inequality Platform (version `version') [Data set]. World Bank Group. https://pip.worldbank.org/"'
	noi disp as res in smcl _n "{p 2 8 2}Please cite the PIP data as:{p_end}" ///
	as text `"{p 6 10 4 100}`cite_data'{p_end}"' /// 
	"{p 75 0 4}{stata pip_cite, data_bibtext version(`version'):bibtex}{p_end}"
	
	return local cite_ado   =  `"`cite_ado'"'
	return local cite_data  =  `"`cite_data'"'
	
	exit
}


/*==================================================
3: BibText 
==================================================*/
local date      =     date("`c(current_date)'", "DMY")  // %tdDDmonCCYY
local time      =     clock("`c(current_time)'", "hms") // %tcHH:MM:SS
local date_time =    `date'*24*60*60*1000 + `time'  // %tcDDmonCCYY_HH:MM:SS
local datetimeHRF:    disp %tcDDmonCCYY_HH:MM:SS `date_time'
local dateHRF:        disp %tdCCYY-NN-DD `date'
local datetimeMaster: disp %tcCCYYNNDDHHMMSS     `date_time'
local datetimeHRF =   trim("`datetimeHRF'")
local dateHRF =   trim("`dateHRF'")


//------------display ado bibtext
if ("${pip_cite_ado}" == "") {
	
	local ado_date = date("${pip_ado_date}", "YMD")
	local ado_year = year(`ado_date')

	local ado_date: disp %tdCCYY-NN-DD `ado_date'
	local ado_date = trim("`ado_date'")

	local  crlf "`=char(10)'`=char(13)'"
	global pip_cite_ado =   ///
	"{p 4 8 2}@software{castaneda${pip_adoyear},{p_end}"                                                                             + /// 
	"{p 8 12 2}title = {\{pip\}: {{Stata}} Module to Access {{World Bank}}’s {{Global Poverty}} and {{Inequality}} Data},{p_end}"    + /// 
	"{p 8 12 2}shorttitle = {PIP},{p_end}"                                                                                           + /// 
	"{p 8 12 2}author = {Castañeda, R.Andrés and Damian Clarke},{p_end}"                                                                               + /// 
	"{p 8 12 2}date = {`ado_date'},{p_end}"                                                                                          + /// 
	"{p 8 12 2}year = {`ado_year'},{p_end}"                                                                                          + /// 
	"{p 8 12 2}location = {{Washington, DC}},{p_end}"                                                                                + /// 
	"{p 8 12 2}url = {https://worldbank.github.io/pip/},{p_end}"                                                                     + /// 
	"{p 8 12 2}urldate = {`dateHRF'},{p_end}"                                                                                        + /// 
	"{p 8 12 2}abstract = {Stata module to access World Bank’s Global Poverty and Inequality data},{p_end}"                          + /// 
	"{p 8 12 2}editora = {Degefu, Tefera Bekele},{p_end}"                                                                            + /// 
	"{p 8 12 2}editoratype = {collaborator},{p_end}"                                                                                 + /// 
	"{p 8 12 2}organization = {{World Bank Group}},{p_end}"                                                                          + /// 
	"{p 8 12 2}version = {${pip_ado_version}},{p_end}"                                                                               + /// 
	"{p 8 12 2}keywords = {api-wrapper}{p_end}"                                                                                      + /// 
	"{p 4 8 2}}{p_end}"   
	
}

if ("`ado_bibtext'" != "") {
	disp _n in smcl `"${pip_cite_ado}"'
	exit
}

local pip_cite_data = ///
"{p 4 8 2}@dataset{worldbank`data_year',{p_end}" + ///
"{p 8 12 2}title = {Poverty and {{Inequality Platform}}},{p_end}" + ///
"{p 8 12 2}shorttitle = {{PIP} Database},{p_end}" + ///
"{p 8 12 2}author = {{World Bank}},{p_end}" + ///
"{p 8 12 2}date = {`data_year'},{p_end}" + ///
"{p 8 12 2}publisher = {{World Bank Group}},{p_end}" + ///
"{p 8 12 2}url = {https://pip.worldbank.org/},{p_end}" + ///
"{p 8 12 2}urldate = {`dateHRF'},{p_end}" + ///
"{p 8 12 2}langid = {english},{p_end}" + ///
"{p 8 12 2}version = {`_version'}{p_end}" + ///
"{p 4 8 2}}{p_end}"   

if ("`data_bibtext'" != "") {
	disp _n in smcl `"`pip_cite_data'"'
	exit
}

*##e

end


// ------------------------------------------------------------------------
// MATA functions
// ------------------------------------------------------------------------


* findfile stata.trk
* local fn = "`r(fn)'"

cap mata: mata drop pip_*()
mata:

// function to look for source of code
void pip_ado() {
	lines  = st_strscalar("pipado")
	lines  = ustrsplit(lines, "`=char(10)'")'
	// Select all comment lines 
	pipdates = select(lines, regexm(lines, `"^\*!"'))
	// Match all dates from these lines assuming named as 2YYYmmmDD (eg 2024Sep29)
	pipver = select(pipdates, regexm(pipdates, `"<2[0-9]{3}[a-zA-Z]{3}[0-9]{2}"'))
	// Latest version is last date
	pipver = pipver[rows(pipver)]
	st_local("pipver", pipver)
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



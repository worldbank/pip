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
]

version 16.0


/*==================================================
1: SET UP
==================================================*/
findfile pip.ado
scalar pipado = fileread("`r(fn)'")
// load data and transform to dataframe
*##s

drop _all
mata {
	lines  = st_strscalar("pipado")
	lines  = ustrsplit(lines, "`=char(10)'")'
	pipver = select(lines, regexm(lines, `"^\*!"'))[1]
	st_local("pipver", pipver)
}

if regexm("`pipver'", "version +([0-9\.]+) +<([a-zA-Z0-9]+)>") {
	local pipversion = regexs(1)
	local pipdate    = regexs(2)
}



/*==================================================
2: 
==================================================*/

noi disp in y "Please cite this Stata tool as:" 
noi disp as text in smcl `" {phang}Castañeda, R.Andres. (`pipdate') "{pip}: Stata Module to Access World Bank’s Global Poverty and Inequality Data" (version `pipversion'). Stata. Washington, DC: World Bank Group. https://worldbank.github.io/pip/"'


noi disp in y _n "Please cite the data as:" 
noi disp as text in smcl `" {phang}World Bank. (2022). Poverty and Inequality Platform (version `version') [Data set]. World Bank Group. https://doi.org/10.0000/XXX/XXXXX"'


*##e

/*==================================================
3: 
==================================================*/



end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



/*==================================================
project:       gather versions availble in a particular server
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    18 Mar 2022 - 11:42:44
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_versions, rclass
syntax [anything(name=server)] , [ ///
clear ///
]
version 16

/*==================================================
Get versions
==================================================*/
qui {
	
	preserve 
	if ("`server'" == "") {
		pip_set_server, `pause'
		*return add
		local url       = "`r(url)'"
		local server    = "`r(server)'"
	}
	
	import delimited using "`server'/versions?format=csv", clear varn(1)
	
	levelsof versions, local(versions) clean
	return local versions = "`versions'"
	noi list // fast list
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



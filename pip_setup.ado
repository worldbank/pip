/*==================================================
project:       Run globals and setup env for pip
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     6 May 2023 - 06:57:11
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_setup, rclass
version 16

syntax [anything(name=subcmd)]  ///
[,                              ///
pause                           /// 
dir(string)                     ///
] 

if ("`pause'" == "pause") pause on
else                      pause off


qui {
	/*==================================================
	Run globals 
	==================================================*/
	
	*##s
	findfile "pip_setup.do"
	local pipsetup_file = "`r(fn)'"
	run  "`pipsetup_file'"
	
	//========================================================
	//  compile mata code
	//========================================================
	
	if ("`dir'" == "") {
		local dir PERSONAL
	}
	
	
	findfile "pip_fun.mata"
	local pip_funmata_file "`r(fn)'"
	tempname spipmata
	scalar `spipmata' = fileread("`pip_funmata_file'")
	
	pip_cache gethash, query(`"`: disp `spipmata''"')
	local pipmata_hash = "`r(piphash)'"
	* disp "`pipmata_hash'"
	
	if ("${pip_pipmata_hash}" != "`pipmata_hash'") {
		run "`pip_funmata_file'"
		lmbuild lpip_fun.mlib, replace
		noi disp "Mata lpip_fun library updated"
		
		local pattern = "pip_pipmata_hash"
		local newline = `"global pip_pipmata_hash  = "`pipmata_hash'""'
		
		mata: pip_replace_in_pattern("`pipsetup_file'", "`pattern'", `"`newline'"')
	}
	
	run  "`pipsetup_file'"
	*##e
	
}

end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control or old (new) ideas:



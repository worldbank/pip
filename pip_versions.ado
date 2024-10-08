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
	
	syntax [anything(name=sbcmd)] , [ ///
	version(string)                ///
	release(numlist)               ///
	PPP_year(numlist)              ///
	identity(string)               ///
	AVAILability                   ///
	*                              ///
	]
	
	version 16.1
	
	qui {
		
		/*==================================================
		Check conditions
		==================================================*/
		
		// reset pip_version global if components are called by user
		if ("`release'" != "" | "`ppp_year'" != "" | "`identity'" != "" ) {
			global pip_version ""
		}
		
		* local version has prvalence over everything else
		if ("${pip_version}" != "" & "`version'" == "") {
			noi disp "{res}version in use {txt}${pip_version}"
			local version = "${pip_version}"
		}
		
		* local version "2022484_2011_02_02_PROD"
		if ("`version'" != "") {
			* check format
			local vintage_pattern = "[0-9]{8}_[0-9]{4}_[0-9]{2}_[0-9]{2}_(PROD|INT|TEST)$"
			if (!ustrregexm("`version'", "`vintage_pattern'")) {
				noi disp in red "version provided, {it:`version'}, " _c /* 
				*/  "does not meet the format criteria: " _n /* 
				 */  in y "`vintage_pattern'"
				error
			}
		}
		
		* locals have prevalence over globals
		else { // if version is specified, all of this is ignored
			if ("${pip_ppp_year}" != "" & "`ppp_year'" == "") {
				noi disp "{res}Note: {txt}global {it:pip_ppp_year} (${pip_ppp_year}) is in use"
				local ppp_year = "${pip_ppp_year}"
			}
			if ("${pip_identity}" != "" & "`identity'" == "") {
				noi disp "{res}Note: {txt}global {it:pip_identity} (${pip_identity}) is in use"
				local identity = "${pip_identity}"
			}
			if ("${pip_release}" != "" & "`release'" == "") {
				noi disp "{res}Note: {txt}global {it:pip_release} (${pip_release}) is in use"
				local release = "${pip_release}"
			}
		}
		
		
		//========================================================
		// Create version frame 
		//========================================================
		
		//------------ get server url
		if ("${pip_host}" == "") {
			pip_set_server,  server(${pip_server})
			return add
		}
		
		local fversions = "_pip_versions_${pip_server}"
		pip_utils frameexists, frame("`fversions'")
		if (`r(fexists)' == 0) {
			
			frame create `fversions'
			
			frame `fversions' {
				pip_timer pip_version.pip_get, on
				
				global pip_tmp_query = "versions?format=csv"
				pip_get , clear gname(pip_tmp_query)
				global pip_tmp_query ""
				
				pip_timer pip_version.pip_get, off
				
				keep version
				//------------* Split and rename 
				split version, parse("_") generate(sp)
				local sp_names "release ppp_year ppp_rv ppp_av identity"
				rename sp# (`sp_names')			
			}
		}
		
		//========================================================
		// Just show availability
		//========================================================
		
		if ("`availability'" != "") {
			frame `fversions' {
				levelsof version, local(versions) clean
				return local versions = "`versions'"
				noi list version // fast list
			}
			exit
		}
		
		
		frame  copy `fversions' _pip_versions_wrk, replace
		frame _pip_versions_wrk {
			
			//========================================================
			// Evaluate conditions
			//========================================================
			
			//------------ Version
			if ("`version'" != "") {
				
				* check availability
				* local server "http://wzlxdpip01.worldbank.org/api/v1"
				* local version "20220408_2011_02_02_PROD"
				count if version == "`version'"
				
				if (r(N) == 0) {
					
					levelsof version, local(vers) clean
					local ver_avlb: list version in vers
					noi disp in red "version {it:`version'} is not available in this server" _n ///
					"Versions available are: "
					foreach ver of local vers {
						noi disp in y "`ver'"
					}
					error
				}
				else {
					global pip_version "`version'"
				}
			} // end of version different ot empty
			
			//------------ It no version is defined by the user
			else  {
				//------------ Release
				if ("`release'" != "") {
					count if release == "`release'"
					if (r(N) == 0) {
						noi disp in red "release, {it:`release'}, is not available." _n ///
						"Releases available are:"
						levelsof release, local(releases) clean
						foreach r of local releases {
							noi disp in y "`r'"
						}
						error
					}
					else {
						keep if release == "`release'"
					}
				}
				//------------ PPP year
				if ("`ppp_year'" != "") {
					count if ppp_year == "`ppp_year'"
					if (r(N) == 0) {
						noi disp in red "ppp_year, {it:`ppp_year'}, is not available." _n ///
						"PPP years available are:"
						levelsof ppp_year, local(ppp_years) clean
						foreach py of local ppp_years {
							noi disp in y "`py'"
						}
						error
					}
					else {
						keep if ppp_year == "`ppp_year'"
					}
				} // end of ppp year
				
				//------------ Identity
				if ("`identity'" != "") {
					local identity = upper("`identity'")
					
					count if identity == "`identity'"
					if (r(N) == 0) {
						noi disp in red "identity, {it:`identity'}, is not available." _n ///
						"Identities available are:"
						levelsof identity, local(identities) clean
						foreach i of local identities {
							noi disp in y "`i'"
						}
						error
					}
					else {
						keep if identity == "`identity'"
					}
				} // end of identity defined
				else {
					count if identity == "PROD"
					if (r(N) == 0) {
						count if identity == "INT"
						if (r(N) == 0) {
							count if identity == "TEST"
							if (r(N) == 0) {
								noi disp in red "Valid identity was not found"
								error
							}
							else {
								keep if identity == "TEST"
							}
						} // If no INT
						else {
							keep if identity == "INT"
						}
					} // end if not PROD
					else {
						keep if identity == "PROD"
					}
				} // end of identity not defined by user
				
				
				//========================================================
				// Sort remaining obs
				//========================================================
				
				// this guarantees only one version 
				sort release ppp_year ppp_rv ppp_av
				keep in l
				local version = version[1]
				global pip_version "`version'"
				local version_qr = "version=`version'"  
				
			} // end of version not specified
			
		} // end frame  
		tokenize "`version'", parse("_")
		return local release    = "`1'"
		return local ppp_year   = "`3'"
		return local identity   = "`9'"
		return local version    = "`version'"
	} // end of qui
	
end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



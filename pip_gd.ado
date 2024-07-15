/*------------------------------------------------------------------------------
project:           Interaction with the PIP API at the grouped data level
Author:            Damian Clarke
Dependencies:      The World Bank
----------------------------------------------------
Creation Date:     7 Jul 2024 - 21:15:36
Modification Date:
Do-file version:   01
References:
Output:

Dev notes [DCC]: See end of file. Also note program drop is temporal for tests
------------------------------------------------------------------------------*/
cap program drop pip_gd
cap program drop pip_gd_check_args
cap program drop pip_gd_query
cap program drop pip_gd_clean
cap program drop pip_gd_display_results

*-------------------------------------------------------------------------------
*--- (0) Program set-up
*-------------------------------------------------------------------------------
program define pip_gd, rclass
	version 16.1
	
	//pip_gd not yet included in pip as pip gd, set must run pip_timer to set struct
	pip_timer
	pip_timer pip_gd, on

	pip_gd_check_args `0'
	
	// grab saved locals
	local optnames "`r(optnames)'"
	mata: pip_retlist2locals("`optnames'")
	
	if "`pause'"=="pause" pause on
	else                  pause off
	
	
	quietly {
        //Set-up
        if "$pip_version"=="" {
            noisily dis as error "No version selected."
            exit 197
        }
        tokenize $pip_version, parse("_")
        local ppp_year `3'

        // Import auxiliary data
        pip_auxframes
        
        //Build query [go to (2) sub-program pip_gd_query]
        noisily pip_gd_query, cum_welfare(`cum_welfare') ///
                              cum_population(`cum_population') ///
                              requested_mean(`requested_mean') ///
                              povline(`povline') ///
                              ppp_year(`ppp_year') ///

        //Download [UNCOMMENT pip_get WHEN HAVING ACCESS TO SERVER]
        pip_timer pip_gd.pip_get, on
        //pip_get, `cacheforce' `clear' `cachedir' 
        pip_timer pip_gd.pip_get, off

        //Clean
        pip_timer pip_gd_clean, on
        pip_gd_clean
        pip_timer pip_gd_clean, off
        
        //Add data notes
        local datalabel "Grouped Statistics"
        local data "`datalabel' (`c(current_date)')"
        
        //Display results
        noi pip_gd_display_results, `n2disp'
    }
	pip_timer pip_gd, off
end



*-------------------------------------------------------------------------------
*--- (1) Syntax check
*-------------------------------------------------------------------------------
//Place-holder -- need to check whether certain options are mandatory.
//  This should be viewed as a structure conditional on determining all required
//  elements and potential further consistency checks
program define pip_gd_check_args, rclass
	version 16.1
	syntax                          ///
	[ ,                             ///
	cum_welfare(numlist)            ///
	cum_population(numlist)         ///
	requested_mean(real 1)          ///
	POVLine(numlist)	            ///
	PPP_year(numlist)	            ///
	pause                           ///
	replace                         /// 
	cacheforce                      ///
	n2disp(passthru)                ///
	cachedir(passthru) *            ///  
	]

	//Set-up
	local version = "${pip_version}"
	tokenize "`version'", parse("_")
	local _version   = "_`1'_`3'_`9'"
	local ppp_year = `3'
	

	//Cumulative welfare
	if "`cum_welfare'"=="" local cum_welfare 0.1 0.2 0.3
	local nwelfare : word count `cum_welfare'
	return local cum_welfare = "`cum_welfare'"	
	local optnames "`optnames' cum_welfare"
	
	//Cumulative population
	if "`cum_population'"=="" local cum_population 0.1 0.2 0.3
	local npopulation : word count `cum_population'
	return local cum_population = "`cum_population'"	
	local optnames "`optnames' cum_population"
	
	if `npopulation'!=`nwelfare' {
        dis as error "cum_population and cum_welfare must be identical lengths."
        exit 122
	}

	//Requested mean	
	return local requested_mean = "`requested_mean'"
	local optnames "`optnames' requested_mean"
	
	// poverty line 
	if "`povline'"=="" {
        if ("`ppp_year'" == "2005") local povline = 1.25
        if ("`ppp_year'" == "2011") local povline = 1.9
        if ("`ppp_year'" == "2017") local povline = 2.15
    }
	return local povline  = "`povline'"
	local optnames "`optnames' povline"
	return local optnames "`optnames'"
end



*-------------------------------------------------------------------------------
*--- (2) Sub-programs
*-------------------------------------------------------------------------------
//---------- 2(a) Build GD Query  ---------------------------------------------- 
program define pip_gd_query, rclass
	version 16.1
	syntax                             ///
	[ ,                                ///
	  cum_population(numlist)          ///
	  cum_welfare(numlist)             ///	  
	  requested_mean(real 1)           ///
	  POVLine(numlist)	               ///
	  ppp_year(numlist)	               ///
	]

	//Build query
	//  Note: Maps particular contents to format for API
	//  Could consider changing test for ease of reading
	local params "cum_welfare cum_population requested_mean"
	foreach p of local params {
        if `"``p''"'==`""' continue
        local query "`query'`p'=``p''&"
	}
	local query = ustrtrim("`query'")
	local query : subinstr local query " " ",", all
	

	// grouped-data [REMOVE 1ST BLOCK IF THIS IS NOT NEEDED FOR LORENZ]
	local endpoint "grouped-stats"
    if "`povline'"=="" {
        global pip_last_queries "`endpoint'?`query'format=csv"
        noisily dis "$pip_last_queries"
        exit
    }
		
	tempname M
	local i = 1
	foreach v of local povline {
	    local queryp = "`endpoint'?`query'povline=`v'&format=csv" 
        if `i'==1 mata: `M' = "`queryp'"
        else      mata: `M' = `M' , "`queryp'"
        local ++i
	}
	mata: st_global("pip_last_queries", invtokens(`M')) 
	noisily dis "$pip_last_queries"
		
end


//---------- 2(b) Clean GD data  ----------------------------------------------- 
program define pip_gd_clean, rclass
	version 16.1
	
	//Setup
	if ("${pip_version}" == "") {
        noisily dis as error "No version selected."
        exit 197
	}
	local version = "${pip_version}"
	tokenize "`version'", parse("_")
	local _version   = "_`1'_`3'_`9'"
	local ppp_version = `3'
	
	//Type confirmation?
	
	//Dealing with invalid values?
	
	//Labeling [**CURRENTLY WITH CAPTURE WHILE SERVER CONNECTION NOT SETUP]
	cap lab var poverty_line     "poverty line in `ppp_version' PPP US\$ (per capita per day)"
	cap lab var mean             "average daily per capita income/consumption `ppp_version' PPP US\$"
	cap lab var median           "median daily per capita income/consumption in `ppp_version' PPP US\$"
	cap lab var headcount        "poverty headcount"
	cap lab var poverty_gap      "poverty gap"
	cap lab var poverty_severity "squared poverty gap"
	cap lab var watts            "watts index"
	cap lab var gini             "gini index"
	cap lab var mld              "mean log deviation"
	cap lab var polarization     "polarization"

	cap ds decile*
	local dec_var = "`r(varlist)'"
	foreach var of local dec_var {
        if regexm("`var'", "([0-9]+)") local q = regexs(1)
        cap lab var `var' "decile `q' welfare share"
	}    
	//Sorting?
		
	//Formatting?
		
	qui compress	
end


//---------- 2(c) Display results  --------------------------------------------- 

program define pip_gd_display_results
	syntax  [, n2disp(integer 1)]

	local n2disp = min(`c(N)', `n2disp')
	
	//Display header
	if      `n2disp'==1 local MSG "first observation"
	else if `n2disp' >1 local MSG "first `n2disp' observations"
	else                local MSG "No observations available"	
	noi dis as result _n "{ul:`MSG'}"


	//Display contents
	local varstodisp 
	noi list `varstodisp' in 1/`n2disp', abbreviate(12) noobs
end

exit


><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
Notes:
    1. API test example is as follows
       http://127.0.0.1:8080/api/v1/grouped-stats?cum_welfare=0.0002,0.0006,0.0011,0.0021,0.0031,0.0048,0.0066,0.0095,0.0128,0.0177,0.0229,0.0355,0.0513,0.0689,0.0882&cum_population=0.001,0.003,0.005,0.009,0.013,0.019,0.025,0.034,0.044,0.0581,0.0721,0.1041,0.1411,0.1792,0.2182&requested_mean=2.911786&povline=1.9
    2. Does requested mean have default option(s)?  And is it a scalar?
    3. Does program revert to error if no cum_population() and cum_welfare() specified?
    4. Need to build for Lorenz
    5. Should MSG "No observations available" not return an error instead of display?
    6. Remove instances of capture in pip_gd_clean
    7. Check whether we need ppp_year as an argument, or just internally accessed always
    
Version Control:

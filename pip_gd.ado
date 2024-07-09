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
cap program drop pip_gd_display_results

*-------------------------------------------------------------------------------
*--- (0) Program set-up
*-------------------------------------------------------------------------------
program define pip_gd, rclass
	version 16.1

	pip_timer pip_gd, on


	pip_gd_check_args `0'
	
	// grab saved locals
	local optnames "`r(optnames)'"
	mata: pip_retlist2locals("`optnames'")
	
	if "`pause'"=="pause" pause on
	else                  pause off
	
	
	quietly {
        //Set-up [Written, but actually seems do not need ppp_year for gd]
        if "$pip_version"=="" {
            noisily dis as error "No version selected."
            exit 197
        }
        tokenize $pip_version, parse("_")
        local ppp_year `3'

        //Build query [go to (2) sub-program pip_gd_query]
        noisily pip_gd_query, cum_welfare(`cum_welfare') cum_population(`cum_population')	

        //Download
        
        //Clean?

        //Add data notes

        //Display results
        noi pip_gd_display_results, `n2disp'
    }
	pip_timer pip_gd, off
end



*-------------------------------------------------------------------------------
*--- (1) Syntax check
*-------------------------------------------------------------------------------
program define pip_gd_check_args, rclass
	version 16.1
	syntax                          ///
	[ ,                             ///
	cum_welfare(numlist)            ///
	cum_population(numlist)         ///
	requested_mean(real 1)          ///
	POVLine(numlist)	            ///
	pause                           ///
	replace                         /// 
	cacheforce                      ///
	n2disp(passthru)                ///
	cachedir(passthru)  *           ///  
	]

	
	//Place-holder -- need to check whether certain options are mandatory
	if "`cum_welfare'"=="" local cum_welfare 0.1 0.2 0.3
	return local cum_welfare = "`cum_welfare'"	
	local optnames "`optnames' cum_welfare"
	
	if "`cum_population'"=="" local cum_population 0.1 0.2 0.3
	return local cum_population = "`cum_population'"	
	local optnames "`optnames' cum_population"

	
	return local optnames "`optnames'"

end



*-------------------------------------------------------------------------------
*--- (2) Sub-programs
*-------------------------------------------------------------------------------
program define pip_gd_query, rclass
	version 16.1
	syntax                             ///
	[ ,                                ///
	  cum_population(numlist)          ///
	  cum_welfare(numlist)             ///	  
	]

	//Build query
	//  Note: test below is to confirm that particular contents should be in API
	//  Could consider changing test for ease of reading
	local params "cum_welfare cum_population requested_mean povline"
	foreach p of local params {
        if `"``p''"'==`""' continue
        local query "`query'`p'=``p'' "
	}
	local query = ustrtrim("`query'")	
	local query : subinstr local query " " "&", all
	

	// grouped-data
h	local endpoint "grouped-stats"
    if "`povline'"=="" {
        global pip_last_queries "`endpoint'?`query'&format=csv"
        noisily dis "$pip_last_queries"
        exit
    }
		
	tempname M
	local i = 1
	foreach v of local povline {
	    local queryp = "`endpoint'?`query'&povline=`v'&format=csv" 
        if `i'==1 mata: `M' = "`queryp'"
        else      mata: `M' = `M' , "`queryp'"
        local ++i
	}
	mata: st_global("pip_last_queries", invtokens(`M')) 
		
end

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
    2. Does requested mean have default option(s), or just ignored if not specified?
    3. Need to build for Lorenz
    4. Should MSG "No observations available" not return an error instead of display?
    5. Ensure that numlists are unpacked in check_args
    

Version Control:

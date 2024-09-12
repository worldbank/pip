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

*-------------------------------------------------------------------------------
*--- (0) Program set-up
*-------------------------------------------------------------------------------
program define pip_gd, rclass
	version 16.1
	
	//pip_gd not yet included in pip as pip gd, set must run pip_timer to set struct
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
							  n_bins(`n_bins') ///
        					  endpoint(`endpoint') ///
        
        pip_timer pip_gd.pip_get, on

        pip_get, `cacheforce' `clear' `cachedir'
        pip_timer pip_gd.pip_get, off

        //Clean
        pip_timer pip_gd_clean, on
        pip_gd_clean, endpoint(`endpoint')
        pip_timer pip_gd_clean, off
        
        //Add data notes
        local datalabel "Grouped Statistics"
        local data "`datalabel' (`c(current_date)')"
        
        //Display results
        noi pip_utils output, `n2disp'
    }
	pip_timer pip_gd, off
end



*-------------------------------------------------------------------------------
*--- (1) Syntax check
*-------------------------------------------------------------------------------
program define pip_gd_check_args, rclass
	version 16.1
	syntax                          ///
	, cum_welfare(numlist)          ///
	  cum_population(numlist)       ///
	[                               ///
	stats                           ///
	lorenz                          ///
	params                          ///
	requested_mean(numlist max=1 >0 <1e10) ///
	POVLine(numlist)	            ///
	PPP_year(numlist)	            ///
	n_bins(numlist max=1 >0 <1000 integer) ///
	CLEAR(string)                   /// 
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

	//Over-arching options: either stats, lorenz or params must be specified
	if "`stats'"==""&"`lorenz'"==""&"`params'"=="" {
		//If nothing is specified, stats is assumed
		local stats stats
	}
	//Only one of these options can be provided
	local j=0
	if "`stats'" !="" local ++j
	if "`lorenz'"!="" local ++j
	if "`params'"!="" local ++j
	if `j'>1 {
    	dis as error "Only one of stats, lorenz or params can be specified."
		exit 184
	}

	//Return end-point name (one must be returned by construction)
	if "`stats'" !="" local endpoint "grouped-stats"
	if "`lorenz'"!="" local endpoint "lorenz-curve"
	if "`params'"!="" local endpoint "regression-params"
	return local endpoint = "`endpoint'"
	local optnames "`optnames' endpoint"

	//requested_mean is required if stats is indicated
	if "`stats'"!="" & "`requested_mean'"=="" {
		dis as error "option requested_mean() required"
		exit 198
	}

	//n_bins is required if lorenz is indicated
	if "`lorenz'"!="" & "`n_bins'"=="" {
		dis as error "option n_bins() required"
		exit 198
	}

	//Cumulative welfare
	local nwelfare : word count `cum_welfare'
	return local cum_welfare = "`cum_welfare'"	
	local optnames "`optnames' cum_welfare"

	//Cumulative population
	local npopulation : word count `cum_population'
	return local cum_population = "`cum_population'"	
	local optnames "`optnames' cum_population"
	
	if `npopulation'!=`nwelfare' {
        dis as error "cum_population and cum_welfare must be identical lengths."
        exit 122
	}

	//Requested mean	
	if "`stats'"!="" {
		return local requested_mean = "`requested_mean'"
		local optnames "`optnames' requested_mean"
	}

	// poverty line 
	if "`stats'"!=""|"`params'"!="" {
		if "`povline'"=="" {
        	if ("`ppp_year'" == "2005") local povline = 1.25
        	if ("`ppp_year'" == "2011") local povline = 1.9
        	if ("`ppp_year'" == "2017") local povline = 2.15
		}
		return local povline  = "`povline'"
		local optnames "`optnames' povline"
	}

	//n_bins
	if "`n_bins'"!="" {
		return local n_bins = "`n_bins'"
		local optnames "`optnames' n_bins"
	}

	//allow n2disp as undocumented option
	if ("`n2disp'"!="" ) {
		return local n2disp = "`n2disp'"
		local optnames "`optnames' n2disp"
	}

	// clear
	if ("`clear'" == "") local clear "clear"
	return local clear = "`clear'"
	local optnames "`optnames' clear"


	// Return all options as local
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
	  endpoint(string)                 ///
	  cum_population(numlist)          ///
	  cum_welfare(numlist)             ///	  
	  requested_mean(numlist)          ///
	  POVLine(numlist)	               ///
	  ppp_year(numlist)	               ///
	  n_bins(numlist)	               ///
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
	
	// Single poverty line
    if "`povline'"=="" {
        global pip_last_queries "`endpoint'?`query'format=csv"
        //noisily dis "$pip_last_queries"
        exit
    }

	// Multiple poverty lines		
	tempname M
	local i = 1
	foreach v of local povline {
	    local queryp = "`endpoint'?`query'povline=`v'&format=csv" 
        if `i'==1 mata: `M' = "`queryp'"
        else      mata: `M' = `M' , "`queryp'"
        local ++i
	}
	mata: st_global("pip_last_queries", invtokens(`M')) 
	//noisily dis "$pip_last_queries"
end


//---------- 2(b) Clean GD data  ----------------------------------------------- 
program define pip_gd_clean, rclass
	version 16.1
	syntax                             ///
	[ ,                                ///
	  endpoint(string)                 ///
	]
	
	//Setup
	if ("${pip_version}" == "") {
        noisily dis as error "No version selected."
        exit 197
	}
	local version = "${pip_version}"
	tokenize "`version'", parse("_")
	local _version   = "_`1'_`3'_`9'"
	local ppp_version = `3'
	
	//Type confirmation
	local str_vars
	if `"`endpoint'"'=="regression-params" {
		local str_vars "lorenz validity normality selected_for_dist selected_for_pov"
	}
	ds
	local all_vars "`r(varlist)'"

	local num_vars: list all_vars - str_vars

	* make sure all numeric variables are numeric -----------
	foreach var of local num_vars {
		cap destring `var', replace 
		if (_rc) {
			noi disp as error "{it:`var'} is not numeric or does not exist." _n ///
			"You're probably calling an old version of the PIP data"
		}
	}

	//Labeling
	if `"`endpoint'"'=="grouped-stats" {
		lab var poverty_line     "poverty line in `ppp_version' PPP US\$ (per capita per day)"
		lab var mean             "average daily per capita income/consumption `ppp_version' PPP US\$"
		lab var median           "median daily per capita income/consumption in `ppp_version' PPP US\$"
		lab var headcount        "poverty headcount"
		lab var poverty_gap      "poverty gap"
		lab var poverty_severity "squared poverty gap"
		lab var watts            "watts index"
		lab var gini             "gini index"
		lab var mld              "mean log deviation"
		lab var polarization     "polarization"

		ds decile*
		local dec_var = "`r(varlist)'"
		foreach var of local dec_var {
			if regexm("`var'", "([0-9]+)") local q = regexs(1)
			lab var `var' "decile `q' welfare share"
		}    
	}
	else if `"`endpoint'"'=="lorenz-curve" {
		lab var welfare "cumulative welfare share"
		lab var weight  "cumulative population share"
	}
	else if `"`endpoint'"'=="regression-params" {
		cap rename (a b c) (A B C)
		cap rename (se_a se_b se_c) (se_A se_B se_C)

		lab var lorenz              "Lorenz function"
		lab var A					"Parameter one estimate (A or theta)" 
		lab var B					"Parameter two estimate (B or gamma)"
		lab var C					"Parameter three estimate (C or delta)"
		lab var ymean				"ymean"
		lab var sst					"Total sum of square"
		lab var sse					"Residual sum of square"
		lab var r2					"R-squared"
		lab var mse					"Mean squared error"
		lab var se_A				"Parameter one standard error"
		lab var se_B				"Parameter two standard error"
		lab var se_C				"Parameter three standard error"
		lab var validity			"Model passes validity tests"
		lab var normality			"Model passes normality tests"
		lab var selected_for_dist	"Model selected for disributional statistics"
		lab var selected_for_pov	"Model selected for povery statistics"
	}	
		
	//Formatting
	if `"`endpoint'"'=="grouped-stats" {
		format headcount poverty_gap poverty_severity watts  gini mld ///
		decile*  mean polarization %8.4f
		
		format poverty_line %6.2f
	}
	else if `"`endpoint'"'=="lorenz-curve" {
		format welfare weight %08.6f
	}
	else if `"`endpoint'"'=="lorenz-curve" {
		format A B C ymean sst sse r2 mse se_A se_B se_C %8.4f
	}
	qui compress	
end

exit


><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
Notes:
DCC:
    1. Test is pip_gd,stats cum_welfare(0.0002,0.0006,0.0011,0.0021,0.0031,0.0048,0.0066,0.0095,0.0128,0.0177,0.0229,0.0355,0.0513,0.0689,0.0882) cum_population(0.001,0.003,0.005,0.009,0.013,0.019,0.025,0.034,0.044,0.0581,0.0721,0.1041,0.1411,0.1792,0.2182) requested_mean(2.911786) povline(1.9) 
    2. Allow variables for cum_population and cum_welfare
	3. Check consistency of cumulative values (monotonic and sum to 1)
	4. Add more descriptive labels than lq and lb ("General Quadratic Lorenz function" and "Beta Lorenz function")
 	5. Add PAUSE debugging structures as in other programs 
	6. Document as a part of help pip
CHECK:
	7. Check how to label ymean
Version Control:

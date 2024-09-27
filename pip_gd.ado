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

------------------------------------------------------------------------------*/

*-------------------------------------------------------------------------------
*--- (0) Program set-up
*-------------------------------------------------------------------------------
program define pip_gd,  rclass
	version 16.1
	
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
        noisily pip_gd_query, cum_welfare(`cum_welfare')       ///
                              cum_population(`cum_population') ///
                              requested_mean(`requested_mean') ///
                              povline(`povline')               ///
                              ppp_year(`ppp_year')             ///
                              n_bins(`n_bins')                 ///
                              endpoint(`endpoint') 
        

		// If clear is empty, saver current frame in temp frame
		// then restore at the end.
		local curframe = c(frame)
		if ("`clear'" == "") {
			local restoreframe = 1
		} 
		else {
			local restoreframe = 0
		}
		local clear "clear"
		
		// If current frame is called _pip_gd, frame drop will fail, so rename
		cap frame drop _pip_gd_old
		if c(frame)=="_pip_gd" {
			frame rename _pip_gd _pip_gd_old
		}
		cap frame drop _pip_gd
		qui frame create _pip_gd
		frame _pip_gd {
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

		// Restore frame
		if (`restoreframe' == 0) {
			//return local frame `curframe'
			frame change _pip_gd 
			noi disp "{res:NOTE: }You are currently working in frame {res: _pip_gd}" _n ///
			"to return to the original frame, type: {stata frame change `curframe'}"
		}
		else {
			frame _pip_gd: pip_utils frame2locals
			return add
			noi disp "{res:NOTE: }Results are available in frame {stata frame change _pip_gd:_pip_gd}," ///
			" or by typing {stata ret list}"
		}
    }
	pip_timer pip_gd, off
end



*-------------------------------------------------------------------------------
*--- (1) Syntax check
*-------------------------------------------------------------------------------
program define pip_gd_check_args, rclass
	version 16.1
	syntax                          ///
	, cum_welfare(string)           ///
	  cum_population(string)        ///
	[                               ///
	stats                           ///
	lorenz                          ///
	params                          ///
	requested_mean(numlist max=1 >0 <1e10) ///
	POVLine(numlist)	            ///
	PPP_year(numlist)	            ///
	n_bins(numlist max=1 >0 <1000 integer) ///
	clear                           /// 
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

	//Parse cumulative welfare and cumulative population

	//Check if numlists
	cap numlist "`cum_welfare'"
	if _rc==0 local cum_welfare `r(numlist)'
	local nwelfare : word count `cum_welfare'

	cap numlist "`cum_population'"
	if _rc==0 local cum_population `r(numlist)'
	local npopulation : word count `cum_population'
	
	if `npopulation'!=`nwelfare' {
        dis as error "cum_population and cum_welfare must be identical lengths."
        exit 122
	}
	//Check if there is a single element, if so this implies variables
	if `npopulation'==1 {
		// Confirm both cum_population and cum_welfare are variables
		cap ds `cum_population'
		if _rc {
			dis as error "cum_population() requires either a numlist or a variable name"
			dis as error "variable `cum_population' not found."
			exit 111
		}
		cap ds `cum_welfare'
		if _rc {
			dis as error "cum_welfare() requires either a numlist or a variable name"
			dis as error "variable `cum_welfare' not found."
			exit 111
		}
		// Check that the variables are the same length
		qui sum `cum_population'
		local Npop = r(N)
		qui sum `cum_welfare'
		local Nwelf = r(N)
		if `Npop'!=`Nwelf' {
			dis as error "Variables indicated in cum_population and cum_welfare must be identical lengths."
			exit 197
		}
		qui count if `cum_population'==. in 1/`Npop'
		if r(N)>0 {
			dis as error "cum_population contains missing values."
			dis as error "Ensure all valid values are provided in first `Npop' observations."
			exit 616
		}
		qui count if `cum_welfare'==. in 1/`Nwelf'
		if r(N)>0 {
			dis as error "cum_welfare contains missing values."
			dis as error "Ensure all valid values are provided in first `Nwelf' observations."
			exit 416
		}
		// Unpack variables and store as numlists
		local cum_pop_update
		local cum_wel_update
		forval i = 1/`Npop' {
			local cum_pop_update `cum_pop_update' `=`cum_population'[`i']'
			local cum_wel_update `cum_wel_update' `=`cum_welfare'[`i']'
		}
		local cum_population `cum_pop_update'
		local cum_welfare `cum_wel_update'
		local nwelfare : word count `cum_welfare'
		local npopulation : word count `cum_population'
	}
	
	//Check that cumulative values are monotonic and sum to 1
	local sum_pop = 0
	tokenize `cum_population'
	forval element = 2/`npopulation' {
		local element_1 = `element'-1
		if ``element'' < ``element_1'' {
			dis as error "cum_population is not monotonic."
			dis as error "Ensure population shares are entered from lowest to highest."
			exit 124
		}
		local sum_pop = ``element''
	}
	local sum_wel = 0
	tokenize `cum_welfare'
	forval element = 2/`nwelfare' {
		local element_1 = `element'-1
		if ``element'' < ``element_1'' {
			dis as error "cum_welfare is not monotonic."
			dis as error "Ensure welfare shares are entered from lowest to highest."
			exit 124
		}
		local sum_wel = ``element''
	}

	if `sum_pop'!=1|`sum_wel'!=1 {
		local sp = string(`sum_pop', "%05.3f")
		local sw = string(`sum_wel', "%05.3f")
		dis "Warning: cum_population sums to `sp' and cumulative welfare sums to `sw'."
	}

	//Return cumulative welfare and population arguments
	return local cum_welfare = "`cum_welfare'"	
	local optnames "`optnames' cum_welfare"

	return local cum_population = "`cum_population'"	
	local optnames "`optnames' cum_population"

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

		lab var lorenz              "Lorenz function (lq=General quadratic, Lb=Beta Lorenz)"
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
1. 
2. 
3. 

Version Control:

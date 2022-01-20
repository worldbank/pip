*********************************************************************************
* pip_query                                                               *
*********************************************************************************
program def pip_query, rclass

version 16.0

syntax [anything(name=subcommand)]    ///
[,                       ///
YEAR(string)          ///
COUntry(string)       ///
REGion(string)         ///
POVLine(string)        ///
POPShare(string)	   ///
PPP(string)            ///
NOSUMmary              ///
ISO                    ///
CLEAR                  ///
AUXiliary              ///
ORIginal               ///
INFOrmation            ///
COESP(string)          ///
SERVER(string)         ///
groupedby(string)      ///
coverage(string)       ///
pause                  /// 
fillgaps               ///
aggregate              ///
wb                     ///
]

if ("`pause'" == "pause") pause on
else                      pause off

quietly {
	
	local curframe = c(frame)
	************************************************
	* 0. Housekeeping
	************************************************
	
	pip_set_server  `server', `pause'
	*return add
	local server = "`r(server)'"
	local base   = "`r(base)'"
	
	
	if ("`ppp'" != "") local ppp_q = "&PPP0=`ppp'"
	return local query_pp = "`ppp_q'"
	
	local region = upper("`region'")
	
	***************************************************
	* 1. Will load guidance database
	***************************************************
	
	pip_info, clear justdata `pause' server(`server')
	
	*---------- Make sure at least one reference year is selected
	local frpipim "_pip_int_means"
	
	if ("`year'" != "all" & ("`wb'" != "" | "`aggregate'" != "")) {	
		
		
		frame `frpipim': levelsof reporting_year, local(ref_years_l)
		local ref_years "`ref_years_l' last"
		
		local no_ref: list year - ref_years
		
		if (`: list no_ref === year') {
			noi disp as err "Not even one of the years select belong to the following reference years: " _n /* 
			*/ " `ref_years_l'"
			error
		}
		
		if ("`no_ref'" != "") {
			noi disp in y "Warning: `no_ref' is/are not part of reference years: `ref_years_l'"
		}
		
	}  // end of 'if' condition
	
	
	***************************************************
	* 2. Keep selected countries and save codes
	***************************************************
	
	*---------- Keep selected country
	
	
	frame `frpipim' {
		
		cap confirm var keep_this
		if (_rc) {
			gen keep_this = 0
		}
		else {
			replace keep_this = 0
		}
		if ("`country'" != "" & lower("`country'") != "all") {
			
			local countries_ : subinstr local country " " "|", all 
			replace keep_this = 1 if regexm(country_code, "`countries_'")
			
		}
		
		if lower("`country'") == "all" replace keep_this = 1
		
		
		* If region is selected instead of countries
		if  ("`region'" != "") {
			
			local region_l: subinstr local region " " "|", all
			
			replace keep_this = 1 if regexm(wb_region, "`region_l'")
			if lower("`region'") == "all" replace keep_this = 1
		}
		
		local touse "keep_this == 1"
		
		local obs = _N
		if (`obs' == 0) {
			di  as err "No surveys found matching your criteria. You could use the " /*  
			*/ " {stata pip_info: guided selection} instead."
			cwf `curframe'
			error
		}
		
		pause query - after filtering conditions of country and region
		
		***************************************************
		* 3. Keep selected years and construct the request
		***************************************************
		
		*---------- Check that at least one year is available
		if ("`wb'" == "" & "`aggregate'" == "") {
			if ("`year'"=="all") | ("`year'"=="last") | ("`fillgaps'"!="") {
				local year_ok = 1
			}
			else {
				
				local yearcheck 0
				levelsof country_code if `touse', local(cts)
				local years_: subinstr local year " " "|", all 
				
				foreach ct of local cts {
					
					count if country_code == "`ct'" & ///
					      regexm(strofreal(reporting_year), "`years_'") & `touse'
								
					local year_ok =  r(N)
					
					if (`year_ok' == 0) {
						
						disp as err _n "Warning: " as text "years selected for `ct' do not " /// 
						"match any survey year." _n /// 
						"You could type {stata pip_info, country(`ct') clear} to check availability." 
					} 
					else {
						if (`yearcheck' == 0 ) {
							local yearcheck 1
						}	
					}
					
				} // end of countries loop
				
				if (`yearcheck' == 0) {
					noi disp as err _n "the countries and years selected do not match any year available."
					error
				}
			}
		}
		
		/*==================================================
		Create Queries
		==================================================*/
		
		*---------- Year and Display query
		local y_comma: subinstr  local year " " ",", all
		if ("`year'" == "last")  local y_comma = "all"
		local year_q = "year=`y_comma'"
		
		if ("`fillgaps'" == "")  {
			local disp_q = ""
		}
		else  {
			local disp_q = "&fill_gaps=true"
			
		}
		
		if ("`aggregate'" != "") {
			local disp_q = "&group_by=none"
		}
		
		if ("`wb'" != "") {
			local disp_q = "&group_by=wb"
		}
		
		return local query_ys = "`year_q'"
		return local query_ds = "`disp_q'"
		
		*---------- Country query
		
		if ( inlist(lower("`country'"), "", "all") ) {
			local country_q = "country=all"
		} 
		else {
			levelsof country_code if `touse', local(country_q) sep(&country=) clean
			local country_q = "country=`country_q'"
			
		}
		return local query_ct = "`country_q'"
		
		if ("`popshare'" != "") {
			*----------Population share query 
			local popshare_q = "popshare=`popshare'"
			return local query_ps = "`popshare_q'"
		}
		else {
			*---------- Poverty lines query
			local povline_q = "povline=`povline'"
			return local query_pl = "`povline_q'"
		}
		
		*---------- Coverage query
		if ("`coverage'" == "") {
			local coverage_q = "reporting_level=all")
			local coverage_q = "reporting_level=`coverage_q'"
		}
		else {
			local coverage_q = `""`coverage'""'
			local coverage_q: subinstr local coverage_q " " `"&reporting_level="', all
			local coverage_q: disp `coverage_q'	
			local coverage_q  = "reporting_level=`coverage_q'"
		}
		return local query_cv = "`coverage_q'"
		
	} // end of frame 
	
	cwf `curframe'
	
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



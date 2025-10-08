{smcl}
{* *! version 1.0.0 oct 2025}{...}
{vieweralsosee "" "--"}{...}
{cmd:help pip agg}{right:{browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}}
{help pip:(return to pip)} {right:{browse "https://worldbank.github.io/pip/"}}
{hline}

{title:syntax}

{pstd}
Country aggregates

{p 8 16 2}
{cmd:pip agg}, [{cmd:,} {it:{help pip##agg_options:agg options}}]


{marker opts_desc}{...}
{title:Options}

{pstd}

{marker agg_options}{...}
{synoptset 27 tabbed}{...}
{synopthdr:agg options}
{synoptline}
{synopt :{opt agg:regate}(string)}Directive to retrieve aggregate 
({it:see details {help pip_agg##fillgaps:below}}).{p_end}
{synopt :{opt y:ear}(numlist|string)}{help numlist} of years  or "all", or "last". Default is "{it:all}".{p_end}
{synopt :{opt povl:ine:}(#)}List of poverty lines (accepts up to 5) in specified PPP (see option {help pip##general_options:ppp_year(#)}) to calculate 
poverty. Default is 3.00 at 2021 PPPs.{p_end}
{synopt :{opt (no)}{opt fill:gaps}}Loads extrapolations and interpolations at the country
level and year estimates with NOT enough data coverage at the regional level 
({it:see details {help pip_agg##fillgaps:below}}).{p_end}
{synopt :{opt no}{opt now:casts}}By default, nowcast estimates are loaded at the
 country, regional, and global levels. Specify {opt nonowcasts} to exclude these
estimates from the results.{p_end}

{synoptline}
{synopt :{helpb pip##general_options: general options}}Options that apply to any subcommand.{p_end}


{marker description}{...}
{title:Description}:

{pstd}
After 2025-09-30, the regional aggregates in PIP API now coincide with the official
aggregates used by the World Bank in WDI. However, it is still possible to retrieve
the previous aggregation using the {cmd:agg} subcommand. For now, it is only 
possible to retrieve the new official aggregates or the previous
ones, but we plan to add more aggregation options in the future.

{pstd}
By default, the {cmd:pip agg}  command (without any options) will display the 
current aggregates available and aborts the process with an error message. 
When options {cmd:aggregate(official)} is specified, the command will return the 
official World Bank aggregates, which is equivalent to the {cmd:pip wb} command. 
When option {cmd:aggregate(pcn)} or {cmd:aggregate(vintage)} is specified, the 
command will return the World Bank aggregates used before the release of 2025-09-30, 
with {result:current data}. If you want to retrieve the previous aggregation with
historical data, you need to use the {opt version()} option.



{marker opt_details}{...}
{title:Options Details}

{phang}
{opt agg:regate(string)} blah

{phang}
{opt year(#)} Four digit years are accepted. When selecting multiple years, use
spaces to separate them. The option {it:all} is a shorthand for calling all
years, while the {it:last} option will download the latest available year
for each country.

{phang}
{opt povline(#)} The poverty lines for which the poverty measures will be
 calculated. When selecting multiple poverty lines, use less than 4 decimals 
 and separate each value with spaces. If left empty, the default poverty line of 
 $3 is used. By default, poverty lines  are expressed in 2021 PPP USD per capita
 per day. If option {opt ppp_year(2011)} is specified, the poverty lines will be
 expressed in 2011 PPPs.

{marker fillgaps}{...}
{phang}
The {opt nofillgaps} option removes all estimates for years lacking sufficient survey coverage for a given aggregate (e.g., regional or global).
({err:This option exists because we strongly discourage using such estimates for analytical purposes}).{p_end}

{phang}
{opt no}{opt now:casts} is an "off" option that suppresses the loading of nowcast estimates at the country, regional, and global levels. Specifying {opt nonowcasts} excludes these estimates from the results.

{marker examples}{...}
{title:Examples}


{phang}
Display aggregates available

{phang2}
{stata pip agg} 

{phang}
Load clickable menu of data available

{phang2}
{stata pip, info}

{phang}
1.3. Load only urban coverage level

{phang2}
{stata pip cl, country(all) coverage("urban") clear}


{ul:2. Differences between queries }

{phang}
2.1. Country estimation at $2.15 in 2015. In this example, since there are no ARG surveys in 
2015, results are loaded only for COL, BRA and IND.

{phang2}
{stata pip, country(COL BRA ARG IND) year(2015) clear}

{phang}
2.2. Reference-year estimation. Filling gaps for ARG and moving the IND estimate
from 2015-2016 to 2015. Only works for reference years. 

{phang2}
{stata pip, country(COL BRA ARG IND) year(2015) clear  fillgaps}

{phang}
2.4. World Bank aggregation ({it:country()} is not available)

{phang2}
{stata pip wb, clear  year(2015)}{p_end}
{phang2}
{stata pip wb, clear  region(SAR LAC)}{p_end}
{phang2}
{stata pip wb, clear}       // all regions and reference years{p_end}

{phang}
2.5. {opt fillgaps}, {opt nofillgaps} and {opt nonowcasts} 

{phang2}
{stata pip, clear}          // survey estimates{p_end}
{phang2}
{stata pip, clear fillgaps} // interpolations, extrapolations and nowcasts{p_end}
{phang2}
{stata pip, clear fillgaps nonowcasts}  // just interpolations and extrapolations{p_end}
{phang2}
{stata pip wb, clear}       // Official regional and global data with 
projections and nowcasts{p_end}
{phang2}
{stata pip wb, nofillgaps}  // remove aggregates for years with no survey coverage but keep nowcast{p_end}
{phang2}
{stata pip wb, nonowcasts}   // Remove nowcasts but keep aggregates for years with no survey coverage{p_end}


{ul:3. Samples uniquely identified by country/year}

{phang2}
{ul:3.1} Longest possible time series for each country, {it:even if} welfare type or survey coverage
changes from one year to another (national coverage is preferred).

{cmd}
	  pip, clear
	* Prepare reporting_level variable
	  label define level 3 "national" 2 "urban" 1 "rural"
	  encode reporting_level, gen(reporting_level_2) label(level)

	* keep only national when more than one is available
	  bysort country_code welfare_type year: egen _ncover = count(reporting_level_2)
	  gen _tokeepn = ( (inlist(reporting_level_2, 3, 4) & _ncover > 1) | _ncover == 1)

	  keep if _tokeepn == 1

	* Keep longest series per country
	  by country_code welfare_type, sort:  gen _ndtype = _n == 1
	  by country_code : replace _ndtype = sum(_ndtype)
	  by country_code : replace _ndtype = _ndtype[_N] // number of welfare_type per country

	  duplicates tag country_code year, gen(_yrep)  // duplicate year

	 bysort country_code welfare_type: egen _type_length = count(year) // length of type series
	 bysort country_code: egen _type_max = max(_type_length)   // longest type series
	 replace _type_max = (_type_max == _type_length)

	* in case of same length in series, keep consumption
	  by country_code _type_max, sort:  gen _ntmax = _n == 1
	  by country_code : replace _ntmax = sum(_ntmax)
	  by country_code : replace _ntmax = _ntmax[_N]  // number of welfare_type per country


	  gen _tokeepl = ((_type_max == 1 & _ntmax == 2) | ///
	                 (welfare_type == 1 & _ntmax == 1 & _ndtype == 2) | ///
	                 _yrep == 0)
	 
	 keep if _tokeepl == 1
	 drop _*

{txt}      ({stata "pip_examples pip_example08":click to run})

{phang2}
{ul:3.2} Longest possible time series for each country, restrict to same welfare type throughout,
but letting survey coverage vary (preferring national).

{cmd}
	  pip, clear
	  
	* Prepare reporting_level variable
	  label define level 3 "national" 2 "urban" 1 "rural"
	  encode reporting_level, gen(reporting_level_2) label(level)
	  
	  bysort country_code welfare_type year: egen _ncover = count(reporting_level_2)
	  gen _tokeepn = ( (inlist(reporting_level_2, 3, 4) & _ncover > 1) | _ncover == 1)

	  keep if _tokeepn == 1
	* Keep longest series per country
	  by country_code welfare_type, sort:  gen _ndtype = _n == 1
	  by country_code : replace _ndtype = sum(_ndtype)
	  by country_code : replace _ndtype = _ndtype[_N] // number of welfare_type per country


	  bysort country_code welfare_type: egen _type_length = count(year)
	  bysort country_code: egen _type_max = max(_type_length)
	  replace _type_max = (_type_max == _type_length)

	* in case of same length in series, keep consumption
	  by country_code _type_max, sort:  gen _ntmax = _n == 1
	  by country_code : replace _ntmax = sum(_ntmax)
	  by country_code : replace _ntmax = _ntmax[_N]  // max 


	  gen _tokeepl = ((_type_max == 1 & _ntmax == 2) | ///
	                (welfare_type == 1 & _ntmax == 1 & _ndtype == 2)) | ///
	                _ndtype == 1

	  keep if _tokeepl == 1
	  drop _*

{txt}      ({stata "pip_examples pip_example09":click to run})

{phang2}
{ul:3.3} Longest series for a country with the same welfare type. 
Not necessarily the latest

{cmd}
	pip, clear
	*Series length by welfare type
	bysort country_code welfare_type:  gen series = _N
	*Longest 
	bysort country_code : egen longest_series=max(series)
	tab country_code if series !=longest_series
	keep if series == longest_series

	*2. If same length: keep most recent 
	bys country_code welfare_type series: egen latest_year=max(year)
	bysort country_code: egen most_recent=max(latest_year)

	tab country_code if longest_series==series & latest_year!=most_recent 
	drop if most_recent>latest_year 

	*3. Not Applicable: if equal length and most recent: keep consumption
	bys country_code: egen preferred_welfare=min(welfare_type)
	drop if welfare_type != preferred_welfare 

{txt}      ({stata "pip_examples pip_example10":click to run})

{ul:4. Analytical examples}

{phang2}
{ul:4.1} Graph of trend in poverty headcount ratio and number of poor for the world

{cmd}
	  pip wb,  clear

	  keep if year > 1989
	  keep if region_code == "WLD"	
	  gen poorpop = headcount*population / 1000000 
	  gen hcpercent = round(headcount*100, 0.1) 
	  gen poorpopround = round(poorpop, 1)

	  twoway (sc hcpercent year, yaxis(1) mlab(hcpercent)           ///
	           mlabpos(7) mlabsize(vsmall) c(l))                    ///
	         (sc poorpopround year, yaxis(2) mlab(poorpopround)     ///
	           mlabsize(vsmall) mlabpos(1) c(l)),                   ///
	         yti("Poverty Rate (%)" " ", size(small) axis(1))       ///
	         ylab(0(10)40, labs(small) nogrid angle(0) axis(1))     ///
	         yti("Number of Poor (million)", size(small) axis(2))   ///
	         ylab(0(400)2000, labs(small) angle(0) axis(2))         ///
	         xlabel(,labs(small)) xtitle("Year", size(small))       ///
	         graphregion(c(white)) ysize(5) xsize(5)                ///
	         legend(order(                                          ///
	         1 "Poverty Rate (% of people living below $2.15)"      ///
	         2 "Number of people who live below $2.15") si(vsmall)  ///
	         row(2)) scheme(s2color)
	
{txt}      ({stata "pip_examples pip_example01":click to run})

{phang2}
{ul:4.2} Graph of trends in poverty headcount ratio by region, multiple poverty lines ($2.15, $3.65, $6.85)

{cmd}	
	  pip wb, povline(2.15 3.65 6.85) clear
	  drop if inlist(region_code, "OHI", "WLD") | year<1990
	  keep poverty_line region_name year headcount
	  replace poverty_line = poverty_line*100
	  replace headcount = headcount*100
	
	  tostring poverty_line, replace format(%12.0f) force
	  reshape wide  headcount,i(year region_name) j(poverty_line) string
	
	  local title "Poverty Headcount Ratio (1990-2019), by region"

	  twoway (sc headcount215 year, c(l) msiz(small))  ///
	         (sc headcount365 year, c(l) msiz(small))  ///
	         (sc headcount685 year, c(l) msiz(small)), ///
	         by(reg,  title("`title'", si(med))        ///
	         	note("Source: pip", si(vsmall)) graphregion(c(white))) ///
	         ylabel(, format(%2.0f)) ///
	         xlab(1990(5)2019 , labsi(vsmall)) xti("Year", si(vsmall))     ///
	         ylab(0(25)100, labsi(vsmall) angle(0))                        ///
	         yti("Poverty headcount (%)", si(vsmall))                      ///
	         leg(order(1 "$2.15" 2 "$3.65" 3 "$6.85") r(1) si(vsmall))        ///
	         sub(, si(small))	scheme(s2color)
{txt}      ({stata "pip_examples pip_example07":click to run})

{phang2}
{ul:4.3} Graph of population distribution across income categories in Latin America, by country

{cmd}
	  pip, region(lac) year(last) povline(2.15 3.65 6.85) clear 
	  keep if welfare_type==2 & year>=2014             // keep income surveys
	  keep poverty_line country_code country_name year headcount
	  replace poverty_line = poverty_line*100
	  replace headcount = headcount*100
	  tostring poverty_line, replace format(%12.0f) force
	  reshape wide  headcount,i(year country_code country_name ) j(poverty_line) string
    
  	  gen percentage_0 = headcount215
	  gen percentage_1 = headcount365 - headcount215
	  gen percentage_2 = headcount685 - headcount365
	  gen percentage_3 = 100 - headcount685
	
	  keep country_code country_name year  percentage_*
	  reshape long  percentage_,i(year country_code country_name ) j(category) 
	  la define category 0 "Extreme poor (< $2.15)" 1 "Poor LIMIC ($2.15-$3.65)" ///
		                 2 "Poor UMIC ($3.65-$6.85)" 3 "Non-poor (> $6.85)"
	  la val category category
	  la var category ""

	  local title "Distribution of Income in Latin America and Caribbean, by country"
	  local note "Source: World Bank PIP, using the latest survey after 2014 for each country."
	  local yti  "Population share in each income category (%)"

	  graph bar (mean) percentage, inten(*0.7) o(category) o(country_code, ///
	    lab(labsi(small) angle(vertical)) sort(1) descending) stack asy                      /// 
	  	blab(bar, pos(center) format(%3.1f) si(tiny))                     /// 
	  	ti("`title'", si(small)) note("`note'", si(*.7))                  ///
	  	graphregion(c(white)) ysize(6) xsize(6.5)                         ///
	  		legend(si(vsmall) r(3))  yti("`yti'", si(small))                ///
	  	ylab(,labs(small) nogrid angle(0)) scheme(s2color)
{txt}      ({stata "pip_examples pip_example03":click to run})


{p 40 20 2}(Go back to {it:{help pip##sections:pip's main menu}}){p_end}




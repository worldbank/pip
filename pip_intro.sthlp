{smcl}
{* *! version 1.0.0 dec 2022}{...}
{vieweralsosee "" "--"}{...}
{cmd:help pip intro}{right:{browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}}
{right:{browse "https://worldbank.github.io/pip/"}}
{hline}


{marker desc}{...}
{title:Description}

{pstd}
The {cmd:pip} command has the same functionality as the {browse "https://pip.worldbank.org/":PIP website}. 
It allows Stata users to compute poverty and inequality indicators for over 160 countries 
in the World Bank's database of household surveys. PIP is a computational tool that allows 
users to conduct country-specific, cross-country, as well as global and regional poverty analyses. 
Users are able estimate rates  over time and at any poverty line specified. {cmd:pip} reports a 
wide range of measures for poverty (at any chosen poverty line) and inequality. See full list of indicators 
available in {cmd:pip} {help pip##list:below}.

{pstd}
{it:{ul:modular structure:}} The {cmd:pip} command works in a modular 
(subcommand, hereafter) fashion. There is no instruction to {cmd:pip} that is 
executed outside a particular subcommand. When no subcommand is invoked, as in 
{cmd:pip, clear}, the subcommand {cmd:cl} (coutry-level estimates) is in use. 
Thus, understanding {cmd:pip} fully is equivalent to understand each subcommand 
and its options fully. 

{pstd}
{it:{ul:welfare aggregate:}} To make estimates 
comparable across countries, the welfare aggregate is expressed in PPP values
of the most recent {browse "https://www.worldbank.org/en/programs/icp":ICP } 
round that has been approved for global poverty estimates
by the directives of the World Bank.  The detailed methodology of the welfare
aggregate conversion can be found in the 
{browse "https://datanalytics.worldbank.org/PIP-Methodology/convert.html": Poverty and Inequality Platform Methodology Handbook}.
 
{pstd}
PIP is the result of a close collaboration between World Bank staff across the Development Data Group, the Development Research Group, and the Poverty and Inequality Global Practice. 



{title:Examples}

{pstd}
The examples below do not comprehend of {cmd:pip}'s features.

{ul:1. Basic examples}

{phang}
1.1. Load latest available survey-year estimates for Colombia and Argentina

{phang2}
{stata pip cl, country(col arg) year(last) clear} 

{phang}
1.2. Load clickable menu

{phang2}
{stata pip, info}

{phang}
1.3. Load only urban coverage level

{phang2}
{stata pip cl, country(all) coverage("urban") clear}


{ul:2. Differences between queries }

{phang}
2.1. Country estimation at $2.15 in 2015. Since there are no surveys in ARG in 
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


{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}



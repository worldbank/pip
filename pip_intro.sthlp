{smcl}
{* *! version 1.0.0 dec 2022}{...}
{vieweralsosee "" "--"}{...}
{cmd:help pip intro}{right:{browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}}
{help pip:(return to pip)} {right:{browse "https://worldbank.github.io/pip/"}}
{hline}

{pstd}
{res}This entry aims to equip new  users with basic knowledge of the most
useful features of the {cmd:pip} command. For a more detailed explanation 
of each subcommand, please visit the {help pip##sbc_table:subcommand directory}. 
{txt}

{title:Remarks}

{pstd}
This introduction is presented under the following headings:

{col 8}{help pip_intro##desc:Description}
{col 8}{help pip_intro##basic:Basic Use}
{col 12}{help pip_intro##cl:Country-level}
{col 12}{help pip_intro##wb:Regional/global-level}
{col 12}{help pip_intro##pl:Poverty Lines}
{col 12}{help pip_intro##da:Data Availability}
{col 12}{help pip_intro##ps:Towards distributional analysis}
{col 12}{help pip_intro##ad:Auxiliary Data}
{col 8}{help pip_intro##example:Examples}


{marker desc}{...}
{title:Description}

{pstd}
The {cmd:pip} command allows Stata users to compute poverty and inequality
indicators for over 160 countries in the World Bank's database of household surveys.
The {browse "https://pip.worldbank.org/":Poverty and Inequality Platform}
(PIP) is a computational tool that allows users to conduct country-specific,
cross-country, as well as global and regional poverty analyses. 
Users are able to estimate rates  over time and at any poverty line specified. {cmd:pip} reports
a  wide range of measures for poverty (at any chosen poverty
line) and inequality. See {help pip####povcal:full list of indicators} available in {cmd:pip}.

{pstd}
{it:{ul:modular structure:}} The {cmd:pip} command works in a modular 
(subcommand) fashion. There is no instruction to {cmd:pip} that is 
executed outside a particular subcommand. When no subcommand is invoked--as 
in {cmd:pip, clear}--the subcommand {cmd:cl} (country-level estimates) 
is in use. Thus, understanding {cmd:pip} fully is equivalent to understand each subcommand and 
all its options. For a list of all subcommands and 
their corresponding help entries, visit the {help pip##sbc_table:subcommand directory},
and their corresponding "options" help file.

{pstd}
{it:{ul:welfare aggregate:}} To make estimates 
comparable across countries, the welfare aggregate is expressed in PPP values
of the most recent {browse "https://www.worldbank.org/en/programs/icp":ICP } 
round that has been approved for global poverty estimates
by the World Bank directives. The detailed methodology behind the welfare
aggregate conversion can be found in the
{browse "https://datanalytics.worldbank.org/PIP-Methodology/convert.html":Poverty and Inequality Platform Methodology Handbook}.
 
{pstd}
{it:{ul:Collaboration:}} PIP is the result of a close collaboration between World Bank staff across the Development Data Group, the Development Research Group, and the Poverty and Inequality Global Practice. 


{marker basic}{...}
{title:Basic use}

{pstd}
The main functionality of {cmd:pip} is to compute poverty and inequality
indicators for over 160 countries in the World Bank's database of household
surveys. Poverty measures are estimated at two  levels of aggregation: country-level 
and regional/global-level. These can be accessed using the subcommands {cmd:cl} (default) 
and {cmd:wb}, respectively. For a detailed explanation of {cmd:cl} and {cmd:wb} click {help pip_cl:here}.

{marker cl}{...}
{ul:country-level}

{pstd}
For instance, you can query poverty at {help pip_intro##pl:$2.15-a-day} poverty line for 
ALL countries in ALL survey years

{p 8 16 2}
{cmd:. pip cl,  clear} 

{pstd} or simply

{p 8 16 2}
{cmd:. pip,  clear}   // (since the default subcommand is {cmd:cl})

{pstd}
You can also filter your query by specific country and survey year
(see full {help pip_countries:list of countries and regions} codes). For instance, Morocco in 2013:

{p 8 16 2}
{cmd:. pip, country(mar) year(2013) clear} 

{pstd}
For extrapolated and interpolated data that underpin the global and regional
poverty numbers, use {cmd:fillgaps} option. There is no survey in Morocco in
2019, but you could estimate it by typing:

{p 8 16 2}
{cmd:. pip, country(mar) year(2019) fillgaps clear} {p_end}

{phang2}
{err:Note:} Extrapolated and interpolated values are made available for transparency
purposes only and are {bf:NOT} intended to be use four country-level analysis, as
they are originally calculated to estimated global poverty. See{help pip##disclaimer: disclaimer note}.

{marker wb}{...}
{ul:regional/global-level}

{pstd}
To get poverty estimates at the regional/global-level, just switch the
{cmd:cl} subcommand for {cmd:wb}

{p 8 16 2}
{cmd:. pip wb, clear} 

{pstd}
Query a particular region using {cmd:region()} options (see full {help pip_countries:list of countries and regions} codes).

{p 8 16 2}
{cmd:. pip wb, clear region(LAC)} 

{marker pl}{...}
{ul:Poverty lines}

{pstd}
By default, {cmd:pip} estimate poverty measures at the international poverty
line of the current {browse "https://www.worldbank.org/en/programs/icp":ICP}
round. For the 2017 round, the value is  $2.15-a-day.
However, you can estimate poverty at different thresholds, indicating the desired
poverty line value(s) in the {it:povline()} option: 

{p 8 16 2}
{cmd:. pip, country(mar) year(2019) fillgaps povline(6.85)} 

{pstd}
You can also query multiple poverty lines (up to 5 values): 

{p 8 16 2}
{cmd:. pip, country(mar) year(2019) fillgaps povline(2.15 3.65 6.85 10)} 

{marker da}{...}
{ul:Data availability}

{pstd}
To display data availability by country and region, type:

{p 8 16 2}
{cmd:. pip info} 

{pstd}
If data is not available for a particular survey year, {cmd:pip} will return
and error but will provide you with a clickable hyperlink to find out the 
survey availability for the country of interest. For example:

{p 8 16 2}
{cmd:. pip, country(mar) year(2019) clear}{p_end}
{p 8 16 2}
{err:  "Survey year 2019 is not available in MAR. Only the following are available: ..."}

{marker ps}{...}
{ul:Towards distributional analysis}

{pstd}
The default use of pip is to get the poverty headcount. However, the inverse operation is also available in {cmd:pip}. You can provide the share of the population using {cmd:popshare()} 
and get in return the monetary value of the welfare distribution.
For instace, you can estimate the median of the welfare vector like this:

{p 8 16 2}
{cmd:.pip, country(mar) year(2013) clear popshare(0.5)}{p_end}

{marker ad}{...}
{ul:Auxiliary data}

{pstd}
Though the main underlying data of PIP are the household surveys, {cmd:pip} makes
use of many other auxiliary data sources such as GDP, CPI, population, among many others.
You can access the list of all auxiliary tables with the following command, and click on the one of your interest: 

{p 8 16 2}
{cmd:.pip tables, clear}{p_end}

{pstd}
Alternatively, you can provide the name of the specific table of interest directly in the command:

{p 8 16 2}
{cmd:.pip tables, table(cpi) clear}{p_end}


{marker examples}{...}
{title:Examples}

{pstd}
The examples below do not comprehend of {cmd:pip}'s features.

{ul:1. Basic examples}

{phang}
1.1. Load latest available survey-year estimates for Colombia and Argentina

{phang2}
{stata pip cl, country(col arg) year(last) clear} 

{phang}
1.2. Load clickable menu of data available

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



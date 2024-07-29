{smcl}
{* *! version 1.0.0 dec 2022}{...}
{vieweralsosee "" "--"}{...}
{cmd:help pip cl} and {cmd:help pip wb}{right:{browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}}
{help pip:(return to pip)} {right:{browse "https://worldbank.github.io/pip/"}}
{hline}

{title:syntax}

{pstd}
{cmd:{it:cl}}: Country level

{p 8 16 2}
{cmd:pip} [cl], [{cmd:,} {it:{help pip##cl_wb_options:cl options}}]


{pstd}
{cmd:{it:wb}}: World Bank global and regional aggregates

{p 8 16 2}
{cmd:pip wb}, [{cmd:,} {it:{help pip##cl_wb_options:wb options}}]


{marker opts_desc}{...}
{title:Options}

{pstd}

{marker cl_wb_options}{...}
{synoptset 27 tabbed}{...}
{synopthdr:cl and wb options}
{synoptline}
{synopt :{opt reg:ion}(3-letter WB code)}List of {help pip_countries##regions:region code} or "all". Default is "{it:all}".{p_end}
{synopt :{opt cov:erage(string)}}Coverage level ("national", "urban", "rural", "all"). Default "{it:all}".{p_end}
{synopt :{opt y:ear}(numlist|string)}{help numlist} of years  or "all", or "last". Default is "{it:all}".{p_end}
{synopt :{opt povl:ine:}(#)}List of poverty lines (accepts up to 5) in specified PPP (see option {help pip##general_options:ppp_year(#)}) to calculate 
poverty. Default is 2.15 at 2017 PPPs.{p_end}
 {pstd}
 
{p 4 4 2}The following options only work at the country level:{p_end}

{synopt :{opt cou:ntry:}(3-letter code)}List of {help pip_countries##countries:country codes} or "all". Default is "{it:all}".{p_end}
{synopt :{opt pops:hare:}(#)}List of quantiles. No default. Cannot be used with option {opt povline:(#)}.{p_end}
{synopt :{opt fill:gaps}}Loads country-level estimates (including extrapolations and interpolations) used to create regional and global aggregates.{p_end}
{synoptline}
{synopt :{helpb pip##general_options: general options}}Options that apply to any subcommand.{p_end}


{marker description}{...}
{title:Description}:

{pstd}
the {cmd:cl} (the default) and {cmd:wb} subcommands are the main modules of {cmd:pip}.
{cmd:cl} provides the country-level poverty and inequality estimates, whereas 
{cmd:wb} provides regional and global level poverty estimates. As of now, the
underlying welfare aggregate is the per capita household income or consumption
expressed in 2017 PPP USD (the option {cmd:ppp_year(2011)} allows to
estimate values in 2011 PPPs). Poverty lines, means, and medians are expressed in
{cmd:daily amounts}. 

{phang}
{res:{ul:Country-level estimates:} }The PIP API reports two types of results:

{pmore}
{opt 1.Survey-year}: Refers to poverty and inequality estimates for the year 
in which the survey was conducted (i.e., survey period). This is the default 
in {cmd:pip cl}. Details of the poverty and inequality estimates 
methodology can be found
{browse "https://datanalytics.worldbank.org/PIP-Methodology/surveyestimates.html":here}.

{pmore}
{opt 2.Lineup-year}: In order to estimate regional and global poverty measures, 
it is necessary to have country-level poverty measures in a reference year that 
is common across countries. Since there is no single year in which all countries in
the world have conducted a household survey suitable for national poverty estimates,
it is necessary to {it: fill the gaps} by interpolating or extrapolating 
poverty measures for those countries with no survey in the reference year.
This process of {it:filling the gaps} is known as {it:lining up} the welfare
aggregate, and hence {it:lineup years} estimates. You can get the lineup estimates
by using the option {it:fillgaps}, as in {cmd:pip cl, fillgaps}. Methodological 
details of the lineup can be found
{browse "https://datanalytics.worldbank.org/PIP-Methodology/lineupestimates.html":here}.
Users are cautioned in the use of lineup values (see{help pip##disclaimer: disclaimer note}).

{pin}
{res:Note 1}: The option {it:fillgaps} reports the underlying country estimates for a lineup-year.
These may coincide with the survey-year estimates if the country has a survey in the
lineup year. In other cases,  these would be extrapolated from the nearest survey or
interpolated between two surveys. 

{pin}
{res:Note 2}: Poverty measures that are calculated for both survey-years and
lineup-years  include the headcount ratio, poverty gap, squared poverty gap and societal poverty.
Inequality measures, including the Gini index, the mean log deviation and decile
shares, are calculated only in survey-years and are not reported for lineup-years.

{phang}
{res:{ul:Regional/Global-level estimates:} }Regional and global aggregates are 
available with subcommand {it:wb} and in {cmd: pip wb} and they calculated only 
for lineup-years. The extrapolated or interpolated survey-year estimates require two
assumptions:

{phang2}
1. Growth in household income or consumption can be approximated by growth in national accounts{p_end}
{phang2}
2. All parts of the distribution grow at the same rate.{...}


{marker opt_details}{...}
{title:Options Details}

{phang}
{opt country(string)} {help pip_countries##countries:Countries and Economies Abbreviations}. 
If specified with {opt year(#)}, this option will return all the countries for which there is
actual survey data in the year specified. When selecting multiple countries, use the corresponding
three-letter codes separated by spaces. The option {it:all} is a shorthand for calling all countries.

{phang}
{opt region(string)} {help pip_countries##regions:Regions Abbreviations}  If 
specified with {opt year(#)}, this option will return all the countries in the specified region(s)
that have a survey in that year. For example, {opt region(LAC)} will return all countries in Latin
America and the Caribbean that have a survey in the specific year. When selecting multiple regions,
use the corresponding three-letter codes separated by spaces. The  option {it:all} is a shorthand
for calling all regions, which is equivalent to calling all countries.

{phang}
{opt coverage(string)} Selects the geographic coverage of the estimates. By default, all coverage
levels are loaded, but the user may select "national", "urban", or "rural".
Only one level of coverage can be selected per query.

{phang}
{opt year(#)} Four digit years are accepted. When selecting multiple years, use
spaces to separate them. The option {it:all} is a shorthand for calling all
years, while the {it:last} option will download the latest available year
for each country.

{phang}
{opt povline(#)} The poverty lines for which the poverty measures will be calculated. When selecting
multiple poverty lines, use less than 4 decimals and separate each value with spaces. If
left empty, the default poverty line of $2.15 is used. By default, poverty lines are expressed in
2017 PPP USD per capita per day. If option {opt ppp_year(2011)} is specified, the poverty lines will be expressed in 2011 PPPs.

{phang}
{ul:{it:The following options only apply to cl}}

{phang}
{opt popshare(#)} The desired quantile. For example, specifying popshare(0.1) returns the first
decile as the value of the poverty line. In other words, the estimated poverty line will be the
nearest income or consumption level such that the incomes of 10% of the population fall below it.
This has no default, and cannot be combined with {opt povline}. The quantile (recorded in the variable
poverty_line) is expressed in 2017 PPP USD per capita per day (unless option {opt ppp_year(2011)} is specified,
in which case it will be reported in 2011 PPP values).

{phang}
{opt fillgaps} Loads all country-level estimates that are used to create the  
global and regional aggregates in the reference years.

{p 8 8 2}{err:Note}: Countries without a survey in the reference-year have been 
extrapolated or interpolated using national accounts growth rates and assuming
distribution-neutrality (see Chapter 6
{browse "https://openknowledge.worldbank.org/bitstream/handle/10986/20384/9781464803611.pdf":here}).
Therefore, changes at the country-level from one reference year to the next need 
to be interpreted carefully and may not be the result of a new household survey.


{marker examples}{...}
{title:Examples}

{pstd}
The examples below do not comprehend of all of {cmd:pip}'s features.

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


{p 40 20 2}(Go back to {it:{help pip##sections:pip's main menu}}){p_end}




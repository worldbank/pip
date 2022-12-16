{smcl}
{* *! version 1.0.0 dec 2022}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install wbopendata" "ssc install wbopendata"}{...}
{vieweralsosee "Help wbopendata (if installed)" "help wbopendata"}{...}
{viewerjumpto "Command description"   "pip##desc"}{...}
{viewerjumpto "Parameters description"   "pip##param"}{...}
{viewerjumpto "Options description"   "pip##options"}{...}
{viewerjumpto "Subcommands"   "pip##subcommands"}{...}
{viewerjumpto "Stored results"   "pip##return"}{...}
{viewerjumpto "Examples"   "pip##Examples"}{...}
{viewerjumpto "Disclaimer"   "pip##disclaimer"}{...}
{viewerjumpto "How to cite"   "pip##howtocite"}{...}
{viewerjumpto "References"   "pip##references"}{...}
{viewerjumpto "Acknowledgments"   "pip##acknowled"}{...}
{viewerjumpto "Authors"   "pip##authors"}{...}
{viewerjumpto "Regions" "pip_countries##regions"}{...}
{viewerjumpto "Countries" "pip_countries##countries"}{...}
{title:Title}

{p2colset 9 24 22 2}{...}
{p2col :{hi:pip} {hline 2}}Access poverty and inequality data from the 
World Bank's {browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}. 
The {cmd:pip} command allows Stata users to access the poverty and inequality indicators 
available in the PIP platform and estimate poverty at any line. PIP contains more 
indicators than its predecessor(povcalnet). See {help pip##list:below} for a comparison
between the indicators in the pip and povcalnet commands. {p_end}
{p2col :{hi:Website: }}{browse "https://worldbank.github.io/pip/"}{p_end}
{p2colreset}{...}
{title:Syntax}

{p 6 16 2}
{cmd:pip} [{it:{help pip##subcommands:subcommand}}]{cmd:,} 
[{it:{help pip##param:Parameters}} {it:{help pip##options:Options}}]

{pstd}
Description of parameters and options

{synoptset 27 tabbed}{...}
{synopthdr:Parameters}
{synoptline}
{synopt :{opt coun:try:}(3-letter code)}List of {it:{help pip_countries##countries:country code}} (accepts multiples) or {it:all}. Default "{it:all}".
Cannot be used with option {it:region()}{p_end}
{synopt :{opt reg:ion}(WB code)}List of {it:{help pip_countries##regions:region code}} (accepts multiple) or {it:all}. Default "{it:all}".
Cannot be used with option {it:country()}{p_end}
{synopt :{opt coverage(string)}}Coverage level ("national", "urban", "rural", "all"). Default "all".{p_end}
{synopt :{opt year:}(numlist|string)}List of years (accepts up to 10),  or {it:all}, or {it:last}. Default "all".{p_end}
{synopt :{opt pov:line:}(#)}List of poverty lines (in PPP specified, see option {cmd:ppp_year(#)}) to calculate 
 poverty measures (accepts up to 5). Default is 2.15 and 2017 PPPs.{p_end}
{synopt :{opt pops:hare:}(#)}List of quantiles. No default. Cannot be used with option {opt pov:line:}{p_end}
{synopt :{opt fill:gaps}}Loads country-level estimates (including extrapolations and interpolations) used to create regional and global aggregates.{p_end}

{synoptset 27 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt :{opt version(string)}}Combination of numbers in the format %Y%m%d_YYYY_RV_AV_SSS 
(click {bf:{help pip_note:here}} for explanation of each component). This {it:version()} option supersedes 
the next 3 options {it:ppp_year()}, {it:release()} & {it:identity()}, as the combination of these parameters uniquely identifies a dataset.{p_end}
{synopt :{opt ppp:_year:}(#)}PPP round (2011 or 2017). {p_end}
{synopt :{opt release(numlist)}}8 digit number with the PIP release date in the format {it:YYYYMMDD}.{p_end}
{synopt :{opt identity(string)}{err:*}}Version of data to run the query on (e.g., prod, int, test). See description of each identity {bf:{help pip_note:here}}.{p_end}
{synopt :{opt server(string)}{err:*}}Name of server to query (e.g, prod, dev, qa). See description of each server {bf:{help pip_note:here}}.{p_end}

{pstd}
{err:*Note}: The {cmd:server()} and {cmd:identity()} options are available internally only for Bank staff.
For a detailed description of the {cmd:server()} and {cmd:identity()} options see {bf:{help pip_note:here}}.

{synoptset 27 tabbed}{...}
{synopthdr:Operational}
{synoptline}
{synopt :{opt clear}}Replaces data in memory.{p_end}
{synopt :{opt querytimes(integer)}}Number of times the API is hit before defaulting to failure. 
Default is 5. {it:Advanced option. Use only if internet connection is poor}.{p_end}
{synopt :{opt table(string)}}Loads one auxiliary table, this option is used along with the {cmd:tables} subcommand.{p_end}

{synoptset 27 tabbed}{...}
{synopthdr:Subcommands}
{synoptline}
{synopt :{opt info:rmation}}Presents a clickable version of the available surveys, 
countries and regions.{p_end}
{synopt :{opt wb}}Downloads World Bank's regional and global aggregation.{p_end}
{synopt :{opt tables}}Provides clickable list of auxiliary tables for download.{p_end}
{synopt :{opt clean:up}}Deletes all pip data from current stata memory.{p_end}
{synopt :{opt dropframe}}({it:Programmer's option}) Deletes auxiliary PIP frames in memory.{p_end}
{synopt :{opt dropglobal}}({it:Programmer's option}) Deletes auxiliary PIP global macros in memory.{p_end}

{pstd}
{bf:Note}: {cmd:pip} requires an internet connection.

{marker sections}{...}
{title:Sections}

{pstd}
Sections are presented under the following headings:

		{it:{help pip##desc:Command description}}
		{it:{help pip##memory:Memory use and frames}}
		{it:{help pip##param:Parameters description}}
		{it:{help pip##options:Options description}}
		{it:{help pip##operational:Operational description}}
		{it:{help pip##subcommands:Subcommands description}}
		{it:{help pip##list:List of pip and povcalnet variables}}
		{it:{help pip##return:Stored results}}
		{it:{help pip##Examples:Examples}}
		{it:{help pip##disclaimer:Disclaimer}}
		{it:{help pip##references:References}}
		{it:{help pip##acknowled:Acknowledgments}}
		{it:{help pip##authors:Authors}}
		{it:{help pip##contact:Contact}}
		{it:{help pip##howtocite:How to cite}}
		{it:{help pip_countries:Region and country codes}}

{marker desc}{...}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}
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
The underlying welfare aggregate is the per capita household income or consumption
 expressed in 2017 PPP USD (with an option to select the 2011 PPPs). Poverty lines are expressed in daily amounts, as well as 
 the means and medians. For more information on the methodology,{browse "https://worldbank.github.io/PIP-Methodology/": click here}.
 
{pstd}
PIP is the result of a close collaboration between World Bank staff accross the Development Data Group, the Development Research Group, and the Poverty and Inequality Global Practice. 


{marker memory}{...}
{title:Memory use and frames}:

{pstd}
{cmd:pip} makes use of the `frames` feature--available since Stata 16--to store a lot of information in memory. This is partly the reason why the first call of pip in a new Stata session is slower compared to subsequent calls. When closing Stata, you may see a pop-up 
message reading {bf:"Frames in memory have changed"}. That is perfectly normal and should not cause any concern. 
However, make sure you save the frames that you created and wish to keep. You can do that by typing {stata frames dir}. 
Frames created by {cmd:pip} are prefixed by {it:_pip} and are marked by an {it:*}, meaning they have not been saved. If you do not wish to save any frames in use, just click "Exit without saving." You can also delete all PIP data in memory using the command {stata pip cleanup}.


{marker typesc}{...}
{title:Type of calculations}:

{pstd}
The pip API reports two types of results:

{phang}
{opt Survey-year}: Estimates refer to the survey period.

{phang}
{opt Reference-year}: Loads poverty measures for a reference year that is common across countries.
Regional and global aggregates are calculated only for reference-years. Survey-year estimates are extrapolated 
or interpolated to a common reference year. These extrapolations and interpolations require additional assumptions,
namely that (a) growth in household income or consumption can be approximated by growth in national accounts and
(b) all parts of the distribution grow at the same rate.{cmd: pip wb} returns the global and regional poverty aggregates
used by the World Bank. 

{pin}
{err:Important}: The option {it:fillgaps} reports the underlying country estimates for a reference-year.
These may coincide with the survey-year estimates if the country has a survey in the reference year. In other cases, 
these would be extrapolated from the nearest survey or interpolated between two surveys. 

{pin}
Poverty measures that are calculated for both survey-years and reference-years  include the headcount ratio, poverty gap,
and squared poverty gap. Inequality measures, including the Gini index, the mean log deviation and decile shares,
are calculated only in survey-years and are not reported for reference-years.

{marker param}{...}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}
{title:Parameters description}

{phang}
{opt country(string)} {help pip_countries##countries:Countries and Economies Abbreviations}. 
If specified with {opt year(#)}, this option will return all the countries for which there is
actual survey data in the year specified.  When selecting multiple countries, use the corresponding
three-letter codes separated by spaces. The option {it:all} is a shorthand for calling all countries.

{phang}
{opt region(string)} {help pip_countries##regions:Regions Abbreviations}  If 
specified with {opt year(#)}, this option will return all the countries in the specified region(s)
that have a survey in that year. For example, {opt region(LAC)} will return all countries in Latin
America and the Caribbean that have a survey in the specific year. When selecting multiple regions,
use the corresponding three-letter codes separated by spaces. The  option {it:all} is a shorthand
for calling all regions, which is equivalent to  calling all countries.

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
{opt povline(#)} The poverty lines for which the poverty measures will be calculated.
When selecting multiple poverty lines, use less than 4 decimals and separate
each value with spaces. If left empty, the default poverty line of $2.15 is used.
By default, poverty lines are expressed in 2017 PPP USD per capita per day.
If option {opt ppp_ppp(2011)} is specified, the poverty lines are expressed in 2011 PPPs.

{phang}
{opt popshare(#)} The desired quantile. For example, specifying popshare(0.1) returns the first
decile as the value of the poverty line. In other words, the estimated poverty line will be the
nearest income or consumption level such that the incomes of 10% of the population fall below it.
This has no default, and cannot be combined with {opt povline}. The quantile (recorded in the variable
poverty_line) is expressed in 2017 PPP USD per capita per day (unless option {opt ppp_year(2011)} is specified,
in which case it is reported in 2011 PPPs).

{phang}
{opt fillgaps} Loads all country-level estimates that are used to create the  
global and regional aggregates in the reference years.

{p 8 8 2}{err:Note}: Countries without a survey in the reference-year have been 
extrapolated or interpolated using national accounts growth rates and assuming
distribution-neutrality (see Chapter 6
{browse "https://openknowledge.worldbank.org/bitstream/handle/10986/20384/9781464803611.pdf":here}).
Therefore, changes at the country-level from one reference year to the next need 
to be interpreted carefully and may not be the result of a new household survey.{p_end}


{marker options}{...}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}
{title:Options description}

{phang}
{opt version} A detailed description of the {bf:version} option is available {bf:{help pip_note:here}}.

{phang}
{opt ppp_year} Allows to specify PPP round (version) that will be used to calculate estimates. Default PPP round year is 2017. The other option are the 2011 PPPs.

{phang}
{opt release} Allows to specify the PIP release date in the format YYYYMMDD.

{phang}
{opt identity} A detailed description of the {bf:identity} option is available {bf:{help pip_note:here}}.

{phang}
{opt server} A detailed description of the {bf:server} option is available {bf:{help pip_note:here}}.  

{marker operational}{...}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}
{title:Operational description}

{marker optinfo}{...}
{phang}
{opt clear} replaces data in memory.

{phang}
{opt querytimes} Number of times the API is hit before defaulting to failure. Default is 5. Advanced option. Use only if internet connection is poor.

{phang}
{opt table} Allows to load one auxiliary table, this option is used along with {cmd:tables} subcommand.



{marker subcommands}{...}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}
{title:Subcommands}

{phang}
{opt information} Presents a clickable version of the available surveys, countries 
and regions. Selecting countries from the menu loads the survey-year estimates.
Choosing regions loads the regional aggregates in the reference years. 

{p 8 8 2}{err:Note}: If option {it:clear} is added, data in memory is replaced 
with a pip guidance database. If option {it:clear} is {ul:not} included,
{cmd:pip} preserves data in memory  but displays a clickable interface of survey
availability in the results window.{p_end} 

{phang}
{opt wb} Download the World Bank's regional and global aggregates. It can be
combined with {it:year()} to filter the aggregated data.

{phang}
{opt tables} Provides access to the auxiliary tables. 
Default command {stata pip tables} a list of auxiliary tables using the 2017 PPPs.
Users can also specify PPP year as {stata  pip tables, ppp_year(2017)}.

{phang}
{opt cleanup} Deletes all PIP data from Stata's memory. 

{phang}
{opt test} By typing {stata pip test}, {cmd:pip} makes use of the global
"${pip_query}" to query your browser directly and test whether the data is
downloadable. 

{marker return}{...}
{title:Stored results}{p 50 20 2}{p_end}

{pstd}
{cmd:pip} stores the following in {cmd:r()}. Suffix _{it:#} is a count of the
poverty line included in {it:povlines()}:

{p2col 5 20 24 2: queries}{p_end}
{synopt:{cmd:r(query_ys_{it:#})}}Years{p_end}
{synopt:{cmd:r(query_pl_{it:#})}}Poverty lines{p_end}
{synopt:{cmd:r(query_ct_{it:#})}}Countries{p_end}
{synopt:{cmd:r(query_cv_{it:#})}}Coverages{p_end}
{synopt:{cmd:r(query_ds_{it:#})}}Whether aggregation was used{p_end}
{synopt:{cmd:r(query_{it:#})}}Concatenation of the queries above{p_end}

{p2col 5 20 24 2: API parts}{p_end}
{synopt:{cmd:r(server)}}Protocol (http://) and server name{p_end}
{synopt:{cmd:r(site_name)}}Site names{p_end}
{synopt:{cmd:r(handler)}}Action handler{p_end}
{synopt:{cmd:r(base)}}Concatenation of server, site_name, and handler{p_end}

{p2col 5 20 24 2: additional info}{p_end}
{synopt:{cmd:r(queryfull_{it:#})}}Complete query{p_end}
{synopt:{cmd:r(npl)}}Total number of poverty lines{p_end}
{synopt:{cmd:pip_query}}Global macro with query information in case {cmd:pip} fails. 
"${pip_query}" to display {p_end}

{marker list}{...}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}
{title:List of pip and povcalnet variables}{p 50 20 2}{p_end}

{pstd}
The following list compares the variables names available in {cmd:pip} with its predecessor command {cmd:povcalnet}.
Only the variables available in povcalnet are listed.

		{hline 43}
		pip variable    {col 40}povcalnet variable
		{hline 20}{col 40}{hline 20}
		country_code     {col 40}countrycode
		country_name     {col 40}countryname
		region_code      {col 40}regioncode
		year             {col 40}year
		welfare_time     {col 40}datayear
		welfare_type     {col 40}datatype
		poverty_line     {col 40}povertyline
		mean             {col 40}mean
		headcount        {col 40}headcount
		poverty_gap      {col 40}povgap
		poverty_severity {col 40}povgapsqr
		watts            {col 40}watts 
		gini             {col 40}gini
		median           {col 40}median
		mld              {col 40}mld
		polarization     {col 40}polarization
		population       {col 40}population
		decile1          {col 40}decile1
		decile2          {col 40}decile2
		decile3          {col 40}decile3
		decile4          {col 40}decile4
		decile5          {col 40}decile5
		decile6          {col 40}decile6
		decile7          {col 40}decile7
		decile8          {col 40}decile8
		decile9          {col 40}decile9
		decile10         {col 40}decile10		
		ppp              {col 40}ppp
		is_interpolated  {col 40}isinterpolated
		distribution_type {col 40}usemicrodata
		survey_coverage  {col 40}coveragetype
		{hline 43}



{marker Examples}{...}
{title:Examples}{p 50 20 2}{p_end}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}

{dlgtab: 1. Basic examples}

{phang}
1.1. Load latest available survey-year estimates for Colombia and Argentina

{phang2}
{stata pip, country(col arg) year(last) clear} 

{phang}
1.2. Load clickable menu

{phang2}
{stata pip, info}

{phang}
1.3. Load only urban coverage level

{phang2}
{stata pip, country(all) coverage("urban") clear}


{dlgtab: 2. Illustration of differences between queries }

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


{dlgtab: 3. Samples uniquely identified by country/year}

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

{dlgtab: 4. Analytical examples}

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

{marker disclaimer}{...}
{title:Disclaimer}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}

{p 4 4 2}To calculate global poverty estimates, survey-year estimates are extrapolated
or interpolated to a common reference year. These extrapolations and interpolations require
additional assumptions, namely that (a) growth in household income or consumption can be
approximated by growth in national accounts and (b) all parts of the distribution grow at
the same rate. Given these assumptions, users are cautioned against using reference-year
estimates (available using the fillgaps option) for comparing a country's poverty trend over time.
For that purpose, users should rely on the survey-year estimates and are advised to take into
account breaks in survey comparability. For details on the methodology please visit the
{browse "https://worldbank.github.io/PIP-Methodology/":PIP Methodology Handbook} and the {browse "https://pip.worldbank.org/publication":Global Poverty Monitoring Technical Notes}.
{p_end}

{p 4 4 2}The term country, used interchangeably with economy, does not imply political independence
but refers to any territory for which authorities report separate social or economic statistics.
{p_end}


{marker references}{...}
{title:References}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}

{p 4 8 2}Castaneda Aguilar, R. A., T.Fujs, C. Lakner, S.K. Tetteh Baah (XXXX)
"Estimating Global Poverty in Stata: The PIP command", XXXX, World Bank, Washington, DC 
{browse "http://":Link}{p_end}

{marker acknowled}{...}
{title:Acknowledgments}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}

{pstd}
The authors would like to thank Ifeanyi Nzegwu Edochie, Tony Fujs, Dean Jolliffe, Daniel Mahler, Minh
Cong Nguyen, Christoph Lakner, Marta Schoch, Samuel Kofi Tetteh Baah, Martha Viveros, Nishan Yonzan,
and Haoyu Wu for comments received on earlier versions of this code. This command builds on the earlier
povcalnet command, which was developed with the help of Espen Prydz, Jorge Soler Lopez, Ruoxuan Wu and Qinghua Zhao. 

{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}
{marker authors}{...}
{title:Author}
{p 4 4 4}R.Andres Castaneda, The World Bank{p_end}
{p 6 6 4}Email: {browse "acastanedaa@worldbank.org":  acastanedaa@worldbank.org}{p_end}
{p 6 6 4}GitHub:{browse "https://github.com/randrescastaneda": randrescastaneda }{p_end}

{title:Contributor}
{pstd}
Tefera Bekele Degefu

{title:Maintainer}
{p 4 4 4}PIP Technical Team, The World Bank{p_end}
{p 6 6 4}Email: {browse "pip@worldbank.org":  pip@worldbank.org}{p_end}

{marker contact}{...}
{title:Contact}
{pstd}
Any comments, suggestions, or bugs can be reported in the 
{browse "https://github.com/worldbank/pip/issues":GitHub issues page}.
All the files are available in the {browse "https://github.com/worldbank/pip":GitHub repository}

{marker howtocite}{...}
{title:Thanks for citing this Stata command as follows}

{p 4 8 2}Castañeda, R.Andrés. (2022) 
"pip: Stata Module to Access World Bank’s Global Poverty and Inequality Data" 
				(version 1.0.0). Stata. Washington, DC: World Bank Group.
        https://worldbank.github.io/pip/ {p_end}

{title:Thanks for citing {cmd:pip} data as follows}

{p 4 8 2} World Bank. (2022). Poverty and Inequality Platform (version {version_ID}) 
[Data set]. World Bank Group. www.pip.worldbank.org. Accessed  {date}{p_end}

{p 4 8 2}Available version_IDs:{p_end}
{p 4 8 2}2017 PPPs: 20220909_2017_01_02_PROD{p_end}
{p 4 8 2}2011 PPPs: 20220909_2011_02_02_PROD{p_end}

{pstd}
Please make reference to the date when the database was downloaded, as statistics may change.

{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}





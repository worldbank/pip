{smcl}
{* *! version 0.3.0 08 apr 2022}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install wbopendata" "ssc install wbopendata"}{...}
{vieweralsosee "Help wbopendata (if installed)" "help wbopendata"}{...}
{viewerjumpto 	"Command description"   "pip##desc"}{...}
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
{p2col :{hi:pip} {hline 2}}Access Global Poverty and Inequality measures from the 
World Bank's new {browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}. 
The {cmd:pip} command allows Stata users to estimate the poverty and inequality indicators 
available in the PIP platform. PIP contains more indicators than its predecessor(povcalnet). 
However, to make the platform compatible with povcalnet, the same indicators are also 
available in {cmd:pip}. See {help pip##list:below} the list comparing pip and povcalnet indicators. {p_end}
{p2col :{hi:Website: }}{browse "https://worldbank.github.io/pip/"}{p_end}
{p2colreset}{...}
{title:Syntax}

{p 6 16 2}
{cmd:pip} [{it:{help pip##subcommands:subcommand}}]{cmd:,} 
[{it:{help pip##Options2:Parameters}} {it:{help pip##options:Options}}]

{pstd}
Description of parameter options

{synoptset 27 tabbed}{...}
{synopthdr:Estimations}
{synoptline}
{synopt :{opt coun:try:}(3-letter code)}List of country code (accepts multiples) or {it:all}. 
Cannot be used with option {it:region()}{p_end}
{synopt :{opt reg:ion}(WB code)}List of region code (accepts multiple) or {it:all}. 
Cannot be used with option {it:country()}{p_end}
{synopt :{opt coverage(string)}}Loads coverage level ("national", "urban", "rural", "all"). Default "all".{p_end}
{synopt :{opt year:}(numlist|string)}List of years (accepts up to 10),  or {it:all}, or {it:last}. Default "all".{p_end}
{synopt :{opt pov:line:}(#)}List of poverty lines (in 2011 PPP-adjusted USD) to calculate 
 poverty measures (accepts up to 5). Default is 1.9.{p_end}
{synopt :{opt pops:hare:}(#)}List of population shares to calculate poverty lines (in 2011 PPP-adjusted USD) and poverty measures. No default. Do not combine with {opt pov:line:}{p_end}
{synopt :{opt fill:gaps}}Loads all countries used to create regional aggregates.{p_end}
{synopt :{opt ppp}{cmd:(#)}}Allows the selection of PPP. {p_end}

{synoptset 27 tabbed}{...}
{synopthdr:Version}
{synoptline}
{synopt :{opt server(string)}{err:*}}Name of a server to query on (e.g, prod, dev, qa). See description of each server {bf:{help pip_note:here}}.{p_end}
{synopt :{opt identity(string)}{err:*}}Version of data to run the query on (e.g., prod, int, test).{p_end}
{synopt :{opt ppp:_year:}(#)}PPP round (eg., 2005, 2011, 2017).{p_end}
{synopt :{opt release(numlist)}}PIP data release date.{p_end}

{synoptset 27 tabbed}{...}
{synopthdr:Operational}
{synoptline}
{synopt :{opt info:rmation}}Presents a clickable version of the available surveys, countries and regions.{p_end}
{synopt :{opt clear}}Replaces data in memory.{p_end}
{synopt :{opt querytimes(integer)}}Number of times the API is hit before defaulting to failure. 
Default is 5. {it:Advance option. Use only if Internet connection is poor}.{p_end}
{synopt :{opt table(string)}}Loads one auxiliary table, this option is used along with the {cmd:tables} subcommand.{p_end}

{synoptset 27 tabbed}{...}
{synopthdr:subcommands}
{synoptline}
{synopt :{opt info:rmation}}Presents a clickable version of the available surveys, 
countries and regions. Same as option {it:information}{p_end}
{synopt :{opt cl}}{err:(temporally disabled)} {it:country-level} query that changes the default combinatorial 
arrangement of parameters for a one-on-one correspondence. 
See a detailed explanation {help pip##typesq: below}.{p_end}
{synopt :{opt wb}}Downloads World Bank's regional and global aggregation.{p_end}
{synopt :{opt tables}}Provides clickable list of auxiliary tables for download.{p_end}
{synopt :{opt cleanup}}Deletes all pip data from current stata memory.{p_end}


{pstd}
{err:*Note}: The {cmd:server()} and {cmd:identity()} options are available internally only for the Bank staff via the Bank???s intranet. 
For detailed description of the {cmd:server()} and {cmd:identity()} options see {bf:{help pip_note:here}}.

{pstd}
{bf:Note}: {cmd:pip} requires Internet connection.

{marker sections}{...}
{title:Sections}

{pstd}
Sections are presented under the following headings:

		{it:{help pip##desc:Command description}}
		{it:{help pip##param:Parameters description}}
		{it:{help pip##options:Options description}}
		{it:{help pip##subcommands:Subcommands}}
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
The {cmd:pip} command allows Stata users to compute poverty and inequality
 indicators for over 160 countries and regions in the World Bank's database of household
 surveys. It has the same functionality as the {browse "https://pip.worldbank.org/":PIP website}.
 PIP is a computational tool that allows users to conduct country-specific, 
 cross-country, as well as global and regional poverty analyses. Users are able estimate rates 
 over time and at any poverty line specified.
 
{pstd}
PIP is managed jointly by the Data and Research Groups in the World Bank's
 Development Economics Division. It draws heavily upon a strong collaboration with the 
 Poverty and Equity Global Practice, which is responsible for the gathering and 
 harmonization of the underlying survey data. 

{pstd}
 {cmd:pip} reports an ample range of measures for poverty (at chosen poverty line) 
 and inequality, including the mean and median welfare (see full list of indicators
 {help pip##list:below}).

{pstd}
The underlying welfare aggregate is the per capita household income or consumption
 expressed in 2011 PPP-adjusted USD. Poverty lines are expressed in daily amounts, as well as 
 the means and medians. For more information on the definition of the indicators,
 {browse "http://iresearch.worldbank.org/pip/Docs/dictionary.html":click here}. 
 For more information on the methodology,{browse "https://worldbank.github.io/PIP-Methodology/": click here}.

{marker typesc}{...}
{title:Type of calculations}:

{pstd}
The pip API allows two types of calculations:

{phang}
{opt Survey-year}: Will load poverty measures for a reference year that is common
across countries. Regional and global aggregates are calculated only for
reference-years. Countries without a survey in the ....

{phang}
{opt reference-year}: are extrapolated or interpolated using national accounts growth
rates, and assuming distribution-neutrality. {cmd: pip wb} returns the global and
regional poverty aggregates used by the World Bank. 

{pin}
{err:Important}: the Option {it:fillgaps} reports the underlying lined-up country 
estimates for a reference-year. Poverty measures calculated for both survey-years 
and reference-years  include Headcount ratio, Poverty Gap, and Squared Poverty Gap.  
Inequality measures, including the Gini index, mean log deviation and decile shares,
 are calculated only in survey-years where microdata is available. Inequality 
 measures are not reported for reference-years.


{marker param}{...}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}
{title:Parameters description}

{phang}
{opt country(string)} {help pip_countries##countries:Countries and Economies Abbreviations}. 
If specified with {opt year(string)}, this option will return all the specific
countries and years for which there is actual survey data.  When selecting multiple
countries, use the corresponding three-letter codes separated by spaces. The option 
{it:all} is a shorthand for calling all countries.

{phang}
{opt region(string)} {help pip_countries##regions:Regions Abbreviations}  If 
specified with {opt year(string)}, this option will return all the specific countries 
and years that belong to the specified region(s). 
For example, {opt region(LAC)} will return all countries in Latin America and the 
Caribbean for which there's an actual survey in the given years. 
When selecting multiple regions, use the corresponding three-letter codes separated
by spaces. The  option {it:all} is a shorthand for calling all regions, which is
equivalent to  calling all countries.

{phang}
{opt year(#)} Four digit years are accepted. When selecting multiple years, use 
spaced to separate them. The option {it:all} is a shorthand for calling all 
possible years, while the {it:last} option will download the latest available year 
for each country.

{phang}
{opt povline(#)} The poverty lines for which the poverty measures will be calculated. 
When selecting multiple poverty lines, use less than 4 decimals and separate 
each value with spaces. If left empty, the default poverty line of $1.9 is used.
Poverty lines are expressed in 2011 PPP-adjusted USD per capita per day.

{phang}
{opt popshare(#)} The desired population share (headcount) for which the poverty lines as poverty measures will be calculated. 
This has not default, and should not be combined with {opt povline}.
The resulting poverty lines are expressed in 2011 PPP-adjusted USD per capita per day.

{marker options}{...}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}
{title:Options description}

{phang}
{opt fillgaps} Loads all country-level estimates that are used to create the  
aggregates in the reference years. This means that estimates use the same reference 
years as aggregate estimates. 

{p 8 8 2}{err:Note}: Countries without a survey in the reference-year have been 
extrapolated or interpolated using national accounts growth rates and assuming
distribution-neutrality (see Chapter 6
{browse "https://openknowledge.worldbank.org/bitstream/handle/10986/20384/9781464803611.pdf":here}).
Therefore, changes at the country-level from one reference year to the next need 
to be interpreted carefully and may not be the result of a new household survey.{p_end}

{phang}
{opt PPP}{cmd:(#)} Allows the selection of PPP exchange rate. This option only 
works if one, and only one, country is selected.

{phang}
{opt coverage(string)} Selects coverage level of estimates. By default, all coverage
levels are loaded, but the user may select "national", "urban", or "rural". 
Only one level of coverage can be selected per query. 

{marker optinfo}{...}
{phang}
{opt information} Presents a clickable version of the available surveys, countries 
and regions. Selecting countries from the menu loads the survey-year estimates.
Choosing regions loads the regional aggregates in the reference years. 

{p 8 8 2}{err:Note}: If option {it:clear} is added, data in memory is replaced 
with a pip guidance database. If option {it:clear} is {ul:not} included,
{cmd:pip} preserves data in memory  but displays a clickable interface of survey
availability in the results window.{p_end}

{phang}
{opt table} Allows us to load one auxiliary table, this option is used along with {cmd:tables} subcommand. {stata pip tables, table(countries)}

{phang}
{opt clear} replaces data in memory.

{marker subcommands}{...}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}
{title:Subcommands}

{phang}
{opt info} Same as option {it:info} {help pip##optinfo:above}. 

{phang}
{opt cl} Stands for {it:country-level} queries. It changes combinatorial query of parameters 
for one-on-one correspondence of parameters. See {help pip##typesq:above} 
for a detailed explanation. 

{phang}
{opt tables} Allows us to download any auxiliary table of the PIP project. 
Default tables command {stata pip tables} provides us list of auxiliary tables for download from PROD server in INT folder based on PPP 2011. 
We can also specify the server, version of the data, and PPP year as {stata  pip tables, server(prod) identity(int) ppp_year(2011)}

{phang}
{opt cleanup} Allows us to delete all PIP data from Stata's memory. 
The pip wrapper makes use of the `frames` feature???available since Stata 16???to store a lot of information in memory.   
This is in part the reason why the first call of pip in a Stata new session is relatively slower to subsequent calls. 
We may have seen the message below before closing Stata. 
That is perfectly normal and should not cause any concern. Just click ???Exist without saving.??? 
However, you can delete all PIP data in memory using command {stata pip cleanup}

{cmd:pip} makes use of the global "${pip_query}".


{marker return}{...}
{title:Stored results}{p 50 20 2}{p_end}

{pstd}
{cmd:pip} stores the following in {cmd:r()}. Suffix _{it:#} refers to the number of 
poverty lines included in {it:povlines()}:

{p2col 5 20 24 2: queries}{p_end}
{synopt:{cmd:r(query_ys_{it:#})}}Years{p_end}
{synopt:{cmd:r(query_pl_{it:#})}}Poverty lines{p_end}
{synopt:{cmd:r(query_ct_{it:#})}}Countries{p_end}
{synopt:{cmd:r(query_cv_{it:#})}}Coverages{p_end}
{synopt:{cmd:r(query_ds_{it:#})}}Whether aggregation was used{p_end}
{synopt:{cmd:r(query_{it:#})}}concatenation of the queries above{p_end}

{p2col 5 20 24 2: API parts}{p_end}
{synopt:{cmd:r(server)}}Protocol (http://) and server name{p_end}
{synopt:{cmd:r(site_name)}}Site names{p_end}
{synopt:{cmd:r(handler)}}Action handler{p_end}
{synopt:{cmd:r(base)}}concatenation of server, site_name, and handler{p_end}

{p2col 5 20 24 2: additional info}{p_end}
{synopt:{cmd:r(queryfull_{it:#})}}Complete query{p_end}
{synopt:{cmd:r(npl)}}Number of poverty lines{p_end}
{synopt:{cmd:pip_query}}Global macro with query information in case {cmd:pip} fails. 
"${pip_query}" to display {p_end}

{marker list}{...}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}
{title:List of pip and povcalnet variables}{p 50 20 2}{p_end}

{pstd}
The following is a comparative list of variables available in pip and povcalnet: 

		{hline 43}
		PIP variables    {col 40}povcalnet variables
		{hline 20}{col 40}{hline 20}
		country_code     {col 40}countrycode
		country_name     {col 40}countryname
		region_code      {col 40}regioncode
		region_name      {col 40}
		survey_coverage  {col 40}coveragetype
		survey_comparability {col 40}
		survey_acronym   {col 40}
		survey_time      {col 40}		
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
		cpi              {col 40}
		ppp              {col 40}ppp
		gdp              {col 40}
		hfce             {col 40}
		is_interpolated  {col 40}isinterpolated
		distribution_type {col 40}usemicrodata
		reporting_level   {col 40}
		comparable_spell   {col 40}
		pop_in_poverty   {col 40}
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


{dlgtab: 2. inIllustration of differences between queries }

{phang}
2.1. Country estimation at $1.9 in 2015. Since there are no surveys in ARG and IND in 
2015, results are loaded for COL and BRA

{phang2}
{stata pip, country(COL BRA ARG IND) year(2015) clear}

{phang}
2.2. fill-gaps. Filling gaps for ARG and IND. Only works for reference years. 

{phang2}
{stata pip, country(COL BRA ARG IND) year(2015) clear  fillgaps}

{phang}
2.4. World Bank aggregation ({it:country()} is not available)

{phang2}
{stata pip wb, clear  year(2015)}{p_end}
{phang2}
{stata pip wb, clear  region(SAR LAC)}{p_end}
{phang2}
{stata pip wb, clear}       // all reference years{p_end}

{phang}
2.5. One-on-one query. 

{phang2}
{stata pip cl, country(COL BRA ARG IND) year(2011) clear coverage("national national urban national")}

{dlgtab: 3. Samples uniquely identified by country/year}

{phang2}
{ul:3.1} National coverage (when available) and longest possible time series for each country, 
{it:even if} welfare type changes from one year to another.

{cmd}
	. pip, clear

	* keep only national
	. bysort countrycode datatype year: egen _ncover = count(coveragetype)
	. gen _tokeepn = ( (inlist(coveragetype, 3, 4) & _ncover > 1) | _ncover == 1)

	. keep if _tokeepn == 1

	* Keep longest series per country
	. by countrycode datatype, sort:  gen _ndtype = _n == 1
	. by countrycode : replace _ndtype = sum(_ndtype)
	. by countrycode : replace _ndtype = _ndtype[_N] // number of datatype per country

	. duplicates tag countrycode year, gen(_yrep)  // duplicate year

	.bysort countrycode datatype: egen _type_length = count(year) // length of type series
	.bysort countrycode: egen _type_max = max(_type_length)   // longest type series
	.replace _type_max = (_type_max == _type_length)

	* in case of same length in series, keep consumption
	. by countrycode _type_max, sort:  gen _ntmax = _n == 1
	. by countrycode : replace _ntmax = sum(_ntmax)
	. by countrycode : replace _ntmax = _ntmax[_N]  // number of datatype per country


	. gen _tokeepl = ((_type_max == 1 & _ntmax == 2) | ///
	.                (datatype == 1 & _ntmax == 1 & _ndtype == 2) | ///
	.                _yrep == 0)
	. 
	. keep if _tokeepl == 1
	. drop _*

{txt}      ({stata "pip_examples pip_example08":click to run})

{phang2}
{ul:3.2} National coverage (when available) and longest possible time series for each country, restrict to same welfare type throughout.

{cmd}
	. pip, clear
	. bysort countrycode datatype year: egen _ncover = count(coveragetype)
	. gen _tokeepn = ( (inlist(coveragetype, 3, 4) & _ncover > 1) | _ncover == 1)

	. keep if _tokeepn == 1
	* Keep longest series per country
	. by countrycode datatype, sort:  gen _ndtype = _n == 1
	. by countrycode : replace _ndtype = sum(_ndtype)
	. by countrycode : replace _ndtype = _ndtype[_N] // number of datatype per country


	. bysort countrycode datatype: egen _type_length = count(year)
	. bysort countrycode: egen _type_max = max(_type_length)
	. replace _type_max = (_type_max == _type_length)

	* in case of same length in series, keep consumption
	. by countrycode _type_max, sort:  gen _ntmax = _n == 1
	. by countrycode : replace _ntmax = sum(_ntmax)
	. by countrycode : replace _ntmax = _ntmax[_N]  // max 


	. gen _tokeepl = ((_type_max == 1 & _ntmax == 2) | ///
	.               (datatype == 1 & _ntmax == 1 & _ndtype == 2)) | ///
	.               _ndtype == 1

	. keep if _tokeepl == 1
	. drop _*

{txt}      ({stata "pip_examples pip_example09":click to run})

{dlgtab: 4. Analytical examples}

{phang2}
{ul:4.1} Graph of trend in poverty headcount ratio and number of poor for the world

{cmd}
	. pip wb,  clear

	. keep if year > 1989
	. keep if regioncode == "WLD"	
	. gen poorpop = headcount*population 
	. gen hcpercent = round(headcount*100, 0.1) 
	. gen poorpopround = round(poorpop, 1)

	. twoway (sc hcpercent year, yaxis(1) mlab(hcpercent)           ///
	.          mlabpos(7) mlabsize(vsmall) c(l))                    ///
	.        (sc poorpopround year, yaxis(2) mlab(poorpopround)     ///
	.          mlabsize(vsmall) mlabpos(1) c(l)),                   ///
	.        yti("Poverty Rate (%)" " ", size(small) axis(1))       ///
	.        ylab(0(10)40, labs(small) nogrid angle(0) axis(1))     ///
	.        yti("Number of Poor (million)", size(small) axis(2))   ///
	.        ylab(0(400)2000, labs(small) angle(0) axis(2))         ///
	.        xlabel(,labs(small)) xtitle("Year", size(small))       ///
	.        graphregion(c(white)) ysize(5) xsize(5)                ///
	.        legend(order(                                          ///
	.        1 "Poverty Rate (% of people living below $1.90)"      ///
	.        2 "Number of people who live below $1.90") si(vsmall)  ///
	.        row(2)) scheme(s2color)
	
{txt}      ({stata "pip_examples pip_example01":click to run})

{phang2}
{ul:4.2} Graph of trends in poverty headcount ratio by region, multiple poverty lines ($1.9, $3.2, $5.5)

{cmd}	
	. pip wb, povline(1.9 3.2 5.5) clear
	. drop if inlist(regioncode, "OHI", "WLD") | year<1990 
	. keep povertyline region year headcount
	. replace povertyline = povertyline*100
	. replace headcount = headcount*100
	
	. tostring povertyline, replace format(%12.0f) force
	. reshape wide  headcount,i(year region) j(povertyline) string
	
	. local title "Poverty Headcount Ratio (1990-2015), by region"

	. twoway (sc headcount190 year, c(l) msiz(small))  ///
	.        (sc headcount320 year, c(l) msiz(small))  ///
	.        (sc headcount550 year, c(l) msiz(small)), ///
	.        by(reg,  title("`title'", si(med))        ///
	.        	note("Source: pip", si(vsmall)) graphregion(c(white))) ///
	.        xlab(1990(5)2015 , labsi(vsmall)) xti("Year", si(vsmall))     ///
	.        ylab(0(25)100, labsi(vsmall) angle(0))                        ///
	.        yti("Poverty headcount (%)", si(vsmall))                      ///
	.        leg(order(1 "$1.9" 2 "$3.2" 3 "$5.5") r(1) si(vsmall))        ///
	.        sub(, si(small))	scheme(s2color)
{txt}      ({stata "pip_examples pip_example07":click to run})

{phang2}
{ul:4.3} Graph of population distribution across income categories in Latin America, by country

{cmd}
	. pip, region(lac) year(last) povline(3.2 5.5 15) clear 
	. keep if datatype==2 & year>=2014             // keep income surveys
	. keep povertyline countrycode countryname year headcount
	. replace povertyline = povertyline*100
	. replace headcount = headcount*100
	. tostring povertyline, replace format(%12.0f) force
	. reshape wide  headcount,i(year countrycode countryname ) j(povertyline) string
	
	. gen percentage_0 = headcount320
	. gen percentage_1 = headcount550 - headcount320
	. gen percentage_2 = headcount1500 - headcount550
	. gen percentage_3 = 100 - headcount1500
	
	. keep countrycode countryname year  percentage_*
	. reshape long  percentage_,i(year countrycode countryname ) j(category) 
	. la define category 0 "Poor LMI (< $3.2)" 1 "Poor UMI ($3.2-$5.5)" ///
		                 2 "Vulnerable ($5.5-$15)" 3 "Middle class (> $15)"
	. la val category category
	. la var category ""

	. local title "Distribution of Income in Latin America and Caribbean, by country"
	. local note "Source: pip, using the latest survey after 2014 for each country."
	. local yti  "Population share in each income category (%)"

	. graph bar (mean) percentage, inten(*0.7) o(category) o(countrycode, ///
	.   lab(labsi(small) angle(vertical))) stack asy                      /// 
	. 	blab(bar, pos(center) format(%3.1f) si(tiny))                     /// 
	. 	ti("`title'", si(small)) note("`note'", si(*.7))                  ///
	. 	graphregion(c(white)) ysize(6) xsize(6.5)                         ///
	. 		legend(si(vsmall) r(3))  yti("`yti'", si(small))                ///
	. 	ylab(,labs(small) nogrid angle(0)) scheme(s2color)
{txt}      ({stata "pip_examples pip_example03":click to run})



{marker disclaimer}{...}
{title:Disclaimer}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}

{p 4 4 2}pip was developed for the sole purpose of public replication of the World Bank???s poverty measures for its widely used international poverty lines, including $1.90 a day and $3.20 a day in 2011 PPP. 
The methods built into pip are considered reliable for that purpose. 
{p_end}
{p 4 4 2}However, we cannot be confident that the methods work well for other purposes, including tracing out the entire distribution of income. 
We would especially warn that estimates of the densities near the bottom and top tails of the distribution could be quite unreliable, and no attempt has been made by the World Bank???s staff to validate the tool for such purposes.
{p_end}
{p 4 4 2}The term country, used interchangeably with economy, does not imply political independence but refers to any territory for which authorities report separate social or economic statistics.
{p_end}

{marker references}{...}
{title:References}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}

{p 4 8 2}Castaneda Aguilar, R. A., C. Lakner, E. B. Prydz, J. Soler Lopez, R. Wu and Q. Zhao (2019)
"Estimating Global Poverty in Stata: The povcalnet command", Global Poverty Monitoring Technical 
Note, No. 9, World Bank, Washington, DC 
{browse "http://documents.worldbank.org/curated/en/docsearch/collection-title/Global%2520Poverty%2520Monitoring%2520Technical%2520Note?colT=Global%2520Poverty%2520Monitoring%2520Technical%2520Note":Link}{p_end}

{marker acknowled}{...}
{title:Acknowledgments}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}

{pstd}
The authors would like to thank Tony Fujs, Dean Jolliffe, Daniel Mahler, Minh
Cong Nguyen, Christoph Lakner, Martha Viveros, Marta Schoch, Samuel Kofi Tetteh
Baah, Nishan Yonzan, Haoyu Wu, and Ifeanyi Nzegwu Edochie for comments received 
on earlier versions of this code. 

{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}
{marker authors}{...}
{title:Author}
{pstd}
R.Andres Castaneda 

{title:Contributor}
{pstd}
Tefera Bekele Degefu

{title:Maintainer}
{p 4 4 4}R.Andres Castaneda, The World Bank{p_end}
{p 6 6 4}Email: {browse "acastanedaa@worldbank.org":  acastanedaa@worldbank.org}{p_end}
{p 6 6 4}GitHub:{browse "https://github.com/randrescastaneda": randrescastaneda }{p_end}

{marker contact}{...}
{title:Contact}
{pstd}
Any comments, suggestions, or bugs can be reported in the 
{browse "https://github.com/worldbank/pip/issues":GitHub issues page}.
All the files are available in the {browse "https://github.com/worldbank/pip":GitHub repository}

{marker howtocite}{...}
{title:Thanks for citing {cmd:pip} as follows}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}

{p 4 8 2}XXXXX (2022) 
"pip: Stata module to access World Bank???s Global Poverty and Inequality data," 
Statistical Software Components 2022, Boston College Department of Economics.{p_end}

{pstd}
Please make reference to the date when the database was downloaded, as statistics may change





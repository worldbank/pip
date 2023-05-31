{smcl}
{* *! version 1.0.0 dec 2022}{...}
{vieweralsosee "" "--"}{...}
{cmd:help pip cl} and {cmd:help pip wb}{right:{browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}}
{right:{browse "https://worldbank.github.io/pip/"}}
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
{err:Note}: Options abbreviation is not allowed in {cmd:pip} 


{marker cl_wb_options}{...}
{synoptset 27 tabbed}{...}
{synopthdr:cl and wb options}
{synoptline}
{synopt :{opt country:}(3-letter code)}List of {it:{help pip_countries##countries:country code}} or {it:all}. Default is "{it:all}".
Does not work with subcommand {cmd:wb}.{p_end}
{synopt :{opt region}(3-letter WB code)}List of {it:{help pip_countries##regions:region code}} or {it:all}. Default is "{it:all}".{p_end}
{synopt :{opt coverage(string)}}Coverage level ("national", "urban", "rural", "all"). Default "all".{p_end}
{synopt :{opt year:}(numlist|string)}{it:{help numlist}} of years  or {it:all}, or {it:last}. Default is "all".{p_end}
{synopt :{opt povline:}(#)}list of poverty lines (in PPP specified, see option {cmd:ppp_year(#)}) to calculate 
 poverty measures (accepts up to 5). Default is 2.15 at 2017 PPPs.{p_end}
 {pstd}
The following only work with subcommand {cmd:cl}

{synopt :{opt popshare:}(#)}List of quantiles. No default. Cannot be used with option {opt povline:(#)}{p_end}
{synopt :{opt fillgaps}}Loads country-level estimates (including extrapolations and interpolations) used to create regional and global aggregates.{p_end}
{synoptline}


{marker description}{...}
{title:Description}:

{pstd}
the {cmd:cl} (the default) and {cmd:wb} subcommands are the main modules of {cmd:pip}.
{cmd:cl} provides the country-level poverty and inequality estimates, whereas 
{cmd:wb} provides regional and global level poverty estimates. As of now, the
underlying welfare aggregate is the per capita household income or consumption
expressed in 2017 PPP USD (with option {cmd:ppp_year(2011)} you can select
estimates in 2011 PPPs values). Poverty lines, means, and medians are expressed in
daily amounts. 

{phang}
{res:{ul:Country-level estimates:} }The PIP API reports two types of results:

{pmore}
{opt 1.Survey-year}: Refers to poverty and inequality estimates for the year 
in which the survey was conducted (i.e., survey period). This is the default 
behavior of {cmd:pip cl}. Details of the poverty and inequality estimates 
methodology can be found 
{browse "https://datanalytics.worldbank.org/PIP-Methodology/surveyestimates.html": here}.

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
{browse "https://datanalytics.worldbank.org/PIP-Methodology/lineupestimates.html": here}.

{pin}
{res:Note 1}: The option {it:fillgaps} reports the underlying country estimates for a lineup-year.
These may coincide with the survey-year estimates if the country has a survey in the
lineup year. In other cases,  these would be extrapolated from the nearest survey or
interpolated between two surveys. 

{pin}
{res:Note 2}: Poverty measures that are calculated for both survey-years and
lineup-years  include the headcount ratio, poverty gap, and squared poverty gap.
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
{ul:{it:The following options only apply to cl}}

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



{marker examples}{...}
{title:Examples}

{err:TO BE COMPLETED}




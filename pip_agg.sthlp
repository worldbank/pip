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
Starting from 2025-09-30, the regional aggregates in the PIP API match the official
aggregates published by the World Bank in the WDI. You can still access previous
aggregations using the {cmd:agg} subcommand. Currently, only the new official
aggregates or the previous ones are available, but more aggregation options may be
added in the future.

{pstd}
By default, running {cmd:pip agg} without options will display the available
aggregates and stop with an error message. To obtain the official World Bank
aggregates, use the {cmd:aggregate(official)} option—this is equivalent to running
{cmd:pip wb}. To access the World Bank aggregates used before 2025-09-30, use
{cmd:aggregate(pcn)} or {cmd:aggregate(vintage)}; these return results with
{result:current data}. If you want the previous aggregation with historical data,
specify the {opt version()} option.



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
Load official aggregates (equivalent to {cmd:pip wb})

{phang2}
{stata pip agg, aggregate(official) clear}

{phang}
Load previous aggregates. ({it:vintage} or {it:pcn} directive. Same results)

{phang2}
{stata pip agg, aggregate(pcn) clear} {it:// for povcalnet}

{phang2}
{stata pip agg, aggregate(vintage) clear} 

{p 40 20 2}(Go back to {it:{help pip##sections:pip's main menu}}){p_end}




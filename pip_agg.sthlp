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




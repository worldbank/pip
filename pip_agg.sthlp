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
{cmd:pip agg}, [{cmd:,} {it:{help pip_agg##agg_options:agg options}}]


{marker opts_desc}{...}
{title:Options}

{pstd}

{marker agg_options}{...}
{synoptset 27 tabbed}{...}
{synopthdr:agg options}
{synoptline}
{synopt :{opt agg:regate}(string)}Which aggregate to retrieve. Several names are accepted as synonyms (see details below).{p_end}
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
This command retrieves regional and global poverty aggregates from the PIP API.
Starting from 2025-09-30, the PIP API regional aggregates match the official
aggregates published by the World Bank in the WDI. The {cmd:agg} subcommand lets
you request either the current official aggregates or previous/vintage
aggregations.

{pstd}
Running {cmd:pip agg} without any options will list the available aggregate names
and stop with an explanatory message. Use the {opt agg( )} option to select an
aggregate. The most commonly-used choices are described below and have several
accepted synonyms.

{pstd}
Key synonyms and behavior:

{phang}
- {it:official}, {it:wb}, {it:region}: These names are equivalent and
	request the official World Bank aggregates (equivalent to {cmd:pip wb}).

{phang}
- {it:pcn}, {it:vintage}, {it:regionpcn}: These names are equivalent and
	request the previous (PovcalNet / vintage) aggregation.

{pstd}
Other aggregate names: Additional aggregate names may be available depending on
the selected {it:pip_version}. These names represent pre-defined grouping
variables (for example, income groups, fragile countries, ida, among others that are stored in the
internal table `country_list` and exposed when you run {cmd:pip agg} with no
arguments. To see the full list of available aggregates for your active
{it:pip_version}, load the auxiliary frames via {cmd:pip tables} (automatically
run by {cmd:pip agg}) and inspect the `country_list` frame.

{pstd}
If you want the previous aggregation with historical data, specify the
{opt version()} option together with an appropriate aggregate name.


{marker opt_details}{...}
{title:Options Details}

{phang}
{opt agg:regate(string)}Select which pre-defined aggregate to retrieve. Accepted
values include synonyms and version-specific names:

{pmore} 
- {it:official}, {it:wb}, {it:region}: synonyms that request the official World
	Bank aggregates (WDI-style).

 {pmore}
- {it:pcn}, {it:vintage}, {it:regionpcn}: synonyms that request the previous
	PovcalNet / vintage aggregation.

{phang}
Other aggregate identifiers may appear in the list printed by {cmd:pip agg} and
correspond to grouping variables available for the active {it:pip_version}. Use
the `country_list` frame (loaded by {cmd:pip tables}) to inspect what these
version-specific values mean.

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




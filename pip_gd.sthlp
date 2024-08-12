{smcl}
{* *! version 1.0.0 dec 2022}{...}
{vieweralsosee "" "--"}{...}
{cmd:help pip gd}{right:{browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}}
{help pip:(return to pip)} {right:{browse "https://worldbank.github.io/pip/"}}
{hline}

{title:Syntax}

{phang}
{cmd:pip gd,} {opt cum_welfare(numlist)} {opt cum_population(numlist)} [ {it:{help pip_subcmd##opts_desc:options}} ]

{marker opts_desc}{...}
{title:Options}

{synoptset 27 tabbed}{...}
{synopthdr:gd options}
{synoptline}
{synopt :{opt stats}} Requests grouped data statistics (the default option of {cmd:pip_gd}.{p_end}
{synopt :{opt params}} Requests regression parameters corresponding to grouped data.{p_end}
{synopt :{opt lorenz}} Requests Lorenz curve data points.{p_end}
{synopt :{opt cum_welfare(numlist)}} List indicating the cuulative welfare shares in particular groups of the population.{p_end}
{synopt :{opt cum_population(numlist)}} List indicating the cumulative population contained in the same groups for which {opt cum_welfare()} is indicated.{p_end}
{synopt :{opt requested_mean(#)}} Scalar value indicating the mean welfare in the population.{p_end}
{synopt :{opt povl:ine:}(numlist)} List of poverty lines in specified PPP (see option {help pip##general_options:ppp_year(#)}) to calculate
poverty. Default is 2.15 at 2017 PPPs.{p_end}
{synoptline}


{marker description}{...}
{title:Description}
{pstd}
The {cmd:gd} subcommand provides poverty and inequality indices when provided with grouped
data.  Grouped data consist of some measure of cumulative welfare such as consumption expenditure
or income, along with population shares by groups such as deciles or percentiles.  Provided
that information is available about some measure of central tendency such as the mean, and a
distributional assumption such as the Lorenz curve is adopted, poverty and inequality measures
can be estimated from grouped data.  The {cmd: pip_gd} subcommand provides these aggregate
statistics based on grouped statistics.

{pstd}
Cumulative welfare and cumulative population should be provided to {cmd:pip_gd} indicating
the cumulative welfare shares and cumulative population contained in specific aggregates, such
as deciles or percentiles (as available). Any number of groups is allowed.  These should start
from the lowest income group and proceed to the highest group, and should all be expressed as
proportions, ie be contained in the interval 0-1.  Poverty lines, means, and medians are
expressed in {cmd:daily amounts}.


{marker opt_details}{...}
{title:Options Details}

{phang}
{opt stats} Indicates that group statistics are desired based on the provided inputs. By
default, it is assumed that group statistics are desired, and so if neither {opt stats},
{opt params} or {opt lorenz} is indicated, {cmd:gd} defaults to the stats option.

{phang}
{opt params} Indicates that regression parameters are desired based on the provided inputs.
One of {opt stats} (group statistics) {opt params} (regression parameters) or {opt lorenz}
(Lorenz curve data points) is required, and if none of these are required, {opt stats} is
assumed as default.  More than one of these options cannot be indicated.

{phang}
{opt lorenz} Indicates that Lorenz curve data points are desired based on the provided inputs.
One of {opt stats} (group statistics) {opt params} (regression parameters) or {opt lorenz}
(Lorenz curve data points) is required, and if none of these are required, {opt stats} is
assumed as default.  More than one of these options cannot be indicated.

{phang}
{opt cum_welfare(numlist)} A list containing the cumulative welfare shares of different groups
of the population.  For example, if the cumulative welfare of deciles are known, the total welfare
of decile 1 should be listed first, then the total cumulative welfare of the population up to
decile 2, and so forth.  Values should be presented as a list, and so separated by white space.

{phang}
{opt cum_population(numlist)} A list containing the cumulative population contained in the groups
indicated by the cumulative welfare measures above.  For example, if the values in {opt: cum_welfare}
are deciles of the population, this list should simply indicate 0.1(0.1)1.  Generically, population
shares corresponding to cumulative welfare should be provided, and the number of elements in the
population share should be identical to that in {opt: cum_welfare}. Values should be presented as a
{help:numlist}, and so separated by white space (or follow alternative valid list formats).

{phang}
{opt requested_mean(#)} Should indicate the average daily welfare in the population to be 
considered.  When combined with cumulative welfare and population, as well as a particular
parametrization of the Lorenz curve, poverty and inequality measures are generated.

{phang}
{opt povline(numlist)} The poverty lines for which the poverty measures will be calculated.
When selecting multiple poverty lines, use less than 4 decimals and separate each value
with spaces. If left empty, the default poverty line of $2.15 is used. By default,
poverty lines are expressed in 2017 PPP USD per capita per day. If option
{opt ppp_year(2011)} is specified, the poverty lines will be expressed in 2011 PPPs.


{marker examples}{...}
{title:Examples}

{ul:Basic examples}

{pstd}
Request poverty and inequality statistics for a particular welfare and population distribution (deciles provided in syntax), with a mean welfare of 2.911786.

{phang2}
{stata pip_gd, cum_welfare(.0002 .0006 .0011 .0021 .0031 .0048 .0066 .0095 .0128 .0177 .0229 .0355 .0513 .0689 .0882) cum_population(.001 .003 .005 .009 .013 .019 .025 .034 .044 .0581 .0721 .1041 .1411 .1792 .2182) requested_mean(2.911786)} 

{ul:Read in a data file containing cumulative welfare and population in columns, and pass this information to {cmd:pip_gd}}

{pstd}
This example considers a csv containing two columns of data: welfare, and population...

{phang2}
{cmd}
        UNDER CONSTRUCTION

{txt}      ({stata "pip_examples pip_example12":click to run})


{p 40 20 2}(Go back to {it:{help pip##sections:pip's main menu}}){p_end}



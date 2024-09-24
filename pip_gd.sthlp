{smcl}
{* *! version 1.0.0 dec 2022}{...}
{vieweralsosee "" "--"}{...}
{cmd:help pip gd}{right:{browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}}
{help pip:(return to pip)} {right:{browse "https://worldbank.github.io/pip/"}}
{hline}

{title:Syntax}

{phang}
{cmd:pip gd,} {opt cum_welfare(numlist|varname)} {opt cum_population(numlist|varname)} [ {it:{help pip_gd##opts_desc:options}} ]
        
{marker opts_desc}{...}
{title:Options}

{synoptset 32 tabbed}{...}
{synopthdr:gd options}
{synoptline}
{synopt :{opt stats}} Requests grouped data statistics (the default option for {cmd:pip_gd}).{p_end}
{synopt :{opt params}} Requests regression parameters corresponding to grouped data.{p_end}
{synopt :{opt lorenz}} Requests Lorenz curve data points corresponding to grouped data.{p_end}
{synopt :{opt cum_welfare(numlist|varname)}} List indicating the cumulative welfare shares in particular groups of the population.{p_end}
{synopt :{opt cum_population(numlist|varname)}} List indicating the cumulative population contained in the same groups for which {opt cum_welfare()} is indicated.{p_end}
{synopt :{opt requested_mean(#)}} Scalar value indicating the mean welfare in the population.{p_end}
{synopt :{opt n_bins(#)}} Scalar value indicating the number of bins requested when Lorenz curve estimates are requested.{p_end}
{synopt :{opt povl:ine:}(numlist)} List of poverty lines in specified PPP (see option {help pip##general_options:ppp_year(#)}) to calculate
poverty. Default is 2.15 at 2017 PPPs.{p_end}
{synopt :{opt clear}}Clear results.{res: NOTE: }This options has a special use. See details {help pip_gd##clear:below}{p_end}
{synoptline}


{marker description}{...}
{title:Description}
{pstd}
The {cmd:gd} subcommand provides information on poverty and inequality indices when provided with 
aggregate values from grouped data.  Grouped data consist of some measure of cumulative welfare 
such as consumption expenditure or income, along with population shares by groups such as deciles 
or percentiles.  Provided
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
{opt cum_welfare(numlist|varname)} A {help numlist} or the name of a variable containing the 
cumulative welfare shares of different groups
of the population.  For example, if the cumulative welfare of deciles are known, the total welfare
of decile 1 should be listed first, then the total cumulative welfare of the population up to
decile 2, and so forth.  If a {help numlist} is provided, values should be presented as a list, 
and so separated by white space (or follow alternative valid list formats).  Alternatively, if 
a variable in memory contains cumulative welfare values, the variable name should be listed, 
ensuring that the variable is ordered from lowest to highest.

{phang}
{opt cum_population(numlist|varname)}  A {help numlist} or the name of a variable containing the 
cumulative population contained in the groups
indicated by the cumulative welfare measures above.  For example, if the values in {opt: cum_welfare}
are deciles of the population, this list should simply indicate 0.1(0.1)1.  Generically, population
shares corresponding to cumulative welfare should be provided, and the number of elements in the
population share should be identical to that in {opt: cum_welfare}. 
If a {help numlist} is provided, values should be presented as a list, 
and so separated by white space (or follow alternative valid list formats).  Alternatively, if 
a variable in memory contains cumulative population values, the variable name should be listed, 
ensuring that the variable is ordered from lowest to highest, with observations corresponding to
the values for the variable indicated in {opt cum_welfare()}.

{phang}
{opt requested_mean(#)} Should indicate the average daily welfare in the population to be 
considered.  When combined with cumulative welfare and population, as well as a particular
parametrization of the Lorenz curve, poverty and inequality measures are generated.  if
{opt stats} is indicated, this is a required option.  This value must be strictly contained
between 0 and 1e10.

{phang}
{opt n_bins(#)} Indicates the number of bins requested of cumulative population and cumulative
welfare when Lorenz curve output is provided.  For example, if {opt n_bins(100)} is indicated,
population percentiles will be returned. If {opt lorenz} is indicated, this is a required
option.  A scalar value should be indicated, strictly between 0 and 1,000.

{phang}
{opt povline(numlist)} The poverty lines for which the poverty measures will be calculated.
When selecting multiple poverty lines, use less than 4 decimals and separate each value
with spaces. If left empty, the default poverty line of $2.15 is used. By default,
poverty lines are expressed in 2017 PPP USD per capita per day. If option
{opt ppp_year(2011)} is specified, the poverty lines will be expressed in 2011 PPPs.

{marker clear}{...}
{phang}
{opt clear} As usual, {it:clear} will clear the results of the current frame. 
If that is the case, {cmd:pip gd} will create frame {it:_pip_gd} with the results of
the calculations. If you want to comeback to the original data, you can use type 
{cmd:frame change {it::your_frame}}, where {it::your_frame} stands for the name of 
the frame where you had the original data.{p_end}

{pin}
 If {it:clear} is not indicated, the results will be stored in frame {it:_pip_gd}, 
 which you can access by typing {cmd:frame change _pip_gd}.  Moreover, the 
 resuls are stored in {cmd:ret list}. The results correspond to the name of the 
 variables in {it:_pip_gd} and to the observation number. So, for example, 
 {it:r(headcount_1)} correponds to the result of the {it:headcount} variables in
 observations 1. See examples {help pip_gd##ex_frame:below}.{p_end}

{marker examples}{...}
{title:Examples}

{ul:Provide vectors}

{pstd}
Request poverty and inequality statistics for a particular welfare and population distribution, with a mean welfare of 2.911786.

{phang2}
{stata pip gd, cum_welfare(.0002 .0006 .0011 .0021 .0031 .0048 .0066 .0095 .0128 .0177 .0229 .0355 .0513 .0689 .0882) cum_population(.001 .003 .005 .009 .013 .019 .025 .034 .044 .0581 .0721 .1041 .1411 .1792 .2182) requested_mean(2.911786)} 

{pstd}
Request the fitted Lorenz curve based on the cumulative population and welfare shares above, with 50 points and graph resulting Lorenz curve.

{phang2}
{stata pip gd, lorenz cum_welfare(.0002 .0006 .0011 .0021 .0031 .0048 .0066 .0095 .0128 .0177 .0229 .0355 .0513 .0689 .0882) cum_population(.001 .003 .005 .009 .013 .019 .025 .034 .044 .0581 .0721 .1041 .1411 .1792 .2182) n_bins(50) n2disp(10)} 

{phang2}
{stata twoway line welfare weight} 

{pstd}
Request the regression parameters used to estimate the Lorenz curve based on the cumulative population and welfare shares above.

{phang2}
{stata pip gd, params cum_welfare(.0002 .0006 .0011 .0021 .0031 .0048 .0066 .0095 .0128 .0177 .0229 .0355 .0513 .0689 .0882) cum_population(.001 .003 .005 .009 .013 .019 .025 .034 .044 .0581 .0721 .1041 .1411 .1792 .2182)} 

{marker ex_frame}{...}
{ul:Using current frame}

{pstd}
Request poverty and inequality statistics to replicate the results of Datt (1998) using the provided data ({res:replace current frame with results}).

    {cmd}
        local pip_temp = c(frame)
        sysuse pip_datt, clear {res:// Load provided Datt data}
        pip gd, cum_welfare(L) cum_population(P)  ///
            requested_mean(109.9) povline(89) {err:clear} {res:// Use options {it:clear} to replace current frame}
        frame change `pip_temp' {res:// if you want too return to original data}
        list
        {txt}      ({stata "pip_examples pip_example12":click to run})

{pstd}
Request poverty and inequality statistics to replicate the results of Datt (1998) using the provided data ({res:Store results in frame and {bf: ret list}}).

    {cmd}
        sysuse pip_datt, clear {res://Load provided Datt data}
        pip gd, cum_welfare(L) cum_population(P)  ///
            requested_mean(109.9) povline(89) {res:// NO option {it:clear}.}
        list  {res:// disp original data}
        ret list {res:// results from calculations}
        frame change _pip_gd {res:// change to _pip_gd frame to see results}
        list {res:// calculations frame}
        {txt}      ({stata "pip_examples pip_example13":click to run})


{p 40 20 2}(Go back to {it:{help pip##sections:pip's main menu}}){p_end}



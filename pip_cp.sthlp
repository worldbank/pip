{smcl}
{* *! version 1.0.0 dec 2022}{...}
{vieweralsosee "" "--"}{...}
{cmd:help pip cp}{right:{browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}}
{help pip:return to pip} {right:{browse "https://worldbank.github.io/pip/"}}
{hline}

{title:Syntax}

{phang}
{cmd:pip cp,} [ {it:{help pip_cp##opts_desc:options}} ]

{marker opts_desc}{...}
{title:Options}

{pstd}

{marker cl_wb_options}{...}
{synoptset 27 tabbed}{...}
{synopthdr:cp options}
{synoptline}
{synopt :{opt cou:ntry:}(3-letter code)}List of {it:{help pip_countries##countries:country codes}} or {it:all}. Default is "{it:all}".{p_end}
{synopt :{opt povl:ine:}(#)}list of poverty lines (in PPP specified, see option {cmd:ppp_year(#)}) to calculate 
 poverty measures. Default is 2.15 at 2017 PPPs.{p_end}
 {pstd}

{marker description}{...}
{title:Description}:

{pstd}
{cmd:cp} subcommand provides country profile data, the underlying estimates are computed in 2017 PPP 
(with option ppp_year(2011) you can select estimates in 2011 PPPs values).

{marker opt_details}{...}
{title:Options Details}

{phang}
{opt country(string)} {help pip_countries##countries:Countries and Economies Abbreviations}.
If specified with {opt year(#)}, this option will return all the countries for which there is
actual survey data in the year specified.  When selecting multiple countries, use the corresponding
three-letter codes separated by spaces. The option {it:all} is a shorthand for calling all countries.

{phang}
{opt povline(#)} The poverty lines for which the poverty measures will be calculated.
When selecting multiple poverty lines, use less than 4 decimals and separate
each value with spaces. If left empty, the default poverty line of $2.15 is used.
By default, poverty lines are expressed in 2017 PPP USD per capita per day.
If option {opt ppp_ppp(2011)} is specified, the poverty lines are expressed in 2011 PPPs. {p_end}
{synoptline}
{synopt :{helpb pip##general_options: general options}}Options that apply to any subcommand{p_end}

{marker examples}{...}
{title:Examples}

{ul:examples section}

{pstd}
Country profile data for all countries can be generated with the following example:

{phang2}
{stata pip cp, clear} 

{pstd}
Here is an example that shows how to generate country profile data for one country for three povery lines:

{phang2}
{stata pip cp, country(arg) povline(1.90 2.15 3.65) clear}




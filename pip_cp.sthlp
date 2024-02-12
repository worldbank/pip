{smcl}
{* *! version 1.0.0 dec 2022}{...}
{vieweralsosee "" "--"}{...}
{cmd:help pip cp}{right:{browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}}
{help pip:(return to pip)} {right:{browse "https://worldbank.github.io/pip/"}}
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
{synopt :{opt povl:ine:}(#)}List of poverty lines (in specified PPP, see option {cmd:ppp_year(#)}) to calculate 
 poverty measures. Default is 2.15 at 2017 PPPs.{p_end}
 {pstd}

{marker description}{...}
{title:Description}:

{pstd}
{cmd:cp} subcommand provides country profile data, also available in {browse "https://pip.worldbank.org/country-profiles":PIP's Country Profile page}.
This dataset comes from the Global Monitoring Indicators (GMI). The Global Monitoring Indicators (GMI) 
are a set of harmonized indicators produced from the Global Monitoring Database (GMD), which is the 
World Bank’s repository of multitopic income and expenditure household surveys used to monitor global 
poverty and shared prosperity. Selected variables have been harmonized so that levels and trends in 
poverty and other key sociodemographic attributes can be compared across and within countries over time. 
This includes indicators such as Multidimensional Poverty Measures, the Shared Prosperity index, and 
poverty and inequality indicators at the national and subnational level. The data comes from household 
surveys collected by the national statistical office in each country. It is then compiled, processed, 
and harmonized. The process is coordinated by the Data for Goals (D4G) team and supported by the six 
regional statistics teams in the Poverty and Equity Global Practice. The Global Poverty & Inequality 
Data Team (GPID) in the Development Economics Data Group (DECDG) also contributes with historical data prior to 
1990, as well as with recent survey data from the Luxemburg Income Study (LIS). 


{marker opt_details}{...}
{title:Options Details}

{phang}
{opt country(string)} 3-letter country codes (see {help pip_countries##countries:Countries and Economies Abbreviations}).
If specified with {opt year(#)}, this option will return all the countries for which there is
actual survey data in the year specified. When selecting multiple countries, use the corresponding
three-letter codes separated by spaces. The option {it:all} is a shorthand for calling all countries.

{phang}
{opt povline(#)} The poverty lines for which the poverty measures will be calculated.
When selecting multiple poverty lines, use less than 4 decimals and separate
each value with spaces. If left empty, the default poverty line of $2.15 is used.
By default, poverty lines are expressed in 2017 PPP USD per capita per day.
If option {opt ppp_ppp(2011)} is specified, the poverty lines will be expressed in 2011 PPPs. {p_end}
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


{p 40 20 2}(Go back to {it:{help pip##sections:pip's main menu}}){p_end}

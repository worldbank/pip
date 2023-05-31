{smcl}
{* *! version 1.0.0 dec 2022}{...}
{vieweralsosee "" "--"}{...}
{cmd:help pip intro}{right:{browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}}
{right:{browse "https://worldbank.github.io/pip/"}}
{hline}


{marker desc}{...}
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
{it:{ul:modular structure:}} The {cmd:pip} command works in a modular 
(subcommand, hereafter) fashion. There is no instruction to {cmd:pip} that is 
executed outside a particular subcommand. When no subcommand is invoked, as in 
{cmd:pip, clear}, the subcommand {cmd:cl} (coutry-level estimates) is in use. 
Thus, understanding {cmd:pip} fully is equivalent to understand each subcommand 
and its options fully. 

{pstd}
{it:{ul:welfare aggregate:}} To make estimates 
comparable across countries, the welfare aggregate is expressed in PPP values
of the most recent {browse "https://www.worldbank.org/en/programs/icp":ICP } 
round that has been approved for global poverty estimates
by the directives of the World Bank.  The detailed methodology of the welfare
aggregate conversion can be found in the 
{browse "https://datanalytics.worldbank.org/PIP-Methodology/convert.html": Poverty and Inequality Platform Methodology Handbook}.
 
{pstd}
PIP is the result of a close collaboration between World Bank staff across the Development Data Group, the Development Research Group, and the Poverty and Inequality Global Practice. 


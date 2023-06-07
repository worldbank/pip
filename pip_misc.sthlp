{smcl}
{* *! version 1.0.0 dec 2022}{...}
{vieweralsosee "" "--"}{...}
{cmd:help pip misc}{right:{browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}}
{help pip:return to pip} {right:{browse "https://worldbank.github.io/pip/"}}
{hline}

{res:Miscellaneous subcommands}

{title:Syntax}

{phang}
{cmd:pip info}


{phang}
{cmd:pip drop,} [options]


{phang}
{cmd:pip test}


{phang}
{cmd:pip cleanup}

{err: add others}

{marker description}{...}
{title:Description}

{phang}
{opt information} Presents a clickable version of the available surveys, countries 
and regions. Selecting countries from the menu loads the survey-year estimates.
Choosing regions loads the regional aggregates in the reference years. 

{p 8 8 2}{err:Note}: If option {it:clear} is added, data in memory is replaced 
with a pip guidance database. If option {it:clear} is {ul:not} included,
{cmd:pip} preserves data in memory  but displays a clickable interface of survey
availability in the results window.{p_end} 

{phang}
{opt cleanup} Deletes all PIP data from Stata's memory. 

{phang}
{opt test} By typing {stata pip test}, {cmd:pip} makes use of the global
"${pip_query}" to query your browser directly and test whether the data is
downloadable. 




{marker opt_details}{...}
{title:Options Details}

{phang}
{opt option(string)} Long description

{phang}
{opt option(string)} Long description



{marker examples}{...}
{title:Examples}

{ul:examples section}

{phang}
Explanation: clickable example

{phang2}
{stata pip, clear} 

{phang}
Explanation: non-clickable example

{phang2}
{cmd: pip, info}





{smcl}
{* *! version 1.0.0 dec 2022}{...}
{vieweralsosee "" "--"}{...}
{cmd:help pip tables}{right:{browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}}
{right:{browse "https://worldbank.github.io/pip/"}}
{hline}

{title:Syntax}


{phang}
{cmd:pip print, } [{it:{help pip_print##opts_desc:options}}]


{marker opts_desc}{...}
{title:Options}

{synoptset 27 tabbed}{...}
{synopthdr:print options}
{synoptline}
{synopt :{opt timer}}displays timer report of last execution of {cmd:pip}{p_end}
{synopt :{opt versions}}displays versions of data available{p_end}
{synopt :{opt tables}}Equivalent to {cmd:pip tables}. Displays auxiliary tables
available.{p_end}
{synopt :{opt available}}Equivalent to {cmd:pip info}. Display data availability. 
You can also use {cmd:pip print, {it:info}} or 
{cmd:pip print, {it:availability}}{p_end}
{synopt :{opt cache}}Equivalent to {cmd:pip cache, info}. 
Displays interactive information of cache local memory.{p_end}
{synoptline}


{marker description}{...}
{title:Description}
{phang}
Description starts here



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





{smcl}
{* *! version 1.0.0 dec 2022}{...}
{vieweralsosee "" "--"}{...}
{cmd:help pip print}{right:{browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}}
{help pip:(return to pip)} {right:{browse "https://worldbank.github.io/pip/"}}
{hline}

{title:Syntax}

{phang}
{cmd:pip print, } [{it:{help pip_print##opts_desc:options}}]

{marker opts_desc}{...}
{title:Options}

{synoptset 27 tabbed}{...}
{synopthdr:print options}
{synoptline}
{synopt :{opt timer}}Displays timer report of last execution of {cmd:pip}.{p_end}
{synopt :{opt versions}}Displays versions of data available.{p_end}
{synopt :{opt tables}}Equivalent to {cmd:pip tables}. Displays auxiliary tables
available.{p_end}
{synopt :{opt available}}Equivalent to {cmd:pip info}. Displays data availability. 
You can also use {cmd:pip print, {it:info}} or 
{cmd:pip print, {it:availability}}.{p_end}
{synopt :{opt cache}}Equivalent to {cmd:pip cache, info}. Displays interactive information of cache local memory.{p_end}
{synopt :{opt setup}}Displays contents of pip_setup.do{p_end}
{synoptline}
{synopt :{helpb pip##general_options: general options}}Options that apply to any subcommand{p_end}

{marker description}{...}
{title:Description}

{pstd}
The subcommand {cmd:print} is a convenient tool to display information about the
{cmd:pip} command and its environment. Most of the instructions available with 
{cmd:pip print} are available in other subcommands as well, but the {cmd:print} 
subcommand just makes it easier to find and remember. 


{marker opt_details}{...}
{title:Options Details}

{phang}
{opt timer} Each time {cmd:pip} is executed it records the time lapsed in each of its
subroutines. This function is intended for developers to make {cmd:pip} code more
efficient. However, it can also be used to measure Internet speed to download PIP data.


{marker examples}{...}
{title:Examples}

{phang}
{stata pip print, versions} 

{phang}
{stata pip print, tables} 

{phang}
{stata pip print, available} 

{phang}
{stata pip print, cache} 

{phang}
{stata pip print, setup} 

{phang}
{stata pip print, timer} 




{p 40 20 2}(Go back to {it:{help pip##sections:pip's main menu}}){p_end}


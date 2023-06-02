{smcl}
{* *! version 1.0.0 dec 2022}{...}
{vieweralsosee "" "--"}{...}
{cmd:help pip tables}{right:{browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}}
{help pip:return to pip} {right:{browse "https://worldbank.github.io/pip/"}}
{hline}

{title:Syntax}

{phang}
{cmd:pip tables} [{it:tables(string)}]

{marker opts_desc}{...}
{title:Options}

{synoptset 27 tabbed}{...}
{synopthdr:tables options}
{synoptline}
{synopt :{opt table(table_name)}}Loads one auxiliary by name.{p_end}
{synoptline}
{synopt :{helpb pip##general_options: general options}}Options that apply to any subcommand{p_end}

{marker description}{...}
{title:Description}

{pstd}
Even Though household surveys are the main data that underpins poverty and inequality estimates at
the country, regional and global levels, there are several other types of data that underlie the calculations. You can access all these data with the {cmd:tables} subcommand. 

{pstd}
This subcommand has two main uses. You can either display a clickable list of all the tables available by typing 

{phang2}
{cmd: pip tables} 

{pstd}
Or you can load a specific table by using the  options {it:table()} as in 

{phang2}
{cmd:pip tables, table({it:table_name})}

{marker opt_details}{...}
{title:Options Details}

{phang}
{opt table(table_name)} Provide name of the table you want to load. If the name you 
provide does not exist, {cmd:pip} returns error. 


{marker examples}{...}
{title:Examples}

{ul:examples section}

{phang}
Display clickable list of auxiliary tables

{phang2}
{stata pip tables} 

{phang}
Load CPI data

{phang2}
{stata pip tables, table(cpi)} 

{phang}
Load GDP data

{phang2}
{stata pip tables, table(gdp)} 





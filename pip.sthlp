{smcl}
{* *! version 1.0.0 dec 2022}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Command description"   "pip##desc"}{...}
{viewerjumpto "Parameters description"   "pip##param"}{...}
{viewerjumpto "Options description"   "pip##options"}{...}
{viewerjumpto "Subcommands"   "pip##subcommands"}{...}
{viewerjumpto "Stored results"   "pip##return"}{...}
{viewerjumpto "Examples"   "pip##Examples"}{...}
{viewerjumpto "Disclaimer"   "pip##disclaimer"}{...}
{viewerjumpto "How to cite"   "pip##howtocite"}{...}
{viewerjumpto "References"   "pip##references"}{...}
{viewerjumpto "Acknowledgments"   "pip##acknowled"}{...}
{viewerjumpto "Authors"   "pip##authors"}{...}
{viewerjumpto "Regions" "pip_countries##regions"}{...}
{viewerjumpto "Countries" "pip_countries##countries"}{...}
{cmd:help pip}{right:{browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}}
{right:{browse "https://worldbank.github.io/pip/"}}
{hline}

{phang}
{res:If you're new to {cmd:pip}, please start by reading {help pip_intro:pip intro}}. 

{title:Syntax}

{p 8 16 2}
{cmd:pip} [{it:{help pip##sbc_table:subcommand}}]{cmd:,} 
[{it:subcommand options}]


{marker sbc_table}{...}
{synoptset 27 tabbed}{...}
{synopthdr:Subcommand}
{synoptline}
{p 4 4 2}Main subcommands{p_end}
{synopt :{helpb pip_cl:cl}}Country-level poverty and inequality estimates. {help pip_cl##options:options}{p_end}
{synopt :{helpb pip_cl:wb}}World Bank's regional and global aggregation. {help pip_cl##options:options}{p_end}
{synopt :{helpb pip_cp:cp}}Country Profile estimates. {help pip_cl##options:options}{p_end}
{synopt :{helpb pip_tables:tables}}Clickable list of auxiliary tables. {help pip_tables##options:options}{p_end}
{synopt :{helpb pip_cache:cache}}Manage local cache. {help pip_cache##options:options}{p_end}
{synopt :{helpb pip_print:print}}Print useful information. {help pip_print##options:options}{p_end}
{synopt :{helpb pip_install:[un]install}}Installs the stable version of pip from SSC 
({cmd:pip install ssc}) or the development version from GitHub ({cmd:pip install gh}).{p_end}
{synopt :{helpb pip_setup:setup}}Utility function to set {cmd:pip} options and 
features.{p_end}

{p 4 4 2}Auxiliary subcommands{p_end}
{synopt :{helpb pip_misc:info}}Displays countries and regions availability.{p_end}
{synopt :{helpb pip_misc:cleanup}}Deletes all pip data from current stata memory.{p_end}
{synopt :{helpb pip_misc:test}}Displays metadata from the last query and provides actions to see output in 
browser (api) or download as .csv.{p_end}
{synopt :{helpb pip_misc:drop}}({it:Programmer's option}) Deletes objects from memory.{p_end}
{synoptline}
{pstd}
{bf:Note}: {cmd:pip} requires an internet connection.


{marker desc}{...}
{title:Description}

{pstd}
The {cmd:pip} command has the same functionality as the {browse "https://pip.worldbank.org/":PIP website}. 
It allows Stata users to compute poverty and inequality indicators for over 160 countries 
in the World Bank's database of household surveys. PIP is a computational tool that allows 
users to conduct country-specific, cross-country, as well as global and regional poverty analyses.

{pstd}
{res:If you're new to {cmd:pip}, please start by reading {help pip_intro:pip intro}}. 
To better understand the details and functionalities of each subcommand, please click on the corresponding subcommand in the table {help pip##sbc_table:above}.


{marker remarks}{...}
{title:Remarks}

{pstd}
The rest of this document contains general information about PIP and the {cmd:pip} Stata command. Sections are presented under the following headings:

		{it:{help pip##general_options:General Options}}
		{it:{help pip##examples:Examples}}
		{it:{help pip##memory:Memory use and Stata frames}}
		{it:{help pip##return:Stored Results}}
		{it:{help pip##povcal:List of pip and povcalnet variables}}
		{it:{help pip##general_troubleshooting:General Troubleshooting}}


{marker general_options}{...}
{title:General Options}

{pstd}
The options below work for any subcommad that returns vintaged data 
(e.g., {cmd:cl}, {cmd:wb}, {cmd:tables})

{marker general_options}{...}
{synoptset 27 tabbed}{...}
{synopthdr:General Options}
{synoptline}
{synopt :{opt ver:sion(string)}}Combination of numbers in the format %Y%m%d_YYYY_RV_AV_SSS
(click {bf:{help pip_note:here}} for an explanation of each component). 
Option {it:version()} takes prevalence over the next 3 options 
{it:ppp_year()}, {it:release()} & {it:identity()}, as the combination of 
these three parameters uniquely identifies a dataset.{p_end}
{synopt :{opt ppp:_year:}(#)}PPP round (2011 or 2017). {p_end}
{synopt :{opt rel:ease(numlist)}}8 digit number with the PIP release date in the format {it:YYYYMMDD}.{p_end}
{synopt :{opt ide:ntity(string)}{err:*}}Version of data to run the query on (e.g., prod, int, test). See description of each identity {bf:{help pip_note:here}}.{p_end}
{synopt :{opt ser:ver(string)}{err:*}}Name of server to query (e.g, prod, dev, qa). See description of each server {bf:{help pip_note:here}}.{p_end}
{synopt :{opt clear}}Replaces data in memory.{p_end}
{synopt :{opt n2d:isp}}Number of rows to display. (default 1).{p_end}
{synopt :{opt cachedir(path)}}Cache directory{p_end}

{pstd}
{err:*Note}: The {cmd:server()} and {cmd:identity()} options are available internally only for World Bank staff upon request to the  
{browse "mailto: pip@worldbank.org":PIP Technical Team}. For a detailed description of the {cmd:server()} and
{cmd:identity()} options see {bf:{help pip_note:here}}.{p_end}
{synoptline}


{marker examples}{...}
{title:Examples}

{pstd}
The examples below do not comprehend all {cmd:pip}'s features. Please refer 
to the {it:examples} section of {help pip##sbc_table:each subcommad}'s help file.

{ul:Basic examples}

{phang}
Load latest available survey-year estimates for Colombia and Argentina

{phang2}
{stata pip cl, country(col arg) year(last) clear} 

{phang}
Load clickable menu

{phang2}
{stata pip, info}

{phang}
Load only urban coverage level

{phang2}
{stata pip cl, country(all) coverage("urban") clear}


{ul:Differences between queries }

{phang}
Country estimation at $2.15 in 2015. Since there are no surveys in ARG in 
2015, results are loaded only for COL, BRA and IND.

{phang2}
{stata pip, country(COL BRA ARG IND) year(2015) clear}

{phang}
Lineup-year estimation. Filling gaps for ARG and moving the IND estimate
from 2015-2016 to 2015. Only works for reference years. 

{phang2}
{stata pip, country(COL BRA ARG IND) year(2015) clear  fillgaps}

{phang}
World Bank aggregation ({it:country()} is not available)

{phang2}
{stata pip wb, clear  year(2015)}{p_end}
{phang2}
{stata pip wb, clear  region(SAR LAC)}{p_end}
{phang2}
{stata pip wb, clear}       // all regions and reference years{p_end}


{marker memory}{...}
{title:Memory use and frames}:

{pstd}
It is important for users to know beforehand that {res: {cmd:pip} is a very invasive Stata command}. 
An explanation of all the ways in which {cmd:pip} interacts with the Stata session, 
operating system, and local storage is provided below. We apologize in advance for the way in which this command works; 
however, we truly believe it allows to take full advantage of {cmd:pip}'s efficiency. 

{ul:Stata frames}

{pstd}
{cmd:pip} makes use of {help frames:Stata frames}--available since Stata 16--to store a lot of information in memory. 
This is partly the reason why the first call of pip in a new Stata session is slower compared to subsequent calls.
When closing Stata, you may see a pop-up message reading {bf:"Frames in memory have changed"}. That is perfectly normal
and should not cause any concern. However, make sure you save the frames that you created and wish to keep.
You can do that by typing {stata frames dir}. Frames created by {cmd:pip} are prefixed by {it:_pip} and are
marked by an {it:*}, meaning they have not been saved. If you do not wish to save any frames in use, just click
"Exit without saving." You can also delete all PIP data in memory using the command {stata pip cleanup}.

{ul:Cache memory}

{pstd}
By default, {cmd:pip} will create cache data of all the queries you make. The first you 
use {cmd:pip} you will have the option to store cache data in your local machine
or in any drive Stata has access to. By default, {cmd:pip} will check whether it could
save cache data in your PERSONAL directory (see {help sysdir: search path}). In case it can't, it will try in PLUS, then
in your current directory and then in SITE. The first time you execute {cmd:pip}, you are
required to either confirm the default cache directory or provide your own directory
path. Also you can opt out and don't save cache data. Just follow the instructions of 
the pop-up messages. 

{ul:pip_setup.do}

{pstd}
The first time you execute {cmd:pip} in your session, it will search for the do-file 
pip_setup.do. In case it is not found, it will be created in your PERSONAL directory.
this do-file contains a set of global macros that store information relevant to the 
performance of pip and to make it compatible with future versions. You can see the 
contents of that file by typing {cmd:pip print, setup}. We highly recommend that you do
{err:NOT} modify this file. Yet, in the event that you end up modifying it and breaking {cmd:pip}, 
you can recreate the pip_setup.do by typing {cmd: pip setup, create}.

{ul:Mata libraries}

{pstd}
{cmd:pip} relies heavily in a set of MATA functions stored in a {help lmbuild:library} called "lpip_fun". 
This library is built in your computer each time the library has been updated in a newer version of {cmd:pip}.
All the Mata functions created by {cmd:pip} are named with the {bf:pip_*} prefix. Yet, none of the
functions are documented as they are intended for {cmd:pip} use only. 


{marker return}{...}
{title:Stored results}{p 50 20 2}{p_end}

{pstd}
{cmd:pip} is an {helpb return:rclass} command, which means that it stores the
results in {cmd:r()}. Each subcommand has its own set of returned results, 
and you can display them by typing {cmd:{ul:ret}urn list} after the execution
of {cmd:pip}. 


{marker povcal}{...}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}
{title:List of pip and povcalnet variables}{p 50 20 2}{p_end}

{pstd}
The first part of the following list compares the variables names available in {cmd:pip}
with its predecessor command {cmd:povcalnet}.
Additional pip variables are listed at the bottom.

		{hline 43}
		pip variable    {col 40}povcalnet variable
		{hline 20}{col 40}{hline 20}
		country_code     {col 40}countrycode
		country_name     {col 40}countryname
		region_code      {col 40}regioncode
		year             {col 40}year
		welfare_time     {col 40}datayear
		welfare_type     {col 40}datatype
		poverty_line     {col 40}povertyline
		mean             {col 40}mean
		headcount        {col 40}headcount
		poverty_gap      {col 40}povgap
		poverty_severity {col 40}povgapsqr
		watts            {col 40}watts 
		gini             {col 40}gini
		median           {col 40}median
		mld              {col 40}mld
		polarization     {col 40}polarization
		population       {col 40}population
		decile1          {col 40}decile1
		decile2          {col 40}decile2
		decile3          {col 40}decile3
		decile4          {col 40}decile4
		decile5          {col 40}decile5
		decile6          {col 40}decile6
		decile7          {col 40}decile7
		decile8          {col 40}decile8
		decile9          {col 40}decile9
		decile10         {col 40}decile10		
		ppp              {col 40}ppp
		is_interpolated  {col 40}isinterpolated
		distribution_type {col 40}usemicrodata
		survey_coverage  {col 40}coveragetype
		{hline 43}
		Other pip variables   {col 40}
		{hline 20}{col 40}
		region_name      {col 40}
		reporting_level  {col 40}
		cpi				 {col 40}
		gdp				 {col 40}
		hfce			 {col 40}
		survey_comparability {col 40}
		survey_acronym   {col 40}
		survey_time      {col 40}
		comparable_spell {col 40}
		spl				 {col 40}
		spr				 {col 40}
		{hline 43}


{marker general_troubleshooting}{...}
{title:General Troubleshooting}

{p 4 4 2} 
In case {cmd:pip} is not working correctly, try the following steps in the given order:
{p_end}

{pmore} 1. Uninstall {cmd:pip} by typing  {cmd: pip uninstall}
	
{pmore} 2. Execute {cmd:which pip}. If {cmd:pip} is still installed, delete all
the {cmd:pip} files from wherever they are in your computer until the command above returns error. The idea is to leave no trace of {cmd:pip} in your computer. 
 
{pmore} 3. Install {cmd:pip} again with the following code and check the version number. It should be the same as the most {browse "https://github.com/worldbank/pip/releases":recent release}

	{cmd}
		github install worldbank/pip
		discard
		which pip
	{txt}

{pmore} 4. Try to run it again and see if {cmd:pip} fails. 

{pmore} 5. If it is still failing, open a new issue in the {browse "https://github.com/worldbank/pip/issues":GitHub issues page}, making sure 
you're adding all the necessary steps to reproduce the problem. 

{pmore} 6. Once the issue is created, run the code below--making sure you replace the commented line--and send the test.log file, along with the issue
number created in the previous step, to {browse "mailto: pip@worldbank.org":pip@worldbank.org}. 

	{cmd}
		log using "test.log", name(pip_test) text replace {result:// this is in your cd}
		cret list
		clear all
		which pip
		set tracedepth 4
		set traceexpand on 
		set traceindent on 
		set tracenumber on
		set trace on
		{result} /* the pip command that is failing. e.g.,
		cap noi pip, region(EAP) year(last) clear */
		{cmd}set trace off
		log close pip_test
	{txt}


{marker disclaimer}{...}
{title:Disclaimer}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}

{p 4 4 2}To calculate global poverty estimates, survey-year estimates are extrapolated
or interpolated to a common reference year. These extrapolations and interpolations require
additional assumptions, namely that (a) growth in household income or consumption can be
approximated by growth in national accounts and (b) all parts of the distribution grow at
the same rate. Given these assumptions, users are cautioned against using reference-year
estimates (available using the fillgaps option) for comparing a country's poverty trend over time.
For that purpose, users should rely on the survey-year estimates and are advised to take into
account breaks in survey comparability. For details on the methodology please visit the
{browse "https://worldbank.github.io/PIP-Methodology/":PIP Methodology Handbook} and the {browse "https://pip.worldbank.org/publication":Global Poverty Monitoring Technical Notes}.
{p_end}

{p 4 4 2}The term country, used interchangeably with economy, does not imply political independence
but refers to any territory for which authorities report separate social or economic statistics.
{p_end}


{marker references}{...}
{title:References}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}

{p 4 8 2}Castaneda Aguilar, R.Andres, T. Fujs, C. Lakner, S. K. Tetteh-Baah(2023)
"Estimating Global Poverty in Stata: The PIP command", 
Global Poverty Monitoring Technical Notes, World Bank, Washington, DC.{p_end}

{marker acknowled}{...}
{title:Acknowledgments}
{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}

{pstd}
The author would like to thank Tefera Bekele Degefu, Ifeanyi Nzegwu Edochie, Tony Fujs, 
Dean Jolliffe, Daniel Mahler, Minh
Cong Nguyen, Christoph Lakner, Marta Schoch, Samuel Kofi Tetteh Baah, Martha Viveros, Nishan Yonzan,
and Haoyu Wu for comments received on earlier versions of this code. This command builds on the earlier
povcalnet command, which was developed with the help of Espen Prydz, Jorge Soler Lopez, Ruoxuan Wu and Qinghua Zhao. 

{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}
{marker authors}{...}
{title:Author}
{p 4 4 4}R.Andres Castaneda, The World Bank{p_end}
{p 6 6 4}Email: {browse "mailto: acastanedaa@worldbank.org":  acastanedaa@worldbank.org}{p_end}
{p 6 6 4}GitHub:{browse "https://github.com/randrescastaneda": randrescastaneda }{p_end}

{title:Contributor}
{pstd}
Tefera Bekele Degefu

{title:Maintainer}
{p 4 4 4}PIP Technical Team, The World Bank{p_end}
{p 6 6 4}Email: {browse "mailto: pip@worldbank.org":  pip@worldbank.org}{p_end}

{marker contact}{...}
{title:Contact}
{pstd}
Any comments, suggestions, or bugs can be reported in the 
{browse "https://github.com/worldbank/pip/issues":GitHub issues page}.
All the files are available in the {browse "https://github.com/worldbank/pip":GitHub repository}.

{marker howtocite}{...}
{title:Thanks for citing this Stata command as follows}

{p 4 8 2}Castaneda, R.Andres. (2023) 
"pip: Stata Module to Access World Bank’s Global Poverty and Inequality Data" 
				(version 0.9.0). Stata. Washington, DC: World Bank Group.
        https://worldbank.github.io/pip/ {p_end}

{title:Thanks for citing {cmd:pip} data as follows}

{p 4 8 2} World Bank. (2023). Poverty and Inequality Platform (version {version_ID}) 
[Data set]. World Bank Group. www.pip.worldbank.org. Accessed  {date}{p_end}

{p 4 8 2}Available version_IDs:{p_end}
{p 4 8 2}2017 PPPs: 20230919_2017_01_02_PROD{p_end}
{p 4 8 2}2011 PPPs: 20230919_2011_02_02_PROD{p_end}

{pstd}
Please make reference to the date when the database was downloaded, as statistics may change.

{p 40 20 2}(Go up to {it:{help pip##sections:Sections Menu}}){p_end}





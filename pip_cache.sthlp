{smcl}
{* *! version 1.0.0 dec 2022}{...}
{vieweralsosee "" "--"}{...}
{cmd:help pip cache}{right:{browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}}
{right:{browse "https://worldbank.github.io/pip/"}}
{hline}

{title:Syntax}

{phang}
{cmd:pip cache ,} [ {it:{help pip_cache##opts_desc:options}} ]

{marker opts_desc}{...}
{title:Options}

{synoptset 27 tabbed}{...}
{synopthdr:cache options}
{synoptline}
{synopt :{opt info}}Displays interactive information of cache local memory.{p_end}
{synopt :{opt delete}}Deletes cache local memory{p_end}
{synopt :{opt cachedir(path)}}displays or deletes cache in that particular 
directory. Seldom used. {p_end}
{synopt :{opt iscache}}Checks whether or not the data loaded has been cached{p_end}
{synoptline}


{marker description}{...}
{title:Description}
{pstd}
Caching is the process of storing data so that future requests for the same data
can be served faster. Even though the PIP API is cached at different levels, it is 
possible that either re-deployment/maintenance of the data in API o Internet
connectivity issues may affect the speed at which PIP data is served. This is why, 
{cmd:pip} provides you with the ability cache PIP data and with a set of tools to 
manage it. 

{pstd}
By default, {cmd:pip} provides the option to store cache data in your local machine
or in any drive Stata has access to. The first time you execute {cmd:pip}, you are
required to either confirm the default cache directory, provide your own directory
path, or opt out. Just follow the instructions of the pop-up messages. 

{pstd}
{cmd:pip} makes specific requests to the 
{browse "https://pip.worldbank.org/api": PIP API} in the for of URLs. 
This URL is hashed and used as the ID of cache. Since 
{cmd:pip} makes sure that the version of the data is part of the URL request,
the hash of the query is unique you only have to request the data once. The only 
case in which you have to hit the API again for the same request is when the API 
parameters for a specific endpoint have changed. Since this happens rarely, your 
cache data is useful for long time. 

{pstd}
In software development, caching is usually a {it:temporary} storing data practice 
because the speed you gain comes to the expense storage memory. You can either 
opt out altogether the caching mechanism of {cmd:pip} or you can manage your cache, 
making use of the tools provided by {cmd:pip}.

{err:TO BE COMPLETED}




{marker opt_details}{...}
{title:Options Details}

{phang}
{opt option(string)} Long description

{phang}
{opt option(string)} Long description

{err:TO BE COMPLETED}





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





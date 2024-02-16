{smcl}
{* *! version 1.0.0 dec 2022}{...}
{vieweralsosee "" "--"}{...}
{cmd:help pip cache}{right:{browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}}
{help pip:(return to pip)} {right:{browse "https://worldbank.github.io/pip/"}}
{hline}

{title:Syntax}

{phang}
{cmd:pip cache,} [ {it:{help pip_cache##opts_desc:options}} ]

{marker opts_desc}{...}
{title:Options}

{synoptset 27 tabbed}{...}
{synopthdr:cache options}
{synoptline}
{synopt :{opt metadata|inventory}}Loads cache metadata file.{p_end}
{synopt :{opt info}}Displays interactive information of cache local memory.{p_end}
{synopt :{opt delete}}Deletes cache local memory.{p_end}
{synopt :{opt setup}}Sets up cache directory. Pair this option with 
{opt cachedir(path)}. {p_end}
{synopt :{opt cachedir(path)}}Cache directory. It works in conjunction with other 
options to manage cache storage. This is also a {help pip##general_options:general option}.{p_end}
{synopt :{opt iscache}}Checks whether or not the data loaded has been cached.{p_end}
{synoptline}
{synopt :{helpb pip##general_options:general options}}Options that apply to any subcommand{p_end}

{marker description}{...}
{title:Description}

{pstd}
Caching is the process of storing data so that future requests for the same data
can be served faster. Even though the PIP API is cached at different levels, it is 
possible that either re-deployment/maintenance of the data in API o Internet
connectivity issues may affect the speed at which PIP data is served. This is why, 
{cmd:pip} offers the ability to cache PIP data and with a set of tools to manage it. 

{pstd}
By default, {cmd:pip} provides the option to store cache data in your local machine
or in any drive Stata has access to. The first time you execute {cmd:pip}, you are
required to either confirm the default cache directory, provide your own directory
path, or opt out. Just follow the instructions of the pop-up messages. 

{pstd}
{cmd:pip} makes specific requests to the 
{browse "https://pip.worldbank.org/api":PIP API} in the form of URLs. 
This URL is hashed and used as the cache's ID. Since 
{cmd:pip} makes sure that the data version is part of the URL request,
the hash of the query is unique and data only needs to be requested once. The only 
case in which it would be necessary to hit the API again for the same request is if the API 
parameters for a specific endpoint have changed. Since this rarely happens, your 
cache data is useful for a long time. 

{pstd}
In software development, caching is usually a {it:temporary} storing data practice 
because the speed gained comes at the expense of storage memory. Users can either 
opt out altogether the caching mechanism of {cmd:pip}, or manage the cache 
making use of the tools provided by {cmd:pip}.


{marker opt_details}{...}
{title:Options Details}

{phang}
{opt metadata|inventory} loads the cache metadata file. Each time  {cmd:pip} saves cache data, it
stores the cache file's metadata into a text file in the same directory of the
cached data. By typing {cmd:pip cache, inventory} or {cmd:pip cache, metadata} 
users can load the text file in readable .dta format. 

{phang}
{opt info} displays a set of interactive tables to manage cache storage. When typing
{cmd:pip cache, info}, {cmd:pip} will display the metadata cache file's content 
in the Stata console. You can click on the different options in order to filter the 
content until you reach one single cache file. Only the categories with the 
{it:(filterable)} label are suitable for filtering. Once you have singled out one cache
entry, you will be provided with information
about the original query and will also be able to execute some actions like loading the
cache file, see it in the browser, download the .csv original file or even delete it. 


{phang}
{opt delete} deletes cache memory. If option {opt cachedir(path)} is not provided, the 
cache will be deleted from the default cache directory. 

{phang}
{opt iscache} Once you have loaded any PIP data using {cmd:pip}, you can type 
{cmd:pip cache, iscache} to confirm whether or not the data loaded in memory has been
cached by {cmd:pip}. The first time you make a query and type {cmd:pip cache, iscache} you will see
that the data is not cached, because it was directly downloaded from
the PIP API. This does not mean that your data has not been cached. It means that 
the actual data in memory was loaded from the API and not from the cache directory. If
you execute the same query and type {cmd:pip cache, iscache}, you will see that it has 
been cached. If you pair this options with {cmd: pip {help pip_print:print}, timer}, 
you will see how fast pip cache is. 

{phang}
{opt setup} sets up cache directory. This option should be paired with {opt cachedir(path)}. Typing {cmd:pip cache, setup {opt cachedir(path)}} is equivalent to {cmd:pip setup, {opt cachedir(path)}}.

{p 40 20 2}(Go back to {it:{help pip##sections:pip's main menu}}){p_end}

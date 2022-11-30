{smcl}
{* *! version 1.0.0 20 sep 2019}{...}

{title:Description of the components in the option {cmd:version()}}

{phang}
{bf:Data Versioning} : One of the main features of PIP is to provide the user with the possibility to 
use any vintage (or version) of the PIP data. The vintage control has the following structure: {it: {bf: %Y%m%d_YYYY_RV_AV_SSS}},
 where each component (separated by "_") is described as follows: 

{p 8 8 2}{it:{bf: %Y%m%d}} : Same as option {it:release()}, refers to an 8-digit number (format YYYYMMDD) that conforms, 
in general, to the release date of PIP. However, it could refer to any date. Other dates are available only to
internal WB users; external users have access only to the publicly released versions.
What identifies a folder as an official release is the suffix SSS, which is explained below. 

{p 8 8 2}{it:{bf: YYYY}} : Refers to the PPP round (e.g. 2011, 2017 at present). 

{p 8 8 2}{it:{bf: RV}} : Refers to the {ul:release version of the PPP round}. The same round of PPPs may
be revised by the International Comparison Program (ICP) team.  

{p 8 8 2}{it:{bf: AV}} : Refers to the {ul:adaptation version of the release version of the PPP round}.
The PPPs that are published and revised by the ICP team are adapted by the PIP team.
This is only done after careful technical analysis and only affects a few countries. 

{p 8 8 2}{it:{bf:SSS}} : Refers to the {ul:identity} of the folder (PROD, INT, or TEST). See the description 
of each {cmd:identity()} folder in the section below. {cmd:NOTE}: external users can only use the identity PROD
in the {it:_SSS} suffix. INT and TEST are for internal WB users only.

{p 8 8 2}*An example of a specific version is the following: 20220909_2017_01_02_PROD. This version is a public release (PROD suffix).
It was released on 9 September 2022. It uses the first release of the 2017 PPPs (the 2017 PPPs have been published in May 2020
and have not been revised as of November 2022). It uses the second adaptation of the 2017 PPPs (identifying multiple
adaptations that were created internally in the preparation of the public release).  

{title:Description of the options {cmd:server()} and {cmd:identity()} {err:[For internal WB users ONLY]}}

{phang}
{opt server(string)} Three servers (PROD, QA, and DEV) are available in PIP. 
This option is only available internally for WB staff. The following are descriptions for each server:

{p 8 8 2}{bf:1) PROD (Production)}: This server contains the data published by the Bank externally 
in {browse "https://pip.worldbank.org/":pip.worldbank.org}. That is, outside the Bank’s intranet
and the only version available also to external users. Use the {cmd:server(prod)} option to access
pip data in the PROD server. 

{p 8 8 2}{bf:2) QA (Quality Assurance server)}: This server is available within the Bank's intranet to check 
new version of pip data before it is released externally. This option can be used in the 
pip stata command as {cmd:server(qa)}. 

{p 8 8 2}{bf:3) DEV (Development)}: This server is used for testing new PIP features and methodological improvements.
This option can be used in the pip stata command as {cmd:server(dev)}.

{phang}
{err: IMPORTANT!:} In order to access data from the QA and DEV servers you need to {cmd:contact}
{browse "pip@worldbank.org":pip@worldbank.org}.

{phang}
{opt identity(string)} Within the DEV server, there exist different versions of the data.
To specify the version of PIP data, include optional parameter {cmd:identity()}.
The command {cmd:identity()} has three possible values (prod, int, and test). When identity() is not specified, the default is prod.
Here are descriptions of each of these values:

{p 8 8 2}{bf: PROD}: Refers to production. This type of folder can be found in {ul:any of the three servers}
explained above (PROD, QA, and DEV). Within the PROD and QA server, this is the only available data version,
so this distinction only matters for the DEV server. Only the folders with the identity(prod) will be considered by the API as production
folders that may be deployed in the main API and website. 

{p 8 8 2}{bf: INT}: Refers to folders that will be used internally by specific people for specific purposes.
These folders are available {ul:only in the DEV server}. These folders will not be sent to production.
These folders are static and should not be modified by the PIP technical team.
An INT folder might be created for a particular paper and will remain unchanged for replication and archiving purposes. 
If the contents of an INT folder are needed to be sent to production, they have to be recreated as a PROD folder. 

{p 8 8 2}{bf: TEST}: Refers to testing folders that can be modified as needed by the PIP 
technical team. These folders are available {ul:only in the DEV server}.

{p 8 8 2}*An example might help to illustrate the differences between the server() and identity() options: Within the DEV server, a new version of the PIP data begins as identity(INT). For example, it is used to try out a methodological innovation. When the work is completed, a decision is made whether to archive and keep this dataset as identity(INT) or whether to eventually move it to production, i.e. turn it into identity(PROD). If it becomes a prod dataset, it then passes from the DEV server to the QA server for further testing and quality assurance. To publish the dataset externally it is transferred from the QA to the PROD server. 

{title:Examples}

{phang}
Here are some examples that show the use of the {cmd:server()} and {cmd:identity()} options:

{phang}
1) {stata pip versions, server(prod)} -> displays all the versions in the PROD server. All these datasets are publicly available. 

{phang}
2) {stata pip, country(PRY) year(2012) server(dev) clear} -> loads the estimates for Paraguay in 2012 from the DEV server. The order in which the data versions are searched within the DEV server are first {it:prod}, then {it:int},
and then {it:test}.

{phang}
3) {stata pip, country(PRY) year(2012) server(dev) identity(INT) clear} -> loads the estimates for Paraguay in 2012 from the DEV server from the INT folder.

{phang}
{help pip:Go back to pip help page}




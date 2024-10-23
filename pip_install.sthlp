{smcl}
{* *! version 1.0.0 dec 2022}{...}
{vieweralsosee "" "--"}{...}
{cmd:help pip [un]install}{right:{browse "https://pip.worldbank.org/":Poverty and Inequality Platform (PIP)}}
{help pip:(return to pip)} {right:{browse "https://worldbank.github.io/pip/"}}
{hline}

{title:Syntax}

{pstd}
Install {cmd:pip}

{phang2}
{cmd:pip install, } {it:{cmd:gh}}|{it:{cmd:ssc}} 
[ {help pip_install##opts_desc:options} ]


{pstd}
Uninstall {cmd:pip}

{phang2}
{cmd:pip uninstall}


{pstd}
Update {cmd:pip}

{phang2}
{cmd:pip update, } [ {help pip_install##opts_desc:options} ]


{marker opts_desc}{...}
{title:Options}

{synoptset 27 tabbed}{...}
{synopthdr:tables options}
{synoptline}
{synopt :{opt gh}}Install {cmd:pip} from 
{browse "https://github.com/worldbank/pip":GitHub}.{p_end}
{synopt :{opt ssc}}Install {cmd:pip} from
{browse "https://ideas.repec.org/c/boc/bocode/s459179.html":SSC}.{p_end}
{synopt :{opt version(#)}}Version to install. Only works with option {it:gh}.{p_end}
{synopt :{opt path(path)}}{it:(Programmer option)} Un/Installs {cmd:pip} 
in to the directory indicated in {opt path()}. Default is PLUS, as it is usually the 
case with commands installed from the SSC.{p_end}
{synopt :{opt check}}Checks whether {cmd:pip update} will result in a new install 
without actually installing the update.  This can be used (with {cmd:pip update} only)
to test for new versions without updating currently installed versions.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:pip} provides three different tools to manage its own installation process:

{pstd}
{opt install} Installs the stable version of {cmd:pip} from SSC ({cmd:pip install ssc}) or
the development version from GitHub ({cmd:pip install gh}). The {it:install} subcommand 
prevents issues from duplicate, and potentially conflicting, installations 
of the command. Using this subcommand it is possible to install pip from SSC 
and from GitHub, one after the other. If a version is already installed, 
the command will request a de-installation or a different installation path. Further
details are provided in the examples section {it:{help pip_install##examples:below}}. {p_end}

{pstd}
{opt uninstall} Uninstalls any version of pip in the installation path. This is
useful before a new installation from either SSC of GitHub. Once you have executed
{cmd:pip uninstall}, you cannot use {cmd:pip install} again because you won't have
any version of {cmd:pip} installed locally. You will need to install {cmd:pip} directly
from either SSC ({cmd:ssc install pip}) or from GitHub ({cmd:github install worldbank/pip}).
{p_end}

{pstd}
{opt update} This subcommand makes sure that the {cmd:pip} version is up-to-date. By
default, the first time that {cmd:pip} is used in a session, it will search for 
any new versions available from either SSC or GitHub, depending on where it 
was originally installed from (for this reason, the run time when {cmd:pip} is 
first called in a session is longer than the run time of subsequent calls to {cmd:pip}). 
If you wish to install the latest version of {cmd:pip} without leaving your Stata session, 
type {cmd:pip update}.
{p_end}

{marker installation_process}{...}
{title:Installation process}

{pmore}
In case of conflicting installation issues, this is the recommended process to install {cmd:pip} properly:{p_end}
{p 10 14 6}1. Uninstall {cmd:pip} by typing {cmd:pip uninstall}{p_end}
{p 10 14 6}2. Install the stable version of {cmd:pip} from the SSC 
({cmd:ssc install pip}) or the development version from GitHub 
({cmd:github install worldbank/pip}){p_end}
{p 10 14 6}3. from now on, {res:always} install pip using the {cmd:install}
subcommand: {cmd:pip install ssc} for SSC, or {cmd:pip install gh} for 
GitHub.{p_end}
{p 10 14 6}4. On rare occasions, if you do not want to restart your Stata 
session but want to update the version of {cmd:pip}, use {cmd:pip update}. {it:Note}: this
subcommand was intended for the members of the core PIP team,
who constantly need to update their {cmd:pip} version.{p_end}
{p 10 14 6}5. If {cmd:pip} fails, restart this process.{p_end}


{marker install_troubleshoot}{...}
{title:Installation troubleshooting}

{p 8 8 2}
Installing the same Stata command from two different sources may result in 
conflicting issues in your {help sysdir:search path} if the installation is 
not {it:{help net:done properly}}. 
The subcommand {cmd:install} is helpful to keep your 
{help sysdir:search path} clean. Say, for example, that you install the 
dev version of {cmd:pip} from GitHub in the regular way, and then 
you install the stable version from SSC. By doing this, you are creating 
two entries in the {it:stata.trk} file, making Stata believe that you 
have installed {cmd:pip} twice, but in reality you do not, because you used 
the same location to install both packages. You can confirm this 
by typing the following: {p_end}
{cmd}
	github install worldbank/pip  {text:// development}
	ssc install pip, replace      {text:// stable}
	
	* {text:You can't uninstall pip directly}
	ado uninstall pip
	{err:criterion matches more than one package}
	
	* {text:This is because you have two versions of {cmd:pip} installed}
	ado dir pip
{result}
	[318] package pip from https://raw.githubusercontent.com/worldbank/pip/master
	'PIP': Poverty and Inequality Platform Stata wrapper

	[319] package pip from http://fmwww.bc.edu/repec/bocode/p
	'PIP': module to access poverty and inequality data from the World Bank's Poverty and Inequality Platform (PIP)
{text}
{p 8 8 2}
By using the {it:install} subcommand, {cmd:pip} makes ensures that all conflicting installations
are solved. You can install {cmd:pip} from SSC and from GitHub, one after the other, and you 
won't have conflicting installations.

{p 8 8 2}
Be aware that if you have more than one version installed in your {help sysdir:search path}, 
{cmd:pip} will request that you confirm that you want to uninstall both versions by typing 
{it:yes} in the conosole and hitting {it:enter}.
{p_end}

	{cmd:pip install ssc}
{err}
	There is more than one version of PIP installed in the same search path, PLUS.
	You need to uninstall pip in PLUS or change installation path with option path()
	Type yes in the console and hit enter to confirm you agree to uninstall pip. 
{text}
{p 8 8 2}To troubleshoot, follow the 
{it:{help pip_install##installation_process:installation process}}.{p_end}


{marker examples}{...}
{title:Examples}

{ul:Installation}

{pstd}
Install the current development version of pip from github (removes the SSC version, if installed)

{phang2}
{cmd: pip install, gh} 

{ul:Updates}

{pstd}
Check for any updates to the current version installed, without actually installing updates

{phang2}
{stata pip update, check}



{p 40 20 2}(Go back to {it:{help pip##sections:pip's main menu}}){p_end}

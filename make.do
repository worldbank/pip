// the 'make.do' file is automatically created by 'github' package.
// execute the code below to generate the package installation files.
// DO NOT FORGET to update the version of the package, if changed!
// for more information visit http://github.com/haghish/github

*##s

cap program drop getfiles
program define getfiles, rclass

	args mask

	local f2add: dir . files "`mask'", respectcase

	foreach a of local f2add {
		local as "`as' `a'"
	}
	local as = trim("`as'")
	local as: subinstr local as " " ";", all

	return local files = "`as'"
end


* Working directory is set by the caller (rundo.exe uses the script's location).
* If running interactively, cd to the project root first.
getfiles "*.ado"
local as = "`r(files)'"

getfiles "*.sthlp"
local hs = "`r(files)'"

getfiles "*.mata"
local ms = "`r(files)'"


getfiles "*.dlg"
local ds = "`r(files)'"

getfiles "*.dta"
local dtas = "`r(files)'"


local toins  "`as';`hs';`ms';`ds';`dtas'"
disp "`toins'"


make pip, replace toc pkg                                  ///  readme
	version(0.11.0)                                                  ///
    license("MIT")                                                         ///
    author(`""R.Andres Castaneda" "Damian Clarke""')                       ///
    affiliation(`" "The World Bank" "University of Chile & University of Exeter""')                                                         ///
    email(`"acastanedaa@worldbank.org" "dclarke4@worldbank.org, dclarke@fen.uchile.cl""')                     ///
    url("")                                                ///
    title("Poverty and Inequality Platform Stata wrapper") ///
    description("World Bank PIP API Stata wrapper")        ///
    install("`toins'")                                     ///
    ancillary("")                                                         

*##e


exit


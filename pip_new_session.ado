*!version 0.11.0  <2026mar19>
/*==================================================
project:       Execute in each new Stata session
Author:        R.Andres Castaneda
E-email:       acastanedaa@worldbank.org
url:
Dependencies:  The World bank
----------------------------------------------------
Creation Date:    30 Nov 2021 - 16:05:24
Modification Date: 19 Mar 2026
Do-file version:    02
References:
Output:
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_new_session
version 16.1

* ---- Skip if already checked this session -----
* $pip_version_checked is set once per session (cleared on Stata restart).
* It prevents repeated API calls when pip is called multiple times.
if ("${pip_version_checked}" != "") exit


* ---- Check for new version on GitHub (once per session) -----
* Failures are fully silent - network issues must not disrupt users
* exit 1 from pip_gh means 'skipped silently' (not an error)

capture pip_gh
if (_rc == 0) {
	* Only consume r() macros if they were actually set by pip_gh
	local update_available = "`r(update_available)'"
	local latest_version   = "`r(latest_version)'"
	local install_cmd      = `"`r(install_cmd)'"'

	if ("`update_available'" == "1" & "`latest_version'" != "" & "`install_cmd'" != "") {
		noi disp as text _n ///
			"Note: A new version of {cmd:pip} is available (v`latest_version'). " ///
			"To update, run: {stata `install_cmd'}"
	}
}

global pip_version_checked "1"


* ---- Update pip_setup globals -----
pip_setup run

end

exit
/* End of do-file */

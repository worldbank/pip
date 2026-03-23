/*==================================================
project:       Offline test stub harness for pip
Author:        DECDG Team
Creation Date: 23 Mar 2026
Purpose:       Redefine all network-dependent pip sub-programs as minimal
               stubs so that top-level pip commands (pip, pip cl, pip wb,
               etc.) can be smoke-tested without any internet connection.

               HOW TO USE
               ----------
               run this file AFTER loading pip_fun.mata and BEFORE running
               any smoke tests:

                   adopath ++ "../.."
                   run "../../pip_fun.mata"
                   run "../test_helpers.do"
                   run "../test_stubs.do"   // <-- activates stubs
                   pip, clear              // now runs offline

               IMPORTANT: these stubs are for testing ONLY. They bypass
               real API calls and return synthetic data. Never use this
               file in production do-files.

               Stubs defined here
               ------------------
               pip_new_session  — no-op; sets pip_version_checked
               pip_set_server   — sets pip_host/pip_server without health check
               pip_versions     — sets pip_version without API call
               pip_cl           — returns minimal 2-row country-level dataset
               pip_wb           — returns minimal 2-row aggregate dataset
               pip_gh           — no-op; returns r(update_available)=0

               Globals set here (to short-circuit further network gates)
               -----------------------------------------------------------
               pip_version_checked  →  "1"   (skips pip_new_session body)
               pip_host             →  stub URL
               pip_server           →  "prod"
               pip_version          →  "20230601_2017_01_02_PROD"
==================================================*/
version 16.1
set more off

// ---- Pre-set globals that short-circuit network gates --------------------
// pip_new_session exits immediately when pip_version_checked is non-empty.
global pip_version_checked "1"
// pip_set_server is skipped inside pip_setup when pip_host is non-empty.
global pip_host   "https://api.worldbank.org/pip/v1"
global pip_server "prod"
// pip_versions short-circuits if pip_version is already set.
global pip_version "20230601_2017_01_02_PROD"
// pip_setup skips mata rebuild when pip_pipmata_hash is already set.
// Leave at "" so pip_setup runs its normal hash-check logic, which is
// fully offline.  Setting it to a wrong value forces a rebuild (also
// offline). Leave it managed by pip_setup itself.


// ---- STUB: pip_new_session -----------------------------------------------
// Real program: pip_new_session.ado
// Network deps: pip_gh (GitHub API) + pip_setup run
// Stub action : mark session as checked so the real body is skipped if
//               called again, then exit.
cap program drop pip_new_session
program define pip_new_session
	global pip_version_checked "1"
end


// ---- STUB: pip_set_server ------------------------------------------------
// Real program: pip_set_server.ado
// Network deps: fileread() health-check against the live API
// Stub action : set the same globals/returns as the real program without
//               making any HTTP request.
cap program drop pip_set_server
program define pip_set_server, rclass
	syntax [, server(string) ]
	global pip_host   "https://api.worldbank.org/pip/v1"
	global pip_server "prod"
	return local server   = "prod"
	return local url      = "https://api.worldbank.org/pip/v1"
	return local base     = "https://api.worldbank.org/pip/v1/pip"
	return local base_grp = "https://api.worldbank.org/pip/v1/pip-grp"
end


// ---- STUB: pip_versions --------------------------------------------------
// Real program: pip_versions.ado
// Network deps: pip_get → downloads versions?format=csv
// Stub action : set pip_version to a syntactically valid version string and
//               return the expected r() macros. Accepts the same syntax as
//               the real program so pip.ado can call it transparently.
cap program drop pip_versions
program define pip_versions, rclass
	syntax [anything], [                    ///
		version(string)                     ///
		release(numlist)                    ///
		PPP_year(numlist)                   ///
		identity(string)                    ///
		AVAILability                        ///
		*                                   ///
	]
	local stub_ver "20230601_2017_01_02_PROD"
	global pip_version "`stub_ver'"
	tokenize "`stub_ver'", parse("_")
	return local release  = "`1'"
	return local ppp_year = "`3'"
	return local identity = "`9'"
	return local version  = "`stub_ver'"
end


// ---- STUB: pip_cl --------------------------------------------------------
// Real program: pip_cl.ado
// Network deps: pip_auxframes, pip_get (downloads country-level data)
// Stub action : clear current data and load a minimal 2-row dataset with
//               the variables that smoke tests assert on.
//               Accepts clear, fillgaps, and any other options silently
//               so that pip.ado can pass est_opts without error.
cap program drop pip_cl
program define pip_cl
	syntax [, clear fillgaps noNOWcasts *]
	clear
	qui set obs 2
	gen str3  country_code     = cond(_n == 1, "CHN", "IND")
	gen str32 country_name     = cond(_n == 1, "China", "India")
	gen str3  region_code      = cond(_n == 1, "EAP", "SAS")
	gen       year             = 2018
	gen       poverty_line     = 2.15
	gen       mean             = 5 + _n
	gen       headcount        = 0.01 * _n
	gen       poverty_gap      = 0.005 * _n
	gen       poverty_severity = 0.002 * _n
	gen byte  welfare_type     = 1
	gen       population       = 1000000 * _n
	if ("`fillgaps'" != "") {
		gen byte is_interpolated = 1
		local datalabel "Country level (lined up)"
	}
	else {
		gen byte is_interpolated = 0
		local datalabel "country level"
	}
	label data "WB poverty at `datalabel' (pip_cl stub)"
end


// ---- STUB: pip_wb --------------------------------------------------------
// Real program: pip_wb.ado
// Network deps: pip_auxframes, pip_get (downloads aggregate data)
// Stub action : clear current data and load a minimal 2-row dataset.
cap program drop pip_wb
program define pip_wb
	syntax [, clear *]
	clear
	qui set obs 2
	gen str3  region_code      = cond(_n == 1, "EAP", "SSA")
	gen str32 region_name      = cond(_n == 1, "East Asia", "Sub-Saharan Africa")
	gen       year             = 2018
	gen       poverty_line     = 2.15
	gen       mean             = 4 + _n
	gen       headcount        = 0.1 * _n
	gen       poverty_gap      = 0.05 * _n
	gen       poverty_severity = 0.02 * _n
	gen       population       = 1e9 * _n
	label data "WB poverty aggregate (pip_wb stub)"
end


// ---- STUB: pip_gh --------------------------------------------------------
// Real program: pip_gh.ado
// Network deps: GitHub releases API
// Stub action : return r(update_available)=0 (no update) silently.
cap program drop pip_gh
program define pip_gh, rclass
	return local update_available = "0"
	return local latest_version   = ""
	return local install_cmd      = ""
end


di as result "(test_stubs.do loaded — offline mode active)"

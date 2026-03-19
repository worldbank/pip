/*==================================================
project:       Reproduction test — stale pip_source bug (pip_utils finalmsg)
Bug:           pip_utils_final_msg calls `noi pip_${pip_source} msg`.
               pip_source is a stale global ("NotInstalled" or other value)
               left by the old pip_update.ado which was deleted in the revamp.
               pip_gh no longer has a `msg` subcommand, so any non-empty
               pip_source value causes `command pip_<value> is unrecognized`.
Expected:      pip_utils finalmsg should complete without error
Actual (buggy): r(199) — command pip_NotInstalled is unrecognized
Fix:           Remove the dead `noi pip_${pip_source} msg` call from
               pip_utils_final_msg in pip_utils.ado
==================================================*/
version 16.1
set more off

* ---- Reproduce: stale pip_source causes r(199) -----

* Add project root to adopath so all pip ado files are found
adopath ++ ".."

* Force-load pip_utils.ado so its sub-programs are defined
run "../pip_utils.ado"

* Read the source file directly and check for the offending pattern
tempname fh
local found_bad 0
file open `fh' using "../pip_utils.ado", read text
file read `fh' line
while r(eof) == 0 {
    if strpos(`"`line'"', "pip_source") > 0 {
        local found_bad 1
        di as error `"  Found offending pattern: `line'"'
    }
    file read `fh' line
}
file close `fh'

if `found_bad' != 0 {
    di as error "BUG 2 NOT FIXED: pip_utils.ado still references pip_source."
    error 9
}

di as result "Bug 2 reproduction test passed (pip_source call removed from pip_utils.ado)."

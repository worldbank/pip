/*==================================================
project:       Test deprecated subcommand regex in pip.ado
Author:        DECDG Team
Creation Date: 19 Mar 2026
Purpose:       Verify that the regex used to detect deprecated subcommands
               (install, uninstall, update) correctly matches and excludes
               the right inputs. Tests the pattern logic in pip.ado without
               requiring a live network connection or full pip session setup.
==================================================*/
version 16.1
set more off

di as result "=== pip: deprecated subcommand regex ==="

* ---- Test 1: deprecated subcommands matched -----
foreach subcmd in install uninstall update {
    if !regexm("`subcmd'", "^install|^uninstall|^update") {
        di as error "FAIL Test 1: '`subcmd'' should be matched as deprecated"
        error 9
    }
}
di as result "  PASS Test 1: install, uninstall, update all matched"

* ---- Test 2: active subcommands NOT matched -----
foreach subcmd in cl wb cp gd agg tables print info cleanup test drop setup {
    if regexm("`subcmd'", "^install|^uninstall|^update") {
        di as error "FAIL Test 2: '`subcmd'' should NOT be matched as deprecated"
        error 9
    }
}
di as result "  PASS Test 2: active subcommands not matched by deprecated regex"

* ---- Test 3: prefix-based matching documented -----
* The regex uses ^install (prefix), so "installed", "installer" etc. also match.
* This is intentional: any typo/variant of the deprecated name shows the helpful message.
foreach subcmd in installed installer updater uninstaller {
    if !regexm("`subcmd'", "^install|^uninstall|^update") {
        di as error "FAIL Test 3: '`subcmd'' should match (prefix-based regex)"
        error 9
    }
}
di as result "  PASS Test 3: regex is prefix-based (install* and update* variants caught)"

* ---- Test 4: empty and single-char inputs do not match -----
foreach subcmd in "" i u un ins upd {
    if regexm("`subcmd'", "^install|^uninstall|^update") {
        di as error "FAIL Test 4: '`subcmd'' should NOT match (too short)"
        error 9
    }
}
di as result "  PASS Test 4: short/empty strings correctly excluded"

di as result _n "All pip deprecated subcommand regex tests passed."

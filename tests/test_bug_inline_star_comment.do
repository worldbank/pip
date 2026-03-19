/*==================================================
project:       Reproduction test — inline * comment bug (pip_gh.ado)
Bug:           * used as inline comment after code is NOT a comment in Stata.
               Stata interprets `exit   * text` as `exit` followed by
               multiplication, producing a syntax error instead of a silent exit.
Expected:      capture block should set _rc == 0 (silent exit)
Actual (buggy): _rc != 0 (syntax/expression error)
Fix:           Replace inline `*` comments with `//` comments
==================================================*/
version 16.1
set more off

* ---- Reproduce: inline * comment causes error instead of silent exit -----

* This simulates the exact pattern in pip_gh.ado line 27 / 38 / 55 / 62.
* When `if (_rc) exit   * comment` fires, Stata does NOT treat `* comment`
* as a comment — it tries to evaluate `exit * comment` as an expression.

* First: confirm the BUGGY pattern (inline *) causes an error in Stata
* Using `local` instead of `exit` to avoid terminating the do-file
local test_rc 1
capture noisily if (`test_rc') local _x = 1   * this is NOT a comment
if _rc == 0 {
    di as error "UNEXPECTED: inline * did not cause an error"
    error 9
}
di as result "  Confirmed: inline * after code causes _rc = " _rc " (expected)"

* Second: confirm the FIXED pattern (inline //) works correctly
capture noisily if (`test_rc') local _x = 1   // this IS a comment

if _rc != 0 {
    di as error "BUG 1 NOT FIXED: inline // comment still fails (_rc = " _rc ")."
    error 9
}

di as result "Bug 1 reproduction test passed (inline // comment works correctly)."

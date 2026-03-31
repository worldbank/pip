/*==================================================
Diagnostic: does syntax, option(string) accept empty strings?
Run from tests/ or project root.
==================================================*/
version 16.1
set more off

di "=== Diagnostic: empty string in syntax ==="

// Test A: syntax, option(string) with non-empty string
program define _diag_prog_a
    syntax, val(string)
    di "A got: '`val''"
end
_diag_prog_a, val("hello")
di "A passed"

// Test B: syntax, [option(string)] with empty string via macro
program define _diag_prog_b
    syntax, [val(string)]
    di "B got: '`val''"
end
local _empty ""
_diag_prog_b, val("`_empty'")
di "B passed"

// Test C: syntax, option(string) (required) with empty string via macro
program define _diag_prog_c
    syntax, val(string)
    di "C got: '`val''"
end
local _empty2 ""
_diag_prog_c, val("`_empty2'")
di "C passed"

// Test D: explicit empty string literal
program define _diag_prog_d
    syntax, val(string)
    di "D got: '`val''"
end
_diag_prog_d, val("")
di "D passed"

di "=== All diagnostics done ==="

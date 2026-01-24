/*==================================================
project:       Test last PIP queries
Author:        R.Andres Castaneda 
----------------------------------------------------
Creation Date:     6 Jun 2023 - 18:25:32
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_test, rclass
	version 16.1
	
	if ("${pip_last_queries}" == "") {
		noi disp "{err}{cmd:pip} has not been executed in this Stata session"
		error
	}
	
	noi disp _n "{txt}{title:Metadata of last query/ies}" _n
	local j = 1
	foreach query of global pip_last_queries {
		local queryfull "${pip_host}/`query'"
		local incsv = ustrtrim(`"`queryfull'"')
		local injson: subinstr local incsv "&format=csv" ""
		if ustrregexm("`incsv'","(.+)/(.+)\?(.+)") {
			local host       = ustrregexs(1)
			local endpoint   = ustrregexs(2)
			local parameters = ustrregexs(3)
		}
		noi disp "{txt}{ul:Query `j'}"
		noi disp "{txt}{p2col 10 36 36 30:attribute}{dup 8: }value{p_end}" /*  
		*/   "{p2colset 10 30 32 30}" /* 
		*/   "{res}{p2line}" /* 
		*/   "{p2col :{res:host}} {txt:`host'}{p_end}" /* 
		*/   "{p2col :{res:endpoint}} {txt:`endpoint'}{p_end}" 
		
		tokenize "`parameters'", parse("&")
		local i = 1
		while ("`1'" != "") {
			if ("`1'" == "&") {
				macro shift
				continue
			}
			if (`i' == 1) {
				local aname "parameters"
				local i = `i' + 1
			}
			else          local aname "."
			noi disp "{p2col :{res:`aname'}} {txt:`1'}{p_end}" 
			macro shift
		}
		noi disp "{p2line}" 
		
		noi disp "{break}{col 10}{ul:{res:ACTION:}}{col 20}"     /* 
		*/ `" {browse "`injson'":see in browser} or {col 35}"' /* 
		*/ `"{browse "`incsv'":download .csv}"' _n
		local j = `j' + 1
	}
	
end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

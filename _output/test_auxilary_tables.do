	// This program compares country level, wb aggregate , fill gaps and auxilary data with previous version of pip data
	
	clear all 
	pip cleanup

	// Version 
	local verDescription "version_0_3_2_9000"
	pip version
	
	// set server and identity options
	global options = "clear server(dev) identity(prod)" 
	
	local tblist "countries country_coverage cpi decomposition dictionary framework gdp incgrp_coverage indicators interpolated_means pce pop pop_region poverty_lines ppp region_coverage regions survey_means"
	foreach tbl of local tblist {
		pip tables, table(`tbl') ${options} 
		cap cf _all using "`output'pip_`tbl'_`verDescription'.dta", all verbose
		if (_rc) {
			disp "There is difference between benchmark and currenty `tbl'"
		} 
		else {
			disp "There is no difference in the `tbl'"
		}
	}
	

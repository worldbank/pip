/*==================================================
project:       
Author:        R.Andres Castaneda 
----------------------------------------------------
Creation Date:    20 Jan 2022 - 09:44:03
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_drop_frames, rclass
syntax, [frame_prefix(string)]

//========================================================
// Conditions
//========================================================

if ("`frame_prefix'" == "") {
	local frame_prefix "pip_"
}


//========================================================
//  Remove frames
//========================================================

qui {
	
	frame dir
	local av_frames "`r(frames)'"
	
	foreach fr of local av_frames {
		
		if (regexm("`fr'", "(^`frame_prefix')(.+)")) {
			
			frame drop `fr'
			
			local dropped "`dropped' `fr'"
		}
		
	} // loop over frames
	
	if ("`dropped'" == "") {
		noi disp in y "NO frame was dropped"
	}
	else {
		noi disp in r "frames `dropped' were dropped"
	}
	
} // end of qui


end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

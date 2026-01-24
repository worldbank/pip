/*==================================================
project:       
Author:        R.Andres Castaneda 
----------------------------------------------------
Creation Date:    20 Jan 2022 - 09:44:03
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pip_drop, rclass
syntax [anything(name=subcommand)], [frame_prefix(string) qui]


qui {
	//========================================================
	// Frames
	//========================================================
	if regexm("`subcommand'", "^frame") {
			
		if ("`frame_prefix'" == "") {
			local frame_prefix "pip_"
		}
		
		//------------ Remove frames
		
		frame dir
		local av_frames "`r(frames)'"
		
		foreach fr of local av_frames {
			
			if (regexm("`fr'", "(^`frame_prefix')(.+)")) {
				
				frame drop `fr'
				
				local dropped "`dropped' `fr'"
			}
			
		} // loop over frames
		
		if ("`dropped'" == "") {
			if ("`qui'" == "") noi disp in y "NO frame was dropped"
		}
		else {
			if ("`qui'" == "")  {
				noi disp in y "The following internal frames were dropped:" 
				foreach f of local dropped {
					noi disp in w "`f'"
				}
			}
		}
		
		
	}
	
	//========================================================
	// Globals 
	//========================================================
	if regexm("`subcommand'", "^global") {
		local pip_globals: all globals "pip_*"
		* disp "`pip_globals'"
		foreach gl of local pip_globals {
			global `gl' ""
		}
		
	}
	
	
} // end of qui

end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

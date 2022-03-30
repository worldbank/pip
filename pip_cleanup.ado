/*==================================================
project:       Clean up PIP files
Author:        R.Andres Castaneda 
----------------------------------------------------
Creation Date:    28 Mar 2022 - 13:43:38
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
program define pip_cleanup 
* clean frames
pip_drop frame, frame_prefix(_pip_) qui

* clean globals
pip_drop global 
noi disp in y "PIP internal data has been cleaned up"
end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

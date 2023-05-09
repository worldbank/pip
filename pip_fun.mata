// ------------------------------------------------------------------------
// MATA functions for PIP
// ------------------------------------------------------------------------



cap mata: mata drop pip_*()

version 16
mata:

mata set mataoptimize on
mata set matafavor speed
mata set matadebug off // (on when debugging; off in production)
mata set matalnum  off // (on when debugging; off in production)



// Read and return the line in a file from a specific position
// of the file
string scalar pip_read_pos_file(string scalar filetoread, real scalar pos)
{
	// set up
	real scalar    fh
	string scalar  line
	
	fh = fopen(filetoread, "r")
	
	// display and return line
	fseek(fh, pos, -1)
	line = strtrim(fget(fh)) 
	fclose(fh)
	return(line)
}

void pip_replace_in_pattern(
string scalar filetoread, 
string scalar pattern,
string scalar newline)
{
	real scalar changed, fh_in, fh_out
	string scalar  out_name, line
	string matrix  EOF
	
	fh_in    = fopen(filetoread, "r")
	out_name = st_tempfilename()
	fh_out   = fopen(out_name, "w")
	
	EOF = J(0, 0, "")
	changed = 0 // indicator of whether or not it changed
	
	while ((line=fget(fh_in))!=EOF) {
		line = strtrim(line)
		if (regexm(line, pattern)) {
			fput(fh_out, newline)
			
			changed = 1
		}
		else {
			fput(fh_out, line)
		}	
	}
	fclose(fh_out)
	fclose(fh_in)
	
	if (changed == 1) {
		st_local("tempf", out_name)
		st_local("origf", filetoread)
		// stata(`"copy `tempf' "`origf'" , replace"')
	} 
	else {
		printf("pattern not found. Nothing to update")
	}
	
}


// check whether a particular folder exist and 
// is writable. Return 0 if there is an error. 
// return 1 if everything is ok. 
real scalar pip_check_folder(
string scalar dir, 
| string scalar subdir)
{
	// check dir exists
	// dir = "c:\ado\personal/" 
	
	real scalar de, md, fh
	string scalar sdir, tfile
	de = direxists(dir)
	if (de == 0) {
		return(0)
	}
	
	// if check creation of subdir
	if (args() == 2) sdir = pathjoin(dir, subdir)
	else             sdir = dir
	
	// If subdir does not exist, create it.
	de = direxists(sdir)
	if (de == 0) {
		// if can't be created, return 0
		md = _mkdir(sdir, 1)
		if (md != 0) {
			printf("{err}Warning: {res}Subdirectory {text}%s {res}could not be created\n", sdir)
			return(0)
		}
	}
	
	// test we can write in the folder
	tfile = pathjoin(sdir, "testing.txt")
	fh    = fopen(tfile, "rw")
	fput(fh, "this is a test")
	fclose(fh)
	
	if (fileexists(tfile)) {
		unlink(tfile)
		return(1)
	}
	else {
		printf("{err}Warning: {res}Subdirectory {text}%s {res}is not writable\n", sdir)
		return(0)
	}
	
}



//========================================================
// deprecated functions
//========================================================


// Write a line starting in a position. 
void pip_write_pos_file( // deprecated
string scalar filetoread, 
real scalar pos, 
string scalar newline) 
{
	
	// set up
	real scalar    fh, pos2 
	string scalar  line, nl
	nl = char(13) + char(10) // new line
	
	
	fh = fopen(filetoread, "rw")
	
	fseek(fh, pos, -1)       // go to the beginning of line of interest
	line   = fget(fh)        // get line
	pos2   = ftell(fh)       // get position of new line 
	fseek(fh, pos, -1)       // come back to line of interest
	fput(fh, " "*(pos2-pos)) // replace with blanks of same length
	fseek(fh, pos, -1)       // come back to line of interest
	fput(fh, newline)        // replace with new line
	fclose(fh)
	
	// printf("ftell(fh): %g\n", ftell(fh))
	// printf("fget(fh): %s\n", fget(fh))
	
}



// Find the position of the line in a file when a pattern is 
// found
real scalar pip_find_pattern_pos(
string scalar filetoread, 
string scalar pattern) 
{
	real scalar    fh, pos_a, pos_b, found
	string scalar  line
	string matrix  EOF
	
	// setup 
	fh = fopen(filetoread, "r")
	EOF = J(0, 0, "")
	
	pos_a = ftell(fh)
	pos_b = 0
	found = 0
	while ((line=fget(fh))!=EOF) {
		line = strtrim(line)
		if (regexm(line, pattern)) {
			fseek(fh, pos_b, -1)
			found = 1
			break
		}
		pos_b = pos_a
		pos_a = ftell(fh)
	}
	fclose(fh)
	
	if (found == 0) {
		printf("{err}pattern {res}%s {err}not found. Returning {res}0\n", pattern)
		pos_a = 0
	}
	
	return(pos_a)
} // end of pip_find_pattern_pos



end 


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



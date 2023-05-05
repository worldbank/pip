// ------------------------------------------------------------------------
// MATA functions for PIP
// ------------------------------------------------------------------------

*##s

cap mata: mata drop pip_*()

version 16
mata:

mata set mataoptimize on
mata set matafavor speed
mata set matadebug off // (on when debugging; off in production)
mata set matalnum  off // (on when debugging; off in production)



// Find the position of the line in a file when a pattern is 
// found
real scalar pip_find_pattern_pos(string scalar filetoread, string scalar pattern) 
{
	real scalar    fh, pos_a, pos_b
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
			printf("line text: %s\n", line)
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


// Read and return the line in a file from a specific position
// of the file
string scalar pip_read_pos_file(string scalar filetoread, real scalar pos)
{
	// set up
	real scalar    fh
	fh = fopen(filetoread, "r")
	
	// display and return line
	fseek(fh, pos, -1)
	line = strtrim(fget(fh)) 
	fclose(fh)
	return(line)
}
	

// Write a line starting in a position. 
void pip_write_pos_file(string scalar filetoread, 
real scalar pos, 
string scalar newline)
{
	
	// set up
	real scalar    fh
	string scalar  nl // new line
	nl = char(13) + char(10)
	
	
	fh = fopen(filetoread, "rw")
	
	// display and return line
	fseek(fh, pos, -1)
	nchar  = ustrlen(fget(fh))
	nnline = ustrlen(newline)
	if (nnline < nchar) {
		// add blanks to make sure the whole line is deleted
		newline = newline + (" "*(nchar - nnline)) 
	}
	fseek(fh, pos, -1)
	
	// printf("ftell(fh): %g\n", ftell(fh))
	// printf("fget(fh): %s\n", fget(fh))
	fput(fh, newline)
	fclose(fh)

	
}

end 
*##e


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:
 



filetoread = findfile("pip_setup.do")
pattern   = "pip_lastupdate"

pos = pip_find_pattern_pos(filetoread, pattern)

if (pos) {
	newline = `"global pip_lastupdate "20230505" "' + char(13) + char(10) + "Is this a new line?"
	pip_write_pos_file(filetoread, pos, newline)
	pip_read_pos_file(filetoread, pos)
}
else {
	printf("Nothing to show")
}









pos_a = ftell(fh)
pos_b = 0
while ((line=fget(fh))!=J(0,0,"")) {
	line = strtrim(line)
	if (regexm(line, pattern)) {
		fseek(fh, pos_b, -1)
		printf("line text: %s\n", line)
		printf("line N: %f\n", ftell(fh))
		break
	}
	pos_b = pos_a
	pos_a = ftell(fh)
}

new_date = `"global pip_lastupdate "20230505""'
fput(fh, new_date)

fclose(fh)
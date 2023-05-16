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
real scalar pip_check_folder(string scalar dir)
{
	// check dir exists
	// dir = "c:\ado\personal/" 
	
	real scalar de, md, fh
	string scalar sdir, tfile
	
	if (direxists(dir) == 0) {
		if (pip_mkdir_recursive(dir, 1) != 0) {
			printf("{err}Warning: {res}directory {text}%s {res}could not be created\n", dir)
			return(0)
		}
	}
	
	
	// test we can write in the folder
	tfile = pathjoin(dir, "testing.txt")
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

// create recursive folders
real scalar pip_mkdir_recursive(string scalar path, | real scalar pub) 
{
	
	string rowvector mpath
	real   rowvector direx
	string scalar    ppath
	real scalar      i
	
	if (args() == 1) pub = 0
	
	mpath = path
	ppath = pathgetparent(path)
	while (ppath != "") {
		mpath = (ppath\ mpath)
		ppath = pathgetparent(ppath)
	}
	
	// check whther dir exists
	direx = J(rows(mpath), 1, 0)
	for (i = 1; i <= rows(mpath); i++) {
		direx[i] = (direxists(mpath[i]) ? 0 : 1)
	}
	
	// filter matrix of not existing directories
	mpath = select(mpath, direx)
	direx = J(rows(mpath), 1, 0)
	// loop over none existing dirs
	for (i = 1; i <= rows(mpath); i++) {
		if (_mkdir(mpath[i], pub) != 0) {
			printf("{err}dir {res}%s {err}could not be created", mpath[i])
			return(693)
		}
	}
	return(0)
	
} // end of function


//========================================================
//  Create locals using the macros in retlist
//========================================================

void pip_retlist2locals(string scalar optnames) 
{
	string rowvector optn
	string scalar    gname
	real scalar      i
	
	optn = tokens(optnames)
	for (i = 1; i <= cols(optn); i++) {
		gname = "r(" + optn[i] + ")"
		st_local(optn[i], st_global(gname))
		
		/* printf("{res}name: {txt}%s\n{res}value: {txt}%s\n\n", 
		optn[i], st_global(gname)) */
	}
}


//========================================================
//  create string of calling of locals
//========================================================

void pip_locals2call(string scalar optnames, string scalar newname)
{
	string rowvector V
	
	V = tokens(optnames)
	V = "`" :+ V :+ "'"
	st_local(newname, invtokens(V))
}


//========================================================
// PIP TIMER
//========================================================
struct pip_time_info
{
	
	//------------ input
	string scalar label // label of timer
	
	//------------ output
	real   scalar counter  // timer counter
	real   matrix time_i   // index of timers
	string colvector time_l   // labels of timers
	
}

struct pip_time_info scalar pip_timeset( )
{
	struct pip_time_info scalar r
	r.label =  r.time_l = J(0,1,"")
	r.counter  = r.time_i = .m
	return(r)
}

// counter
real scalar pip_time_count(struct pip_time_info scalar r)
{
	if (r.counter == .m) {
		r.counter = 1
	}
	else {
		r.counter = r.counter + 1
	}
	return(r.counter)
}


// get all the info of the time
struct pip_time_info scalar pip_timer_on(string scalar label,  /* 
*/                                    struct pip_time_info scalar r)
{
	
	//------------ setup
	string scalar pattern
	
	//------------create timer
	if (r.time_l == J(0,1,"")) {
		timer_clear()
		r.time_l = label
		r.time_i = pip_time_count(r)
	}
	else {
		pattern = "^"+label+"$"
		if (anyof(ustrregexm(r.time_l, pattern), 1)) {
			errprintf("%s is already in used\n", label)
			exit(498)
		}
		
		r.time_l = r.time_l \ label
		r.time_i = r.time_i \ pip_time_count(r)
	}
	// start timer
	timer_on(r.counter)
	return(r)
}

void pip_timer_off(string scalar label,  /* 
*/                 struct pip_time_info scalar r)
{
	//------------ setup
	string scalar pattern
	real colvector w  // check whether label is in r.time_l
	
	//------------stop timer
	pattern = "^"+label+"$"
	w       = selectindex(ustrregexm(r.time_l, pattern))
	if (rows(w) > 0) {
		timer_off(w)
	}
	else {
		errprintf("%s is not a timer\ntimers available are\n", label)
		r.time_l
		exit(498)
	}
}
void pip_time_print_info(struct pip_time_info scalar r)
{
	real scalar i 
	printf("{res}PIP timer report {hline 40}\n")
	for (i = 1; i <= rows(r.time_l); i++) {
		printf("{txt}{col 2}%g.{col 6}%s: {res}{col 40}%5.0g{txt} secs\n", /* 
	 */	     i, r.time_l[i], timer_value(i)[1])
	}
	printf("{res}{hline 57}")
	
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

*##s
cap mata: mata drop pip_time*()
* cap mata: mata drop pip_time_info()

mata


end

*##e
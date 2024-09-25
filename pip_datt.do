/*==================================================
project:       Document data from Datt 1998
Author:        R.andres.castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    23 Sep 2024 - 16:48:05
Modification Date:   
Do-file version:    01
References: 
paperwebpage: https://ageconsearch.umn.edu/record/94862/?v=pdf        
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
version 16.1
drop _all

/*==================================================
              1: data
==================================================*/
clear all

* Input the data
input W X P L
0.92    24.84   0.0092  0.00208
2.47    35.8    0.0339  0.01013
5.11    45.36   0.085   0.03122
7.9     55.1    0.164   0.07083
9.69    64.92   0.2609  0.12808
15.24   77.08   0.4133  0.23498
13.64   91.75   0.5497  0.34887
16.99   110.64  0.7196  0.51994
10      134.9   0.8196  0.6427
9.78    167.76  0.9174  0.79201
3.96    215.48  0.957   0.86966
1.81    261.66  0.9751  0.91277
2.49    384.97  1       1
end

tempvar TT
egen `TT' = total(W * X)
* Generate the new variable R
gen R = (W * X) / `TT'
drop `TT'


/*==================================================
              2: labels and info
==================================================*/
label var W "Percentage of population"
label var X "Mean monthly per capita expenditure in Rs"
label var P "cumulative proportion of population"
label var L "cumulative proportion of expenditure"
label var R "Relative share of expenditure"

note: Source: Datt, Gaurav. {it:Computational tools for poverty measurement and analysis.} (1998): 1-29.
note: Source link: {browse "https://ageconsearch.umn.edu/record/94862/?v=pdf"}

char _dta[mean_lcu]  109.90
char _dta[povline_lcu] 89.00
char _dta[FGT0] 45.06
char _dta[FGT1] 12.47
char _dta[FGT2] 4.752
char _dta[gini] 0.289

// char _dta[ppp]  109.90
// char _dta[mean_ppp]  109.90
// char _dta[povline_ppp] 89.00

/*==================================================
              3: Save
==================================================*/

save "pip_datt.dta", replace



exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:



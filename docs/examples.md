## Examples


```stata
* Available pip data versions can be checked as
pip versions

* Note: pip command provides optional parameter `version` that can be used to specify which version of the pip data should be used to generate estimates. If the version parameter is not provided, a query will be run on the latest pip data.

* Retrieve ONE country with default parameters

pip, country("ALB") clear 

* Retrieve MULTIPLE countries with default parameters

pip, country("all") clear

pip, country("ALB CHN") clear

* Change poverty line
pip, country("ALB CHN") povline(10) clear

pip, country("ALB CHN") povline(5 10) clear

* Select specific years

pip, country("ALB") year("2002 2012") clear
pip, country("ALB") year("2002 2020") clear  // just 2002
cap noi pip, country("ALB") year("2020") clear       // error

pip, country("ALB") year("2002") clear

* Change coverage

pip, country("all") coverage("urban") clear

pip, country("all") coverage("rural") clear

pip, country("all") coverage("national") clear

pip, country("all") coverage("rural national") clear

* Fill gaps when surveys are missing for specific year

pip, country("ALB CHN") fillgaps clear 
pip, country("ALB CHN") fillgaps coverage("national") clear

* PPP

pip, country("ALB CHN") ppp(50 100) clear

                                   
*----------  Understanding requests and aggregates
// --------------------------
// Basic Syntax  and defaults
// ------------------------

****** Main defaults
** all survey years, all coverages, 1.9 USD poverty. 
pip

** filter by country
pip, country(COL) clear

** Filter by year (only surveys avaialable in that year)
pip, year(2017) clear

** Filter by coverage (national, urban, rural)
pip, coverage(urban) clear

** Poverty lines
pip, povline(3.2) clear

// ------------------------
// pip features
// ------------------------

** fill gaps (Reference Years)
* regular 
pip, country(COL BRA ARG IND) year(2015) clear 

* fill gaps
pip, country(COL BRA ARG IND) year(2015) clear  fillgaps

** Customized Aggregate
pip, country(COL BRA ARG IND) year(2015) clear  aggregate

***** Aggregating all countries

** using country(all)
pip, country(all) year(2015) clear  aggregate

** parsing the list of all countries 
pip info, clear
levelsof country_code, local(all) clean 
pip, country(`all') year(2015) clear  aggregate

***** WB aggregates
pip wb, clear  year(2015)
pip wb, clear  region(SAR LAC)
pip wb, clear             // all reference years

// ------------------------
// advance options  and features
// --------------------

* Different national coverages
pip, coverage(national) country(IND COL) clear

* PPP option

```




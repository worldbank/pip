*********************************************************************************
*pip_examples-: Auxiliary program for -pip-                    		*
*! v1.0  		sept2018               by 	Jorge Soler Lopez					*
*											Espen Beer Prydz					*
*											Christoph Lakner					*
*											Ruoxuan Wu							*
*											Qinghua Zhao						*
*											World Bank Group					*
*! based on JP Azevedo wbopendata_examples										*
*********************************************************************************

*  ----------------------------------------------------------------------------
*  0. Main program
*  ----------------------------------------------------------------------------

capture program drop pip_examples
program pip_examples
version 16.0
args EXAMPLE
set more off
`EXAMPLE'
end


*  ----------------------------------------------------------------------------
*  World Poverty Trend (reference year)
*  ----------------------------------------------------------------------------
program define pip_example01

	pip wb,  clear

	keep if year > 1989
	keep if region_code == "WLD"	
  gen poorpop = headcount * population/ 1000000
  gen hcpercent = round(headcount*100, 0.1) 
  gen poorpopround = round(poorpop, 1)

  twoway (sc hcpercent year, yaxis(1) mlab(hcpercent)           ///
           mlabpos(7) mlabsize(vsmall) c(l))                    ///
         (sc poorpopround year, yaxis(2) mlab(poorpopround)     ///
           mlabsize(vsmall) mlabpos(1) c(l)),                   ///
         yti("Poverty Rate (%)" " ", size(small) axis(1))       ///
         ylab(0(10)40, labs(small) nogrid angle(0) axis(1))     ///
         yti("Number of Poor (million)", size(small) axis(2))   ///
         ylab(0(400)2000, labs(small) angle(0) axis(2))         ///
         xlabel(,labs(small)) xtitle("Year", size(small))       ///
         graphregion(c(white)) ysize(5) xsize(5)                ///
         legend(order(                                          ///
         1 "Poverty Rate (% of people living below $2.15)"      ///
         2 "Number of people who live below $2.15") si(vsmall)  ///
         row(2)) scheme(s2color)

end
*  ----------------------------------------------------------------------------
*  Millions of poor by region (reference year) 
*  ----------------------------------------------------------------------------
program define pip_example02
	pip wb, clear
	keep if year > 1989
	gen poorpop = headcount * population /1000000
	gen hcpercent = round(headcount*100, 0.1) 
	gen poorpopround = round(poorpop, 1)
	encode region_name, gen(rid)

	levelsof rid, local(regions)
	foreach region of local regions {
		local legend = `"`legend' `region' "`: label rid `region''" "'
	}

	keep year rid poorpop
	reshape wide poorpop,i(year) j(rid)
	foreach i of numlist 2(1)7{
		egen poorpopacc`i'=rowtotal(poorpop1 - poorpop`i')
	}

	twoway (area poorpop1 year)                              ///
		(rarea poorpopacc2 poorpop1 year)                      ///
		(rarea poorpopacc3 poorpopacc2 year)                   ///
		(rarea poorpopacc4 poorpopacc3 year)                   ///
		(rarea poorpopacc5 poorpopacc4 year)                   ///
		(rarea poorpopacc6 poorpopacc5 year)                   ///
		(rarea poorpopacc7 poorpopacc6 year)                   ///
		(line poorpopacc7 year, lwidth(midthick) lcolor(gs0)), ///
		ytitle("Millions of Poor" " ", size(small))            ///
		xtitle(" " "", size(small)) scheme(s2color)            ///
		graphregion(c(white)) ysize(7) xsize(8)                ///
		ylabel(,labs(small) nogrid angle(verticle)) xlabel(,labs(small)) ///
		legend(order(`legend') si(vsmall))
end

*  ----------------------------------------------------------------------------
*  Categories of income and poverty in LAC
*  ----------------------------------------------------------------------------
program pip_example03
	pip, region(lac) year(last) povline(3.65 6.85 15) clear 
	keep if welfare_type ==2 & year>=2014             // keep income surveys
	keep poverty_line country_code country_name year headcount
	replace poverty_line = poverty_line*100
	replace headcount = headcount*100
	tostring poverty_line, replace format(%12.0f) force
	reshape wide  headcount,i(year country_code country_name ) j(poverty_line) string
	
	gen percentage_0 = headcount365
	gen percentage_1 = headcount685 - headcount365
	gen percentage_2 = headcount1500 - headcount685
	gen percentage_3 = 100 - headcount1500
	
	keep country_code country_name year  percentage_*
	reshape long  percentage_,i(year country_code country_name ) j(category) 
	la define category 0 "Poor LMI (< $3.65)" 1 "Poor UMI ($3.65-$6.85)" ///
		                 2 "Vulnerable ($6.85-$15)" 3 "Middle class (> $15)"
	la val category category
	la var category ""

	local title "Distribution of Income in Latin America and Caribbean, by country"
	local note "Source: PIP, using the latest survey after 2014 for each country."
	local yti  "Population share in each income category (%)"

	graph bar (mean) percentage, inten(*0.7) o(category) o(country_code, ///
	  lab(labsi(small) angle(vertical))) stack asy                      /// 
		blab(bar, pos(center) format(%3.1f) si(tiny))                     /// 
		ti("`title'", si(small)) note("`note'", si(*.7))                  ///
		graphregion(c(white)) ysize(6) xsize(6.5)                         ///
			legend(si(vsmall) r(3))  yti("`yti'", si(small))                ///
		ylab(,labs(small) nogrid angle(0)) scheme(s2color)
end

*  ----------------------------------------------------------------------------
* Trend of Gini 
*  ----------------------------------------------------------------------------
program pip_example04
pip, country(arg gha tha) year(all) clear
	replace gini = gini * 100
	keep if welfare_time  > 1989
	twoway (connected gini welfare_time  if country_code == "ARG")  ///
		(connected gini welfare_time  if country_code == "GHA")       ///
		(connected gini welfare_time  if country_code == "THA"),      /// 
		ytitle("Gini Index" " ", size(small))                   ///
		xtitle(" " "", size(small)) ylabel(,labs(small) nogrid  ///
		angle(verticle)) xlabel(,labs(small))                   ///
		graphregion(c(white)) scheme(s2color)                   ///
		legend(order(1 "Argentina" 2 "Ghana" 3 "Thailand") si(small) row(1)) 
		
end	   

*  ----------------------------------------------------------------------------
*  Growth incidence curves
*  ----------------------------------------------------------------------------
program pip_example05
  pip, country(arg gha tha) year(all)  clear
	reshape long decile, i(country_code welfare_time) j(dec)
	
	egen panelid=group(country_code dec)
	replace welfare_time =int(welfare_time)
	xtset panelid welfare_time 
	
	replace decile=10*decile*mean
	gen g=(((decile/L5.decile)^(1/5))-1)*100
	
	replace g=(((decile/L7.decile)^(1/7))-1)*100 if country_code=="GHA"
	replace dec=10*dec
	
	twoway (sc g dec if welfare_time ==2016 & country_code=="ARG", c(l)) ///
			(sc g dec if welfare_time ==2005 & country_code=="GHA", c(l))    ///
			(sc g dec if welfare_time ==2015 & country_code=="THA", c(l)),   ///
			yti("Annual growth in decile average income (%)" " ",      ///
			size(small))  xlabel(0(10)100,labs(small))                 ///
			xtitle("Decile group", size(small)) graphregion(c(white))  ///
			legend(order(1 "Argentina(2011-2016)"                      ///
			2 "Ghana(1998-2005)" 3 "Thailand(2010-2015)")              ///
			si(vsmall) row(1)) scheme(s2color)

end

*  ----------------------------------------------------------------------------
*  Gini & per capita GDP
*  ----------------------------------------------------------------------------
program pip_example06
	set checksum off
	wbopendata, indicator(NY.GDP.PCAP.PP.KD) long clear
	rename countrycode country_code
	tempfile PerCapitaGDP
	save `PerCapitaGDP', replace
	
	pip, povline(2.15) country(all) year(last) clear iso
	keep country_code country_name year gini
	drop if gini == -1
	* Merge Gini coefficient with per capita GDP
	merge m:1 country_code year using `PerCapitaGDP', keep(match)
	replace gini = gini * 100
	drop if ny_gdp_pcap_pp_kd == .
	twoway (scatter gini ny_gdp_pcap_pp_kd, mfcolor(%0)       ///
		msize(vsmall)) (lfit gini ny_gdp_pcap_pp_kd),           ///
		ylabel(, format(%2.0f)) ///
		ytitle("Gini Index" " ", size(small))                   ///
		xtitle(" " "GDP per Capita per Year (in 2017 USD PPP)", ///
		size(small))  graphregion(c(white)) ysize(5) xsize(7)   ///
		ylabel(,labs(small) nogrid angle(verticle))             ///
		xlabel(,labs(small)) scheme(s2color)                    ///
    legend(order(1 "Gini Index" 2 "Fitted Value") si(small))
end




*  ----------------------------------------------------------------------------
*  Regional Poverty Evolution
*  ----------------------------------------------------------------------------
program define pip_example07
	pip wb, povline(2.15 3.65 6.85) clear
	drop if inlist(region_code, "OHI", "WLD") | year<1990 
	keep poverty_line region_name year headcount
	replace poverty_line = poverty_line*100
	replace headcount = headcount*100
	
	tostring poverty_line, replace format(%12.0f) force
	reshape wide  headcount,i(year region_name) j(poverty_line) string
	
	local title "Poverty Headcount Ratio (1990-2019), by region"

	twoway (sc headcount215 year, c(l) msiz(small))  ///
	       (sc headcount365 year, c(l) msiz(small))  ///
	       (sc headcount685 year, c(l) msiz(small)), ///
	       by(reg,  title("`title'", si(med))        ///
	       	note("Source: PIP", si(vsmall)) graphregion(c(white))) ///
			ylabel(, format(%2.0f)) ///
	       xlab(1990(5)2019 , labsi(vsmall)) xti("Year", si(vsmall))     ///
	       ylab(0(25)100, labsi(vsmall) angle(0))                        ///
	       yti("Poverty headcount (%)", si(vsmall))                      ///
	       leg(order(1 "$2.15" 2 "$3.65" 3 "$6.85") r(1) si(vsmall))        ///
	       sub(, si(small))	scheme(s2color)
end





// ------------------------------------------------------------------------
// National level and longest available series (temporal change in welfare)
// ------------------------------------------------------------------------

program define pip_example08

pip, clear

* keep only national
bysort country_code welfare_type  year: egen _ncover = count(survey_coverage )
gen _tokeepn = ( (inlist(survey_coverage , 3, 4) & _ncover > 1) | _ncover == 1)

keep if _tokeepn == 1

* Keep longest series per country
by country_code welfare_type , sort:  gen _ndtype = _n == 1
by country_code : replace _ndtype = sum(_ndtype)
by country_code : replace _ndtype = _ndtype[_N] // number of welfare_type  per country

duplicates tag country_code year, gen(_yrep)  // duplicate year

bysort country_code welfare_type : egen _type_length = count(year) // length of type series
bysort country_code: egen _type_max = max(_type_length)   // longest type series
replace _type_max = (_type_max == _type_length)

* in case of same length in series, keep consumption
by country_code _type_max, sort:  gen _ntmax = _n == 1
by country_code : replace _ntmax = sum(_ntmax)
by country_code : replace _ntmax = _ntmax[_N]  // number of welfare_type  per country


gen _tokeepl = ((_type_max == 1 & _ntmax == 2) | ///
	             (welfare_type  == 1 & _ntmax == 1 & _ndtype == 2) | ///
	             _yrep == 0)

keep if _tokeepl == 1
drop _*

end

// ------------------------------------------------------------------------
// National level and longest available series of same welfare type
// ------------------------------------------------------------------------

program define pip_example09

pip, clear

* keep only national
bysort country_code welfare_type  year: egen _ncover = count(survey_coverage )
gen _tokeepn = ( (inlist(survey_coverage , 3, 4) & _ncover > 1) | _ncover == 1)

keep if _tokeepn == 1
* Keep longest series per country
by country_code welfare_type , sort:  gen _ndtype = _n == 1
by country_code : replace _ndtype = sum(_ndtype)
by country_code : replace _ndtype = _ndtype[_N] // number of welfare_type  per country


bysort country_code welfare_type : egen _type_length = count(year)
bysort country_code: egen _type_max = max(_type_length)
replace _type_max = (_type_max == _type_length)

* in case of same length in series, keep consumption
by country_code _type_max, sort:  gen _ntmax = _n == 1
by country_code : replace _ntmax = sum(_ntmax)
by country_code : replace _ntmax = _ntmax[_N]  // max 


gen _tokeepl = ((_type_max == 1 & _ntmax == 2) | ///
	             (welfare_type  == 1 & _ntmax == 1 & _ndtype == 2)) | ///
               _ndtype == 1

keep if _tokeepl == 1
drop _*

end


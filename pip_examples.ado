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
program define pcn_example01

	pip wb,  clear

	keep if reporting_year > 1989
	keep if region_code == "WLD"	
  gen poorpop = headcount*reporting_pop 
  gen hcpercent = round(headcount*100, 0.1) 
  gen poorpopround = round(poorpop, 1)

  twoway (sc hcpercent reporting_year, yaxis(1) mlab(hcpercent)           ///
           mlabpos(7) mlabsize(vsmall) c(l))                    ///
         (sc poorpopround reporting_year, yaxis(2) mlab(poorpopround)     ///
           mlabsize(vsmall) mlabpos(1) c(l)),                   ///
         yti("Poverty Rate (%)" " ", size(small) axis(1))       ///
         ylab(0(10)40, labs(small) nogrid angle(0) axis(1))     ///
         yti("Number of Poor (million)", size(small) axis(2))   ///
         ylab(0(400)2000, labs(small) angle(0) axis(2))         ///
         xlabel(,labs(small)) xtitle("Year", size(small))       ///
         graphregion(c(white)) ysize(5) xsize(5)                ///
         legend(order(                                          ///
         1 "Poverty Rate (% of people living below $1.90)"      ///
         2 "Number of people who live below $1.90") si(vsmall)  ///
         row(2)) scheme(s2color)

end
*  ----------------------------------------------------------------------------
*  Millions of poor by region (reference year) 
*  ----------------------------------------------------------------------------
program define pcn_example02
	pip wb, clear
	keep if reporting_year > 1989
	gen poorpop = headcount * reporting_pop 
	gen hcpercent = round(headcount*100, 0.1) 
	gen poorpopround = round(poorpop, 1)
	encode region, gen(rid)

	levelsof rid, local(regions)
	foreach region of local regions {
		local legend = `"`legend' `region' "`: label rid `region''" "'
	}

	keep reporting_year rid poorpop
	reshape wide poorpop,i(reporting_year) j(rid)
	foreach i of numlist 2(1)7{
		egen poorpopacc`i'=rowtotal(poorpop1 - poorpop`i')
	}

	twoway (area poorpop1 reporting_year)                              ///
		(rarea poorpopacc2 poorpop1 reporting_year)                      ///
		(rarea poorpopacc3 poorpopacc2 reporting_year)                   ///
		(rarea poorpopacc4 poorpopacc3 reporting_year)                   ///
		(rarea poorpopacc5 poorpopacc4 reporting_year)                   ///
		(rarea poorpopacc6 poorpopacc5 reporting_year)                   ///
		(rarea poorpopacc7 poorpopacc6 reporting_year)                   ///
		(line poorpopacc7 reporting_year, lwidth(midthick) lcolor(gs0)), ///
		ytitle("Millions of Poor" " ", size(small))            ///
		xtitle(" " "", size(small)) scheme(s2color)            ///
		graphregion(c(white)) ysize(7) xsize(8)                ///
		ylabel(,labs(small) nogrid angle(verticle)) xlabel(,labs(small)) ///
		legend(order(`legend') si(vsmall))
end

*  ----------------------------------------------------------------------------
*  Categories of income and poverty in LAC
*  ----------------------------------------------------------------------------
program pcn_example03
	pip, region(lac) year(last) povline(3.2 5.5 15) clear 
	keep if welfare_type ==2 & reporting_year>=2014             // keep income surveys
	keep poverty_line country_code countryname reporting_year headcount
	replace poverty_line = poverty_line*100
	replace headcount = headcount*100
	tostring poverty_line, replace format(%12.0f) force
	reshape wide  headcount,i(reporting_year country_code countryname ) j(poverty_line) string
	
	gen percentage_0 = headcount320
	gen percentage_1 = headcount550 - headcount320
	gen percentage_2 = headcount1500 - headcount550
	gen percentage_3 = 100 - headcount1500
	
	keep country_code countryname reporting_year  percentage_*
	reshape long  percentage_,i(reporting_year country_code countryname ) j(category) 
	la define category 0 "Poor LMI (< $3.2)" 1 "Poor UMI ($3.2-$5.5)" ///
		                 2 "Vulnerable ($5.5-$15)" 3 "Middle class (> $15)"
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
program pcn_example04
pip, country(arg gha tha) year(all) clear
	replace gini = gini * 100
	keep if survey_year  > 1989
	twoway (connected gini survey_year  if country_code == "ARG")  ///
		(connected gini survey_year  if country_code == "GHA")       ///
		(connected gini survey_year  if country_code == "THA"),      /// 
		ytitle("Gini Index" " ", size(small))                   ///
		xtitle(" " "", size(small)) ylabel(,labs(small) nogrid  ///
		angle(verticle)) xlabel(,labs(small))                   ///
		graphregion(c(white)) scheme(s2color)                   ///
		legend(order(1 "Argentina" 2 "Ghana" 3 "Thailand") si(small) row(1)) 
		
end	   

*  ----------------------------------------------------------------------------
*  Growth incidence curves
*  ----------------------------------------------------------------------------
program pcn_example05
  pip, country(arg gha tha) year(all)  clear
	reshape long decile, i(country_code survey_year ) j(dec)
	
	egen panelid=group(country_code dec)
	replace survey_year =int(survey_year )
	xtset panelid survey_year 
	
	replace decile=10*decile*mean
	gen g=(((decile/L5.decile)^(1/5))-1)*100
	
	replace g=(((decile/L7.decile)^(1/7))-1)*100 if country_code=="GHA"
	replace dec=10*dec
	
	twoway (sc g dec if survey_year ==2016 & country_code=="ARG", c(l)) ///
			(sc g dec if survey_year ==2005 & country_code=="GHA", c(l))    ///
			(sc g dec if survey_year ==2015 & country_code=="THA", c(l)),   ///
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
program pcn_example06
	set checksum off
	wbopendata, indicator(NY.GDP.PCAP.PP.KD) long clear
	tempfile PerCapitaGDP
	save `PerCapitaGDP', replace
	
	pip, povline(1.9) country(all) year(last) clear iso
	keep country_code countryname reporting_year gini
	drop if gini == -1
	* Merge Gini coefficient with per capita GDP
	merge m:1 country_code reporting_year using `PerCapitaGDP', keep(match)
	replace gini = gini * 100
	drop if ny_gdp_pcap_pp_kd == .
	twoway (scatter gini ny_gdp_pcap_pp_kd, mfcolor(%0)       ///
		msize(vsmall)) (lfit gini ny_gdp_pcap_pp_kd),           ///
		ytitle("Gini Index" " ", size(small))                   ///
		xtitle(" " "GDP per Capita per Year (in 2011 USD PPP)", ///
		size(small))  graphregion(c(white)) ysize(5) xsize(7)   ///
		ylabel(,labs(small) nogrid angle(verticle))             ///
		xlabel(,labs(small)) scheme(s2color)                    ///
    legend(order(1 "Gini Index" 2 "Fitted Value") si(small))
end




*  ----------------------------------------------------------------------------
*  Regional Poverty Evolution
*  ----------------------------------------------------------------------------
program define pcn_example07
	pip wb, povline(1.9 3.2 5.5) clear
	drop if inlist(region_code, "OHI", "WLD") | reporting_year<1990 
	keep poverty_line region reporting_year headcount
	replace poverty_line = poverty_line*100
	replace headcount = headcount*100
	
	tostring poverty_line, replace format(%12.0f) force
	reshape wide  headcount,i(reporting_year region) j(poverty_line) string
	
	local title "Poverty Headcount Ratio (1990-2015), by region"

	twoway (sc headcount190 reporting_year, c(l) msiz(small))  ///
	       (sc headcount320 reporting_year, c(l) msiz(small))  ///
	       (sc headcount550 reporting_year, c(l) msiz(small)), ///
	       by(reg,  title("`title'", si(med))        ///
	       	note("Source: PIP", si(vsmall)) graphregion(c(white))) ///
	       xlab(1990(5)2015 , labsi(vsmall)) xti("Year", si(vsmall))     ///
	       ylab(0(25)100, labsi(vsmall) angle(0))                        ///
	       yti("Poverty headcount (%)", si(vsmall))                      ///
	       leg(order(1 "$1.9" 2 "$3.2" 3 "$5.5") r(1) si(vsmall))        ///
	       sub(, si(small))	scheme(s2color)
end





// ------------------------------------------------------------------------
// National level and longest available series (temporal change in welfare)
// ------------------------------------------------------------------------

program define pcn_example08

pip, clear

* keep only national
bysort country_code welfare_type  reporting_year: egen _ncover = count(survey_coverage )
gen _tokeepn = ( (inlist(survey_coverage , 3, 4) & _ncover > 1) | _ncover == 1)

keep if _tokeepn == 1

* Keep longest series per country
by country_code welfare_type , sort:  gen _ndtype = _n == 1
by country_code : replace _ndtype = sum(_ndtype)
by country_code : replace _ndtype = _ndtype[_N] // number of welfare_type  per country

duplicates tag country_code reporting_year, gen(_yrep)  // duplicate year

bysort country_code welfare_type : egen _type_length = count(reporting_year) // length of type series
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

program define pcn_example09

pip, clear

* keep only national
bysort country_code welfare_type  reporting_year: egen _ncover = count(survey_coverage )
gen _tokeepn = ( (inlist(survey_coverage , 3, 4) & _ncover > 1) | _ncover == 1)

keep if _tokeepn == 1
* Keep longest series per country
by country_code welfare_type , sort:  gen _ndtype = _n == 1
by country_code : replace _ndtype = sum(_ndtype)
by country_code : replace _ndtype = _ndtype[_N] // number of welfare_type  per country


bysort country_code welfare_type : egen _type_length = count(reporting_year)
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


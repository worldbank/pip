## [Home](index.md) --- [Get Started](get_started.md) --- [Visualizations examples](vis.md) --- [Help file](help_file.md) 

# Visualization Examples

## Global Poverty Trends 1990-2020 (reference year)

```stata
pip wb,  clear 
	
local years = "1991|1993|1996|1999|2002|2005|2008|2010|2011|2012|2013|2015|2017|2019|2020"
keep if regexm(strofreal(year), "`years'")
keep if region_code == "WLD"	

gen poorpop = headcount * population/ 1000000 
gen hcpercent = round(headcount*100, 0.1) 
gen poorpopround = round(poorpop, 1)

twoway (sc hcpercent year, ///
       yaxis(1) mlab(hcpercent) mlabpos(7) mlabsize(vsmall) c(l)) ///
       (sc poorpopround year,  ///
       yaxis(2) mlab(poorpopround) mlabsize(vsmall) mlabpos(1) c(l)), ///
  yti("Poverty Rate (%)" " ", size(small) axis(1))  ///
  ylab(0(10)40, labs(small) nogrid angle(0) axis(1))  ///
  yti("Number of Poor (million)", size(small) axis(2)) ///
  ylab(0(400)2000, labs(small) angle(0) axis(2))  ///
  xlabel(,labs(small)) xtitle("Year", size(small))  ///
  graphregion(c(white)) ysize(5) xsize(5)  ///
xlabel(1990(5)2020) xscale(range(1990 2020) noextend)  ///
  legend(order( ///
  1 "Poverty Rate (% of people living below $1.90)"  ///
  2 "Number of people who live below $1.90") si(vsmall) row(2)) scheme(s2color)
```

<center>
<img src="/pip/img/worldpoverty.png" 
alt="worldpoverty" width="550" height="500" />
</center>

## Millions of poor by region (reference year) 

```stata
pip wb, clear
keep if year > 1989
local years = "1990|1993|1996|1999|2002|2005|2008|2010|2011|2012|2013|2015|2017|2019|2020"
gen poorpop = headcount * population/ 1000000 
gen hcpercent = round(headcount*100, 0.1) 
gen poorpopround = round(poorpop, 1)
encode region_name, gen(rid)

levelsof rid, local(regions)
foreach region_name of local regions {
	local legend = `"`legend' `region_name' "`: label rid `region_name''" "'
}

keep year rid poorpop
reshape wide poorpop,i(year) j(rid)
foreach i of numlist 2(1)7{
	egen poorpopacc`i'=rowtotal(poorpop1 - poorpop`i')
}


twoway (area poorpop1 year) ///
(rarea poorpopacc2 poorpop1 year) ///
(rarea poorpopacc3 poorpopacc2 year) ///
(rarea poorpopacc4 poorpopacc3 year) ///
(rarea poorpopacc5 poorpopacc4 year) ///
(rarea poorpopacc6 poorpopacc5 year) ///
(rarea poorpopacc7 poorpopacc6 year) ///
(line poorpopacc7 year, lwidth(midthick) lcolor(gs0)), ///
ytitle("Millions of Poor" " ", size(small))  ///
xtitle(" " "", size(small)) scheme(s2color)  ///
graphregion(c(white)) ysize(7) xsize(8)  ///
ylabel(,labs(small) nogrid angle(verticle)) xlabel(,labs(small)) ///
legend(order(`legend') si(vsmall) symxsize(*.5) symysize(*.5))
```

<center>
<img src="/pip/img/Millionsofpoor.png" 
alt="Millionsofpoor" width="550" height="500" />
</center>

## Distribution of Income in Latin America and Caribbean, by country

```stata
pip, region(lac) year(last) povline(3.2 5.5 15) fillgaps clear  
keep if welfare_type==2 & year>=2014 // keep income surveys
keep poverty_line country_code country_name year headcount
replace poverty_line = poverty_line*100
replace headcount = headcount*100
tostring poverty_line, replace format(%12.0f) force
reshape wide  headcount,i(year country_code country_name ) j(poverty_line) string
gen percentage_0 = headcount320
gen percentage_1 = headcount550 - headcount320
gen percentage_2 = headcount1500 - headcount550
gen percentage_3 = 100 - headcount1500
keep country_code country_name year  percentage_*
reshape long  percentage_,i(year country_code country_name ) j(category) 
la define category 0 "Poor LMI (<$3.2)" 1 "Poor UMI ($3.2-$5.5)" ///
2 "Vulnerable ($5.5-$15)" 3 "Middle class (>$15)"
la val category category
la var category ""

graph bar (mean) percentage, inten(*0.7) o(category) ///
o(country_code, lab(labsi(small) angle(vertical))) stack asy /// 
blab(bar, pos(center) format(%3.1f) size(8pt)) /// 
ti("Distribution of Income in Latin America and Caribbean, by country", si(small)) ///
note("Source: PIP, using the latest survey after 2014 for each country. ", si(*.7)) ///
graphregion(c(white)) ysize(6) xsize(6.5) legend(si(vsmall) r(3))  ///
yti("Population share in each income category (%)", si(small)) ///
ylab(,labs(small) nogrid angle(0)) scheme(s2color)
```
<center>
<img src="/pip/img/LAC.png" 
alt="LAC" width="550" height="500" />
</center>


## Growth Incidence Curves  for Chile, Ghana, and Togo

```stata
 pip, country(chl gha tgo) year(all)  clear
 reshape long decile, i(country_code welfare_time) j(dec)
 egen panelid = group(country_code dec)
 replace welfare_time = int(welfare_time)
 xtset panelid welfare_time
 replace decile = 10*decile*mean
 gen g =(((decile/L6.decile)^(1/6))-1)*100		
 replace g =(((decile/L7.decile)^(1/7))-1)*100 if country_code =="GHA"
 replace g =(((decile/L4.decile)^(1/4))-1)*100 if country_code =="TGO"

 replace dec=10*dec
 
 twoway (sc g dec if welfare_time == 2017 & country_code == "CHL", c(l)) ///
 		(sc g dec if welfare_time == 2005 & country_code == "GHA", c(l))    ///
 		(sc g dec if welfare_time == 2015 & country_code == "TGO", c(l)),   ///
 		yti("Annual growth in decile average income (%)" " ",      ///
 		size(small))  xlabel(0(10)100,labs(small))                 ///
 		xtitle("Decile group", size(small)) graphregion(c(white))  ///
 		legend(order(1 "Chile (2011-2017)"                      ///
 		2 "Ghana(1998-2005)" 3 "Togo (2011-2015)")              ///
 		si(vsmall) row(1)) scheme(s2color)
```
<center>
<img src="/pip/img/Income_growth.png" 
alt="Income_growth" width="550" height="500" />
</center>


## Gini Indices for Chile, Ghana, and Togo

```stata
pip,  country(chl gha tgo) year(all) clear
	replace gini = gini * 100
	keep if welfare_time > 1989
	twoway (connected gini welfare_time if country_code == "CHL")  ///
		(connected gini welfare_time if country_code == "GHA")       ///
		(connected gini welfare_time if country_code == "TGO"),      /// 
		ytitle("Gini Index" " ", size(small))                   ///
		xtitle(" " "", size(small)) ylabel(,labs(small) nogrid  ///
		angle(verticle)) xlabel(,labs(small))                   ///
		graphregion(c(white)) scheme(s2color)                   ///
		legend(order(1 "Chile" 2 "Ghana" 3 "Togo") si(small) row(1)) 
```

<center>
<img src="/pip/img/Gini.png" 
alt="Gini" width="550" height="500" />
</center>

## Relationship between inequality and GDP

```stata
set checksum off
wbopendata, indicator(NY.GDP.PCAP.PP.KD) long clear
rename countrycode country_code
tempfile PerCapitaGDP
save `PerCapitaGDP', replace

pip, povline(1.9) country(all) year(last) clear
keep country_code country_name year gini
drop if gini == -1
* Merge Gini coefficient with per capita GDP
merge m:1 country_code year using `PerCapitaGDP', keep(match)
replace gini = gini * 100
drop if ny_gdp_pcap_pp_kd == .
twoway (scatter gini ny_gdp_pcap_pp_kd, mfcolor(%0) ///
msize(vsmall)) (lfit gini ny_gdp_pcap_pp_kd), ///
ytitle("Gini Index" " ", size(small))  ///
xtitle(" " "GDP per Capita per Year (in 2011 USD PPP)", size(small))  ///
graphregion(c(white)) ysize(5) xsize(7)  ///
ylabel(,labs(small) nogrid angle(verticle)) xlabel(,labs(small)) ///
legend(order(1 "Gini Index" 2 "Fitted Value") si(small)) scheme(s2color)
````
<center>
<img src="/pip/img/Gini&GDP.png" 
alt="Gini&GDP" width="550" height="500" />
</center>


## Distribution of Income in Sub-Saharan Africa and East Asia and Pacific over time

```stata
pip wb, povline(1.9 3.2 5.5 15) clear
keep if year>=1995 
keep poverty_line region_code region_name year headcount
replace poverty_line = poverty_line*100
replace headcount = headcount*100
tostring poverty_line, replace format(%12.0f) force
reshape wide  headcount,i(year region_code region_name) j(poverty_line) string
gen percentage_0 = headcount190
gen percentage_1 = headcount320 - headcount190 
gen percentage_2 = headcount550 - headcount320
gen percentage_3 = headcount1500 - headcount550
gen percentage_4 = 100 - headcount1500
keep region_code region_name year  percentage_*
reshape long  percentage_,i(year region_code region_name) j(category) 
la define category 0 "Poor IPL (<$1.9)" 1 "Poor LMIC ($1.9-$3.2)" 2 "Poor UMIC ($3.2-$5.5)" ///
3 "$5.5-$15" 4 "Middle class (>$15)"
la val category category
la var category ""

graph bar (mean) percentage if region_code=="SSA" & (year>=1995 & year<=2019), inten(*0.7) o(category) ///
o(year, lab(labsi(small) angle(vertical))) stack asy /// 
blab(bar, pos(center) format(%3.1f) size(7pt)) /// 
ti("Distribution of Income in Sub-Saharan Africa over time", si(small)) ///
graphregion(c(white)) ysize(6) xsize(6.5) legend(si(vsmall) r(2) symxsize(*.4))  ///
yti("Population share in each income category (%)", si(small)) ///
ylab(,labs(small) nogrid angle(0)) scheme(s2color) name(ssa, replace)
graph export ssa.png, as(png) hei(1000) replace

graph bar (mean) percentage if region_code=="EAP" & (year>=1995 & year<=2019), inten(*0.7) o(category) ///
o(year, lab(labsi(small) angle(vertical))) stack asy /// 
blab(bar, pos(center) format(%3.1f) size(7pt)) /// 
ti("Distribution of Income in East Asia and Pacific over time", si(small)) ///
graphregion(c(white)) ysize(6) xsize(6.5) legend(si(vsmall) r(2) symxsize(*.4)) ///
yti("Population share in each income category (%)", si(small)) ///
ylab(,labs(small) nogrid angle(0)) scheme(s2color) name(eap, replace)
graph export eap.png, as(png) hei(1000) replace
```


<center>
<img src="/pip/img/ssa.png" 
alt="Gini&GDP" width="550" height="500" />
<img src="/pip/img/eap.png" 
alt="Gini&GDP" width="550" height="500" />
</center>



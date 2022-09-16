## [Home](index.md) --- [Get Started](get_started.md) --- [Visualizations examples](vis.md) --- [Help file](help_file.md) 

			Title

					pip --         Access Global Poverty and Inequality measures from the World Bank's new Poverty and Inequality Platform (PIP).  The pip command allows Stata users to estimate the poverty and
								 inequality indicators available in the PIP platform. PIP contains more indicators than its predecessor(povcalnet).  However, to make the platform compatible with povcalnet, the same
								 indicators are also available in pip. See below the list comparing pip and povcalnet indicators.
					Website:       https://worldbank.github.io/pip/
			Syntax

				  pip [subcommand], [Parameters Options]

				Description of parameter options

				Estimations                  Description
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				  country(3-letter code)     List of country code (accepts multiples) or all.  Cannot be used with option region()
				  region(WB code)            List of region code (accepts multiple) or all.  Cannot be used with option country()
				  coverage(string)           Loads coverage level ("national", "urban", "rural", "all"). Default "all".
				  year(numlist|string)       List of years (accepts up to 10), or all, or last. Default "all".
				  povline(#)                 List of poverty lines (in 2011 PPP-adjusted USD) to calculate poverty measures (accepts up to 5). Default is 1.9.
				  popshare(#)                List of population shares to calculate poverty lines (in 2011 PPP-adjusted USD) and poverty measures. No default. Do not combine with povline
				  fillgaps                   Loads all countries used to create regional aggregates.
				  ppp(#)                     Allows the selection of PPP.

				Version                      Description
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				  server(string)*            Name of a server to query on (e.g, prod, dev, qa). See description of each server here.
				  identity(string)*          Version of data to run the query on (e.g., prod, int, test).
				  ppp_year(#)                PPP round (eg., 2005, 2011, 2017).
				  release(numlist)           PIP data release date.

				Operational                  Description
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				  information                Presents a clickable version of the available surveys, countries and regions.
				  clear                      Replaces data in memory.
				  querytimes(integer)        Number of times the API is hit before defaulting to failure.  Default is 5. Advance option. Use only if Internet connection is poor.
				  table(string)              Loads one auxiliary table, this option is used along with the tables subcommand.

				subcommands                  Description
				----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				  information                Presents a clickable version of the available surveys, countries and regions. Same as option information
				  cl                         (temporally disabled) country-level query that changes the default combinatorial arrangement of parameters for a one-on-one correspondence.  See a detailed explanation 
											   below.
				  wb                         Downloads World Bank's regional and global aggregation.
				  tables                     Provides clickable list of auxiliary tables for download.
				  cleanup                    Deletes all pip data from current stata memory.


				*Note: The server() and identity() options are available internally only for the Bank staff via the Bank’s intranet.  For detailed description of the server() and identity() options see here.

				Note: pip requires Internet connection.

			Sections

				Sections are presented under the following headings:

							Command description
							Parameters description
							Options description
							Subcommands
							List of pip and povcalnet variables
							Stored results
							Examples
							Disclaimer
							References
							Acknowledgments
							Authors
							Contact
							How to cite
							Region and country codes

													(Go up to Sections Menu)
			Description

				The pip command allows Stata users to compute poverty and inequality indicators for over 160 countries and regions in the World Bank's database of household surveys. It has the same functionality as the
				PIP website.  PIP is a computational tool that allows users to conduct country-specific, cross-country, as well as global and regional poverty analyses. Users are able estimate rates over time and at
				any poverty line specified.

				PIP is managed jointly by the Data and Research Groups in the World Bank's Development Economics Division. It draws heavily upon a strong collaboration with the Poverty and Equity Global Practice, which
				is responsible for the gathering and harmonization of the underlying survey data.

				pip reports an ample range of measures for poverty (at chosen poverty line) and inequality, including the mean and median welfare (see full list of indicators below).

				The underlying welfare aggregate is the per capita household income or consumption expressed in 2011 PPP-adjusted USD. Poverty lines are expressed in daily amounts, as well as the means and medians. For
				more information on the definition of the indicators, click here.  For more information on the methodology, click here.

			Type of calculations:

				The pip API allows two types of calculations:

				Survey-year: Will load poverty measures for a reference year that is common across countries. Regional and global aggregates are calculated only for reference-years. Countries without a survey in the
					....

				reference-year: are extrapolated or interpolated using national accounts growth rates, and assuming distribution-neutrality.  pip wb returns the global and regional poverty aggregates used by the World
					Bank.

					Important: the Option fillgaps reports the underlying lined-up country estimates for a reference-year. Poverty measures calculated for both survey-years and reference-years include Headcount ratio,
					Poverty Gap, and Squared Poverty Gap.  Inequality measures, including the Gini index, mean log deviation and decile shares, are calculated only in survey-years where microdata is available.
					Inequality measures are not reported for reference-years.


													(Go up to Sections Menu)
			Parameters description

				country(string) Countries and Economies Abbreviations.  If specified with year(string), this option will return all the specific countries and years for which there is actual survey data.  When
					selecting multiple countries, use the corresponding three-letter codes separated by spaces. The option all is a shorthand for calling all countries.

				region(string) Regions Abbreviations If specified with year(string), this option will return all the specific countries and years that belong to the specified region(s).  For example, region(LAC) will
					return all countries in Latin America and the Caribbean for which there's an actual survey in the given years.  When selecting multiple regions, use the corresponding three-letter codes separated by
					spaces. The option all is a shorthand for calling all regions, which is equivalent to calling all countries.

				year(#) Four digit years are accepted. When selecting multiple years, use spaced to separate them. The option all is a shorthand for calling all possible years, while the last option will download the
					latest available year for each country.

				povline(#) The poverty lines for which the poverty measures will be calculated.  When selecting multiple poverty lines, use less than 4 decimals and separate each value with spaces. If left empty, the
					default poverty line of $1.9 is used.  Poverty lines are expressed in 2011 PPP-adjusted USD per capita per day.

				popshare(#) The desired population share (headcount) for which the poverty lines as poverty measures will be calculated.  This has not default, and should not be combined with povline.  The resulting
					poverty lines are expressed in 2011 PPP-adjusted USD per capita per day.

													(Go up to Sections Menu)
			Options description

				fillgaps Loads all country-level estimates that are used to create the aggregates in the reference years. This means that estimates use the same reference years as aggregate estimates.

					Note: Countries without a survey in the reference-year have been extrapolated or interpolated using national accounts growth rates and assuming distribution-neutrality (see Chapter 6 here).
					Therefore, changes at the country-level from one reference year to the next need to be interpreted carefully and may not be the result of a new household survey.

				PPP(#) Allows the selection of PPP exchange rate. This option only works if one, and only one, country is selected.

				coverage(string) Selects coverage level of estimates. By default, all coverage levels are loaded, but the user may select "national", "urban", or "rural".  Only one level of coverage can be selected per
					query.

				information Presents a clickable version of the available surveys, countries and regions. Selecting countries from the menu loads the survey-year estimates.  Choosing regions loads the regional
					aggregates in the reference years.

					Note: If option clear is added, data in memory is replaced with a pip guidance database. If option clear is not included, pip preserves data in memory but displays a clickable interface of survey
					availability in the results window.

				table Allows us to load one auxiliary table, this option is used along with tables subcommand. pip tables, table(countries)

				clear replaces data in memory.

													(Go up to Sections Menu)
			Subcommands

				info Same as option info above.

				cl Stands for country-level queries. It changes combinatorial query of parameters for one-on-one correspondence of parameters. See above for a detailed explanation.

				tables Allows us to download any auxiliary table of the PIP project.  Default tables command pip tables provides us list of auxiliary tables for download from PROD server in INT folder based on PPP
					2011.  We can also specify the server, version of the data, and PPP year as pip tables, server(prod) identity(int) ppp_year(2011)

				cleanup Allows us to delete all PIP data from Stata's memory.  The pip wrapper makes use of the `frames` feature—available since Stata 16—to store a lot of information in memory.  This is in part the
					reason why the first call of pip in a Stata new session is relatively slower to subsequent calls.  We may have seen the message below before closing Stata.  That is perfectly normal and should not
					cause any concern. Just click “Exist without saving.” However, you can delete all PIP data in memory using command pip cleanup

			pip makes use of the global "${pip_query}".


			Stored results

				pip stores the following in r(). Suffix _# refers to the number of poverty lines included in povlines():

				queries        
				  r(query_ys_#)              Years
				  r(query_pl_#)              Poverty lines
				  r(query_ct_#)              Countries
				  r(query_cv_#)              Coverages
				  r(query_ds_#)              Whether aggregation was used
				  r(query_#)                 concatenation of the queries above

				API parts      
				  r(server)                  Protocol (http://) and server name
				  r(site_name)               Site names
				  r(handler)                 Action handler
				  r(base)                    concatenation of server, site_name, and handler

				additional info
				  r(queryfull_#)             Complete query
				  r(npl)                     Number of poverty lines
				  pip_query                  Global macro with query information in case pip fails.  "${pip_query}" to display

													(Go up to Sections Menu)
			List of pip and povcalnet variables

				The following is a comparative list of variables available in pip and povcalnet:

							-------------------------------------------
							PIP variables          povcalnet variables
							--------------------   --------------------
							country_code           countrycode
							country_name           countryname
							region_code            regioncode
							region_name            
							survey_coverage        coveragetype
							survey_comparability   
							survey_acronym         
							survey_time                           
							year                   year
							welfare_time           datayear
							welfare_type           datatype
							poverty_line           povertyline
							mean                   mean
							headcount              headcount
							poverty_gap            povgap
							poverty_severity       povgapsqr
							watts                  watts 
							gini                   gini
							median                 median
							mld                    mld
							polarization           polarization
							population             population
							decile1                decile1
							decile2                decile2
							decile3                decile3
							decile4                decile4
							decile5                decile5
							decile6                decile6
							decile7                decile7
							decile8                decile8
							decile9                decile9
							decile10               decile10               
							cpi                    
							ppp                    ppp
							gdp                    
							hfce                   
							is_interpolated        isinterpolated
							distribution_type      usemicrodata
							reporting_level        
							comparable_spell       
							pop_in_poverty         
							-------------------------------------------



			Examples
													(Go up to Sections Menu)

					+--------------------+
				----+  1. Basic examples +--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

				1.1. Load latest available survey-year estimates for Colombia and Argentina

					pip, country(col arg) year(last) clear

				1.2. Load clickable menu

					pip, info

				1.3. Load only urban coverage level

					pip, country(all) coverage("urban") clear


					+----------------------------------------------------+
				----+  2. inIllustration of differences between queries  +------------------------------------------------------------------------------------------------------------------------------------------------

				2.1. Country estimation at $1.9 in 2015. Since there are no surveys in ARG and IND in 2015, results are loaded for COL and BRA

					pip, country(COL BRA ARG IND) year(2015) clear

				2.2. fill-gaps. Filling gaps for ARG and IND. Only works for reference years.

					pip, country(COL BRA ARG IND) year(2015) clear fillgaps

				2.4. World Bank aggregation (country() is not available)

					pip wb, clear year(2015)
					pip wb, clear region(SAR LAC)
					pip wb, clear // all reference years

				2.5. One-on-one query.

					pip cl, country(COL BRA ARG IND) year(2011) clear coverage("national national urban national")

					+-------------------------------------------------+
				----+  3. Samples uniquely identified by country/year +---------------------------------------------------------------------------------------------------------------------------------------------------

					3.1 National coverage (when available) and longest possible time series for each country, even if welfare type changes from one year to another.


					. pip, clear

					* keep only national
					. bysort countrycode datatype year: egen _ncover = count(coveragetype)
					. gen _tokeepn = ( (inlist(coveragetype, 3, 4) & _ncover > 1) | _ncover == 1)

					. keep if _tokeepn == 1

					* Keep longest series per country
					. by countrycode datatype, sort:  gen _ndtype = _n == 1
					. by countrycode : replace _ndtype = sum(_ndtype)
					. by countrycode : replace _ndtype = _ndtype[_N] // number of datatype per country

					. duplicates tag countrycode year, gen(_yrep)  // duplicate year

					.bysort countrycode datatype: egen _type_length = count(year) // length of type series
					.bysort countrycode: egen _type_max = max(_type_length)   // longest type series
					.replace _type_max = (_type_max == _type_length)

					* in case of same length in series, keep consumption
					. by countrycode _type_max, sort:  gen _ntmax = _n == 1
					. by countrycode : replace _ntmax = sum(_ntmax)
					. by countrycode : replace _ntmax = _ntmax[_N]  // number of datatype per country


					. gen _tokeepl = ((_type_max == 1 & _ntmax == 2) | ///
					.                (datatype == 1 & _ntmax == 1 & _ndtype == 2) | ///
					.                _yrep == 0)
					. 
					. keep if _tokeepl == 1
					. drop _*

				  (click to run)

					3.2 National coverage (when available) and longest possible time series for each country, restrict to same welfare type throughout.


					. pip, clear
					. bysort countrycode datatype year: egen _ncover = count(coveragetype)
					. gen _tokeepn = ( (inlist(coveragetype, 3, 4) & _ncover > 1) | _ncover == 1)

					. keep if _tokeepn == 1
					* Keep longest series per country
					. by countrycode datatype, sort:  gen _ndtype = _n == 1
					. by countrycode : replace _ndtype = sum(_ndtype)
					. by countrycode : replace _ndtype = _ndtype[_N] // number of datatype per country


					. bysort countrycode datatype: egen _type_length = count(year)
					. bysort countrycode: egen _type_max = max(_type_length)
					. replace _type_max = (_type_max == _type_length)

					* in case of same length in series, keep consumption
					. by countrycode _type_max, sort:  gen _ntmax = _n == 1
					. by countrycode : replace _ntmax = sum(_ntmax)
					. by countrycode : replace _ntmax = _ntmax[_N]  // max 


					. gen _tokeepl = ((_type_max == 1 & _ntmax == 2) | ///
					.               (datatype == 1 & _ntmax == 1 & _ndtype == 2)) | ///
					.               _ndtype == 1

					. keep if _tokeepl == 1
					. drop _*

				  (click to run)

					+-------------------------+
				----+  4. Analytical examples +---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

					4.1 Graph of trend in poverty headcount ratio and number of poor for the world


					. pip wb,  clear

					. keep if year > 1989
					. keep if regioncode == "WLD"   
					. gen poorpop = headcount*population 
					. gen hcpercent = round(headcount*100, 0.1) 
					. gen poorpopround = round(poorpop, 1)

					. twoway (sc hcpercent year, yaxis(1) mlab(hcpercent)           ///
					.          mlabpos(7) mlabsize(vsmall) c(l))                    ///
					.        (sc poorpopround year, yaxis(2) mlab(poorpopround)     ///
					.          mlabsize(vsmall) mlabpos(1) c(l)),                   ///
					.        yti("Poverty Rate (%)" " ", size(small) axis(1))       ///
					.        ylab(0(10)40, labs(small) nogrid angle(0) axis(1))     ///
					.        yti("Number of Poor (million)", size(small) axis(2))   ///
					.        ylab(0(400)2000, labs(small) angle(0) axis(2))         ///
					.        xlabel(,labs(small)) xtitle("Year", size(small))       ///
					.        graphregion(c(white)) ysize(5) xsize(5)                ///
					.        legend(order(                                          ///
					.        1 "Poverty Rate (% of people living below $1.90)"      ///
					.        2 "Number of people who live below $1.90") si(vsmall)  ///
					.        row(2)) scheme(s2color)
					
				  (click to run)

					4.2 Graph of trends in poverty headcount ratio by region, multiple poverty lines ($1.9, $3.2, $5.5)

			   
					. pip wb, povline(1.9 3.2 5.5) clear
					. drop if inlist(regioncode, "OHI", "WLD") | year<1990 
					. keep povertyline region year headcount
					. replace povertyline = povertyline*100
					. replace headcount = headcount*100
					
					. tostring povertyline, replace format(%12.0f) force
					. reshape wide  headcount,i(year region) j(povertyline) string
					
					. local title "Poverty Headcount Ratio (1990-2015), by region"

					. twoway (sc headcount190 year, c(l) msiz(small))  ///
					.        (sc headcount320 year, c(l) msiz(small))  ///
					.        (sc headcount550 year, c(l) msiz(small)), ///
					.        by(reg,  title("`title'", si(med))        ///
					.               note("Source: pip", si(vsmall)) graphregion(c(white))) ///
					.        xlab(1990(5)2015 , labsi(vsmall)) xti("Year", si(vsmall))     ///
					.        ylab(0(25)100, labsi(vsmall) angle(0))                        ///
					.        yti("Poverty headcount (%)", si(vsmall))                      ///
					.        leg(order(1 "$1.9" 2 "$3.2" 3 "$5.5") r(1) si(vsmall))        ///
					.        sub(, si(small))       scheme(s2color)
				  (click to run)

					4.3 Graph of population distribution across income categories in Latin America, by country


					. pip, region(lac) year(last) povline(3.2 5.5 15) clear 
					. keep if datatype==2 & year>=2014             // keep income surveys
					. keep povertyline countrycode countryname year headcount
					. replace povertyline = povertyline*100
					. replace headcount = headcount*100
					. tostring povertyline, replace format(%12.0f) force
					. reshape wide  headcount,i(year countrycode countryname ) j(povertyline) string
					
					. gen percentage_0 = headcount320
					. gen percentage_1 = headcount550 - headcount320
					. gen percentage_2 = headcount1500 - headcount550
					. gen percentage_3 = 100 - headcount1500
					
					. keep countrycode countryname year  percentage_*
					. reshape long  percentage_,i(year countrycode countryname ) j(category) 
					. la define category 0 "Poor LMI (< $3.2)" 1 "Poor UMI ($3.2-$5.5)" ///
											 2 "Vulnerable ($5.5-$15)" 3 "Middle class (> $15)"
					. la val category category
					. la var category ""

					. local title "Distribution of Income in Latin America and Caribbean, by country"
					. local note "Source: pip, using the latest survey after 2014 for each country."
					. local yti  "Population share in each income category (%)"

					. graph bar (mean) percentage, inten(*0.7) o(category) o(countrycode, ///
					.   lab(labsi(small) angle(vertical))) stack asy                      /// 
					.       blab(bar, pos(center) format(%3.1f) si(tiny))                     /// 
					.       ti("`title'", si(small)) note("`note'", si(*.7))                  ///
					.       graphregion(c(white)) ysize(6) xsize(6.5)                         ///
					.               legend(si(vsmall) r(3))  yti("`yti'", si(small))                ///
					.       ylab(,labs(small) nogrid angle(0)) scheme(s2color)
				  (click to run)



			Disclaimer
													(Go up to Sections Menu)

				pip was developed for the sole purpose of public replication of the World Bank’s poverty measures for its widely used international poverty lines, including $1.90 a day and $3.20 a day in 2011 PPP.  The
				methods built into pip are considered reliable for that purpose.
				However, we cannot be confident that the methods work well for other purposes, including tracing out the entire distribution of income.  We would especially warn that estimates of the densities near the
				bottom and top tails of the distribution could be quite unreliable, and no attempt has been made by the World Bank’s staff to validate the tool for such purposes.
				The term country, used interchangeably with economy, does not imply political independence but refers to any territory for which authorities report separate social or economic statistics.

			References
													(Go up to Sections Menu)

				Castaneda Aguilar, R. A., C. Lakner, E. B. Prydz, J. Soler Lopez, R. Wu and Q. Zhao (2019) "Estimating Global Poverty in Stata: The povcalnet command", Global Poverty Monitoring Technical Note, No. 9,
					World Bank, Washington, DC Link

			Acknowledgments
													(Go up to Sections Menu)

				The authors would like to thank Tony Fujs, Dean Jolliffe, Daniel Mahler, Minh Cong Nguyen, Christoph Lakner, Martha Viveros, Marta Schoch, Samuel Kofi Tetteh Baah, Nishan Yonzan, Haoyu Wu, and Ifeanyi
				Nzegwu Edochie for comments received on earlier versions of this code.

													(Go up to Sections Menu)
			Author
				R.Andres Castaneda

			Contributor
				Tefera Bekele Degefu

			Maintainer
				R.Andres Castaneda, The World Bank
				  Email:  acastanedaa@worldbank.org
				  GitHub: randrescastaneda

			Contact
				Any comments, suggestions, or bugs can be reported in the GitHub issues page.  All the files are available in the GitHub repository

			Thanks for citing pip as follows
													(Go up to Sections Menu)

				XXXXX (2022) "pip: Stata module to access World Bank’s Global Poverty and Inequality data," Statistical Software Components 2022, Boston College Department of Economics.

				Please make reference to the date when the database was downloaded, as statistics may change





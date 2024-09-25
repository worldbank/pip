## [Home](index.md) --- [Get Started](get_started.md) --- [Visualizations examples](vis.md) --- [Help file](help_file.md) 

          help pip                                                                                                    Poverty and Inequality Platform (PIP)
                                                                                                                           https://worldbank.github.io/pip/
          -------------------------------------------------------------------------------------------------------------------------------------------------

              If you're new to pip, please start by reading pip intro

          Syntax

                  pip [subcommand], [subcommand options]


              Subcommand                   Description
              -------------------------------------------------------------------------------------------------------------------------------------------
              Main subcommands
                cl                         Country-level poverty and inequality estimates. options
                wb                         World Bank's regional and global aggregation. options
                cp                         Country Profile estimatesoptions
                tables                     Clickable list of auxiliary tables. options
                cache                      Manage local cache. options
                print                      Print useful information. options
                [un]install                Installs the stable version of pip from SSC (pip install ssc) or the development version from GitHub (pip
                                             install gh)
                setup                      Utility function to set pip options and features.

              Auxiliary subcommands
                info                       Display countries and regions availability
                cleanup                    Deletes all pip data from current stata memory.
                test                       Display in console last query metadata and provide actions to test it in browser.
                drop                       (Programmer's option) Deletes objects from memory.
              -------------------------------------------------------------------------------------------------------------------------------------------
              Note: pip requires an internet connection.


          Description

              The pip command has the same functionality as the PIP website.  It allows Stata users to compute poverty and inequality indicators for over
              160 countries in the World Bank's database of household surveys. PIP is a computational tool that allows users to conduct country-specific,
              cross-country, as well as global and regional poverty analyses.

              If you're new to pip, please start by reading pip intro.  If you want to understand the details and functionalities of each subcommand,
              please click on the corresponding subcommand of the table above.


          Remarks

              The rest of this document contains general information about PIP and the pip Stata command. Sections are presented under the following
              headings:

                          General Options
                          Examples
                          Memory use and Stata frames
                          Stored Results
                          List of pip and povcalnet variables
                          General Troubleshooting


          General Options

              The options below work for any subcommad that returns vintaged data (e.g., cl, wb, tables)

              General Options              Description
              -------------------------------------------------------------------------------------------------------------------------------------------
                version(string)            Combination of numbers in the format %Y%m%d_YYYY_RV_AV_SSS (click here for explanation of each component).
                                             Option version() takes prevalence over the next 3 options ppp_year(), release() & identity(), as the
                                             combination of these three parameters uniquely identifies a dataset.
                ppp_year(#)                PPP round (2011 or 2017).
                release(numlist)           8 digit number with the PIP release date in the format YYYYMMDD.
                identity(string)*          Version of data to run the query on (e.g., prod, int, test). See description of each identity here.
                server(string)*            Name of server to query (e.g, prod, dev, qa). See description of each server here.
                clear                      Replaces data in memory.
                n2disp                     Number of rows to display. (default 1).
                cachedir(path)             Cache directory

              *Note: The server() and identity() options are available internally only for World Bank staff upon request to the  PIP technical team.  For
              a detailed description of the server() and identity() options see here.
              -------------------------------------------------------------------------------------------------------------------------------------------



          Examples

              The examples below do not comprehend all pip's features. Please refer to the examples section of the help file of each subcommad.

          Basic examples

              Load latest available survey-year estimates for Colombia and Argentina

                  pip cl, country(col arg) year(last) clear

              Load clickable menu

                  pip, info

              Load only urban coverage level

                  pip cl, country(all) coverage("urban") clear


          Differences between queries 

              Country estimation at $2.15 in 2015. Since there are no surveys in ARG in 2015, results are loaded only for COL, BRA and IND.

                  pip, country(COL BRA ARG IND) year(2015) clear

              Lineup-year estimation. Filling gaps for ARG and moving the IND estimate from 2015-2016 to 2015. Only works for reference years.

                  pip, country(COL BRA ARG IND) year(2015) clear fillgaps

              World Bank aggregation (country() is not available)

                  pip wb, clear year(2015)
                  pip wb, clear region(SAR LAC)
                  pip wb, clear // all regions and reference years


          Memory use and frames:

              pip is a very invasive Stata command. We say it upfront so you don't get surprises in the future, pip is invasive. Below you will find all
              the ways in which pip interacts wit you Stata session, your operating system, and your local storage. We apologize in advance for this
              behavior, but we think it is for your own benefit to take fully advantage of pip efficiency.

          Stata frames

              pip makes use of Stata frames--available since Stata 16--to store a lot of information in memory. This is partly the reason why the first
              call of pip in a new Stata session is slower compared to subsequent calls. When closing Stata, you may see a pop-up message reading "Frames
              in memory have changed". That is perfectly normal and should not cause any concern.  However, make sure you save the frames that you
              created and wish to keep. You can do that by typing frames dir.  Frames created by pip are prefixed by _pip and are marked by an *, meaning
              they have not been saved. If you do not wish to save any frames in use, just click "Exit without saving." You can also delete all PIP data
              in memory using the command pip cleanup.

          Cache memory

              By default, pip will create cache data of all the queries you make. The first you use pip you will have the option to store cache data in
              your local machine or in any drive Stata has access to. By default, pip will check whether it could save cache data in your PERSONAL
              directory (see  search path). In case it can't, it will try in PLUS, then in your current directory and then in SITE. The first time you
              execute pip, you are required to either confirm the default cache directory or provide your own directory path. Also you can opt out and
              don't save cache data. Just follow the instructions of the pop-up messages.

          pip_setup.do

              The first time you execute pip in your session, it will search for the do-file pip_setup.do. In case it is not found, it will be created in
              your PERSONAL directory.  this do-file contains a set of global macros that store information relevant to the performance of pip and to
              make it compatible with future versions. You can see the contents of that file by typing pip print, setup. We highly recommend you do NOT
              modify this file. Yet, in case you can't resist the temptation and end up modifying and breaking pip, you can recreate the pip_setup.do by
              typing pip setup, create.

          Mata libraries

              pip relies heavily in a set of MATA functions stored in a library called "lpip_fun". This library is built in your computer each time the
              library has been updated in a newer version of pip. All the Mata functions created by pip are named with the pip_* prefix. Yet, none of the
              functions is documented as they are intended for pip use only.


          Stored results

              pip is an rclass command, which means that it stores the results in r(). Each subcommand has its own set of returned results, and you can
              display them by typing return list after the execution of pip.


                                                  (Go up to Sections Menu)
          List of pip and povcalnet variables

              The following list compares the variables names available in pip with its predecessor command povcalnet.  Only the variables available in
              povcalnet are listed.

                          -------------------------------------------
                          pip variable           povcalnet variable
                          --------------------   --------------------
                          country_code           countrycode
                          country_name           countryname
                          region_code            regioncode
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
                          ppp                    ppp
                          is_interpolated        isinterpolated
                          distribution_type      usemicrodata
                          survey_coverage        coveragetype
                          -------------------------------------------



          General Troubleshooting

              In case pip is not working correctly, try the following steps in order

                  1. Uninstall pip by typing pip uninstall

                  2. Execute which pip. If pip is still installed, delete all the pip files from wherever they are in your computer until the command
                  above returns error. The idea is to leave no trace of pip in your computer.

                  3. Install pip again with the following code and check the version number. It should be the same as the most recent release

                  
                          github install worldbank/pip
                          discard
                          which pip
                  

                  4. Try to run it again and see if pip fails.

                  5. If it is still failing, open a new issue in the GitHub issues page, making sure you're adding all the necessary steps to reproduce
                  the problem.

                  6. Once the issue is created, run the code below--making sure you replace the commented line--and send the test.log file, along with
                  the issue number created in the previous step, to pip@worldbank.org.

                  
                          log using "test.log", name(pip_test) text replace // this is in your cd
                          cret list
                          clear all
                          which pip
                          set tracedepth 4
                          set traceexpand on 
                          set traceindent on 
                          set tracenumber on
                          set trace on
                           /* the pip command that is failing. e.g.,
                          cap noi pip, region(EAP) year(last) clear */
                          set trace off
                          log close pip_test
                  


          Disclaimer
                                                  (Go up to Sections Menu)

              To calculate global poverty estimates, survey-year estimates are extrapolated or interpolated to a common reference year. These
              extrapolations and interpolations require additional assumptions, namely that (a) growth in household income or consumption can be
              approximated by growth in national accounts and (b) all parts of the distribution grow at the same rate. Given these assumptions, users are
              cautioned against using reference-year estimates (available using the fillgaps option) for comparing a country's poverty trend over time.
              For that purpose, users should rely on the survey-year estimates and are advised to take into account breaks in survey comparability. For
              details on the methodology please visit the PIP Methodology Handbook and the Global Poverty Monitoring Technical Notes.

              The term country, used interchangeably with economy, does not imply political independence but refers to any territory for which
              authorities report separate social or economic statistics.


          References
                                                  (Go up to Sections Menu)

              Castaneda Aguilar, R.Andres, T. Fujs, C. Lakner, S. K. Tetteh-Baah(2023) "Estimating Global Poverty in Stata: The PIP command", Global
                  Poverty Monitoring Technical Notes, World Bank, Washington, DC

          Acknowledgments
                                                  (Go up to Sections Menu)

              The author would like to thank Tefera Bekele Degefu, Ifeanyi Nzegwu Edochie, Tony Fujs, Dean Jolliffe, Daniel Mahler, Minh Cong Nguyen,
              Christoph Lakner, Marta Schoch, Samuel Kofi Tetteh Baah, Martha Viveros, Nishan Yonzan, and Haoyu Wu for comments received on earlier
              versions of this code. This command builds on the earlier povcalnet command, which was developed with the help of Espen Prydz, Jorge Soler
              Lopez, Ruoxuan Wu and Qinghua Zhao.

                                                  (Go up to Sections Menu)
          Author
              R.Andres Castaneda, The World Bank
                Email:  acastanedaa@worldbank.org
                GitHub: randrescastaneda

          Contributor
              Tefera Bekele Degefu

          Maintainer
              PIP Technical Team, The World Bank
                Email:  pip@worldbank.org

          Contact
              Any comments, suggestions, or bugs can be reported in the GitHub issues page.  All the files are available in the GitHub repository

          Thanks for citing this Stata command as follows

              Castaneda, R.Andres. (2023) "pip: Stata Module to Access World Bank’s Global Poverty and Inequality Data" (version 0.9.0). Stata.
                  Washington, DC: World Bank Group.  https://worldbank.github.io/pip/

          Thanks for citing pip data as follows

              World Bank. (2022). Poverty and Inequality Platform (version {version_ID}) [Data set]. World Bank Group. www.pip.worldbank.org. Accessed
                  {date}

              Available version_IDs:
              2017 PPPs: 20220909_2017_01_02_PROD
              2011 PPPs: 20220909_2011_02_02_PROD

              Please make reference to the date when the database was downloaded, as statistics may change.

                                                  (Go up to Sections Menu)






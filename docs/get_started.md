## [Home](index.md) --- [Get Started](get_started.md) --- [Visualizations examples](vis.md) --- [Help file](help_file.md) 

# Getting Started

Here are some examples on how to use the `pip` command. 

## Default Options

Be default, `pip` returns poverty estimates at \$2.15 usd a day in 2017 PPP for all the surveys available. 

```stata
pip, clear

* Version in use: 20220909_2017_01_02_PROD
* 
*  first 15 observations
* 
*      +-------------------------------------------------------------------------------------+
*      | country_code   year   poverty_line   headcount      mean      median   welfare_type |
*      |-------------------------------------------------------------------------------------|
*   1. |          AGO   2000           2.15      0.2141    7.3744   4.6645291    Consumption |
*   2. |          AGO   2008           2.15      0.1463    6.5138   4.6942547    Consumption |
*   3. |          AGO   2018           2.15      0.3112    5.4822   3.4205505    Consumption |
*      |-------------------------------------------------------------------------------------|
*   4. |          ALB   1996           2.15      0.0053    7.9332    6.972102    Consumption |
*   5. |          ALB   2002           2.15      0.0109    8.1082   6.6881407    Consumption |
*   6. |          ALB   2005           2.15      0.0059    9.1660   7.7997904    Consumption |
*   7. |          ALB   2008           2.15      0.0020   10.0382   8.4001988    Consumption |
*   8. |          ALB   2012           2.15      0.0062    9.5172   8.2403842    Consumption |
*   9. |          ALB   2014           2.15      0.0102   10.1413   8.2953753    Consumption |
*  10. |          ALB   2015           2.15      0.0012   12.0554   9.8873826    Consumption |
*  11. |          ALB   2016           2.15      0.0014   12.5411   10.282371    Consumption |
*  12. |          ALB   2016           2.15      0.0580    9.9520     8.14022         Income |
*  13. |          ALB   2017           2.15      0.0039   12.4112   10.187669    Consumption |
*  14. |          ALB   2017           2.15      0.0526   10.4110   8.7049054         Income |
*  15. |          ALB   2018           2.15      0.0005   13.3165   11.639975    Consumption |
*      +-------------------------------------------------------------------------------------+

```


## Basic Options

### Filter by country

```stata
pip, country("ALB") clear

* Version in use: 20220909_2017_01_02_PROD
*
*     +-------------------------------------------------------------------------------------+
*     | country_code   year   poverty_line   headcount      mean      median   welfare_type |
*     |-------------------------------------------------------------------------------------|
*  1. |          ALB   1996           2.15      0.0053    7.9332    6.972102    Consumption |
*  2. |          ALB   2002           2.15      0.0109    8.1082   6.6881407    Consumption |
*  3. |          ALB   2005           2.15      0.0059    9.1660   7.7997904    Consumption |
*  4. |          ALB   2008           2.15      0.0020   10.0382   8.4001988    Consumption |
*  5. |          ALB   2012           2.15      0.0062    9.5172   8.2403842    Consumption |
*     +------------------------------------------------------------------------------------+

pip, country("ALB CHN") clear

* Version in use: 20220909_2017_01_02_PROD
* 
* first 15 observations
*
*     +-------------------------------------------------------------------------------------+
*     | country_code   year   poverty_line   headcount      mean      median   welfare_type |
*     |-------------------------------------------------------------------------------------|
*  1. |          ALB   1996           2.15      0.0053    7.9332    6.972102    Consumption |
*  2. |          ALB   2002           2.15      0.0109    8.1082   6.6881407    Consumption |
*  3. |          ALB   2005           2.15      0.0059    9.1660   7.7997904    Consumption |
*  4. |          ALB   2008           2.15      0.0020   10.0382   8.4001988    Consumption |
*  5. |          ALB   2012           2.15      0.0062    9.5172   8.2403842    Consumption |
*  6. |          ALB   2014           2.15      0.0102   10.1413   8.2953753    Consumption |
*  7. |          ALB   2015           2.15      0.0012   12.0554   9.8873826    Consumption |
*  8. |          ALB   2016           2.15      0.0014   12.5411   10.282371    Consumption |
*  9. |          ALB   2016           2.15      0.0580    9.9520     8.14022         Income |
* 10. |          ALB   2017           2.15      0.0039   12.4112   10.187669    Consumption |
* 11. |          ALB   2017           2.15      0.0526   10.4110   8.7049054         Income |
* 12. |          ALB   2018           2.15      0.0005   13.3165   11.639975    Consumption |
* 13. |          ALB   2018           2.15      0.0389   10.8972   9.1996278         Income |
* 14. |          ALB   2019           2.15      0.0000   15.5814   13.077384    Consumption |
*     |-------------------------------------------------------------------------------------|
* 15. |          CHN   1981           2.15      0.9687    0.9970    .9098843         Income |
*     +-------------------------------------------------------------------------------------+

```

### Filter by year

```stata
pip, country("ALB") year("2002 2012") clear

* Version in use: 20220909_2017_01_02_PROD
*
*     +------------------------------------------------------------------------------------+
*     | country_code   year   poverty_line   headcount     mean      median   welfare_type |
*     |------------------------------------------------------------------------------------|
*  1. |          ALB   2002           2.15      0.0109   8.1082   6.6881407    Consumption |
*  2. |          ALB   2012           2.15      0.0062   9.5172   8.2403842    Consumption |
*     +------------------------------------------------------------------------------------+

pip, country("ALB") year("2021") clear       // error
* Version in use: 20220909_2017_01_02_PROD
*
* Warning: years selected for ALB do not match any survey year.
* You could type pip_info, country(ALB) version(20220909_2017_01_02_PROD clear to check availability.
*
* the countries and years selected do not match any year available.
* invalid syntax
* r(197);

```
### Modify the poverty line

```stata
pip, country("ALB CHN") povline(5.5) clear
* Version in use: 20220909_2017_01_02_PROD
*
* first 15 observations
*
*     +-------------------------------------------------------------------------------------+
*     | country_code   year   poverty_line   headcount      mean      median   welfare_type |
*     |-------------------------------------------------------------------------------------|
*  1. |          ALB   1996           5.50      0.3151    7.9332    6.972102    Consumption |
*  2. |          ALB   2002           5.50      0.3581    8.1082   6.6881407    Consumption |
*  3. |          ALB   2005           5.50      0.2520    9.1660   7.7997904    Consumption |
*  4. |          ALB   2008           5.50      0.1798   10.0382   8.4001988    Consumption |
*  5. |          ALB   2012           5.50      0.2085    9.5172   8.2403842    Consumption |
*  6. |          ALB   2014           5.50      0.2675   10.1413   8.2953753    Consumption |
*  7. |          ALB   2015           5.50      0.1491   12.0554   9.8873826    Consumption |
*  8. |          ALB   2016           5.50      0.1522   12.5411   10.282371    Consumption |
*  9. |          ALB   2016           5.50      0.3040    9.9520     8.14022         Income |
* 10. |          ALB   2017           5.50      0.1494   12.4112   10.187669    Consumption |
* 11. |          ALB   2017           5.50      0.2708   10.4110   8.7049054         Income |
* 12. |          ALB   2018           5.50      0.1011   13.3165   11.639975    Consumption |
* 13. |          ALB   2018           5.50      0.2423   10.8972   9.1996278         Income |
* 14. |          ALB   2019           5.50      0.0487   15.5814   13.077384    Consumption |
*     |-------------------------------------------------------------------------------------|
* 15. |          CHN   1981           5.50      1.0000    0.9970    .9098843         Income |
*     +-------------------------------------------------------------------------------------+

```

## Other features

### Get estimates for references years when survey years are not available

The `fillgaps` option triggers the interpolation/extrapolation of poverty estimates to reference years even when survey years are not available

```stata
* 
pip, countr(AGO) clear
* Version in use: 20220909_2017_01_02_PROD
*
* first 3 observations
*
*     +------------------------------------------------------------------------------------+
*     | country_code   year   poverty_line   headcount     mean      median   welfare_type |
*     |------------------------------------------------------------------------------------|
*  1. |          AGO   2000           2.15      0.2141   7.3744   4.6645291    Consumption |
*  2. |          AGO   2008           2.15      0.1463   6.5138   4.6942547    Consumption |
*  3. |          AGO   2018           2.15      0.3112   5.4822   3.4205505    Consumption |
*     +------------------------------------------------------------------------------------+

pip, countr(AGO) clear fillgaps
* Version in use: 20220909_2017_01_02_PROD
*
* first 15 observations
*
*     +------------------------------------------------------------------------------------+
*     | country_code   year   poverty_line   headcount     mean      median   welfare_type |
*     |------------------------------------------------------------------------------------|
*  1. |          AGO   1981           2.15      0.1490   9.8386   4.6645291    Consumption |
*  2. |          AGO   1982           2.15      0.1573   9.4952   4.6645291    Consumption |
*  3. |          AGO   1983           2.15      0.1552   9.5473   4.6645291    Consumption |
*  4. |          AGO   1984           2.15      0.1513   9.7658   4.6645291    Consumption |
*  5. |          AGO   1985           2.15      0.1515   9.7553   4.6645291    Consumption |
*  6. |          AGO   1986           2.15      0.1528   9.6898   4.6645291    Consumption |
*  7. |          AGO   1987           2.15      0.1516   9.7372   4.6645291    Consumption |
*  8. |          AGO   1988           2.15      0.1458   9.9803   4.6645291    Consumption |
*  9. |          AGO   1989           2.15      0.1533   9.6473   4.6645291    Consumption |
* 10. |          AGO   1990           2.15      0.1655   9.0051   4.6645291    Consumption |
* 11. |          AGO   1991           2.15      0.1681   8.7970   4.6645291    Consumption |
* 12. |          AGO   1992           2.15      0.1929   8.0161   4.6645291    Consumption |
* 13. |          AGO   1993           2.15      0.2742   5.8989   4.6645291    Consumption |
* 14. |          AGO   1994           2.15      0.2802   5.7881   4.6645291    Consumption |
* 15. |          AGO   1995           2.15      0.2490   6.4456   4.6645291    Consumption |
*     +------------------------------------------------------------------------------------+

```
### Compute custom aggregates (aggregate is disable for now)
The `aggregate` option computes aggregate welfare statistics of custom group of countries using the reference year estimates (i.e. including the interpolation/extrapolation)

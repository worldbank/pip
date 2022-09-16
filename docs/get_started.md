## [Home](index.md) --- [Get Started](get_started.md) --- [Visualizations examples](vis.md) --- [Help file](help_file.md) 

# Getting Started

Here are some examples on how to use the `pip` command. 

## Default Options

Be default, `pip` returns poverty estimates at \$1.9 usd a day in 2011 PPP for all the surveys available. 

```stata
pip, clear

* Version in use: 20220503_2011_02_02_PROD
*
* first 15 observations
*
*     +------------------------------------------------------------------------------------+
*     | country_code   year   poverty_line   headcount      mean     median   welfare_type |
*     |------------------------------------------------------------------------------------|
*  1. |          AGO   2000           1.90      0.3637    4.1004   2.593653    Consumption |
*  2. |          AGO   2008           1.90      0.3445    3.6219   2.610182    Consumption |
*  3. |          AGO   2018           1.90      0.4990    3.0483   1.901955    Consumption |
*     |------------------------------------------------------------------------------------|
*  4. |          ALB   1996           1.90      0.0092    6.5708   5.774805    Consumption |
*  5. |          ALB   2002           1.90      0.0157    6.7158   5.539608    Consumption |
*  6. |          ALB   2005           1.90      0.0086    7.5919   6.460357    Consumption |
*  7. |          ALB   2008           1.90      0.0031    8.3143   6.957659    Consumption |
*  8. |          ALB   2012           1.90      0.0085    7.8829   6.825289    Consumption |
*  9. |          ALB   2014           1.90      0.0158    8.3998   6.870837    Consumption |
* 10. |          ALB   2015           1.90      0.0025    9.9851   8.189454    Consumption |
* 11. |          ALB   2016           1.90      0.0041   10.3875   8.516612    Consumption |
* 12. |          ALB   2016           1.90      0.0668    8.2430   6.742326         Income |
* 13. |          ALB   2017           1.90      0.0043   10.2799   8.438172    Consumption |
* 14. |          ALB   2017           1.90      0.0607    8.6232    7.21004         Income |
* 15. |          ALB   2018           1.90      0.0012   11.0297   9.641079    Consumption |
*     +------------------------------------------------------------------------------------+
```


## Basic Options

### Filter by country

```stata
pip, country("ALB") clear

* Version in use: 20220503_2011_02_02_PROD
*
*
*     +------------------------------------------------------------------------------------+
*     | country_code   year   poverty_line   headcount      mean     median   welfare_type |
*     |------------------------------------------------------------------------------------|
*  1. |          ALB   1996           1.90      0.0092    6.5708   5.774805    Consumption |
*  2. |          ALB   2002           1.90      0.0157    6.7158   5.539608    Consumption |
*  3. |          ALB   2005           1.90      0.0086    7.5919   6.460357    Consumption |
*  4. |          ALB   2008           1.90      0.0031    8.3143   6.957659    Consumption |
*  5. |          ALB   2012           1.90      0.0085    7.8829   6.825289    Consumption |
*     +------------------------------------------------------------------------------------+

pip, country("ALB CHN") clear

* Version in use: 20220503_2011_02_02_PROD
* 
* first 15 observations
*
*     +------------------------------------------------------------------------------------+
*     | country_code   year   poverty_line   headcount      mean     median   welfare_type |
*     |------------------------------------------------------------------------------------|
*  1. |          ALB   1996           1.90      0.0092    6.5708   5.774805    Consumption |
*  2. |          ALB   2002           1.90      0.0157    6.7158   5.539608    Consumption |
*  3. |          ALB   2005           1.90      0.0086    7.5919   6.460357    Consumption |
*  4. |          ALB   2008           1.90      0.0031    8.3143   6.957659    Consumption |
*  5. |          ALB   2012           1.90      0.0085    7.8829   6.825289    Consumption |
*  6. |          ALB   2014           1.90      0.0158    8.3998   6.870837    Consumption |
*  7. |          ALB   2015           1.90      0.0025    9.9851   8.189454    Consumption |
*  8. |          ALB   2016           1.90      0.0668    8.2430   6.742326         Income |
*  9. |          ALB   2016           1.90      0.0041   10.3875   8.516612    Consumption |
* 10. |          ALB   2017           1.90      0.0607    8.6232    7.21004         Income |
* 11. |          ALB   2017           1.90      0.0043   10.2799   8.438172    Consumption |
* 12. |          ALB   2018           1.90      0.0012   11.0297   9.641079    Consumption |
* 13. |          ALB   2018           1.90      0.0457    9.0259   7.619805         Income |
* 14. |          ALB   2019           1.90      0.0000   12.9056   10.83165    Consumption |
*     |------------------------------------------------------------------------------------|
* 15. |          CHN   1981           1.90      0.5918    1.8524   1.763812         Income |
*     +------------------------------------------------------------------------------------+

```

### Filter by year

```stata
pip, country("ALB") year("2002 2012") clear

* Version in use: 20220503_2011_02_02_PROD
*
*     +-----------------------------------------------------------------------------------+
*     | country_code   year   poverty_line   headcount     mean     median   welfare_type |
*     |-----------------------------------------------------------------------------------|
*  1. |          ALB   2002           1.90      0.0157   6.7158   5.539608    Consumption |
*  2. |          ALB   2012           1.90      0.0085   7.8829   6.825289    Consumption |
*     +-----------------------------------------------------------------------------------+


pip, country("ALB") year("2021") clear       // error
* Version in use: 20220503_2011_02_02_PROD
*
* Warning: years selected for ALB do not match any survey year.
* You could type pip_info, country(ALB) version(20220503_2011_02_02_PROD) clear to check availability.
*
* the countries and years selected do not match any year available.
* invalid syntax
* r(197);

```
### Modify the poverty line

```stata
pip, country("ALB CHN") povline(5.5) clear
* Version in use: 20220503_2011_02_02_PROD
*
* first 15 observations
*
*     +------------------------------------------------------------------------------------+
*     | country_code   year   poverty_line   headcount      mean     median   welfare_type |
*     |------------------------------------------------------------------------------------|
*  1. |          ALB   1996           5.50      0.4462    6.5708   5.774805    Consumption |
*  2. |          ALB   2002           5.50      0.4967    6.7158   5.539608    Consumption |
*  3. |          ALB   2005           5.50      0.3855    7.5919   6.460357    Consumption |
*  4. |          ALB   2008           5.50      0.3111    8.3143   6.957659    Consumption |
*  5. |          ALB   2012           5.50      0.3453    7.8829   6.825289    Consumption |
*  6. |          ALB   2014           5.50      0.3703    8.3998   6.870837    Consumption |
*  7. |          ALB   2015           5.50      0.2446    9.9851   8.189454    Consumption |
*  8. |          ALB   2016           5.50      0.2390   10.3875   8.516612    Consumption |
*  9. |          ALB   2016           5.50      0.3995    8.2430   6.742326         Income |
* 10. |          ALB   2017           5.50      0.3578    8.6232    7.21004         Income |
* 11. |          ALB   2017           5.50      0.2383   10.2799   8.438172    Consumption |
* 12. |          ALB   2018           5.50      0.3239    9.0259   7.619805         Income |
* 13. |          ALB   2018           5.50      0.1686   11.0297   9.641079    Consumption |
* 14. |          ALB   2019           5.50      0.0996   12.9056   10.83165    Consumption |
*     |------------------------------------------------------------------------------------|
* 15. |          CHN   1981           5.50      0.9996    1.1494          .         Income |
*     +------------------------------------------------------------------------------------+

```

## Other features

### Get estimates for references years when survey years are not available

The `fillgaps` option triggers the interpolation/extrapolation of poverty estimates to reference years even when survey years are not available

```stata
* 
pip, countr(AGO) clear
* Version in use: 20220503_2011_02_02_PROD
*
* first 3 observations
*
*     +-----------------------------------------------------------------------------------+
*     | country_code   year   poverty_line   headcount     mean     median   welfare_type |
*     |-----------------------------------------------------------------------------------|
*  1. |          AGO   2000           1.90      0.3637   4.1004   2.593653    Consumption |
*  2. |          AGO   2008           1.90      0.3445   3.6219   2.610182    Consumption |
*  3. |          AGO   2018           1.90      0.4990   3.0483   1.901955    Consumption |
*     +-----------------------------------------------------------------------------------+

pip, countr(AGO) clear fillgaps
* Version in use: 20220503_2011_02_02_PROD
*
* first 15 observations
*
*     +-----------------------------------------------------------------------------------+
*     | country_code   year   poverty_line   headcount     mean     median   welfare_type |
*     |-----------------------------------------------------------------------------------|
*  1. |          AGO   1981           1.90      0.2585   5.4706   2.593653    Consumption |
*  2. |          AGO   1982           1.90      0.2710   5.2797   2.593653    Consumption |
*  3. |          AGO   1983           1.90      0.2695   5.3087   2.593653    Consumption |
*  4. |          AGO   1984           1.90      0.2614   5.4301   2.593653    Consumption |
*  5. |          AGO   1985           1.90      0.2615   5.4243   2.593653    Consumption |
*  6. |          AGO   1986           1.90      0.2636   5.3879   2.593653    Consumption |
*  7. |          AGO   1987           1.90      0.2616   5.4142   2.593653    Consumption |
*  8. |          AGO   1988           1.90      0.2548   5.5494   2.593653    Consumption |
*  9. |          AGO   1989           1.90      0.2643   5.3643   2.593653    Consumption |
* 10. |          AGO   1990           1.90      0.2883   5.0072   2.593653    Consumption |
* 11. |          AGO   1991           1.90      0.2963   4.8914   2.593653    Consumption |
* 12. |          AGO   1992           1.90      0.3267   4.4572   2.593653    Consumption |
* 13. |          AGO   1993           1.90      0.4607   3.2800   2.593653    Consumption |
* 14. |          AGO   1994           1.90      0.4696   3.2184   2.593653    Consumption |
* 15. |          AGO   1995           1.90      0.4208   3.5840   2.593653    Consumption |
*     +-----------------------------------------------------------------------------------+

```
### Compute custom aggregates (aggregate is disable for now)
The `aggregate` option computes aggregate welfare statistics of custom group of countries using the reference year estimates (i.e. including the interpolation/extrapolation)

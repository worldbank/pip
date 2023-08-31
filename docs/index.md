## [Home](index.md) --- [PIP introduction](pip_intro.md) --- [Visualizations examples](vis.md) --- [Help file](help_file.md) 

# Estimating Global Poverty in Stata

[![githubrelease](https://img.shields.io/github/release/worldbank/pip/all.svg?label=current+release)](https://github.com/worldbank/pip/releases)

The `pip` Stata command allows Stata users to compute poverty and inequality indicators for more than 160 countries and regions included in the World Bank’s database of household surveys. It has the same functionality as the [PIP website](https://pip.worldbank.org/home). PIP is a computational tool that allows users to estimate poverty rates for regions, sets of countries or individual countries, over time and at any poverty line.

PIP is managed jointly by the Data and Research Groups in the World Bank’s Development Economics Division. It draws heavily upon a strong collaboration with the Poverty and Equity Global Practice, which is responsible for the gathering and harmonization of the underlying survey data.

PIP reports the following measures at the chosen poverty line:
- Headcount ratio
- Poverty Gap
- Squared Poverty Gap
- Watts index

It also reports these inequality measures:
- Gini index
- Mean log deviation
- Decile shares

The underlying welfare aggregate is per capita household income or consumption expressed in 2017 PPP USD. Poverty lines are expressed in daily amounts, while means and medians are monthly.

For more information on the definition of the indicators, click [here](http://iresearch.worldbank.org/PovcalNet/Docs/dictionary.html)
For more information on the methodology, click [here](https://worldbank.github.io/PIP-Methodology/)

[This note](http://documents.worldbank.org/curated/en/836101568994246528/) provides more detail on the Stata command and summarizes key features of the PIP methodology

To download `pipr` R package click [here](https://worldbank.github.io/pipr/)

## Installation 

### From SSC (Not yet available)

```stata
ssc install pip
```

### From GitHub 

We recommend installing the [`github`](https://github.com/haghish/github) Stata command by [E. F. Haghish](https://github.com/haghish)

```stata
net install github, from("https://haghish.github.io/github/")
github install worldbank/pip
```

If you get an error similar to the image below, it might be the case that downloading from Github is not available in your computer due to firewall restrictions. Try disconnecting from the VPN and installing `pip` again.

<center>
<img src="/pip/img/error_message.png"/>
</center>

If none of the options above worked, you could still install pip manually following these steps,

1. In the [GitHub repository](https://github.com/worldbank/pip) of the `pip` Stata command, click on the green icon "Clone or Download" at the top. 
2. Download the package as a zip file. 
3. Extract the files with extension `.ado` and `.sthlp` only, and place them in the directory `c:/ado/plus/p`
4. type `discard` in Stata. 

#### Troubleshooting
In case `pip` is not working correctly, try the following steps in order

1. Uninstall `pip` by typing this
```stata
github uninstall pip
```
2. Execute the following and see if `pip` is still installed somewhere in your computer
```stata
which pip 
```
If it is installed, delete all the `pip` files from wherever they are in your computer until the command above returns error. The idea is to leave no trace of `pip` in your computer.

3. Install `pip` again with the following code and check the version number. It should be the same as the most [recent release](https://github.com/worldbank/pip/releases)
```stata
github install worldbank/pip
which pip
```
4. Try to run it again and see if `pip` fails.

5. If it is still failing, please run the code below--making sure your replace the commented line--and send the test.log file to [pip@worldbank.org](https://github.com/worldbank/pip/blob/main/pip@worldbank.org)

```stata
log using "test.log", name(test) text replace // this is in your cd
cret list
clear all
which pip
set tracedepth 4
set traceexpand on 
set traceindent on 
set tracenumber on
set trace on
// Insert here the pip directive that is failing
set trace off
```
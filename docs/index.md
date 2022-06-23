## [Home](index.md) --- [Get Started](get_started.md) --- [Visualizations examples](vis.md) --- [Help file](help_file.md) 

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

The underlying welfare aggregate is per capita household income or consumption expressed in 2011 PPP-adjusted USD. Poverty lines are expressed in daily amounts, while means and medians are monthly.

For more information on the definition of the indicators, click [here](http://iresearch.worldbank.org/PovcalNet/Docs/dictionary.html)
For more information on the methodology, click [here](https://worldbank.github.io/PIP-Methodology/)

[This note](http://documents.worldbank.org/curated/en/836101568994246528/) provides more detail on the Stata command and summarizes key features of the PovcalNet methodology

To download `pip` R package click [here](https://worldbank.github.io/pipr/)

## Installation 

### From SSC (Not yet available)

```stata
ssc install pip
```

### From GitHub 

#### Recommended installation (Might not be available in your computer due to firewall restriction of your organization. In this case, see alternative installation below.):
We recommend installing `povcalnet` using the [`github`](https://github.com/haghish/github) Stata command by [E. F. Haghish](https://github.com/haghish)

```stata
net install github, from("https://haghish.github.io/github/")
github install PIP-Technical-Team/pip
```

Alternatively you can install the package by typing the followinf line, 

```stata
THIS OPTION IS NOT YET AVAILABLE
net install pip, from("https://raw.githubusercontent.com/worldbank/pip/master/")
```

#### Alternative installation from GitHub in case the options above do not work due to firewall restrictions:

1. In the [GitHub repository](https://github.com/worldbank/pip) of the `pip` Stata command, click on the green icon "Clone or Download" at the top. 
2. Download the package as a zip file. 
3. Extract the files with extension `.ado` and `.sthlp` only, and place them in the directory `c:/ado/plus/p`
4. type `discard` in Stata. 

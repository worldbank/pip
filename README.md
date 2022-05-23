[![](https://img.shields.io/badge/devel%20version-0.3.2-blue.svg)](https://github.com/worldbank/pip)


# `{pip}` : Poverty and Inequality Platform Stata wrapper


## Description

World Bank PIP API Stata wrapper

## Installation

### From SSC (NOT AVAILABLE YET)

```stata
ssc install pip
```

### From GitHub 

We recommend installing the [github](https://github.com/haghish/github) Stata command by [E. F. Haghish](https://github.com/haghish)

```stata
net install github, from("https://haghish.github.io/github/")
github install worldbank/pip
```

If you get an error similar to the image below, it might be the case that downloading from Github is not available in your computer due to firewall restrictions. Try disconnecting from the VPN and installing `{pip}` again.

![image](https://user-images.githubusercontent.com/35301997/152870576-c10787a8-e271-41ee-8eb0-79d63afacac6.png)

If none of the options above worked, you could still install `pip` manually following these steps, 

1. Click on the green icon "Clone or Download" above. 
2. Download the package as zip. 
3. Extract the files with extension `.ado` and `.sthlp` only, and place them in the directory `c:/ado/plus/p`
4. type `discard` in Stata. 


## Troubleshooting

In case `{pip}` is not working correctly, try the following steps in order

1.	Uninstall `{pip}` by typing this
```stata
github uninstall pip
```

2.	Execute the following and see if `{pip}` is still installed somewhere in your computer
```stata
which pip
```

If it is installed, delete all the `{pip}` files from wherever they are in your computer until the command above returns error. The idea is to leave no trace of  `{pip}` in your computer. 
 
3.	Install `{pip}` again with the following code and check the version number. It should be the same as the most [recent release](https://github.com/worldbank/pip/releases)


```stata
github install worldbank/pip
which pip
```
4.	Try to run it again and see if `{pip}` fails. 
5.	If it is still failing, please run the code below--making sure your replace the commented line--and send the test.log file to [pip@worldbank.org](pip@worldbank.org)

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

## License

MIT


## Author


**R.Andres Castaneda**  
The World Bank  
acastanedaa@worldbank.org

Contributor
------
Tefera Bekele Degefu
The World Bank  
tdegefu@worldbank.org

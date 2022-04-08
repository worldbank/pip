[![](https://img.shields.io/badge/devel%20version-0.3.1-blue.svg)](https://github.com/worldbank/pip)


`pip` : Poverty and Inequality Platform Stata wrapper
=====================================================

Description
-----------

World Bank PIP API Stata wrapper


Installation
-----------

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

If you get an error similar to the image below, it might be the case that downloading from Github is not available in your computer due to firewall restrictions. Try disconnecting from the VPN and installing `pip` again.

![image](https://user-images.githubusercontent.com/35301997/152870576-c10787a8-e271-41ee-8eb0-79d63afacac6.png)

If none of the options above worked, you could still install `pip` manually following these steps, 

1. Click on the green icon "Clone or Download" above. 
2. Download the package as zip. 
3. Extract the files with extension `.ado` and `.sthlp` only, and place them in the directory `c:/ado/plus/p`
4. type `discard` in Stata. 

License
-----------
MIT


Author
------

**R.Andres Castaneda**  
The World Bank  
acastanedaa@worldbank.org

Contributor
------
Tefera Bekele Degefu
The World Bank  
tdegefu@worldbank.org

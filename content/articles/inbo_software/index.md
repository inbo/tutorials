---
title: "Software by INBO: packages for environmentalists and ecologists!"
date: 2020-12-03
categories: ["development", "r", "statistics", "databases"]
tags: ["open science", "packages", "r", "python"]
output: 
    md_document:
        preserve_yaml: true
        variant: gfm
---

At the Research Institute for Nature and Forest (INBO), we are eager to sustain, promote and develop open-source software that is relevant to biodiversity researchers! This page lists **R and Python packages** which INBO developed or made a significant contribution to. Several of these packages continue being developed.

Please, feel free to **try out** packages! If you encounter a problem or if you have a suggestion, we encourage you to post an issue on the package’s code repository. You can also directly contribute improvements with a pull request.

The package links below refer to the package’s **documentation website**, if available. When there is no documentation website, often one or more **vignettes** are available within the package, describing the package’s purpose and demonstrating its use.

[bioRad]: https://adokter.github.io/bioRad/
[camtrapdp]: https://inbo.github.io/camtrapdp/
[dhcurve]: https://inbo.github.io/dhcurve/
[effectclass]: https://effectclass.netlify.app/
[etn]: https://inbo.github.io/etn/
[forrescalc]: https://inbo.github.io/forrescalc/
[frictionless]: https://frictionlessdata.github.io/frictionless-r/
[git2rdata]: https://ropensci.github.io/git2rdata/
[grts]: https://github.com/ThierryO/grts
[gulltracking]: https://inbo.github.io/gulltracking/
[gwloggeR]: https://dov-vlaanderen.github.io/groundwater-logger-validation/gwloggeR/docs/articles/gwloggeR.html
[inbodb]: https://inbo.github.io/inbodb/
[inboggvegan]: https://github.com/inbo/inboggvegan
[INBOmd]: https://inbomd.netlify.app/articles/introduction.html
[inborutils]: https://inbo.github.io/inborutils/
[INBOtheme]: https://inbo.github.io/INBOtheme/
[inlatools]: https://inlatools.netlify.app/
[LSVI]: https://inbo.github.io/LSVI/
[multimput]: https://github.com/inbo/multimput
[n2khab]: https://inbo.github.io/n2khab/
[niche_vlaanderen]: https://inbo.github.io/niche_vlaanderen/
[protocolhelper]: https://inbo.github.io/protocolhelper/
[pydov]: https://pydov.readthedocs.io/
[pyinaturalist]: https://pyinaturalist.readthedocs.io/
[pywhip]: https://inbo.github.io/pywhip/
[rgbif]: https://docs.ropensci.org/rgbif/
[wateRinfo]: https://docs.ropensci.org/wateRinfo/
[watina]: https://inbo.github.io/watina/

The following table gives a **quick overview**:

Research stage | Related INBO packages
--- | ---
Study design | [grts][grts], [protocolhelper][protocolhelper]
Retrieve data: general | [frictionless][frictionless], [inbodb][inbodb]
Retrieve data: environmental | [pydov][pydov], [wateRinfo][wateRinfo], [watina][watina]
Retrieve data: biological | [bioRad][biorad], [camtrapdp][camtrapdp], [etn][etn], [forrescalc][forrescalc], [gulltracking][gulltracking],  [n2khab][n2khab], [pyinaturalist][pyinaturalist], [rgbif][rgbif]
Store data | [frictionless][frictionless], [git2rdata][git2rdata]
Validate data | [pywhip][pywhip]
Analyze data: graphs | [inboggvegan][inboggvegan]
Analyze data: models | [dhcurve][dhcurve], [effectclass][effectclass], [gwloggeR][gwloggeR], [inlatools][inlatools], [multimput][multimput], [niche_vlaanderen][niche_vlaanderen]
Analyze data: indices | [LSVI][LSVI]
Publish | [INBOmd][INBOmd], [INBOtheme][INBOtheme]
Miscellaneous (mixed content) | [inborutils][inborutils]

## Study design 

- **R package [grts][grts]**: draw a sample from a sampling frame with the Generalized Random Tessellation Stratified (GRTS) sampling strategy.
- **R package [protocolhelper][protocolhelper]**: provides templates for protocols and helper functions to start developing a new protocol or move an existing protocol to the [INBO protocols repository](https://github.com/inbo/protocols)

## Retrieve data

### General

- **R package [frictionless][frictionless]**: read and write Frictionless Data Packages. A [Data Package](https://specs.frictionlessdata.io/data-package/) is a simple container format and standard to describe and package a collection of (tabular) data. It is typically used to publish FAIR and open datasets.
- **R package [inbodb][inbodb]**: connect to and retrieve data from databases on the INBO server, with dedicated functions to query some of these databases.

### Environmental data

- **Python package [pydov][pydov]**: to query and download data from [Databank Ondergrond Vlaanderen (DOV)](https://www.dov.vlaanderen.be/). DOV aggregates data about soil, subsoil and groundwater of Flanders and makes them publicly available. Interactive and human-readable extraction and querying of the data is provided by a web application, whereas the focus of this package is to support machine-based extraction and conversion of the data.
- **R package [wateRinfo][wateRinfo]**: facilitates access to [waterinfo.be](https://www.waterinfo.be/), a website managed by the [Flanders Environment Agency (VMM)](https://en.vmm.be/) and [Flanders Hydraulics Research](https://www.waterbouwkundiglaboratorium.be/). The website provides access to real-time water and weather related environmental variables for Flanders (Belgium), such as rainfall, air pressure, discharge, and water level. The package provides functions to search for stations and variables, and download time series.
- **R package [watina][watina]**: provides functions to query and process data from the Watina database (mainly groundwater data).

### Biological data

- **R package [bioRad][bioRad]**: extract, visualize and summarize aerial movements of birds and insects from weather radar data.
- **R package [camtrapdp][camtrapdp]**: aims to experiment and test visualization functionalities for camera trap data formatted following the [Camera Trap Data Package standard](https://github.com/tdwg/camtrap-dp).
- **R package [etn][etn]**: provides functionality to access and process data from the [European Tracking Network (ETN)](http://www.lifewatch.be/etn/) database hosted by the Flanders Marine Institute (VLIZ) as part of the Flemish contribution to LifeWatch.
- **R package [forrescalc][forrescalc]**: provides aggregated values on dendrometry, regeneration and vegetation of the Flemish forest reserve monitoring network, and functions to derive these data starting from individual tree measurements in Fieldmap.
- **R package [gulltracking][gulltracking]**: provides functionality to annotate GPS tracking data of gulls stored in [Movebank](https://www.movebank.org/). These data are collected by the LifeWatch [GPS tracking network for large birds](http://lifewatch.be/en/gps-tracking-network-large-birds).
- **R package [n2khab][n2khab]**: provides preprocessed reference data *(including checklists, spatial habitat distribution, administrative & environmental layers, GRTSmaster_habitats)* and preprocessing functions, supporting reproducible and transparent analyses on Flemish Natura 2000 (*n2k*) habitats (*hab*) and regionally important biotopes (RIBs).
- **Python package [pyinaturalist][pyinaturalist]**: Python client for the [iNaturalist](https://inaturalist.org) APIs.
- **R package [rgbif][rgbif]**: provides an R interface to the [Global Biodiversity Information Facility API](https://www.gbif.org/developer/summary).

## Store data

- **R package [frictionless][frictionless]**: read and write Frictionless Data Packages. A [Data Package](https://specs.frictionlessdata.io/data-package/) is a simple container format and standard to describe and package a collection of (tabular) data. It is typically used to publish FAIR and open datasets.
- **R package [git2rdata][git2rdata]**: an R package for writing and reading dataframes as plain text files. Important information is stored in a metadata file, which allows to maintain the classes of variables. `git2rdata` is ideal for storing R dataframes as plain text files under version control, as it strives to minimize row based diffs between two consecutive commits. The package is intended to facilitate a reproducible and traceable workflow.

## Validate data

- **Python package [pywhip][pywhip]**: a package to validate data against [whip specifications](https://github.com/inbo/whip), a human and machine-readable syntax to express specifications for data.

## Analyze data

### Make graphs

- **R package [inboggvegan][inboggvegan]**: provides R functions for multivariate plots. More specifically, extended biplot and screeplot functionality is offered for the `vegan` package.

### Fit models and make model predictions

- **R package [dhcurve][dhcurve]**: an R package to predict tree height for a given girth, based on a model and data on tree height, tree girth, tree species and location (in Dutch).
- **R package [effectclass][effectclass]**: an R package to classify and visualize modelled effects by comparing their confidence interval with thresholds.
- **R package [gwloggeR][gwloggeR]**: an R package to detect anomalous observations in timeseries of groundwater loggerdata (water pressure and air pressure). Additive outliers, temporal changes and level shifts are detected.
- **R package [inlatools][inlatools]**: provides a set of functions which can be useful to diagnose [INLA models](http://www.r-inla.org/): calculating Pearson residuals, simulation based checks for over- or underdispersion, simulation based checks for the distribution, visualising the effect of the variance or precision on random effects (random intercept, first order random walk, second order random walk). The functions can be useful to choose sensible priors and diagnose the fitted model.
- **R package [multimput][multimput]**: an R package that assists with analysing datasets with missing values using multiple imputation.
- **Python package [niche_vlaanderen][niche_vlaanderen]**: Python package to run the NICHE Vlaanderen model. Based on calculated abiotic properties of the location, NICHE Vlaanderen determines whether certain vegetation types can develop. An additional flooding module allows the user to test whether the predicted vegetations are compatible with a particular flooding regime. The package is a redevelopment of an existing ArcGIS plugin in Python, without external non-open source dependencies.

### Calculate indices

- **R package [LSVI][LSVI]**: bundles a number of functions to support researchers in determining the local conservation status (‘LSVI’) of Natura 2000 habitats in Flanders. Several functions retrieve the criteria and/or associated species lists for determining the LSVI. A specific function allows to calculate the LSVI. The package is written in Dutch.

## Publish your workflow and discuss your results

- **R package [INBOmd][INBOmd]**: provides several styles for `rmarkdown` files and several templates to generate reports, presentations and posters. The styles are based on the corporate identity of INBO and the Flemish government. All templates are based on `bookdown`, which is an extension of `rmarkdown`. `bookdown` is taylored towards writing books and technical documentation.
- **R package [INBOtheme][INBOtheme]**: contains `ggplot2` themes for INBO, the Flemish government and Elsevier journals. The documentation website includes a set of example figures for each available theme.

## Last but *not least*: miscellaneous!

- **R package [inborutils][inborutils]**: provides a collection of useful R utilities and snippets that we consider recyclable for multiple projects. The functions are either out of scope or just not mature enough to include as extensions to existing packages.

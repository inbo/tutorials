---
title: "Styleguide new git repositories"
description: "Guidelines for structuring git repositories"
author: "Thierry Onkelinx, Hans Van Calster"
date: 2020-03-17
categories: ["styleguide"]
tags: ["styleguide", "git", "github"]
---

## Naming

* Use lowercase for repository, directory, and file names. For R-related files, use uppercase `R`.

        https://github.com/inbo/data-publication
        ../tutorials/gis/leaflet-R.Rmd

* Use dash (`-`) to separate words in directory, and file names. Don't use underscores.

        .../datasets/bird-tracking-gull-occurrences/mapping/dwc-occurrence.sql

* Avoid the use of dash (`-`) in the name of repositories that you intend for R package development (it is OK to use a dash in repository names for other purposes). Especially if you intend to publish the package at CRAN at some point. CRAN demands package names to comply with the following: "contain only (ASCII) letters, numbers and dot, have at least two characters and start with a letter and not end in a dot". Few packages include a dot in their name, so avoid this too.

## READMEs


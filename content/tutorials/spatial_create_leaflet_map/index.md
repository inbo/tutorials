---
title: "Let's create an interactive map!"
description: "Creating interactive maps with leaflet"
author: "Jeroen Speybroeck"
date: 2018-06-14
categories: ["r"]
tags: ["gis", "r", "maps"]
output: 
    md_document:
        preserve_yaml: true
        variant: markdown_github
---

Introduction
------------

The required packages are **leaflet** and **sp**.

``` r
library(leaflet)
library(sp)
```

Dummy data
----------

Let's create a dumy `data.frame` to play around, i.e. the three locations of INBO:

``` r
names <- c("VAC HT","Geraardsbergen","Linkebeek")
lat <- c(50.865664, 50.760201, 50.767950)
lon <- c(4.349944, 3.874300, 4.333044)
data <- data.frame(names,lat,lon)
```

We created three points:

``` r
plot(data$lon, data$lat)
```

![](index_files/figure-markdown_github/unnamed-chunk-3-1.png)

Creating a map
--------------

We need to convert the `data.frame` to a `SpatialPointsDataFrame`:

``` r
crs_wgs84 <- CRS(SRS_string = "EPSG:4326")
pts <- SpatialPointsDataFrame(data[c("lon","lat")], 
                              data[!(names(data) %in% c("lon","lat"))],
                              proj4string = crs_wgs84)
```

The `leaflet` package is ideal to create a basic interactive map:

``` r
library(leaflet)
leaf_map <- leaflet(pts) %>% 
  addTiles(group = "OSM") %>%
  addCircleMarkers()
```

``` r
leaf_map
```

![](index_files/figure-markdown_github/unnamed-chunk-6-1.png)

**Nice, no?!**

More information is provided [at the leaflet information website](https://rstudio.github.io/leaflet/)!

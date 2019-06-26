---
title: "How to make spatial joins (point in polygon)?"
description: "Various ways to make a spatial join between GIS point data and polygon data"
author: "Stijn Van Hoey, Hans Van Calster"
date: 2019-06-20
categories: ["r", "gis"]
tags: ["gis", "r", "maps"]
output: 
    md_document:
        preserve_yaml: true
        variant: markdown_github
---

``` r
library(R.utils)
```

    ## Loading required package: R.oo

    ## Loading required package: R.methodsS3

    ## R.methodsS3 v1.7.1 (2016-02-15) successfully loaded. See ?R.methodsS3 for help.

    ## R.oo v1.22.0 (2018-04-21) successfully loaded. See ?R.oo for help.

    ## 
    ## Attaching package: 'R.oo'

    ## The following objects are masked from 'package:methods':
    ## 
    ##     getClasses, getMethods

    ## The following objects are masked from 'package:base':
    ## 
    ##     attach, detach, gc, load, save

    ## R.utils v2.8.0 successfully loaded. See ?R.utils for help.

    ## 
    ## Attaching package: 'R.utils'

    ## The following object is masked from 'package:utils':
    ## 
    ##     timestamp

    ## The following objects are masked from 'package:base':
    ## 
    ##     cat, commandArgs, getOption, inherits, isOpen, parse, warnings

``` r
library(rgdal)
```

    ## Loading required package: sp

    ## rgdal: version: 1.3-6, (SVN revision 773)
    ##  Geospatial Data Abstraction Library extensions to R successfully loaded
    ##  Loaded GDAL runtime: GDAL 2.2.3, released 2017/11/20
    ##  Path to GDAL shared files: C:/R/Library/rgdal/gdal
    ##  GDAL binary built with GEOS: TRUE 
    ##  Loaded PROJ.4 runtime: Rel. 4.9.3, 15 August 2016, [PJ_VERSION: 493]
    ##  Path to PROJ.4 shared files: C:/R/Library/rgdal/proj
    ##  Linking to sp version: 1.3-1

    ## 
    ## Attaching package: 'rgdal'

    ## The following object is masked from 'package:R.oo':
    ## 
    ##     getDescription

``` r
library(tidyverse)
```

    ## Warning: package 'tidyverse' was built under R version 3.5.3

    ## -- Attaching packages ---------------------------------------------------------------------------------- tidyverse 1.2.1 --

    ## v ggplot2 3.1.1     v purrr   0.3.2
    ## v tibble  2.1.1     v dplyr   0.8.1
    ## v tidyr   0.8.2     v stringr 1.4.0
    ## v readr   1.3.1     v forcats 0.4.0

    ## Warning: package 'ggplot2' was built under R version 3.5.3

    ## Warning: package 'tibble' was built under R version 3.5.3

    ## Warning: package 'purrr' was built under R version 3.5.3

    ## Warning: package 'dplyr' was built under R version 3.5.3

    ## -- Conflicts ------------------------------------------------------------------------------------- tidyverse_conflicts() --
    ## x tidyr::extract() masks R.utils::extract()
    ## x dplyr::filter()  masks stats::filter()
    ## x dplyr::lag()     masks stats::lag()

``` r
library(leaflet)
library(sp)
library(sf)
```

    ## Linking to GEOS 3.6.1, GDAL 2.2.3, PROJ 4.9.3

``` r
library(rgbif)
library(DBI)
```

What we want to do
------------------

In this short tutorial, we explore various options to deal with the situation where we have (1) a spatially referenced GIS file with polygons and (2) a spatially referenced set of points that overlaps with the GIS polygons.

Typically, both data sources contain information (apart from the spatial locations) that needs to be related to each other in some way. In this case study, we want to know for each point in which polygon it is located.

Get some data to work with
--------------------------

For the point data, we will work with data on the invasive species - Chinese mitten crab (**Eriocheir sinensis**) in Flanders, Belgium, from the year 2008 (GBIF.org (20th June 2019) GBIF Occurrence Download <https://doi.org/10.15468/dl.decefb>).

We will use convenience functions from the `rgbif` package to download the data as a zip file and to import the data as a `tibble` in the R environment.

``` r
invasive_species <- occ_download_get("0032582-190415153152247",
                                     path = tempdir(),
                                     overwrite = TRUE) %>% 
  occ_download_import() %>%
  filter(!is.na(decimalLongitude), !is.na(decimalLatitude))
```

    ## Download file size: 0.01 MB

    ## On disk at C:\Users\HANS_V~1\AppData\Local\Temp\Rtmpa8Ea0C\0032582-190415153152247.zip

We will use the European reference grid system from the European Environmental Agency as an example of a GIS vector layer (each grid cell is a polygon). The Belgian part of the grid system can be downloaded as a sqlite/spatialite database from the EEA website using the following code:

``` r
# explicitly set mode = "wb", otherwise zip file will be corrupt
download.file("https://www.eea.europa.eu/data-and-maps/data/eea-reference-grids-2/gis-files/belgium-spatialite/at_download/file", destfile = file.path(tempdir(), "Belgium_spatialite.zip"), mode = "wb")

# this will extract a file Belgium.sqlite to the temporary folder
unzip(zipfile = file.path(tempdir(), "Belgium_spatialite.zip"), exdir = tempdir())  
```

Point in polygon with the `sf` package
--------------------------------------

The spatial query can be done with the aid of the [`sf` package](https://r-spatial.github.io/sf/). The package has built-in functions to read spatial data (which uses GDAL as backbone).

We will project the data to Belgian Lambert 72 (<https://epsg.io/31370>), because the join assumes planar coordinates.

``` r
be10grid <- read_sf(file.path(tempdir(), "Belgium.sqlite"), 
                    layer = "be_10km")  %>%
  # convert to Belgian Lambert 72
  st_transform(crs = 31370)
```

We now get a `sf` object which is also a `data.frame` and a `tbl`:

``` r
class(be10grid)
```

    ## [1] "sf"         "tbl_df"     "tbl"        "data.frame"

Let's have a look at this object:

``` r
be10grid
```

    ## Simple feature collection with 580 features and 3 fields
    ## geometry type:  POLYGON
    ## dimension:      XY
    ## bbox:           xmin: -22402.56 ymin: -1449.985 xmax: 311353.3 ymax: 305932.2
    ## epsg (SRID):    31370
    ## proj4string:    +proj=lcc +lat_1=51.16666723333333 +lat_2=49.8333339 +lat_0=90 +lon_0=4.367486666666666 +x_0=150000.013 +y_0=5400088.438 +ellps=intl +towgs84=-106.8686,52.2978,-103.7239,0.3366,-0.457,1.8422,-1.2747 +units=m +no_defs
    ## # A tibble: 580 x 4
    ##    cellcode   eoforigin noforigin                                  GEOMETRY
    ##    <chr>          <dbl>     <dbl>                             <POLYGON [m]>
    ##  1 10kmE376N~   3760000   3180000 ((-20851.02 240718.4, -21626.25 250679.5~
    ##  2 10kmE376N~   3760000   3190000 ((-21626.25 250679.5, -22402.56 260640.9~
    ##  3 10kmE377N~   3770000   3140000 ((-7781.475 201650, -8552.253 211611, 14~
    ##  4 10kmE377N~   3770000   3150000 ((-8552.253 211611, -9324.075 221572.1, ~
    ##  5 10kmE377N~   3770000   3160000 ((-9324.075 221572.1, -10096.95 231533.3~
    ##  6 10kmE377N~   3770000   3170000 ((-10096.95 231533.3, -10870.87 241494.6~
    ##  7 10kmE377N~   3770000   3180000 ((-10870.87 241494.6, -11645.85 251456.1~
    ##  8 10kmE377N~   3770000   3190000 ((-11645.85 251456.1, -12421.9 261417.9,~
    ##  9 10kmE377N~   3770000   3200000 ((-12421.9 261417.9, -13199.02 271379.8,~
    ## 10 10kmE377N~   3770000   3210000 ((-13199.02 271379.8, -13977.21 281342.1~
    ## # ... with 570 more rows

We can see that the spatial information resides in a `GEOMETRY` list column.

Similarly, the package has built-in functions to convert a `data.frame` containing coordinates to a spatial `sf` object:

``` r
invasive_spatial <- st_as_sf(invasive_species,
                             coords = c("decimalLongitude",
                                        "decimalLatitude"),
                             crs = 4326) %>%
  # convert to Lambert72
  st_transform(crs = 31370)
```

Resulting in:

``` r
invasive_spatial
```

    ## Simple feature collection with 513 features and 43 fields
    ## geometry type:  POINT
    ## dimension:      XY
    ## bbox:           xmin: 35125.7 ymin: 188235.3 xmax: 153743.2 ymax: 220135
    ## epsg (SRID):    31370
    ## proj4string:    +proj=lcc +lat_1=51.16666723333333 +lat_2=49.8333339 +lat_0=90 +lon_0=4.367486666666666 +x_0=150000.013 +y_0=5400088.438 +ellps=intl +towgs84=-106.8686,52.2978,-103.7239,0.3366,-0.457,1.8422,-1.2747 +units=m +no_defs
    ## # A tibble: 513 x 44
    ##    gbifID datasetKey occurrenceID kingdom phylum class order family genus
    ##     <int> <chr>      <chr>        <chr>   <chr>  <chr> <chr> <chr>  <chr>
    ##  1 1.15e9 258c9ce5-~ INBO:VIS:00~ Animal~ Arthr~ Mala~ Deca~ Pseud~ Erio~
    ##  2 1.15e9 258c9ce5-~ INBO:VIS:00~ Animal~ Arthr~ Mala~ Deca~ Pseud~ Erio~
    ##  3 1.15e9 258c9ce5-~ INBO:VIS:00~ Animal~ Arthr~ Mala~ Deca~ Pseud~ Erio~
    ##  4 1.15e9 258c9ce5-~ INBO:VIS:00~ Animal~ Arthr~ Mala~ Deca~ Pseud~ Erio~
    ##  5 1.15e9 258c9ce5-~ INBO:VIS:00~ Animal~ Arthr~ Mala~ Deca~ Pseud~ Erio~
    ##  6 1.15e9 258c9ce5-~ INBO:VIS:00~ Animal~ Arthr~ Mala~ Deca~ Pseud~ Erio~
    ##  7 1.15e9 258c9ce5-~ INBO:VIS:00~ Animal~ Arthr~ Mala~ Deca~ Pseud~ Erio~
    ##  8 1.15e9 258c9ce5-~ INBO:VIS:00~ Animal~ Arthr~ Mala~ Deca~ Pseud~ Erio~
    ##  9 1.15e9 258c9ce5-~ INBO:VIS:00~ Animal~ Arthr~ Mala~ Deca~ Pseud~ Erio~
    ## 10 1.15e9 258c9ce5-~ INBO:VIS:00~ Animal~ Arthr~ Mala~ Deca~ Pseud~ Erio~
    ## # ... with 503 more rows, and 35 more variables: species <chr>,
    ## #   infraspecificEpithet <lgl>, taxonRank <chr>, scientificName <chr>,
    ## #   countryCode <chr>, locality <lgl>, publishingOrgKey <chr>,
    ## #   coordinateUncertaintyInMeters <dbl>, coordinatePrecision <lgl>,
    ## #   elevation <lgl>, elevationAccuracy <lgl>, depth <lgl>,
    ## #   depthAccuracy <lgl>, eventDate <chr>, day <int>, month <int>,
    ## #   year <int>, taxonKey <int>, speciesKey <int>, basisOfRecord <chr>,
    ## #   institutionCode <chr>, collectionCode <lgl>, catalogNumber <lgl>,
    ## #   recordNumber <lgl>, identifiedBy <chr>, dateIdentified <lgl>,
    ## #   license <chr>, rightsHolder <chr>, recordedBy <chr>, typeStatus <lgl>,
    ## #   establishmentMeans <lgl>, lastInterpreted <chr>, mediaType <lgl>,
    ## #   issue <chr>, geometry <POINT [m]>

Now we are ready to make the spatial overlay. This is done with the aid of `sf::st_join`. The default join type is `st_intersects`. This will result in the same spatial overlay as `sp::over` (see next section). We join the information from the grid to the points through a left join. See [the DE-9IM topological model](https://en.wikipedia.org/wiki/DE-9IM) for explanations about all possible spatial joins.

Note that with `st_intersects` points on a polygon boundary and points corresponding to a polygon vertex are considered to be inside the polygon. In the case where points are joined with polygons, `st_intersects` and `st_covered_by` will give the same result. The join type `st_within` can be used if we want to join only when points are completely within (excluding polygon boundary).

``` r
invasive_be10grid_sf <- invasive_spatial %>%
  st_join(be10grid,
          join = st_intersects, 
          left = TRUE) %>%
  select(-eoforigin, -noforigin)  # exclude the EofOrigin NofOrigin columns
```

Looking at the resulting object:

``` r
invasive_be10grid_sf
```

    ## Simple feature collection with 513 features and 44 fields
    ## geometry type:  POINT
    ## dimension:      XY
    ## bbox:           xmin: 35125.7 ymin: 188235.3 xmax: 153743.2 ymax: 220135
    ## epsg (SRID):    31370
    ## proj4string:    +proj=lcc +lat_1=51.16666723333333 +lat_2=49.8333339 +lat_0=90 +lon_0=4.367486666666666 +x_0=150000.013 +y_0=5400088.438 +ellps=intl +towgs84=-106.8686,52.2978,-103.7239,0.3366,-0.457,1.8422,-1.2747 +units=m +no_defs
    ## First 10 features:
    ##        gbifID                           datasetKey      occurrenceID
    ## 1  1146738051 258c9ce5-1bda-4001-a192-347c9e7fb186 INBO:VIS:00749170
    ## 2  1146738044 258c9ce5-1bda-4001-a192-347c9e7fb186 INBO:VIS:00748773
    ## 3  1146738029 258c9ce5-1bda-4001-a192-347c9e7fb186 INBO:VIS:00759838
    ## 4  1146738026 258c9ce5-1bda-4001-a192-347c9e7fb186 INBO:VIS:00746956
    ## 5  1146737979 258c9ce5-1bda-4001-a192-347c9e7fb186 INBO:VIS:00749169
    ## 6  1146737949 258c9ce5-1bda-4001-a192-347c9e7fb186 INBO:VIS:00748450
    ## 7  1146737902 258c9ce5-1bda-4001-a192-347c9e7fb186 INBO:VIS:00722473
    ## 8  1146737751 258c9ce5-1bda-4001-a192-347c9e7fb186 INBO:VIS:00738847
    ## 9  1146737736 258c9ce5-1bda-4001-a192-347c9e7fb186 INBO:VIS:00738889
    ## 10 1146737717 258c9ce5-1bda-4001-a192-347c9e7fb186 INBO:VIS:00759840
    ##     kingdom     phylum        class    order             family     genus
    ## 1  Animalia Arthropoda Malacostraca Decapoda Pseudothelphusidae Eriocheir
    ## 2  Animalia Arthropoda Malacostraca Decapoda Pseudothelphusidae Eriocheir
    ## 3  Animalia Arthropoda Malacostraca Decapoda Pseudothelphusidae Eriocheir
    ## 4  Animalia Arthropoda Malacostraca Decapoda Pseudothelphusidae Eriocheir
    ## 5  Animalia Arthropoda Malacostraca Decapoda Pseudothelphusidae Eriocheir
    ## 6  Animalia Arthropoda Malacostraca Decapoda Pseudothelphusidae Eriocheir
    ## 7  Animalia Arthropoda Malacostraca Decapoda Pseudothelphusidae Eriocheir
    ## 8  Animalia Arthropoda Malacostraca Decapoda Pseudothelphusidae Eriocheir
    ## 9  Animalia Arthropoda Malacostraca Decapoda Pseudothelphusidae Eriocheir
    ## 10 Animalia Arthropoda Malacostraca Decapoda Pseudothelphusidae Eriocheir
    ##               species infraspecificEpithet taxonRank
    ## 1  Eriocheir sinensis                   NA   SPECIES
    ## 2  Eriocheir sinensis                   NA   SPECIES
    ## 3  Eriocheir sinensis                   NA   SPECIES
    ## 4  Eriocheir sinensis                   NA   SPECIES
    ## 5  Eriocheir sinensis                   NA   SPECIES
    ## 6  Eriocheir sinensis                   NA   SPECIES
    ## 7  Eriocheir sinensis                   NA   SPECIES
    ## 8  Eriocheir sinensis                   NA   SPECIES
    ## 9  Eriocheir sinensis                   NA   SPECIES
    ## 10 Eriocheir sinensis                   NA   SPECIES
    ##                              scientificName countryCode locality
    ## 1  Eriocheir sinensis H.Milne Edwards, 1853          BE       NA
    ## 2  Eriocheir sinensis H.Milne Edwards, 1853          BE       NA
    ## 3  Eriocheir sinensis H.Milne Edwards, 1853          BE       NA
    ## 4  Eriocheir sinensis H.Milne Edwards, 1853          BE       NA
    ## 5  Eriocheir sinensis H.Milne Edwards, 1853          BE       NA
    ## 6  Eriocheir sinensis H.Milne Edwards, 1853          BE       NA
    ## 7  Eriocheir sinensis H.Milne Edwards, 1853          BE       NA
    ## 8  Eriocheir sinensis H.Milne Edwards, 1853          BE       NA
    ## 9  Eriocheir sinensis H.Milne Edwards, 1853          BE       NA
    ## 10 Eriocheir sinensis H.Milne Edwards, 1853          BE       NA
    ##                        publishingOrgKey coordinateUncertaintyInMeters
    ## 1  1cd669d0-80ea-11de-a9d0-f1765f95f18b                           250
    ## 2  1cd669d0-80ea-11de-a9d0-f1765f95f18b                           250
    ## 3  1cd669d0-80ea-11de-a9d0-f1765f95f18b                           250
    ## 4  1cd669d0-80ea-11de-a9d0-f1765f95f18b                           250
    ## 5  1cd669d0-80ea-11de-a9d0-f1765f95f18b                           250
    ## 6  1cd669d0-80ea-11de-a9d0-f1765f95f18b                           250
    ## 7  1cd669d0-80ea-11de-a9d0-f1765f95f18b                           250
    ## 8  1cd669d0-80ea-11de-a9d0-f1765f95f18b                           250
    ## 9  1cd669d0-80ea-11de-a9d0-f1765f95f18b                           250
    ## 10 1cd669d0-80ea-11de-a9d0-f1765f95f18b                           250
    ##    coordinatePrecision elevation elevationAccuracy depth depthAccuracy
    ## 1                   NA        NA                NA    NA            NA
    ## 2                   NA        NA                NA    NA            NA
    ## 3                   NA        NA                NA    NA            NA
    ## 4                   NA        NA                NA    NA            NA
    ## 5                   NA        NA                NA    NA            NA
    ## 6                   NA        NA                NA    NA            NA
    ## 7                   NA        NA                NA    NA            NA
    ## 8                   NA        NA                NA    NA            NA
    ## 9                   NA        NA                NA    NA            NA
    ## 10                  NA        NA                NA    NA            NA
    ##               eventDate day month year taxonKey speciesKey
    ## 1  2008-09-17T00:00:00Z  17     9 2008  2225776    2225776
    ## 2  2008-06-03T00:00:00Z   3     6 2008  2225776    2225776
    ## 3  2008-03-20T00:00:00Z  20     3 2008  2225776    2225776
    ## 4  2008-07-03T00:00:00Z   3     7 2008  2225776    2225776
    ## 5  2008-09-17T00:00:00Z  17     9 2008  2225776    2225776
    ## 6  2008-04-10T00:00:00Z  10     4 2008  2225776    2225776
    ## 7  2008-03-13T00:00:00Z  13     3 2008  2225776    2225776
    ## 8  2008-03-19T00:00:00Z  19     3 2008  2225776    2225776
    ## 9  2008-03-19T00:00:00Z  19     3 2008  2225776    2225776
    ## 10 2008-10-28T00:00:00Z  28    10 2008  2225776    2225776
    ##        basisOfRecord institutionCode collectionCode catalogNumber
    ## 1  HUMAN_OBSERVATION            INBO             NA            NA
    ## 2  HUMAN_OBSERVATION            INBO             NA            NA
    ## 3  HUMAN_OBSERVATION            INBO             NA            NA
    ## 4  HUMAN_OBSERVATION            INBO             NA            NA
    ## 5  HUMAN_OBSERVATION            INBO             NA            NA
    ## 6  HUMAN_OBSERVATION            INBO             NA            NA
    ## 7  HUMAN_OBSERVATION            INBO             NA            NA
    ## 8  HUMAN_OBSERVATION            INBO             NA            NA
    ## 9  HUMAN_OBSERVATION            INBO             NA            NA
    ## 10 HUMAN_OBSERVATION            INBO             NA            NA
    ##    recordNumber identifiedBy dateIdentified license rightsHolder
    ## 1            NA   Jan Breine             NA CC0_1_0         INBO
    ## 2            NA   Jan Breine             NA CC0_1_0         INBO
    ## 3            NA   Jan Breine             NA CC0_1_0         INBO
    ## 4            NA   Jan Breine             NA CC0_1_0         INBO
    ## 5            NA   Jan Breine             NA CC0_1_0         INBO
    ## 6            NA   Jan Breine             NA CC0_1_0         INBO
    ## 7            NA   Jan Breine             NA CC0_1_0         INBO
    ## 8            NA   Jan Breine             NA CC0_1_0         INBO
    ## 9            NA   Jan Breine             NA CC0_1_0         INBO
    ## 10           NA   Jan Breine             NA CC0_1_0         INBO
    ##    recordedBy typeStatus establishmentMeans          lastInterpreted
    ## 1  Jan Breine         NA                 NA 2018-12-06T16:48:49.929Z
    ## 2  Jan Breine         NA                 NA 2018-12-06T16:48:49.930Z
    ## 3  Jan Breine         NA                 NA 2018-12-06T16:48:49.913Z
    ## 4  Jan Breine         NA                 NA 2018-12-06T16:48:49.900Z
    ## 5  Jan Breine         NA                 NA 2018-12-06T16:48:49.885Z
    ## 6  Jan Breine         NA                 NA 2018-12-06T16:48:49.880Z
    ## 7  Jan Breine         NA                 NA 2018-12-06T16:48:49.860Z
    ## 8  Jan Breine         NA                 NA 2018-12-06T16:48:49.762Z
    ## 9  Jan Breine         NA                 NA 2018-12-06T16:48:49.773Z
    ## 10 Jan Breine         NA                 NA 2018-12-06T16:48:49.773Z
    ##    mediaType                  issue     cellcode                  geometry
    ## 1         NA REFERENCES_URI_INVALID 10kmE392N312 POINT (143788.9 201487.1)
    ## 2         NA REFERENCES_URI_INVALID 10kmE392N312 POINT (143788.9 201487.1)
    ## 3         NA REFERENCES_URI_INVALID 10kmE389N311 POINT (114822.9 188235.3)
    ## 4         NA REFERENCES_URI_INVALID 10kmE393N311 POINT (153743.2 191634.8)
    ## 5         NA REFERENCES_URI_INVALID 10kmE392N312 POINT (143788.9 201487.1)
    ## 6         NA REFERENCES_URI_INVALID 10kmE392N312 POINT (147138.3 199035.5)
    ## 7         NA REFERENCES_URI_INVALID 10kmE381N314  POINT (35125.7 205808.5)
    ## 8         NA REFERENCES_URI_INVALID 10kmE391N312 POINT (136197.7 197300.8)
    ## 9         NA REFERENCES_URI_INVALID 10kmE391N312 POINT (136197.7 197300.8)
    ## 10        NA REFERENCES_URI_INVALID 10kmE389N311 POINT (121593.8 190203.2)

Point in polygon with the `sp` package
--------------------------------------

Instead of `sf` objects (= `data.frames` or `tibbles` with a geometry list-column), the `sp` package works with `Spatial` spatial data classes (which has many derived spatial data classes for points, polygons, ...).

First, we need to convert the `data.frame` with point locations to a `SpatialPointsDataFrame`. We also need to ensure that the coordinate reference system (CRS) for both the point locations and the grid is the same. The data from GBIF are in WGS84 format.

``` r
crs_wgs84 <- CRS("+init=epsg:4326")
coord <- invasive_species %>%
    select(decimalLongitude, decimalLatitude)
invasive_spatial <- SpatialPointsDataFrame(coord,
                                           data = invasive_species,
                                           proj4string = crs_wgs84)
```

The `sp` package has no native methods to read the Belgium 10 km x 10 km grid, but we can use `rgdal::readOGR` to connect with the sqlite/spatialite database and extract the Belgium 10 km x 10 km grid as a `SpatialPolygonsDataFrame`. Apart from the 10 km x 10 km grid, the database also contains 1 km x 1 km and 100 km x 100 km grids as raster or vector files.

``` r
be10grid <- readOGR(dsn = file.path(tempdir(), "Belgium.sqlite"), 
                  layer = "be_10km")
```

    ## OGR data source with driver: SQLite 
    ## Source: "C:\Users\hans_vancalster\AppData\Local\Temp\Rtmpa8Ea0C\Belgium.sqlite", layer: "be_10km"
    ## with 580 features
    ## It has 3 fields

We transform the 10 km x 10 km grid to the same CRS system:

``` r
be10grid <- spTransform(be10grid, crs_wgs84)
```

Now we are ready to spatially join (overlay) the `SpatialPointsDataFrame` wth the 10 km x 10 km grid. This can be done using `sp::over`. The first two arguments of the function give, respectively, the geometry (locations) of the queries, and the layer from which the geometries or attributes are queried. See `?sp::over`. In this case, when x = "SpatialPoints" and y = "SpatialPolygonsDataFrame", it returns a `data.frame` of the second argument with row entries corresponding to the first argument.

``` r
invasive_be10grid <- over(x = invasive_spatial, y = be10grid)
invasive_species_be10grid <- bind_cols(invasive_species,
                                       invasive_be10grid)
```

To see what the result looks like, we can select the most relevant variables and print it (first ten rows).

``` r
invasive_species_be10grid %>%
  select(species, starts_with("decimal"),
         eventDate, cellcode) %>%
  head(10)
```

    ## # A tibble: 10 x 5
    ##    species       decimalLatitude decimalLongitude eventDate      cellcode  
    ##    <chr>                   <dbl>            <dbl> <chr>          <fct>     
    ##  1 Eriocheir si~            51.1             4.28 2008-09-17T00~ 10kmE392N~
    ##  2 Eriocheir si~            51.1             4.28 2008-06-03T00~ 10kmE392N~
    ##  3 Eriocheir si~            51.0             3.87 2008-03-20T00~ 10kmE389N~
    ##  4 Eriocheir si~            51.0             4.42 2008-07-03T00~ 10kmE393N~
    ##  5 Eriocheir si~            51.1             4.28 2008-09-17T00~ 10kmE392N~
    ##  6 Eriocheir si~            51.1             4.33 2008-04-10T00~ 10kmE392N~
    ##  7 Eriocheir si~            51.2             2.73 2008-03-13T00~ 10kmE381N~
    ##  8 Eriocheir si~            51.1             4.17 2008-03-19T00~ 10kmE391N~
    ##  9 Eriocheir si~            51.1             4.17 2008-03-19T00~ 10kmE391N~
    ## 10 Eriocheir si~            51.0             3.96 2008-10-28T00~ 10kmE389N~

What have we done?
------------------

To wrap this up, we make a map that shows what we have done. We will use the results obtained with the `sf` package.

First, we need to transform `invasive_be10grid_sf` back to WGS84 (the background maps in leaflet are in WGS84) (`be10grid` is already in WGS84 format).

``` r
invasive_be10grid_sf <- invasive_be10grid_sf %>%
  st_transform(crs = 4326)
```

Zooming in on the point markers and hovering over a marker will show the reference grid identifier for the grid cell as it is joined to spatial points object `invasive_be10grid`. Clicking in a grid cell will bring up a popup showing the reference grid identifier for the grid cell as it is named in `be10grid`.

``` r
leaflet(be10grid) %>%
  addTiles() %>%
  addPolygons(popup = ~cellcode) %>%
  addMarkers(data = invasive_be10grid_sf,
             label = ~cellcode)
```

![](index_files/figure-markdown_github/unnamed-chunk-18-1.png)

---
title: "How to use open vector file formats in R: GeoPackage & GeoJSON"
description: "A simple tutorial to demonstrate the use of *.gpkg and *.geojson files in R"
authors: [florisvdh]
date: 2020-02-03
categories: ["r", "gis"]
tags: ["gis", "r"]
output: 
  md_document:
    preserve_yaml: true
    variant: gfm+footnotes
---

This tutorial uses a few basic functions from the
[dplyr](https://dplyr.tidyverse.org) and
[sf](https://r-spatial.github.io/sf/) packages. While only a few
functions are used, you can use the previous hyperlinks to access the
tutorials (vignettes) of these packages for more functions and
information.

``` r
options(stringsAsFactors = FALSE)
library(tidyverse)
library(sf)
library(inborutils)
```

You will find a bit more background about ‘why and what’, regarding the
considered open standards, in [a separate
post](../../articles/geospatial_standards/) on this website.

In short, the GeoPackage and GeoJSON formats are ideal for exchange,
publication, interoperability & durability and to open science in
general.

The below table compares a few vector formats that are currently used a
lot. This tutorial focuses on the open
formats.

| Property                                              |    GeoPackage     |       GeoJSON RFC7946        |     Shapefile     |          ESRI geodatabase          |
| :---------------------------------------------------- | :---------------: | :--------------------------: | :---------------: | :--------------------------------: |
| Open standard?                                        |        yes        |             yes              |        no         |                 no                 |
| Write support by GDAL (OGR)                           |        yes        |             yes              |        yes        |                 no                 |
| Supported OS                                          |  cross-platform   |        cross-platform        |  cross-platform   |              Windows               |
| Extends non-spatial format:                           |      SQLite       |             JSON             |     dBase IV      |    MS Access (for personal gdb)    |
| Text or binary?                                       |      binary       |             text             |      binary       |               binary               |
| Number of files                                       |         1         |              1               |     3 or more     | 1 (personal gdb) / many (file gdb) |
| Inspect version’s differences in git version control? |        no         | yes (but care must be taken) |        no         |                 no                 |
| Can store multiple layers?                            |        yes        |              no              |        no         |                yes                 |
| Multiple geometry types allowed per layer?            |        yes        |             yes              |        no         |                yes                 |
| Coordinate reference system (CRS) in file             | same as input CRS |            WGS84             | same as input CRS |         same as input CRS          |

## How to make and use GeoPackages (`*.gpkg`)

### Making a GeoPackage from a geospatial `sf` object in R

As an example, we download a geospatial layer of Special Areas of
Conservation in Flanders (version *sac\_2013-01-18*) from Zenodo:

``` r
# meeting a great function from the 'inborutils' package:
download_zenodo(doi = "10.5281/zenodo.3386815")
```

*Did you know this: you can visit a website of this dataset by just
prefixing the DOI \[1\] with `doi.org/`\!*

The data source is a shapefile, in this case consisting of 6 different
files. Read the geospatial data into R as an `sf` object, and let’s just
keep the essentials (though it doesn’t matter for the GeoPackage):

``` r
sac <- 
  read_sf("sac.shp") %>% 
  select(sac_code = GEBCODE,
         sac_name = NAAM,
         subsac_code = DEELGEBIED,
         polygon_id = POLY_ID)
```

Have a look at its contents by printing the object:

``` r
sac
```

    ## Simple feature collection with 616 features and 4 fields
    ## geometry type:  POLYGON
    ## dimension:      XY
    ## bbox:           xmin: 22084.25 ymin: 153207.4 xmax: 258865 ymax: 243333
    ## epsg (SRID):    NA
    ## proj4string:    +proj=lcc +lat_1=49.8333339 +lat_2=51.16666723333333 +lat_0=90 +lon_0=4.367486666666666 +x_0=150000.01256 +y_0=5400088.4378 +ellps=intl +units=m +no_defs
    ## # A tibble: 616 x 5
    ##    sac_code  sac_name       subsac_code polygon_id                      geometry
    ##    <chr>     <chr>          <chr>            <int>                 <POLYGON [m]>
    ##  1 BE2100020 Heesbossen, V… BE2100020-4          1 ((180272.3 243198.7, 180275.…
    ##  2 BE2100020 Heesbossen, V… BE2100020-2          2 ((178655.5 241042.4, 178602.…
    ##  3 BE2100024 Vennen, heide… BE2100024-…          3 ((197492.4 234451.4, 197286.…
    ##  4 BE2100015 Kalmthoutse H… BE2100015-1          4 ((153735.8 228386, 153838.5 …
    ##  5 BE2100024 Vennen, heide… BE2100024-…          5 ((198272.4 234699, 198568.8 …
    ##  6 BE2100020 Heesbossen, V… BE2100020-6          6 ((181098 233705.3, 181395.1 …
    ##  7 BE2100024 Vennen, heide… BE2100024-…          7 ((199185.8 233540.2, 199122.…
    ##  8 BE2100024 Vennen, heide… BE2100024-…          8 ((199553.4 233061.2, 199141.…
    ##  9 BE2100024 Vennen, heide… BE2100024-5          9 ((192190.9 232648.7, 192196 …
    ## 10 BE2100024 Vennen, heide… BE2100024-2         10 ((187597 231264.9, 187549.3 …
    ## # … with 606 more rows

To write the GeoPackage, we just use the GPKG driver of the powerful
[GDAL](https://gdal.org) library (supporting most open and some closed
formats), which can be elegantly accessed through `sf::st_write()`:

``` r
sac %>% 
  st_write("sac.gpkg")
```

    ## Updating layer `sac' to data source `sac.gpkg' using driver `GPKG'
    ## Writing 616 features with 4 fields and geometry type Polygon.

Is that all?  
***YES :-)***

Really?  
***YES :-)***

Well, hmmm, if you really want to know a little bit more…

A GeoPackage can contain many layers. So, it is good practice to
explicitly define the layer name within the GeoPackage (above, it was
automatically called ‘sac’). For example:

``` r
sac %>% 
  st_write("sac.gpkg",
           layer = "special_areas_conservation",
           delete_dsn = TRUE)
```

    ## Deleting source `sac.gpkg' using driver `GPKG'
    ## Updating layer `special_areas_conservation' to data source `sac.gpkg' using driver `GPKG'
    ## Writing 616 features with 4 fields and geometry type Polygon.

Note, `delete_dsn` was set as `TRUE` to replace the whole GeoPackage.
(There is also a `delete_layer` argument to overwrite an existing
*layer* with the same name.)

Let’s extract a selection of features from the
`special_areas_conservation` layer, and add it as a second layer into
the GeoPackage file:

``` r
sac %>% 
  filter(str_detect(sac_name, "Turnhout")) %>% # only polygons having 'Turnhout' in their name field
  st_write("sac.gpkg",
           layer = "turnhout")
```

    ## Updating layer `turnhout' to data source `sac.gpkg' using driver `GPKG'
    ## Writing 16 features with 4 fields and geometry type Polygon.

So yes, adding layers to a GeoPackage is done simply by `st_write()`
again to the same GeoPackage file (by default, `delete_dsn` is `FALSE`),
and defining the new layer’s name.

So, which layers are available in the GeoPackage?

``` r
gdalUtils::ogrinfo("sac.gpkg") %>% 
  cat(sep = "\n")
```

    ## INFO: Open of `sac.gpkg'
    ##       using driver `GPKG' successful.
    ## 1: special_areas_conservation (Polygon)
    ## 2: turnhout (Polygon)

***You see?***

### Reading a GeoPackage file

Can it become more simple than this?

``` r
# (note: the 'layer' argument is unneeded if there's just one layer)
sac_test <- st_read("sac.gpkg",
                    layer = "special_areas_conservation")
```

    ## Reading layer `special_areas_conservation' from data source `/media/floris/DATA/git_repositories/tutorials/content/tutorials/spatial_standards_vector/sac.gpkg' using driver `GPKG'
    ## Simple feature collection with 616 features and 4 fields
    ## geometry type:  POLYGON
    ## dimension:      XY
    ## bbox:           xmin: 22084.25 ymin: 153207.4 xmax: 258865 ymax: 243333
    ## epsg (SRID):    NA
    ## proj4string:    +proj=lcc +lat_1=49.8333339 +lat_2=51.16666723333333 +lat_0=90 +lon_0=4.367486666666666 +x_0=150000.01256 +y_0=5400088.4378 +ellps=intl +units=m +no_defs

Ready\!

`st_read()` is a function of the great `sf` package – hence the result
is an `sf` object again.

Also other geospatial software will (or should) be able to open the
GeoPackage format. It is an open standard, after all\!

## How to make and use GeoJSON files (`*.geojson`)

### Making a GeoJSON file from a geospatial `sf` object in R

As another example, let’s download a shapefile of stream habitat 3260 in
Flanders (version *2018*):

``` r
download_zenodo(doi = "10.5281/zenodo.3386246")
```

*Again: you can visit a website of this dataset by just prefixing the
DOI with `doi.org/`\!*

The data source is a shapefile again, in this case consisting of 4
different files. Similar as above, we read the geospatial data into R as
an `sf` object and select a few attributes to work with:

``` r
habitatstreams <- 
  read_sf("habitatstreams.shp") %>% 
  select(river_name = NAAM,
         source = BRON)
```

``` r
habitatstreams
```

    ## Simple feature collection with 560 features and 2 fields
    ## geometry type:  LINESTRING
    ## dimension:      XY
    ## bbox:           xmin: 33097.92 ymin: 157529.6 xmax: 254039 ymax: 243444.6
    ## epsg (SRID):    NA
    ## proj4string:    +proj=lcc +lat_1=49.8333339 +lat_2=51.16666723333333 +lat_0=90 +lon_0=4.367486666666666 +x_0=150000.01256 +y_0=5400088.4378 +ellps=intl +units=m +no_defs
    ## # A tibble: 560 x 3
    ##    river_name    source                                                 geometry
    ##    <chr>         <chr>                                          <LINESTRING [m]>
    ##  1 WOLFPUTBEEK   VMM     (127857.1 167681.2, 127854.9 167684.5, 127844 167688.9…
    ##  2 OUDE KALE     VMM     (95737.01 196912.9, 95732.82 196912.4, 95710.38 196907…
    ##  3 VENLOOP       EcoInv  (169352.7 209314.9, 169358.8 209290.5, 169326.2 209283…
    ##  4 VENLOOP       EcoInv  (169633.6 209293.5, 169625 209289.2, 169594.4 209321, …
    ##  5 KLEINE NETE   EcoInv  (181087.1 208607.2, 181088.6 208608.1, 181089 208608.4…
    ##  6 KLEINE NETE   EcoInv  (180037.4 208360.4, 180038.3 208377.5, 180038.3 208378…
    ##  7 KLEINE NETE   EcoInv  (180520 208595.7, 180540.5 208607.4, 180541.2 208607.7…
    ##  8 KLEINE NETE   EcoInv  (187379.9 209998.8, 187381.3 209998.5, 187381.6 209998…
    ##  9 RAAMDONKSEBE… extrap… (183545.5 192409, 183541.9 192406.7, 183541.9 192403, …
    ## 10 KLEINE NETE   EcoInv  (183516.4 208261.7, 183567.3 208279.2, 183567.3 208279…
    ## # … with 550 more rows

Nowadays, it is recommended to use the more recent and strict
**RFC7946** implementation of GeoJSON. The previous ‘GeoJSON 2008’
implementation is now obsoleted (see [the
post](../../articles/geospatial_standards/) on this tutorials website
for a bit more background).

The RFC7946 standard is well supported by GDAL’s GeoJSON driver, however
GDAL must be given the explicit option `RFC7946=YES` in order to use it
already \[2\].

Write the GeoJSON file as follows:

``` r
habitatstreams %>% 
  st_write("habitatstreams.geojson",
           layer_options = "RFC7946=YES")
```

    ## Writing layer `habitatstreams' to data source `habitatstreams.geojson' using driver `GeoJSON'
    ## options:        RFC7946=YES 
    ## Writing 560 features with 2 fields and geometry type Line String.

Done creating\!

### Do I look good?

Hey wait, wasn’t a GeoJSON file just a text file?  
***Indeed.***

So I can just open it as a text file to get an idea of its contents?  
***Well seen :-)***

Hence, also use it in versioned workflows?  
***Didn’t hear that. (Cool, though…)***

Let’s just look at the top 7 lines of the file:

    {
    "type": "FeatureCollection",
    "name": "habitatstreams",
    "features": [
    { "type": "Feature", "properties": { "river_name": "WOLFPUTBEEK", "source": "VMM" }, "geometry": { "type": "LineString", "coordinates": [ [ 4.0532635, 50.8196905 ], [ 4.0532327, 50.8197202 ], [ 4.0530778, 50.8197594 ], [ 4.0528708, 50.8199422 ], [ 4.052834, 50.8201498 ], [ 4.0528767, 50.8204559 ] ] } },
    { "type": "Feature", "properties": { "river_name": "OUDE KALE", "source": "VMM" }, "geometry": { "type": "LineString", "coordinates": [ [ 3.5931564, 51.0803318 ], [ 3.5930966, 51.0803266 ], [ 3.5927771, 51.0802782 ], [ 3.5926209, 51.080259 ], [ 3.5925707, 51.0802465 ], [ 3.5925106, 51.0802316 ], [ 3.592303, 51.0801396 ], [ 3.5921047, 51.0800302 ], [ 3.5920091, 51.0799694 ], [ 3.5919755, 51.0799432 ], [ 3.5919328, 51.07991 ], [ 3.5919165, 51.0798833 ] ] } },
    { "type": "Feature", "properties": { "river_name": "VENLOOP", "source": "EcoInv" }, "geometry": { "type": "LineString", "coordinates": [ [ 4.6443172, 51.1940245 ], [ 4.644403, 51.1938051 ], [ 4.6439364, 51.1937415 ], [ 4.6438717, 51.1936806 ], [ 4.6439146, 51.1934056 ] ] } },

You can see it basically lists the feature attributes and the
coordinates of the lines’ vertices, with each feature starting on a new
line.

Compare the coordinates with those of the `sf` object `habitatstreams`
above: the data have automatically been transformed to WGS84\!

Note: in order to be still manageable (text file size, usage in
versioning systems) it seems wise to use GeoJSON for more simple cases –
**points and rather simple lines and polygons** – and use the binary
GeoPackage format for larger (more complex) cases.

### Reading a GeoJSON file

Just do
    this:

``` r
habitatstreams_test <- st_read("habitatstreams.geojson")
```

    ## Reading layer `habitatstreams' from data source `/media/floris/DATA/git_repositories/tutorials/content/tutorials/spatial_standards_vector/habitatstreams.geojson' using driver `GeoJSON'
    ## Simple feature collection with 560 features and 2 fields
    ## geometry type:  LINESTRING
    ## dimension:      XY
    ## bbox:           xmin: 2.69742 ymin: 50.72875 xmax: 5.85425 ymax: 51.50032
    ## epsg (SRID):    4326
    ## proj4string:    +proj=longlat +datum=WGS84 +no_defs

Same story as for the GeoPackage: other geospatial software will (or
should) be able to open the GeoJSON format as well, as it’s an open and
well established standard.

From the message of `st_read()` you can see the CRS is WGS84
([EPSG-code 4326](https://epsg.io/4326)) - this is always expected when
reading a GeoJSON file.

If you want to transform the data to another CRS, e.g. Belgian Lambert
72 ([EPSG-code 31370](https://epsg.io/31370)), use `sf::st_transform()`:

``` r
habitatstreams_test %>% 
  st_transform(31370)
```

    ## Simple feature collection with 560 features and 2 fields
    ## geometry type:  LINESTRING
    ## dimension:      XY
    ## bbox:           xmin: 33013.71 ymin: 157590.5 xmax: 253945.9 ymax: 243502.9
    ## epsg (SRID):    31370
    ## proj4string:    +proj=lcc +lat_1=51.16666723333333 +lat_2=49.8333339 +lat_0=90 +lon_0=4.367486666666666 +x_0=150000.013 +y_0=5400088.438 +ellps=intl +towgs84=-106.8686,52.2978,-103.7239,0.3366,-0.457,1.8422,-1.2747 +units=m +no_defs
    ## First 10 features:
    ##        river_name   source                       geometry
    ## 1     WOLFPUTBEEK      VMM LINESTRING (127768.8 167742...
    ## 2       OUDE KALE      VMM LINESTRING (95650.24 196973...
    ## 3         VENLOOP   EcoInv LINESTRING (169263.1 209374...
    ## 4         VENLOOP   EcoInv LINESTRING (169544 209352.8...
    ## 5     KLEINE NETE   EcoInv LINESTRING (180997 208666.5...
    ## 6     KLEINE NETE   EcoInv LINESTRING (179947.3 208419...
    ## 7     KLEINE NETE   EcoInv LINESTRING (180429.9 208655...
    ## 8     KLEINE NETE   EcoInv LINESTRING (187289.6 210058...
    ## 9  RAAMDONKSEBEEK extrapol LINESTRING (183455.2 192468...
    ## 10    KLEINE NETE   EcoInv LINESTRING (183426.2 208321...

1.  DOI = Digital Object Identifier. See <https://www.doi.org>.

2.   Though GeoJSON 2008 is
    [obsoleted](http://geojson.org/geojson-spec.html), the now
    recommended [RFC7946](https://tools.ietf.org/html/rfc7946) standard
    is still officially in a *proposal* stage. That is probably the
    reason why GDAL does not yet default to RFC7946. A somehow confusing
    stage, it seems.

---
title: "Goodbye PROJ.4 strings! How to specify a coordinate reference system in R?"
description: "Current good practice in specifying a CRS in R"
author: "Floris Vanderhaeghe"
date: 2020-09-18
categories: ["r", "gis"]
tags: ["gis", "r", "maps"]
link-citations: TRUE
bibliography: bibliography.json
output: 
    md_document:
        preserve_yaml: true
        variant: gfm
        pandoc_args: !expr c("--csl", system.file("research-institute-for-nature-and-forest.csl", package = "INBOmd"))
    html_document: 
        pandoc_args: !expr c("--csl", system.file("research-institute-for-nature-and-forest.csl", package = "INBOmd"))
---

## Coordinate reference systems: minimal background

### What?

A coordinate reference system (**CRS**) is what you need if you want to
interpret numeric coordinates as actual point locations with reference
to the Earth. Two types of coordinate reference system exist: *geodetic*
and *projected* CRSes. The former serve only to locate coordinates
relative to a 3D model of the Earth surface, while the latter add a
projection to generate coordinates on a 2D map. Coordinate operations
convert or transform coordinates from one CRS to another, and you often
need them because the CRS may differ between dataset 1, dataset 2 or a
certain mapping technology.

As you can expect, a CRS is defined by several elements. Essentially, a
CRS exists of a ‘coordinate system’ and a ‘datum’ (s.l.), but we will
not go deeper into those here as we will focus on implementation.
However it is highly recommended to read further about this, in order to
better understand what a CRS means. Good contemporary resources in an R
context (with further resources referred therein) are:

  - the section on ‘*Coordinate reference systems*’ by Pebesma & Bivand
    ([2020](#ref-pebesma_spatial_2020))
  - the section ‘*Coordinate reference systems: background*’ in Bivand
    ([2019](#ref-bivand_ecs530_2019)) (there is also an accompanying
    [video](https://www.youtube.com/watch?v=Rgn4Ns2UgAg&list=PLXUoTpMa_9s10NVk4dBQljNOaOXAOhcE0&index=4&t=0s)
    of that lesson).

There are a few authorative lists of CRSes around the globe, the most
famous one being the [EPSG dataset](https://www.epsg.org), where each
CRS has a unique *EPSG code*. You can consult these CRSes interactively
at <http://www.epsg-registry.org> (official source) and through
third-party websites such as <http://epsg.io>. For example, the ‘World
Geodetic System 1984’ (WGS84) is a geodetic CRS with EPSG code `4326`,
and ‘Belge 1972 / Belgian Lambert 72’ is a projected CRS with EPSG code
`31370`.

### How *was* a CRS represented in R? Evolutions in PROJ and GDAL.

It is good to know this, but you *can* skip this section if you like.

The reason for writing this tutorial are the recent (and ongoing)
changes in several important geospatial libraries, especially **GDAL**
and **PROJ**. They are used by most geospatial tools, including the
basic R packages `rgdal`, `sp`, `sf` and `raster`.

Since long, coordinate reference systems in R (and many other tools)
have been represented by so called ‘PROJ.4 strings’ (or ‘proj4strings’),
referring to the long-standing version 4 of the PROJ library. But, we
will not use them here - it is counteradvised to use them any longer\!

Let’s just have **one last nostalgic peek** (and then, no more\!\!): the
proj4string for the Belgian Lambert 72 CRS (EPSG:31370) “*was*”:

    +proj=lcc +lat_1=51.16666723333333 +lat_2=49.8333339 +lat_0=90 +lon_0=4.367486666666666 +x_0=150000.013 +y_0=5400088.438 +ellps=intl +towgs84=-106.8686,52.2978,-103.7239,0.3366,-0.457,1.8422,-1.2747 +units=m +no_defs

Several reasons, such as higher accuracy requirements in transformations
and the availability of better standards than proj4strings, have led to
recent changes in PROJ and GDAL, which also meant reduced compatibility
with proj4strings.

**GDAL 3** and **PROJ ≥ 6**, which many R packages now support and
promote, will just ignore and drop some parts of the proj4strings (such
as `+datum` and `+towgs84` keys) if an R package would still provide it
to them. In R, the older GDAL 2.x and PROJ 4 (and hence, proj4strings)
will still be supported for some time,\[1\] for their continued use in
older environments.

If you want to read more about the changes, here are some recommended
URLs:

  - <https://www.r-spatial.org> (at the time of writing, especially
    [this](https://www.r-spatial.org/r/2020/03/17/wkt.html) post)
  - <http://rgdal.r-forge.r-project.org/articles/PROJ6_GDAL3.html>
  - <https://gdalbarn.com>

### How *is* a CRS represented in R?

**Answer**: It is done by using the
**[WKT2](http://docs.opengeospatial.org/is/18-010r7/18-010r7.html)
string**, a recent and much better standard, maintained by the Open
Geospatial Consortium. WKT stands for ‘Well-known text’. ‘WKT2’ is
simply the recent version of WKT, approved in 2019, so you can also
refer to it as WKT.\[2\]

For example, this is the WKT2 string for WGS84:

    GEOGCRS["WGS 84",
        DATUM["World Geodetic System 1984",
            ELLIPSOID["WGS 84",6378137,298.257223563,
                LENGTHUNIT["metre",1]],
            ID["EPSG",6326]],
        PRIMEM["Greenwich",0,
            ANGLEUNIT["degree",0.0174532925199433],
            ID["EPSG",8901]],
        CS[ellipsoidal,2],
            AXIS["longitude",east,
                ORDER[1],
                ANGLEUNIT["degree",0.0174532925199433,
                    ID["EPSG",9122]]],
            AXIS["latitude",north,
                ORDER[2],
                ANGLEUNIT["degree",0.0174532925199433,
                    ID["EPSG",9122]]],
        USAGE[
            SCOPE["unknown"],
            AREA["World"],
            BBOX[-90,-180,90,180]]]

## How to specify a CRS in R?

``` r
library(sp)
library(raster)
library(sf)
```

Great news\!  
The R packages further down, and many that depend on them, now provide a
means of CRS specification *irrespective* of the GDAL/PROJ version,
hence compliant with newer GDAL/PROJ.

  - **DO:**
    
    **The *general principle* that we recommend is: specify the CRS by
    using the *EPSG code*, but do so *without* using a proj4string (even
    though that *might* still work, continued support for it is not to
    be expected).**

  - **DON’T:**
    
    **Don’t use proj4strings, such as `+init=epsg:????`,
    `+proj=longlat`, …**

In the below code chunks, this is demonstrated for several important
geospatial R packages: **`sf`**, **`sp`** and **`raster`**. Other
geospatial R packages should normally inherit their approach.

First, some practical notes:

  - In order to remain compatible with GDAL 2 and PROJ 4, some packages
    will still internally derive a proj4string as well (notably by
    calling the core package `rgdal`). This happens even while you did
    not enter a proj4string. Note that the derived proj4string will not
    be used further if you’re on GDAL 3 / PROJ ≥ 6, and a WKT2 string
    will be generated as well for actual use. In the presence of GDAL 3
    / PROJ ≥ 6, you will (at the time of writing) get a **warning**
    about dropped keys in the generated proj4strings,\[3\] but in the
    meantime, for most geospatial R packages you can safely ignore this
    warning.
  - **Windows** users: to make sure that the `rgdal` and `sf` packages
    use GDAL 3 / PROJ ≥ 6 – which is now highly advised: please
    **update** all your packages in a pure R console (not RStudio) that
    uses your latest installed R version, by running
    `update.packages(ask = FALSE, checkBuilt = TRUE)`.

As a demo data set for vector data, we use a dataset of city centers
(points) included in the `rgdal` package.

``` r
cities <- 
  st_read(system.file("vectors/cities.shp", package = "rgdal"))
```

This is how it looks like:

``` r
cities
```

    Simple feature collection with 606 features and 4 fields
    geometry type:  POINT
    dimension:      XY
    bbox:           xmin: -165.27 ymin: -53.15 xmax: 177.1302 ymax: 78.2
    geographic CRS: WGS 84
    First 10 features:
                   NAME COUNTRY POPULATION CAPITAL                   geometry
    1          Murmansk  Russia     468000       N  POINT (33.08604 68.96355)
    2       Arkhangelsk  Russia     416000       N  POINT (40.64616 64.52067)
    3  Saint Petersburg  Russia    5825000       N  POINT (30.45333 59.95189)
    4           Magadan  Russia     152000       N      POINT (150.78 59.571)
    5             Perm'  Russia    1160000       N  POINT (56.23246 58.00024)
    6     Yekaterinburg  Russia    1620000       N  POINT (60.61013 56.84654)
    7  Nizhniy Novgorod  Russia    2025000       N  POINT (43.94067 56.28968)
    8           Glasgow      UK    1800000       N POINT (-4.269948 55.86281)
    9            Kazan'  Russia    1140000       N  POINT (49.14547 55.73301)
    10      Chelyabinsk  Russia    1325000       N    POINT (61.39261 55.145)

We now convert it to a plain dataframe (non-spatial) with the XY
coordinates as columns, for the sake of the exercise. We want to add the
CRS ourselves\!

``` r
cities <- 
  cbind(st_drop_geometry(cities), 
        st_coordinates(cities))
head(cities, 10) # top 10 rows
```

``` 
               NAME COUNTRY POPULATION CAPITAL          X        Y
1          Murmansk  Russia     468000       N  33.086040 68.96355
2       Arkhangelsk  Russia     416000       N  40.646160 64.52067
3  Saint Petersburg  Russia    5825000       N  30.453327 59.95189
4           Magadan  Russia     152000       N 150.780014 59.57100
5             Perm'  Russia    1160000       N  56.232464 58.00024
6     Yekaterinburg  Russia    1620000       N  60.610130 56.84654
7  Nizhniy Novgorod  Russia    2025000       N  43.940670 56.28968
8           Glasgow      UK    1800000       N  -4.269948 55.86281
9            Kazan'  Russia    1140000       N  49.145466 55.73301
10      Chelyabinsk  Russia    1325000       N  61.392612 55.14500
```

### `sf` package

Note that also the [`stars`](https://r-spatial.github.io/stars/)
package, useful to represent *vector and raster data cubes*, uses the
below approach.

Let’s check whether **[`sf`](https://r-spatial.github.io/sf/)** uses
(for Windows: comes with) the minimal PROJ/GDAL versions that we want\!

``` r
sf::sf_extSoftVersion()
```

``` 
          GEOS           GDAL         proj.4 GDAL_with_GEOS     USE_PROJ_H 
       "3.8.0"        "3.0.4"        "6.3.1"         "true"         "true" 
```

Good to go\!

#### Defining a CRS with `sf`

You can simply provide the EPSG code using `st_crs()`:

``` r
crs_wgs84 <- st_crs(4326) # WGS84 has EPSG code 4326
```

It is a so-called `crs` object:

``` r
class(crs_wgs84)
```

    [1] "crs"

#### Printing the WKT2 string with `sf`

You can directly acces the `wkt` element of the `crs` object:

``` r
cat(crs_wgs84$wkt)
```

    GEOGCRS["WGS 84",
        DATUM["World Geodetic System 1984",
            ELLIPSOID["WGS 84",6378137,298.257223563,
                LENGTHUNIT["metre",1]]],
        PRIMEM["Greenwich",0,
            ANGLEUNIT["degree",0.0174532925199433]],
        CS[ellipsoidal,2],
            AXIS["geodetic latitude (Lat)",north,
                ORDER[1],
                ANGLEUNIT["degree",0.0174532925199433]],
            AXIS["geodetic longitude (Lon)",east,
                ORDER[2],
                ANGLEUNIT["degree",0.0174532925199433]],
        USAGE[
            SCOPE["unknown"],
            AREA["World"],
            BBOX[-90,-180,90,180]],
        ID["EPSG",4326]]

There are a few extras to note:

  - printing the `crs` object shows us both the EPSG code (more
    generally: the user’s CRS specification) and the WKT2 string:

<!-- end list -->

``` r
crs_wgs84
```

    Coordinate Reference System:
      User input: EPSG:4326 
      wkt:
    GEOGCRS["WGS 84",
        DATUM["World Geodetic System 1984",
            ELLIPSOID["WGS 84",6378137,298.257223563,
                LENGTHUNIT["metre",1]]],
        PRIMEM["Greenwich",0,
            ANGLEUNIT["degree",0.0174532925199433]],
        CS[ellipsoidal,2],
            AXIS["geodetic latitude (Lat)",north,
                ORDER[1],
                ANGLEUNIT["degree",0.0174532925199433]],
            AXIS["geodetic longitude (Lon)",east,
                ORDER[2],
                ANGLEUNIT["degree",0.0174532925199433]],
        USAGE[
            SCOPE["unknown"],
            AREA["World"],
            BBOX[-90,-180,90,180]],
        ID["EPSG",4326]]

  - if the user inputted the CRS with an EPSG code (which we did\!), the
    latter can be returned as a number:

<!-- end list -->

``` r
crs_wgs84$epsg
```

    [1] 4326

You *can* (but should you?) export a (clipped) proj4string as well, with
`crs_wgs84$proj4string`.

#### Set the CRS of a `sf` object

First we prepare a `sf` object from `cities` but still without a CRS:

``` r
cities2 <- st_as_sf(cities, coords = c("X", "Y"))
cities2
```

    Simple feature collection with 606 features and 4 fields
    geometry type:  POINT
    dimension:      XY
    bbox:           xmin: -165.27 ymin: -53.15 xmax: 177.1302 ymax: 78.2
    CRS:            NA
    First 10 features:
                   NAME COUNTRY POPULATION CAPITAL                   geometry
    1          Murmansk  Russia     468000       N  POINT (33.08604 68.96355)
    2       Arkhangelsk  Russia     416000       N  POINT (40.64616 64.52067)
    3  Saint Petersburg  Russia    5825000       N  POINT (30.45333 59.95189)
    4           Magadan  Russia     152000       N      POINT (150.78 59.571)
    5             Perm'  Russia    1160000       N  POINT (56.23246 58.00024)
    6     Yekaterinburg  Russia    1620000       N  POINT (60.61013 56.84654)
    7  Nizhniy Novgorod  Russia    2025000       N  POINT (43.94067 56.28968)
    8           Glasgow      UK    1800000       N POINT (-4.269948 55.86281)
    9            Kazan'  Russia    1140000       N  POINT (49.14547 55.73301)
    10      Chelyabinsk  Russia    1325000       N    POINT (61.39261 55.145)

Note the missing CRS\!

Let’s add the CRS by using the EPSG code (we could also assign
`crs_wgs84` instead):

``` r
st_crs(cities2) <- 4326
```

Done\!

#### Get the CRS of a `sf` object

Really, all you need is `st_crs()`, once more\!

``` r
st_crs(cities2)
```

    Coordinate Reference System:
      User input: EPSG:4326 
      wkt:
    GEOGCRS["WGS 84",
        DATUM["World Geodetic System 1984",
            ELLIPSOID["WGS 84",6378137,298.257223563,
                LENGTHUNIT["metre",1]]],
        PRIMEM["Greenwich",0,
            ANGLEUNIT["degree",0.0174532925199433]],
        CS[ellipsoidal,2],
            AXIS["geodetic latitude (Lat)",north,
                ORDER[1],
                ANGLEUNIT["degree",0.0174532925199433]],
            AXIS["geodetic longitude (Lon)",east,
                ORDER[2],
                ANGLEUNIT["degree",0.0174532925199433]],
        USAGE[
            SCOPE["unknown"],
            AREA["World"],
            BBOX[-90,-180,90,180]],
        ID["EPSG",4326]]

Great\!

As this returns the `crs` object, you can also use `st_crs(cities2)$wkt`
to specifically return the WKT2 string\!

### `sp` package

Note that the actively developed (and matured) `sf` package is now much
recommended over the `sp` package (a view also shared by `sf` and `sp`
developers). The
**[`sp`](https://cran.r-project.org/web/packages/sp/index.html)**
package, which has very long been *the* go-to before `sf` came, is
maintained in order to support existing code, but it is not further
developed as much.

The `sp` package relies on the `rgdal` R package to communicate with
GDAL and PROJ, so let’s check whether `rgdal` uses (for Windows: comes
with) the minimal PROJ/GDAL versions that we want.

``` r
rgdal::rgdal_extSoftVersion()
```

``` 
          GDAL GDAL_with_GEOS           PROJ             sp 
       "3.0.4"         "TRUE"        "6.3.1"        "1.4-2" 
```

Okido.

#### Defining a CRS with `sp`

``` r
crs_wgs84 <- CRS(SRS_string = "EPSG:4326") # WGS84 has EPSG code 4326
```

It is a so-called `CRS` object:

``` r
class(crs_wgs84)
```

    [1] "CRS"
    attr(,"package")
    [1] "sp"

#### Printing the WKT2 string with `sp`

``` r
wkt_wgs84 <- wkt(crs_wgs84)
cat(wkt_wgs84)
```

    GEOGCRS["WGS 84",
        DATUM["World Geodetic System 1984",
            ELLIPSOID["WGS 84",6378137,298.257223563,
                LENGTHUNIT["metre",1]],
            ID["EPSG",6326]],
        PRIMEM["Greenwich",0,
            ANGLEUNIT["degree",0.0174532925199433],
            ID["EPSG",8901]],
        CS[ellipsoidal,2],
            AXIS["longitude",east,
                ORDER[1],
                ANGLEUNIT["degree",0.0174532925199433,
                    ID["EPSG",9122]]],
            AXIS["latitude",north,
                ORDER[2],
                ANGLEUNIT["degree",0.0174532925199433,
                    ID["EPSG",9122]]],
        USAGE[
            SCOPE["unknown"],
            AREA["World"],
            BBOX[-90,-180,90,180]]]

Also note that, when *printing* a `CRS` object of `sp` (e.g. by running
`crs_wgs84`), you still just get a proj4string (with parts dropped if on
recent GDAL/PROJ)\! We won’t print it here\! However do know that the
WKT2 string is currently also *contained* in the `CRS` object, just call
`wkt()` to see it.

#### Set the CRS of a `Spatial*` object in `sp`

First we prepare a `SpatialPointsDataFrame` from `cities` but still
without a CRS:

``` r
cities2 <- cities
coordinates(cities2) <-  ~ X + Y
```

Now, we can add a CRS:

``` r
proj4string(cities2) <- crs_wgs84
```

Note the name of the `proj4string<-` replacement function in `sp`: it
still reminds of old days, but the result is GDAL3/PROJ≥6 compliant\!
Maybe we’ll get another function in the future that cuts the link with
the ‘proj4string’ name.

#### Get the CRS of a `Spatial*` object in `sp`

Again, use `wkt()`: it works on both `CRS` and `Spatial*` objects\!

``` r
cat(wkt(cities2))
```

    GEOGCRS["WGS 84",
        DATUM["World Geodetic System 1984",
            ELLIPSOID["WGS 84",6378137,298.257223563,
                LENGTHUNIT["metre",1]],
            ID["EPSG",6326]],
        PRIMEM["Greenwich",0,
            ANGLEUNIT["degree",0.0174532925199433],
            ID["EPSG",8901]],
        CS[ellipsoidal,2],
            AXIS["longitude",east,
                ORDER[1],
                ANGLEUNIT["degree",0.0174532925199433,
                    ID["EPSG",9122]]],
            AXIS["latitude",north,
                ORDER[2],
                ANGLEUNIT["degree",0.0174532925199433,
                    ID["EPSG",9122]]],
        USAGE[
            SCOPE["unknown"],
            AREA["World"],
            BBOX[-90,-180,90,180]]]

Et voilà\!

### `raster` package

At the time of writing, you still needed the development version of
`raster` for the below code to run. You can install the development
version with: `remotes::install_github("rspatial/raster")`. If below
code does not run with the CRAN version (usually obtained with
`install.packages()`), use the development version.

As you will see, **[`raster`](https://rspatial.org/raster/pkg/)** more
or less aligns with `sp`, although it has a few extras. For example:
`raster` does not require the use of the `proj4string<-` replacement
function to set the CRS. `raster` provides `crs<-`.

Let’s make a dummy raster first, without CRS:

``` r
within_belgium <- 
  raster(extent(188500, 190350, 227550, 229550),
         res = 50)
values(within_belgium) <- 1:ncell(within_belgium)
within_belgium
```

    class      : RasterLayer 
    dimensions : 40, 37, 1480  (nrow, ncol, ncell)
    resolution : 50, 50  (x, y)
    extent     : 188500, 190350, 227550, 229550  (xmin, xmax, ymin, ymax)
    crs        : NA 
    source     : memory
    names      : layer 
    values     : 1, 1480  (min, max)

This raster is intended for use in the Belgian Lambert 72 CRS (EPSG
31370).

#### Defining and printing a CRS with `raster`

This is not applicable. Just use the facilities of the `sp` package if
you want to make a separate CRS object for usage in a `Raster*` object
(see below).

#### Set the CRS of a `Raster*` object in `raster`

We prepare a few copies of the data:

``` r
within_belgium1 <- within_belgium
within_belgium2 <- within_belgium
within_belgium3 <- within_belgium
within_belgium4 <- within_belgium
```

Setting the CRS is done with the `crs<-` replacement function. It can
take a multitude of formats; these are all equivalent:

``` r
crs(within_belgium1) <- 31370
crs(within_belgium2) <- "EPSG:31370"
crs(within_belgium3) <- st_crs(31370)$wkt # a WKT string
crs(within_belgium4) <- CRS(SRS_string = "EPSG:31370") # an sp CRS object
```

Note that we could also have provided the `crs` argument in `raster()`,
when creating the `RasterLayer` object. It can take any of the above
formats.

#### Get the CRS of a `Raster*` object in `raster`

It goes the same as in `sp`:

``` r
cat(wkt(within_belgium1))
```

    PROJCRS["Belge 1972 / Belgian Lambert 72",
        BASEGEOGCRS["Belge 1972",
            DATUM["Reseau National Belge 1972",
                ELLIPSOID["International 1924",6378388,297,
                    LENGTHUNIT["metre",1]]],
            PRIMEM["Greenwich",0,
                ANGLEUNIT["degree",0.0174532925199433]],
            ID["EPSG",4313]],
        CONVERSION["Belgian Lambert 72",
            METHOD["Lambert Conic Conformal (2SP)",
                ID["EPSG",9802]],
            PARAMETER["Latitude of false origin",90,
                ANGLEUNIT["degree",0.0174532925199433],
                ID["EPSG",8821]],
            PARAMETER["Longitude of false origin",4.36748666666667,
                ANGLEUNIT["degree",0.0174532925199433],
                ID["EPSG",8822]],
            PARAMETER["Latitude of 1st standard parallel",51.1666672333333,
                ANGLEUNIT["degree",0.0174532925199433],
                ID["EPSG",8823]],
            PARAMETER["Latitude of 2nd standard parallel",49.8333339,
                ANGLEUNIT["degree",0.0174532925199433],
                ID["EPSG",8824]],
            PARAMETER["Easting at false origin",150000.013,
                LENGTHUNIT["metre",1],
                ID["EPSG",8826]],
            PARAMETER["Northing at false origin",5400088.438,
                LENGTHUNIT["metre",1],
                ID["EPSG",8827]],
            ID["EPSG",19961]],
        CS[Cartesian,2],
            AXIS["(E)",east,
                ORDER[1],
                LENGTHUNIT["metre",1,
                    ID["EPSG",9001]]],
            AXIS["(N)",north,
                ORDER[2],
                LENGTHUNIT["metre",1,
                    ID["EPSG",9001]]],
        USAGE[
            SCOPE["unknown"],
            AREA["Belgium - onshore"],
            BBOX[49.5,2.5,51.51,6.4]]]

Let’s verify whether all objects do indeed have the same CRS:

``` r
all.equal(wkt(within_belgium1),
          wkt(within_belgium2),
          wkt(within_belgium3),
          wkt(within_belgium4))
```

    [1] TRUE

YES\!

## Literature

<div id="refs" class="references">

<div id="ref-bivand_ecs530_2019">

Bivand R. (2019). ECS530: (III) Coordinate reference systems. Tuesday 3
December 2019, 09:15-11.00, aud. C \[WWW document\].
<https://rsbivand.github.io/ECS530_h19/ECS530_III.html#coordinate_reference_systems:_background>
(accessed September 16, 2020).

</div>

<div id="ref-pebesma_spatial_2020">

Pebesma E. & Bivand R. (2020). Spatial Data Science.
<https://r-spatial.org/book>.

</div>

</div>

1.  The core geospatial R packages are aware of the GDAL/PROJ versions,
    in order to properly communicate with these.

2.  In order to emphasize the fact that the improvements in version 2
    were instructive to the new versions of GDAL and PROJ, you will
    often see explicit mention of ‘WKT2’.

3.  The packages give a warning especially to make developers of
    *other*, dependent packages *aware* that they should also make sure
    their functions do not *require* proj4strings or use hardcoded
    proj4strings. Instead, they should defer the handling of CRS
    representation to the basic geospatial R packages (i.e. dependent on
    the version of PROJ/GDAL). So, the appearance of these warnings
    marks a period of transition in order to let other packages become
    GDAL 3 and PROJ ≥ 6 compliant. And the good news is that most
    popular geospatial packages *have* become GDAL 3 and PROJ ≥ 6
    compliant\!

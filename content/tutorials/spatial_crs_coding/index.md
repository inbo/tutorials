---
title: "Goodbye PROJ.4! How to specify a coordinate reference system in R?"
description: "Current good practice in specifying a CRS in R"
authors: [florisvdh]
date: 2021-07-08
categories: ["r", "gis"]
tags: ["gis", "r", "maps"]
csl: https://raw.githubusercontent.com/citation-style-language/styles/master/research-institute-for-nature-and-forest.csl
link-citations: TRUE
bibliography: bibliography.json
output: 
  md_document:
    preserve_yaml: true
    variant: gfm+footnotes
---

## Coordinate reference systems: minimal background

### What?

A coordinate reference system (**CRS**) – also called spatial reference
system (SRS) – is what you need if you want to interpret numeric
coordinates as actual point locations with reference to the Earth. Two
types of coordinate reference system are much used in spatial science:
*geodetic* and *projected* CRSs. The former serve only to locate
coordinates relative to a 3D model of the Earth surface, while the
latter add a projection to generate coordinates on a 2D map. Coordinate
operations convert or transform coordinates from one CRS to another, and
you often need them because the CRS may differ between dataset 1,
dataset 2 or a specific mapping technology (such as `leaflet`).

As you can expect, a CRS is defined by several elements. Essentially, a
CRS exists of:

-   a coordinate system,
-   a ‘datum’ (s.l.): it localizes the geodetic coordinate system
    relative to the Earth and needs a geometric definition of the
    ellipsoid,
-   *only for projected CRSs:* coordinate conversion parameters that
    determine the conversion from the geodetic to the projected
    coordinates.

We will not go deeper into these components, because we want to focus on
implementation. However it is highly recommended to read further about
this, in order to better understand what a CRS means. A good
contemporary resource in an R context is the section ‘*Coordinate
reference systems: background*’ in [Bivand](#ref-bivand_ecs530_2019)
([2019](#ref-bivand_ecs530_2019)) (there is also an accompanying
[video](https://www.youtube.com/watch?v=Rgn4Ns2UgAg&list=PLXUoTpMa_9s10NVk4dBQljNOaOXAOhcE0&index=4&t=0s)
of that lesson).

There are a few coordinated lists of CRSs around the globe, the most
famous one being the [EPSG dataset](https://www.epsg.org), where each
CRS has a unique *EPSG code*. You can consult these CRSs interactively
at <https://epsg.org> (official source) and through third-party websites
such as <https://jjimenezshaw.github.io/crs-explorer> and
<http://epsg.io>. For example, the ‘World Geodetic System 1984’ (WGS 84)
is a geodetic CRS with EPSG code `4326`, and ‘Belge 1972 / Belgian
Lambert 72’ is a projected CRS with EPSG code `31370`.

In R, you can also search for CRSs and EPSG codes since these are
included in the PROJ database, used by R packages like `sf`. An example
for Belgian CRSs:

``` r
proj_db <- system.file("proj/proj.db", package = "sf")
  # For dynamically linked PROJ, provide the path to proj.db yourself:
  if (proj_db == "") proj_db <- proj_db_path
crs_table <- sf::read_sf(proj_db, "crs_view") # extracts the "crs_view" table
subset(crs_table, grepl("Belg|Ostend", name) & auth_name == "EPSG")[2:5]
```

    # A tibble: 8 × 4
      auth_name code  name                                          type     
      <chr>     <chr> <chr>                                         <chr>    
    1 EPSG      3447  ETRS89 / Belgian Lambert 2005                 projected
    2 EPSG      3812  ETRS89 / Belgian Lambert 2008                 projected
    3 EPSG      21500 BD50 (Brussels) / Belge Lambert 50            projected
    4 EPSG      31300 BD72 / Belge Lambert 72                       projected
    5 EPSG      31370 BD72 / Belgian Lambert 72                     projected
    6 EPSG      5710  Ostend height                                 vertical 
    7 EPSG      6190  BD72 / Belgian Lambert 72 + Ostend height     compound 
    8 EPSG      8370  ETRS89 / Belgian Lambert 2008 + Ostend height compound 

<!-- ```{r} -->
<!-- # showing relevant tables of proj.db: -->
<!-- grep("crs", sf::st_layers(proj_db)$name, value = TRUE) -->
<!-- ``` -->
<!-- You can do this with the help of the `rgdal` package: -->
<!-- ```{r} -->
<!-- epsg_crs_table <- rgdal::make_EPSG()[, 1:2] -->
<!-- subset(epsg_crs_table, grepl("Belg", note)) -->
<!-- ``` -->

### How *did* we represent a CRS in R? Evolutions in PROJ and GDAL.

It is good to know this, but you *can* skip this section if you like.

The reason for writing this tutorial are the recent (and ongoing)
changes in several important geospatial libraries, especially **GDAL**
and **PROJ**. They are used by most geospatial tools, including the key
geospatial R packages `rgdal`, `sp`, `sf`, `stars`, `terra` and
`raster`.

Since long, coordinate reference systems in R (and many other tools)
have been represented by so called ‘PROJ.4 strings’ (or ‘proj4strings’),
referring to the long-standing version 4 of the PROJ library. But, we
will not use them here! It is discouraged to use ‘PROJ strings’[^1] any
longer to represent a CRS; several string elements for CRSs are now
deprecated or unsupported. Currently, PROJ (<https://proj.org>) regards
PROJ strings only as a means of specifying a *coordinate operation*
(conversions or transformations *between* CRSs). Performing coordinate
operations is the main aim of PROJ.

Let’s just have **one last nostalgic peek** (and then, no more!!) to the
proj4string for EPSG:31370, the Belgian Lambert 72 CRS:[^2]

    +proj=lcc +lat_1=51.16666723333333 +lat_2=49.8333339 +lat_0=90 +lon_0=4.367486666666666 +x_0=150000.013 +y_0=5400088.438 +ellps=intl +towgs84=-106.8686,52.2978,-103.7239,0.3366,-0.457,1.8422,-1.2747 +units=m +no_defs

Several reasons have led to recent changes in GDAL and PROJ, such as the
former use of the WGS 84 CRS as an intermediate ‘hub’ in coordinate
transformation or in defining a CRS’s datum (introducing unneeded
errors), higher accuracy requirements in transformations and the
availability of better CRS specification standards than PROJ strings.
The changes are included in **GDAL 3** and **PROJ ≥ 6**, which many R
packages now support and promote.

In consequence, support for PROJ strings to represent a CRS is reduced
and discouraged. It *can* still be done, preferrably adding the
`+type=crs` element to distinguish such a string from modern PROJ
strings. The latter represent a coordinate operation, not a CRS.
Currently, support for most geodetic datums is already lacking in PROJ
strings[^3] (unless one defines it indirectly, but likely less
accurately, with the now deprecated `+towgs84` key). The WGS 84 ensemble
datum[^4]
([datum:EPSG::6326](https://epsg.org/datum_6326/World-Geodetic-System-1984-ensemble.html))
is now by default assumed for a CRS declared with a PROJ string.

If you want to read more about the changes, here are some recommended
resources:

-   <https://www.r-spatial.org> (at the time of writing, especially
    [Pebesma & Bivand](#ref-pebesma_r_2020)
    ([2020](#ref-pebesma_r_2020)))
-   [Bivand](#ref-bivand_migration_2020)
    ([2020a](#ref-bivand_migration_2020)) (`rgdal` vignette)
-   [Bivand](#ref-bivand_upstream_2020)
    ([2020b](#ref-bivand_upstream_2020)) (video recording; see slides
    45-66 in [Bivand](#ref-bivand_how_2020_1)
    ([2020c](#ref-bivand_how_2020_1)))
-   <https://gdalbarn.com>
-   [Nowosad & Lovelace](#ref-nowosad_recent_2020)
    ([2020](#ref-nowosad_recent_2020)) (webinar and slides, also
    including other developments in spatial R)

### What *is* the new way to represent a CRS in R?

**Answer**: The current approach is the
**[WKT2](http://docs.opengeospatial.org/is/18-010r7/18-010r7.html)
string**, a recent and much better standard, maintained by the Open
Geospatial Consortium. WKT stands for ‘Well-known text.’ ‘WKT2’ is
simply the recent version of WKT, approved in 2019, so you can also
refer to it as WKT.[^5]

For example, this is the WKT2 string for WGS 84:

    GEOGCRS["WGS 84 (with axis order normalized for visualization)",
        ENSEMBLE["World Geodetic System 1984 ensemble",
            MEMBER["World Geodetic System 1984 (Transit)",
                ID["EPSG",1166]],
            MEMBER["World Geodetic System 1984 (G730)",
                ID["EPSG",1152]],
            MEMBER["World Geodetic System 1984 (G873)",
                ID["EPSG",1153]],
            MEMBER["World Geodetic System 1984 (G1150)",
                ID["EPSG",1154]],
            MEMBER["World Geodetic System 1984 (G1674)",
                ID["EPSG",1155]],
            MEMBER["World Geodetic System 1984 (G1762)",
                ID["EPSG",1156]],
            MEMBER["World Geodetic System 1984 (G2139)",
                ID["EPSG",1309]],
            ELLIPSOID["WGS 84",6378137,298.257223563,
                LENGTHUNIT["metre",1],
                ID["EPSG",7030]],
            ENSEMBLEACCURACY[2.0],
            ID["EPSG",6326]],
        PRIMEM["Greenwich",0,
            ANGLEUNIT["degree",0.0174532925199433],
            ID["EPSG",8901]],
        CS[ellipsoidal,2],
            AXIS["geodetic longitude (Lon)",east,
                ORDER[1],
                ANGLEUNIT["degree",0.0174532925199433,
                    ID["EPSG",9122]]],
            AXIS["geodetic latitude (Lat)",north,
                ORDER[2],
                ANGLEUNIT["degree",0.0174532925199433,
                    ID["EPSG",9122]]],
        USAGE[
            SCOPE["Horizontal component of 3D system."],
            AREA["World."],
            BBOX[-90,-180,90,180]],
        REMARK["Axis order reversed compared to EPSG:4326"]]

An alternative representation of the WKT2 string - not yet official at
the time of writing - is
[PROJJSON](https://proj.org/specifications/projjson.html). It is a more
convenient format to use in coding.

## How to specify a CRS in R?

``` r
library(sp)
library(raster)
library(sf)
```

Great news!  
The R packages further down, and many that depend on them, now provide a
means of CRS specification *irrespective* of the GDAL/PROJ version,
hence compliant with newer GDAL/PROJ.

-   **DO:**

    **The *general principle* that we recommend is: specify the CRS by
    using the *EPSG code*, but do so *without* using a PROJ string.**

    *Note: in case you wish to define a custom CRS yourself, ideally use
    WKT2 or its more convenient
    [PROJJSON](https://proj.org/specifications/projjson.html)
    counterpart.*

-   **DON’T:**

    **It’s no longer advised to use PROJ strings to specify a CRS, such
    as `+init=epsg:????`, `+proj=longlat`, … (even though that *might*
    still work, their usage is discouraged).**

Below it is demonstrated how to specify a CRS that is defined in the
EPSG database (hence, having an EPSG code), for several important
geospatial R packages: **`sf`**, **`sp`** and **`raster`**. Other
geospatial R packages should normally inherit their approach.

First, a practical note:

-   Some packages internally still derive a PROJ string as well. This
    happens even while you did not enter a PROJ string. Note that the
    derived PROJ string will not be used further if you’re on GDAL 3 /
    PROJ ≥ 6, and a WKT2 string will be generated as well for actual
    use. In the presence of GDAL 3 / PROJ ≥ 6 and when using `sp` or
    `raster`, you will (at the time of writing) get a **warning** from
    `rgdal` about dropped keys in the generated PROJ strings.[^6] You
    can safely ignore this warning on condition that you didn’t define
    the CRS with a PROJ string. Also, you can suppress the warning with
    `options(rgdal_show_exportToProj4_warnings = "none")` in the
    beginning of your script (before loading `rgdal` or dependent
    packages).

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
    Geometry type: POINT
    Dimension:     XY
    Bounding box:  xmin: -165.27 ymin: -53.15 xmax: 177.1302 ymax: 78.2
    Geodetic CRS:  WGS 84
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
CRS ourselves!

``` r
cities <- 
  cbind(st_drop_geometry(cities), 
        st_coordinates(cities))
head(cities, 10) # top 10 rows
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

### `sf` package

Note that also the [`stars`](https://r-spatial.github.io/stars/)
package, useful to represent *vector and raster data cubes*, uses the
below approach.

Let’s check whether **[`sf`](https://r-spatial.github.io/sf/)** uses
(for Windows: comes with) the minimal PROJ/GDAL versions that we want!

``` r
sf::sf_extSoftVersion()
```

              GEOS           GDAL         proj.4 GDAL_with_GEOS     USE_PROJ_H 
          "3.10.1"        "3.4.0"        "8.2.0"         "true"         "true" 
              PROJ 
           "8.2.0" 

Good to go!

#### Defining a CRS with `sf`

You can simply provide the EPSG code using `st_crs()`:

``` r
crs_wgs84 <- st_crs(4326) # WGS 84 has EPSG code 4326
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
        ENSEMBLE["World Geodetic System 1984 ensemble",
            MEMBER["World Geodetic System 1984 (Transit)"],
            MEMBER["World Geodetic System 1984 (G730)"],
            MEMBER["World Geodetic System 1984 (G873)"],
            MEMBER["World Geodetic System 1984 (G1150)"],
            MEMBER["World Geodetic System 1984 (G1674)"],
            MEMBER["World Geodetic System 1984 (G1762)"],
            MEMBER["World Geodetic System 1984 (G2139)"],
            ELLIPSOID["WGS 84",6378137,298.257223563,
                LENGTHUNIT["metre",1]],
            ENSEMBLEACCURACY[2.0]],
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
            SCOPE["Horizontal component of 3D system."],
            AREA["World."],
            BBOX[-90,-180,90,180]],
        ID["EPSG",4326]]

There are a few extras to note:

-   printing the `crs` object shows us both the EPSG code (more
    generally: the user’s CRS specification) and the WKT2 string:

``` r
crs_wgs84
```

    Coordinate Reference System:
      User input: EPSG:4326 
      wkt:
    GEOGCRS["WGS 84",
        ENSEMBLE["World Geodetic System 1984 ensemble",
            MEMBER["World Geodetic System 1984 (Transit)"],
            MEMBER["World Geodetic System 1984 (G730)"],
            MEMBER["World Geodetic System 1984 (G873)"],
            MEMBER["World Geodetic System 1984 (G1150)"],
            MEMBER["World Geodetic System 1984 (G1674)"],
            MEMBER["World Geodetic System 1984 (G1762)"],
            MEMBER["World Geodetic System 1984 (G2139)"],
            ELLIPSOID["WGS 84",6378137,298.257223563,
                LENGTHUNIT["metre",1]],
            ENSEMBLEACCURACY[2.0]],
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
            SCOPE["Horizontal component of 3D system."],
            AREA["World."],
            BBOX[-90,-180,90,180]],
        ID["EPSG",4326]]

-   if the user inputted the CRS with an EPSG code (which we did!), the
    latter can be returned as a number:

``` r
crs_wgs84$epsg
```

    [1] 4326

You *can* (but should you?) export a PROJ string as well, with
`crs_wgs84$proj4string`.

#### Set the CRS of an `sf` object

First we prepare an `sf` object from `cities` but still without a CRS:

``` r
cities2 <- st_as_sf(cities, coords = c("X", "Y"))
cities2
```

    Simple feature collection with 606 features and 4 fields
    Geometry type: POINT
    Dimension:     XY
    Bounding box:  xmin: -165.27 ymin: -53.15 xmax: 177.1302 ymax: 78.2
    CRS:           NA
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

Note the missing CRS!

Let’s add the CRS by using the EPSG code (we could also assign
`crs_wgs84` instead):

``` r
st_crs(cities2) <- 4326
```

Done!

#### Get the CRS of an `sf` object

Really, all you need is `st_crs()`, once more!

``` r
st_crs(cities2)
```

    Coordinate Reference System:
      User input: EPSG:4326 
      wkt:
    GEOGCRS["WGS 84",
        ENSEMBLE["World Geodetic System 1984 ensemble",
            MEMBER["World Geodetic System 1984 (Transit)"],
            MEMBER["World Geodetic System 1984 (G730)"],
            MEMBER["World Geodetic System 1984 (G873)"],
            MEMBER["World Geodetic System 1984 (G1150)"],
            MEMBER["World Geodetic System 1984 (G1674)"],
            MEMBER["World Geodetic System 1984 (G1762)"],
            MEMBER["World Geodetic System 1984 (G2139)"],
            ELLIPSOID["WGS 84",6378137,298.257223563,
                LENGTHUNIT["metre",1]],
            ENSEMBLEACCURACY[2.0]],
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
            SCOPE["Horizontal component of 3D system."],
            AREA["World."],
            BBOX[-90,-180,90,180]],
        ID["EPSG",4326]]

Great!

As this returns the `crs` object, you can also use `st_crs(cities2)$wkt`
to specifically return the WKT2 string!

### `sp` package

Note that the actively developed (and matured) `sf` package is now
recommended over the `sp` package (a view also shared by `sf` and `sp`
developers). The
**[`sp`](https://cran.r-project.org/web/packages/sp/index.html)**
package, which has very long been *the* go-to package before `sf`
matured, is maintained in order to support existing code, but it is not
further developed as much.

The `sp` package relies on the `rgdal` R package to communicate with
GDAL and PROJ, so let’s check whether `rgdal` uses (for Windows: comes
with) the minimal PROJ/GDAL versions that we want.

``` r
rgdal::rgdal_extSoftVersion()
```

              GDAL GDAL_with_GEOS           PROJ             sp           EPSG 
           "3.4.0"         "TRUE"        "8.2.0"        "1.4-6"      "v10.038" 

Okido.

#### Defining a CRS with `sp`

``` r
crs_wgs84 <- CRS(SRS_string = "EPSG:4326") # WGS 84 has EPSG code 4326
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

    GEOGCRS["WGS 84 (with axis order normalized for visualization)",
        ENSEMBLE["World Geodetic System 1984 ensemble",
            MEMBER["World Geodetic System 1984 (Transit)",
                ID["EPSG",1166]],
            MEMBER["World Geodetic System 1984 (G730)",
                ID["EPSG",1152]],
            MEMBER["World Geodetic System 1984 (G873)",
                ID["EPSG",1153]],
            MEMBER["World Geodetic System 1984 (G1150)",
                ID["EPSG",1154]],
            MEMBER["World Geodetic System 1984 (G1674)",
                ID["EPSG",1155]],
            MEMBER["World Geodetic System 1984 (G1762)",
                ID["EPSG",1156]],
            MEMBER["World Geodetic System 1984 (G2139)",
                ID["EPSG",1309]],
            ELLIPSOID["WGS 84",6378137,298.257223563,
                LENGTHUNIT["metre",1],
                ID["EPSG",7030]],
            ENSEMBLEACCURACY[2.0],
            ID["EPSG",6326]],
        PRIMEM["Greenwich",0,
            ANGLEUNIT["degree",0.0174532925199433],
            ID["EPSG",8901]],
        CS[ellipsoidal,2],
            AXIS["geodetic longitude (Lon)",east,
                ORDER[1],
                ANGLEUNIT["degree",0.0174532925199433,
                    ID["EPSG",9122]]],
            AXIS["geodetic latitude (Lat)",north,
                ORDER[2],
                ANGLEUNIT["degree",0.0174532925199433,
                    ID["EPSG",9122]]],
        USAGE[
            SCOPE["Horizontal component of 3D system."],
            AREA["World."],
            BBOX[-90,-180,90,180]],
        REMARK["Axis order reversed compared to EPSG:4326"]]

Also note that, when *printing* a `CRS` object of `sp` (e.g. by running
`crs_wgs84`), you still just get a PROJ string! We won’t print it here!
However do know that the WKT2 string is currently also *contained* in
the `CRS` object, just call `wkt()` to see it.

#### Set the CRS of a `Spatial*` object in `sp`

First we prepare a `SpatialPointsDataFrame` from `cities` but still
without a CRS:

``` r
cities2 <- cities
coordinates(cities2) <-  ~ X + Y
```

Now, we can add a CRS:

``` r
slot(cities2, "proj4string") <- crs_wgs84
```

Note the name of the `proj4string` slot in `cities2`: it still reminds
of old days, but the result is GDAL3/PROJ≥6 compliant!

#### Get the CRS of a `Spatial*` object in `sp`

Again, use `wkt()`: it works on both `CRS` and `Spatial*` objects!

``` r
cat(wkt(cities2))
```

    GEOGCRS["WGS 84 (with axis order normalized for visualization)",
        ENSEMBLE["World Geodetic System 1984 ensemble",
            MEMBER["World Geodetic System 1984 (Transit)",
                ID["EPSG",1166]],
            MEMBER["World Geodetic System 1984 (G730)",
                ID["EPSG",1152]],
            MEMBER["World Geodetic System 1984 (G873)",
                ID["EPSG",1153]],
            MEMBER["World Geodetic System 1984 (G1150)",
                ID["EPSG",1154]],
            MEMBER["World Geodetic System 1984 (G1674)",
                ID["EPSG",1155]],
            MEMBER["World Geodetic System 1984 (G1762)",
                ID["EPSG",1156]],
            MEMBER["World Geodetic System 1984 (G2139)",
                ID["EPSG",1309]],
            ELLIPSOID["WGS 84",6378137,298.257223563,
                LENGTHUNIT["metre",1],
                ID["EPSG",7030]],
            ENSEMBLEACCURACY[2.0],
            ID["EPSG",6326]],
        PRIMEM["Greenwich",0,
            ANGLEUNIT["degree",0.0174532925199433],
            ID["EPSG",8901]],
        CS[ellipsoidal,2],
            AXIS["geodetic longitude (Lon)",east,
                ORDER[1],
                ANGLEUNIT["degree",0.0174532925199433,
                    ID["EPSG",9122]]],
            AXIS["geodetic latitude (Lat)",north,
                ORDER[2],
                ANGLEUNIT["degree",0.0174532925199433,
                    ID["EPSG",9122]]],
        USAGE[
            SCOPE["Horizontal component of 3D system."],
            AREA["World."],
            BBOX[-90,-180,90,180]],
        REMARK["Axis order reversed compared to EPSG:4326"]]

Et voilà!

### `raster` package

Be aware that a [`terra`](https://rspatial.org/terra/pkg/) package has
been recently created as a successor to `raster`. It is aimed at faster
processing and it is *only* compatible with GDAL3/PROJ≥6.

As you will see, **[`raster`](https://rspatial.org/raster/pkg/)** more
or less aligns with `sp`, although it has a few extras. For example:
`raster` provides a `crs<-` replacement function to set the CRS.

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

    PROJCRS["BD72 / Belgian Lambert 72",
        BASEGEOGCRS["BD72",
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
                ID["EPSG",8827]]],
        CS[Cartesian,2],
            AXIS["easting (X)",east,
                ORDER[1],
                LENGTHUNIT["metre",1]],
            AXIS["northing (Y)",north,
                ORDER[2],
                LENGTHUNIT["metre",1]],
        USAGE[
            SCOPE["Engineering survey, topographic mapping."],
            AREA["Belgium - onshore."],
            BBOX[49.5,2.5,51.51,6.4]],
        ID["EPSG",31370]]

Let’s verify whether all objects do indeed have the same CRS:

``` r
all.equal(wkt(within_belgium1), wkt(within_belgium2))
```

    [1] TRUE

``` r
all.equal(wkt(within_belgium1), wkt(within_belgium3))
```

    [1] TRUE

``` r
all.equal(wkt(within_belgium1), wkt(within_belgium4))
```

    [1] TRUE

YES!

## Literature

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-bivand_ecs530_2019" class="csl-entry">

Bivand R. (2019). ECS530: (III) Coordinate reference systems. Tuesday 3
December 2019, 09:15-11.00, aud. C.
<https://rsbivand.github.io/ECS530_h19/ECS530_III.html#coordinate_reference_systems:_background>
(accessed September 16, 2020).

</div>

<div id="ref-bivand_migration_2020" class="csl-entry">

Bivand R. (2020a). Migration to PROJ6/GDAL3.
<http://rgdal.r-forge.r-project.org/articles/PROJ6_GDAL3.html> (accessed
September 21, 2020).

</div>

<div id="ref-bivand_how_2020_1" class="csl-entry">

Bivand R. (2020c). How R Helped Provide Tools for Spatial Data Analysis.
<https://github.com/rsbivand/celebRation20_files/raw/master/bivand_200229.pdf>.

</div>

<div id="ref-bivand_upstream_2020" class="csl-entry">

Bivand R. (2020b). Upstream software dependencies of the R-spatial
ecosystem (video recording). In: How R Helped Provide Tools for Spatial
Data Analysis @ CelebRation 2020. <https://youtu.be/D4-roPsMz48?t=2166>
(accessed September 21, 2020).

</div>

<div id="ref-nowosad_recent_2020" class="csl-entry">

Nowosad J. & Lovelace R. (2020). Recent changes in R spatial and how to
be ready for them.
<https://geocompr.github.io/post/2020/whyr_webinar004/> (accessed
September 21, 2020).

</div>

<div id="ref-pebesma_r_2020" class="csl-entry">

Pebesma E. & Bivand R. (2020). R spatial follows GDAL and PROJ
development. <https://www.r-spatial.org/r/2020/03/17/wkt.html> (accessed
September 21, 2020).

</div>

</div>

[^1]: ‘PROJ string’ is the term used in current PROJ documentation.
    Here, we only use ‘PROJ.4 string’ (or ‘proj4string’) when referring
    specifically to the PROJ string appearance in version 4 of the PROJ
    software.

[^2]: Note that the *currently returned* PROJ string for EPSG:31370, if
    requested from PROJ ≥ 6 or GDAL 3 (not shown), lacks the datum
    reference which, in PROJ.4, was defined indirectly by `+towgs84`
    with the 7-parameter (Helmert) transformation to the WGS 84 datum.
    Hence the current PROJ string is a deficient representation of
    EPSG:31370.

[^3]: Formerly, more geodetic datums could be specified in a PROJ string
    with the `+datum` key. Currently only `WGS84`, `NAD27` and `NAD83`
    are still supported this way. Further, if an ellipsoid is specified
    with `+ellps` (and that includes the WGS 84 ellipsoid), the datum of
    the resulting CRS is considered as ‘unknown.’ The usage of PROJ
    strings to define CRSs, including the `+datum` and `+towgs84`
    elements, will remain supported for mere backward compatibility (to
    support existing data sets), but is regarded deprecated and is
    discouraged by PROJ.

[^4]: An [ensemble
    datum](https://docs.opengeospatial.org/as/18-005r4/18-005r4.html#97)
    is a collection of different but closely related datum realizations
    without making a distinction between them. By not specifying the
    applicable datum realization for a coordinate data set, some degree
    of inaccuracy is allowed when using an ensemble datum as part of a
    CRS.

[^5]: In order to emphasize the fact that the improvements in version 2
    were instructive to the new versions of GDAL and PROJ, you will
    often see explicit mention of ‘WKT2.’

[^6]: The packages give a warning especially to make developers of
    *other*, dependent packages *aware* that they should also make sure
    their functions do not *require* PROJ strings or use hardcoded PROJ
    strings. Instead, they should defer the handling of CRS
    representation to the basic geospatial R packages (i.e. dependent on
    the version of PROJ/GDAL). So, the appearance of these warnings
    marks a period of transition in order to let other packages become
    GDAL 3 and PROJ ≥ 6 compliant. And the good news is that most
    popular geospatial packages *have* become GDAL 3 and PROJ ≥ 6
    compliant!

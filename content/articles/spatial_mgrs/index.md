---
title: "Notes about the Military Grid Reference System (MGRS), sometimes called 'UTM grid'"
description: ""
authors: [florisvdh]
date: 2023-05-03
categories: ["gis"]
tags: ["gis", "utm", "grids"]
output: 
  md_document:
    preserve_yaml: true
    variant: gfm+footnotes
---

## Introduction

In biodiversity monitoring the Military Grid Reference System (MGRS),
sometimes called the ‘UTM grid’ is used a lot. Example projects where
this spatial reference system is used are the Atlas Florae Europaea,
European Invertebrate Survey. In Belgium various faunistic inventories
use this grid.

This post contains the synthesis of a small literature study on the
topic.

## UTM versus MGRS

### UTM projection (Universal Transverse Mercator)

In the referred projects, it would be more appropriate to use the term
‘Military Grid Reference System’ (MGRS) than the term ‘UTM grid’.
Strictly spoken an ‘UTM grid’ should only refer to XY gridlines of a UTM
coordinate system (as in any projected coordinate system) and hence it’s
wrong to substitute ‘MGRS’ by ‘UTM’ (-grid, -coordinate, …).

Using ‘UTM grid’ to refer to the MGRS causes confusion and is actually
wrong for several reasons:

- UTM (Universal Transverse Mercator) itself is a map projection system
  for the Earth, composed of single Transverse Mercator projections
  (conformal, transverse cylindrical projection) for 60 ‘UTM zones’,
  each 6 degrees of longitude wide and reaching from South to North
  Pole. The largest part of Belgium (and the whole of Flanders) is
  situated in UTM zone 31, and the map projection called ‘UTM zone 31N’
  applies (‘N’ referring to the northern hemisphere). UTM projects
  geographical coordinates (degrees) to cartesian coordinates (meters),
  so the result is just XY coordinates like in other projections, often
  resulting in high numbers, especially for Y since that is
  ‘distance (m) north of the equator’ (for the northern hemisphere).

``` r
# R example: ETRS89 / UTM zone 31N coordinates of a point in Belgium
library(sf)
point <- st_sfc(st_point(c(4, 51)), crs = "OGC:CRS84")
st_transform(point, "EPSG:25831") |> st_coordinates()
```

    ##             X       Y
    ## [1,] 570168.9 5650301

- a ‘UTM grid’ should naturally refer to grid lines chosen in the
  cartesian coordinate system obtained by UTM projection (e.g. lines
  every 1 km, 2.5 km or 250 m depending on the map scale).
- UTM defines no explicit subdivisions of the cartesian coordinate
  system by means of latitude bands, square cells of size 100 km and
  further subdivisions thereof, let alone a separate geocoding system
  used to uniquely identify such resulting cells.

### MGRS (Military Grid Reference System)

The system of further subdivisions and geocoding of the cartesian
coordinate system is what the **MGRS** provides. The coordinate system
obtained by UTM projection is used in subdividing each UTM zone into
MGRS grid zones between 80°S and 84°N, and MGRS combines this with a UPS
(Universal Polar Stereographic) projection to apply subdivisions in the
polar regions.

The MGRS was designed by the end of the 1940s by the U.S. Army and is
used by NATO militaries for locating positions worldwide up to 1 m
resolution. It was designed to prevent the need for long numeric
coordinates.

An MGRS ‘grid reference’ (also called MGRS coordinate) is defined as:

    [Grid Zone Designation] [Grid Square ID] [Truncated integer X-coordinate] [Truncated integer Y-coordinate]

The spaces can be omitted or kept. The integer coordinates are truncated
depending on the desired precision, with the *maximum* of 5 digits
corresponding to a precision of 1 meter (i.e. the unit of the UTM
coordinate system).

An example is `31U ES 56914 61249` at the 1 m resolution, which resolves
to `31U ES 56 61` at 1 km resolution.

In the UTM area of MGRS (between 80°S and 84°N), an MGRS grid reference
is built as follows:

- The Grid Zone Designation (GZD), e.g. `31U`, combines the UTM
  zone (31) with the letter code (U) that corresponds to a latitude band
  of generally 8° high; each intersection defines an *MGRS grid zone* of
  6° x 8° large. In some places, this subdivision is subsequently
  altered to obtain more convenient units.
- Each grid zone is further subdivided in the UTM coordinate system into
  *grid squares* (cells) of size 100 km, such that their border
  coordinates match multiples of 100 000 m. The Grid Square ID is a code
  of 2 characters unique *within* the grid zone, e.g. `ES`, with ‘E’
  referring to a column and ‘S’ to a row. As grid zones get wider in the
  direction of the equator, more grid squares are present in zones near
  the equator than in zones located much further north or south.
- Next, each grid square gets its own coordinate system in meters, which
  is equivalent to dropping the digits that represent the
  hundred-thousands and higher in the numeric X and Y UTM coordinates
  (i.e. obtaining an integer coordinate of 5 digits). Hence, for grid
  squares that are not clipped by the UTM zone border, the origin (0, 0)
  is the southwest corner of the grid square. By truncating this
  integer, a precision can be chosen of 1, 10, 100, 1000 or 10 000
  meters.
  - Since coordinates are always truncated (not rounded) to integers,
    this effectively means that an MGRS grid reference represents a
    square cell with its size reflecting the chosen resolution, although
    potentially clipped by the UTM zone border. E.g. in `31U ES 1 4` X =
    1 refers to the semi-open interval \[10, 20\[ km.

## What is the relation to coordinate reference systems (CRSs)?

Projected CRSs combine a map projection (such as UTM) with a geodetic
datum that relates actual positions on the Earth surface to the
(unprojected) geodetic coordinate system, which also implies defining
the ellipsoid and prime meridian. So the geodetic datum is a property of
the geodetic CRS (3D) that is projected to a projected CRS (2D) for
mapping purposes. Without a geodetic datum, you won’t know the correct
position of a UTM coordinate or MGRS grid reference [^1]. See the [CRS
tutorial](../../tutorials/spatial_crs_coding/) for more information.

Although its aim is positioning, and although it needs a compound CRS
for implementation, MGRS is referred as a geocoding standard rather than
a CRS since it does not match the typical structure of a CRS – instead
it adds complexity on top of a compound CRS.

In Belgium, the most relevant UTM CRSs for UTM zone 31 are:

- ED50 / UTM zone 31N (`EPSG:23031`) which was applied in older maps
- ETRS89 / UTM zone 31N (`EPSG:25831`)
- WGS 84 / UTM zone 31N (`EPSG:32631`)

Run `sf::st_crs("EPSG:25831")` in R to inspect the WKT string.

## Authorative resources and data

An explicitly authorative resource appears not to exist, although many
resources are mutually consistent. Wikipedia mainly refers to several
documents of the NGA Office of Geomatics (<https://earth-info.nga.mil>).

The NGA Office of Geomatics
[distributes](https://earth-info.nga.mil/index.php?dir=coordsys&action=coordsys)
worldwide WGS 84 vector layers of MGRS grid polygons [up to 1
km](https://earth-info.nga.mil/index.php?dir=coordsys&action=mgrs-1km-polyline-dloads)
resolution.

The Geoplan Center provides an [MGRS site](http://mgrs-data.org) that
serves as a library for MGRS data and information, including [geospatial
layers](http://mgrs-data.org/data/).

The match of these layers with any WGS 84 UTM CRS and with the WGS 84
graticule of parallels and meridians can be easily verified post-hoc.

## Criticisms about the MGRS

Criticisms about the MGRS can be found. This mainly has to do with the
complexity of the system itself, even though the resulting coordinates
are shorter.

- The geocoding system is quite excentric compared to CRSs, especially
  in current times where computing power is available and handling large
  numeric coordinates is automated and mathematically simpler.
- The complexity may be a source of mistakes. A reknowned geodesist has
  advocated to not use it outside of the United States.

## Software implementations

MGRS and corresponding conversion methods have not been implemented in
PROJ because of the technical non-fit.

They have been implemented in open geospatial software though. The
following list may be incomplete:

- in the C++ library
  [GeographicLib](https://geographiclib.sourceforge.io). It grew out of
  a desire to improve on the GEOTRANS package for transforming between
  geographic and MGRS coordinates (see further). GeographicLib also
  provides utilities that can be run in a shell environment, such as
  `GeoConvert` for converting coordinates to or from MGRS. These
  utilities also have an
  [online](https://geographiclib.sourceforge.io/doc/library.html#online-utilities)
  implementation.
- by the [GEOTRANS](https://earth-info.nga.mil) executables and C
  libraries of the NGA Office of Geomatics. They provide various
  coordinate conversions and transformations.
- by the Python [mgrs](https://pypi.org/project/mgrs/) package that uses
  the GEOTRANS C library.
- in the QGIS plugin [Lat Lon
  Tools](https://plugins.qgis.org/plugins/latlontools/) by the National
  Security Agency ([code
  repo](https://github.com/NationalSecurityAgency/qgis-latlontools-plugin)).
  Apart from some geoprocessing algorithms, the plugin also provides a
  GUI for easy coordinate conversion based on interaction with the map.

Note that some of these implementations don’t require a geodetic datum
(hence CRS), but of course (converted) coordinates still need a geodetic
datum to refer to an actual position on the Earth surface and to use
them in maps.

Since it has not been implemented in PROJ, regular geospatial R packages
cannot convert to or from MGRS grid references.

One easy possibility to derive MGRS grid references in **R** is by
calling the QGIS plugin ‘Lat Lon Tools’ with the
[qgisprocess](https://github.com/r-spatial/qgisprocess) package,
e.g. calling its algorithm `latlontools:point2mgrs`.

Various online web applications allow to interactively determine MGRS
coordinates, or display the MGRS grid. One example is
[map.army](https://www.map.army/doc/en/map/coordinategrid/).

## Bibliography

[^1]: Older series of Belgian maps distributed by the NGI
    (\<www.ngi.be\>) used the ED50 geodetic datum
    ([datum:EPSG::6230](https://epsg.org/datum_6230/European-Datum-1950.html)),
    which affects the position of coordinates (hence MGRS grid) by about
    90 m in E-W direction and about 200 m in N-S direction compared to
    the WGS 84 datum
    ([datum:EPSG::6326](https://epsg.org/datum_6326/World-Geodetic-System-1984-ensemble.html)).

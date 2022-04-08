---
title: "Using WMS services in R"
description: "How to use WMS (raster) GIS services within R scripts"
authors: [thierryo, florisvdh]
date: 2022-04-08
categories: ["r", "gis"]
tags: ["gis", "webservice", "r", "maps"]
output: 
  md_document:
    preserve_yaml: true
    variant: gfm+footnotes
---

WMS stands for [Web Map
Service](https://en.wikipedia.org/wiki/Web_Map_Service). The service
provides prerendered tiles at different scales. This makes it useful to
include them as background images in maps.

We will use the `leaflet` package to make interactive maps.

``` r
library(leaflet)
```

First, we define some WMS URLs for Flanders and Belgium to play with:

``` r
# Flanders:
wms_grb <- "https://geoservices.informatievlaanderen.be/raadpleegdiensten/GRB-basiskaart/wms"
wms_ortho <- "https://geoservices.informatievlaanderen.be/raadpleegdiensten/OMWRGBMRVL/wms"
wms_inbo <- "https://geoservices.informatievlaanderen.be/raadpleegdiensten/INBO/wms"
wms_hunting <- "https://geoservices.informatievlaanderen.be/raadpleegdiensten/Jacht/wms"
# Belgium:
wms_cartoweb_be <- "https://cartoweb.wms.ngi.be/service"
wms_ortho_be <- "https://wms.ngi.be/inspire/ortho/service"
```

-   `wms_grb` links to the WMS of the
    [GRB-basiskaart](http://www.geopunt.be/catalogus/webservicefolder/aa04ae22-2297-98c3-1ffd-3440-5aff-bd2c-8a0cc151),
    the Flemish cadastral map. It depicts land parcels, buildings,
    watercourses, roads and railroads.

-   `wms_ortho` contains a mosaic of recent
    [orthophotos](http://www.geopunt.be/catalogus/webservicefolder/418e8e4a-12c1-80a8-8306-fcf4-799c-581d-c4e38594)
    made during the winter. The layer `Ortho` contains the images, the
    layer `Vliegdagcontour` detail on the time when the pictures were
    taken.

-   `wms_inbo` is a WMS providing [several layers]().

-   `wms_hunting` displays [hunting
    grounds](http://www.geopunt.be/catalogus/webservicefolder/525f1e17-c7d8-3bf3-550c-82c4-7fb3-e97c-a9bc3a6b)
    in Flanders.

-   `wms_cartoweb_be` provides several [cartographic layers from the
    National Geographic
    Institute](https://www.ngi.be/website/aanbod/digitale-geodata/cartoweb-be/)
    (NGI).

-   `wms_ortho_be` provides recent [orthophotos for the whole Belgian
    territory](https://www.geo.be/catalog/details/29238f19-ac79-4a4a-a797-5490226381ec?l=en),
    compiled by NGI.

In the WFS tutorial, we present a handy [**overview** of
websites](../spatial_wfs_services/#useful-overviews-of-web-feature-services)
with WMS (and WFS) services.

# Simple maps

WMS layers can be added to a `leaflet` map using the `addWMSTiles()`
function.

It is required to define the map view with `setView()`, by providing a
map center (as longitude and latitude coordinates) and a zoom level.

``` r
leaflet() %>% 
  setView(lng = 4.287638, lat = 50.703039, zoom = 15) %>%
  addWMSTiles(
    wms_grb,
    layers = "GRB_BSK",
    options = WMSTileOptions(format = "image/png", transparent = TRUE)
  )
```

![Leaflet map with the GRB-basiskaart as
background](index_files/figure-gfm/unnamed-chunk-4-1.png)

*Note: run the code to see this and the following interactive maps.*

``` r
leaflet() %>% 
  setView(lng = 4.287638, lat = 50.703039, zoom = 15) %>% 
  addWMSTiles(
    wms_ortho,
    layers = "Ortho",
    options = WMSTileOptions(format = "image/png", transparent = TRUE)
  )
```

![Leaflet map with the orthophoto mosaic as
background](index_files/figure-gfm/unnamed-chunk-5-1.png)

``` r
leaflet() %>% 
  setView(lng = 4.287638, lat = 50.703039, zoom = 15) %>% 
  addWMSTiles(
    wms_inbo,
    layers = "PNVeg",
    options = WMSTileOptions(format = "image/png", transparent = TRUE)
  )
```

![Leaflet map with the potential natural
vegetation](index_files/figure-gfm/unnamed-chunk-6-1.png)

``` r
leaflet() %>% 
  setView(lng = 4.287638, lat = 50.703039, zoom = 15) %>% 
  addWMSTiles(
    wms_cartoweb_be,
    layers = "topo",
    options = WMSTileOptions(format = "image/png")
  )
```

![Leaflet map of the topographic CartoWeb layer. At zoom level
15.](index_files/figure-gfm/unnamed-chunk-7-1.png)

Setting another zoom level of the CartoWeb service triggers the display
of another topographic map. Of course you can do that interactively with
the above map (not supported on this web site though).

``` r
leaflet() %>% 
  setView(lng = 4.287638, lat = 50.703039, zoom = 12) %>% 
  addWMSTiles(
    wms_cartoweb_be,
    layers = "topo",
    options = WMSTileOptions(format = "image/png")
  )
```

![Leaflet map of the topographic CartoWeb layer. At zoom level
12.](index_files/figure-gfm/unnamed-chunk-8-1.png)

# Combining multiple layers

Below, we also add OpenStreetMap in the background.

``` r
leaflet() %>% 
  setView(lng = 4.287638, lat = 50.703039, zoom = 14) %>% 
  addTiles(group = "OSM") %>%
  addWMSTiles(
    wms_hunting,
    layers = "Jachtterr",
    options = WMSTileOptions(format = "image/png", transparent = TRUE)
  )
```

![Leaflet map of hunting grounds with the OpenStreetMap in the
background](index_files/figure-gfm/unnamed-chunk-9-1.png)

By adding `addWMSTiles()` multiple times, several WMSs can be displayed
on top of each other.

``` r
leaflet() %>% 
  setView(lng = 4.287638, lat = 50.703039, zoom = 14) %>% 
  addTiles(group = "OSM") %>%
  addWMSTiles(
    wms_grb,
    layers = "GRB_BSK",
    options = WMSTileOptions(format = "image/png", transparent = TRUE),
    group = "GRB"
  ) %>%
  addWMSTiles(
    wms_hunting,
    layers = "Jachtterr",
    options = WMSTileOptions(format = "image/png", transparent = TRUE),
    group = "hunting<br>grounds"
  ) %>%
  addLayersControl(
    baseGroups = "OSM",
    overlayGroups = c("GRB", "hunting<br>grounds"),
    options = layersControlOptions(collapsed = FALSE)
  )
```

![Leaflet map with the GRB-basiskaart, hunting ground and the
OpenStreetMap (OSM) as
background](index_files/figure-gfm/unnamed-chunk-10-1.png)

The `overlay` layer of the NGI CartoWeb service is aimed at higher zoom
levels and is useful to put on top of a map. Here we take the NGI
orthophoto service as a background map. We must set the `overlay` layer
transparent in order to see the layers below – the default option being
`transparent = FALSE`.

``` r
leaflet() %>% 
  setView(lng = 4.287638, lat = 50.703039, zoom = 16) %>% 
  addWMSTiles(
    wms_ortho_be,
    layers = "orthoimage_coverage",
    group = "Orthophoto BE") %>%
  addWMSTiles(
    wms_cartoweb_be,
    layers = "overlay",
    options = WMSTileOptions(format = "image/png", transparent = TRUE),
    group = "Topo BE"
  ) %>%
  addLayersControl(
    baseGroups = "Orthophoto BE",
    overlayGroups = "Topo BE"
  )
```

![Leaflet map with the Belgian orthophoto mosaic as background and a
topographic overlay on
top](index_files/figure-gfm/unnamed-chunk-11-1.png)

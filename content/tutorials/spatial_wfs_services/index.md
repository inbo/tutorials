---
title: "Using WFS service in R"
description: "How to use WFS (vectors/features) GIS services within R scripts"
author: "Thierry Onkelinx"
date: 2018-03-07T16:50:01+01:00
categories: ["r"]
tags: ["gis", "webservice", "r", "maps"]
output: 
    md_document:
        preserve_yaml: true
        variant: markdown_github
---

What is WFS?
============

In computing, the Open Geospatial Consortium **Web Feature Service (WFS)** Interface Standard provides an interface allowing requests for geographical features across the web using platform-independent calls. One can think of geographical features as the "source code" behind a map, whereas the WMS interface or online tiled mapping portals like Google Maps return only an image, which end-users cannot edit or spatially analyze. The XML-based GML furnishes the default payload-encoding for transporting geographic features, but other formats like shapefiles can also serve for transport. In early 2006 the OGC members approved the OpenGIS GML Simple Features Profile. This profile is designed both to increase interoperability between WFS servers and to improve the ease of implementation of the WFS standard. (Source: [Wikipedia](https://en.wikipedia.org/wiki/Web_Feature_Service))

Download vector data from WFS
=============================

This examples illustrates how you can download information from a WFS for further use in R. First of all we need to URL of the service. Note that we appended the protocol `WFS:` in front of the URL. `ogrinfo()` from `gdalUtils` is used to extra some information on the service. `cat()` prints this information. The summary indicates that the service provides three layers: "BWK:Bwkhab", "BWK:Bwkfauna" and "BWK:Hab3260". It also reveals the kind of layers, in this case two polygon layers and one line layer.

``` r
wfs_bwk <- "WFS:https://geoservices.informatievlaanderen.be/overdrachtdiensten/BWK/wfs"
wfs_weather <- "WFS:http://opendata.meteo.be/service/aws/ows"
library(gdalUtils)
info <- ogrinfo(wfs_bwk, so = TRUE)
cat(info, sep = "\n")
```

    ## Had to open data source read-only.
    ## INFO: Open of `WFS:https://geoservices.informatievlaanderen.be/overdrachtdiensten/BWK/wfs'
    ##       using driver `WFS' successful.
    ## Metadata:
    ##   ABSTRACT=Directe downloadservice voor de Biologische Waarderingskaart en Natura 2000 Habitatkaart.
    ##   PROVIDER_NAME=agentschap Informatie Vlaanderen
    ##   TITLE=WFS Biologische Waarderingskaart en Natura 2000 Habitatkaart
    ## 1: BWK:Bwkhab (Curve Polygon)
    ## 2: BWK:Bwkfauna (Curve Polygon)
    ## 3: BWK:Hab3260 (Line String)

Let's start by downloading the "BWK:Bwkhab" layer for the Hallerbos area. We use `ogr2ogr()` from the `gdalUtils` package. The main part is defining the input and output. We store the data in [GeoJSON](https://en.wikipedia.org/wiki/GeoJSON) format which is an open standard format designed for representing simple geographical features, along with their non-spatial attributes. It is based on JSON, the JavaScript Object Notation.

We also add the bounding box from which we want to retrieve the data. This is very important to add. If you omit a bounding box, the service will return the entire map which can be very large.

``` r
ogr2ogr(
  src_datasource_name = wfs_bwk,           # the input source
  layer = "BWK:Bwkhab",                    # the layer from the input
  dst_datasource_name = "bwkhab.geojson",  # the target file
  f = "geojson",                           # the target format
  spat = c(left = 142600, bottom = 153800, right = 146000, top = 156900),
                                           # the bounding box
  t_srs = "EPSG:31370",                    # the coordinate reference system
  verbose = TRUE
)
```

    ## Checking gdal_installation...

    ## Scanning for GDAL installations...

    ## Checking the gdalUtils_gdalPath option...

    ## GDAL version 2.2.2

    ## GDAL command being used: "/usr/bin/ogr2ogr" -spat 142600 153800 146000 156900 -f "geojson" -t_srs "EPSG:31370" "bwkhab.geojson" "WFS:https://geoservices.informatievlaanderen.be/overdrachtdiensten/BWK/wfs" "BWK:Bwkhab"

    ## character(0)

At this point, all features are downloaded and can be used in R as we would we any other local file. So we need to load the file with `readOGR()` from `rgdal`.

``` r
library(rgdal)
```

    ## Loading required package: sp

    ## rgdal: version: 1.3-6, (SVN revision 773)
    ##  Geospatial Data Abstraction Library extensions to R successfully loaded
    ##  Loaded GDAL runtime: GDAL 2.2.2, released 2017/09/15
    ##  Path to GDAL shared files: /usr/share/gdal/2.2
    ##  GDAL binary built with GEOS: TRUE 
    ##  Loaded PROJ.4 runtime: Rel. 4.9.2, 08 September 2015, [PJ_VERSION: 492]
    ##  Path to PROJ.4 shared files: (autodetected)
    ##  Linking to sp version: 1.2-3

``` r
bwkhab <- readOGR("bwkhab.geojson", stringsAsFactors = FALSE)
```

    ## OGR data source with driver: GeoJSON 
    ## Source: "/home/stijn_vanhoey/githubs/inbo_tutorials/content/tutorials/spatial_wfs_services/bwkhab.geojson", layer: "BWK:Bwkhab"
    ## with 314 features
    ## It has 32 fields

``` r
summary(bwkhab)
```

    ## Object of class SpatialPolygonsDataFrame
    ## Coordinates:
    ##        min      max
    ## x 137307.1 146356.1
    ## y 153734.4 165353.8
    ## Is projected: TRUE 
    ## proj4string :
    ## [+proj=lcc +lat_1=51.16666723333333 +lat_2=49.8333339 +lat_0=90
    ## +lon_0=4.367486666666666 +x_0=150000.013 +y_0=5400088.438
    ## +ellps=intl
    ## +towgs84=-106.8686,52.2978,-103.7239,0.3366,-0.457,1.8422,-1.2747
    ## +units=m +no_defs]
    ## Data attributes:
    ##     gml_id               UIDN             OIDN            TAG           
    ##  Length:314         Min.   :  1184   Min.   :  1184   Length:314        
    ##  Class :character   1st Qu.:175124   1st Qu.:173440   Class :character  
    ##  Mode  :character   Median :338130   Median :335492   Mode  :character  
    ##                     Mean   :332296   Mean   :327872                     
    ##                     3rd Qu.:491850   3rd Qu.:488782                     
    ##                     Max.   :659382   Max.   :637654                     
    ##      EVAL              EENH1              EENH2          
    ##  Length:314         Length:314         Length:314        
    ##  Class :character   Class :character   Class :character  
    ##  Mode  :character   Mode  :character   Mode  :character  
    ##                                                          
    ##                                                          
    ##                                                          
    ##     EENH3              EENH4              EENH5          
    ##  Length:314         Length:314         Length:314        
    ##  Class :character   Class :character   Class :character  
    ##  Mode  :character   Mode  :character   Mode  :character  
    ##                                                          
    ##                                                          
    ##                                                          
    ##     EENH6              EENH7              EENH8          
    ##  Length:314         Length:314         Length:314        
    ##  Class :character   Class :character   Class :character  
    ##  Mode  :character   Mode  :character   Mode  :character  
    ##                                                          
    ##                                                          
    ##                                                          
    ##       V1                 V2                 V3           
    ##  Length:314         Length:314         Length:314        
    ##  Class :character   Class :character   Class :character  
    ##  Mode  :character   Mode  :character   Mode  :character  
    ##                                                          
    ##                                                          
    ##                                                          
    ##      HERK               INFO             BWKLABEL        
    ##  Length:314         Length:314         Length:314        
    ##  Class :character   Class :character   Class :character  
    ##  Mode  :character   Mode  :character   Mode  :character  
    ##                                                          
    ##                                                          
    ##                                                          
    ##      HAB1               PHAB1            HAB2               PHAB2       
    ##  Length:314         Min.   : 40.00   Length:314         Min.   : 0.000  
    ##  Class :character   1st Qu.:100.00   Class :character   1st Qu.: 0.000  
    ##  Mode  :character   Median :100.00   Mode  :character   Median : 0.000  
    ##                     Mean   : 95.83                      Mean   : 4.108  
    ##                     3rd Qu.:100.00                      3rd Qu.: 0.000  
    ##                     Max.   :100.00                      Max.   :50.000  
    ##      HAB3               PHAB3              HAB4               PHAB4  
    ##  Length:314         Min.   : 0.00000   Length:314         Min.   :0  
    ##  Class :character   1st Qu.: 0.00000   Class :character   1st Qu.:0  
    ##  Mode  :character   Median : 0.00000   Mode  :character   Median :0  
    ##                     Mean   : 0.06369                      Mean   :0  
    ##                     3rd Qu.: 0.00000                      3rd Qu.:0  
    ##                     Max.   :20.00000                      Max.   :0  
    ##      HAB5               PHAB5     HERKHAB            HERKPHAB        
    ##  Length:314         Min.   :0   Length:314         Length:314        
    ##  Class :character   1st Qu.:0   Class :character   Class :character  
    ##  Mode  :character   Median :0   Mode  :character   Mode  :character  
    ##                     Mean   :0                                        
    ##                     3rd Qu.:0                                        
    ##                     Max.   :0                                        
    ##   HABLEGENDE       
    ##  Length:314        
    ##  Class :character  
    ##  Mode  :character  
    ##                    
    ##                    
    ## 

Let's make a simple plot of the object. Note that the object contains features outside of the bounding box. Those are features which have only some part within the bounding box.

``` r
spplot(bwkhab, zcol = "PHAB1", scales = list(draw = TRUE))
```

![](index_files/figure-markdown_github/unnamed-chunk-5-1.png)

Download feature attribute data from WFS
========================================

In some situations, we do not need the spatial features (polygons, lines, points), but are interested in the data at a particular point (i.e. attribute table data) of the spatial feature. When working in a local GIS environment, one would use a spatial operator to extract the data (e.g. `within`, `intersects`, `contains`,...). Actually, WFS supports certain spatial operators as part of the service to directly query this data and overcomes the need to download the spatial feature data first.

We rely on the `httr` package to talk to web services:

``` r
library(httr)  # generic webservice package
```

Consider the following use case: You want to extract the attribute data from a [soil map](http://www.geopunt.be/catalogus/datasetfolder/5c129f2d-4498-4bc3-8860-01cb2d513f8f) for a number of sampling points (point coordinates). This use case can be tackled by relying on the WFS service and the affiliated spatial operators.

Our example data point (in Lambert 72):

``` r
x_lam <- 173995.67
y_lam <- 212093.44
```

From this point we know the data, so we can verify the result (in dutch):

-   Bodemtype: s-Pgp3(v)
-   Bodemserie: Pgp
-   Textuurklasse: licht zandleem
-   Drainageklasse: uiterst nat, gereduceerd

Hence, we now want to extract these soil properties from the WFS, for the coordinates defined above.

``` r
properties_of_interest <- c("Drainageklasse",
                            "Textuurklasse",
                            "Bodemserie",
                            "Bodemtype")
```

The URL of the wfs service of the soil map of the Flemish region:

``` r
wfs_bodemtypes <- "https://www.dov.vlaanderen.be/geoserver/bodemkaart/bodemtypes/wfs?"
```

The essential part is to set up the proper query! The required data for the service is defined in the [metadata](https://www.dov.vlaanderen.be/geoserver/bodemkaart/bodemtypes/wfs?version=1.1.0&request=GetCapabilities&service=wfs) description. This can look a bit overwhelming in the start, but is a matter of looking for some specific elements of the (XML) document:

-   `service` (WFS), `request` (GetFeature) and `version` (1.1.0) are mandatory fields (see below)
-   `typeName`: Look at the different `<FeatureType...` enlisted and pick the `<Name>` of the one you're interested in. In this particular case `bodemkaart:bodemtypes` is the only one available.
-   `outputFormat`: The supported output formats are enlisted in `<ows:Parameter name="outputFormat">`. As the service provides CSV as output, this is a straightforward option. `json` is another popular one.
-   `propertyname`: A list of the attribute table fields (cfr. supra). A full list of the Flanders soil map is provided [here](https://www.dov.vlaanderen.be/geoserver/bodemkaart/bodemtypes/wfs?request=DescribeFeatureType).
-   We also define the `CRS`, using the [EPSG code](http://spatialreference.org/).
-   `CQL_FILTER`: Define the spatial operator, in this case `INTERSECTS` of the WFS `geom` and our `POINT` coordinate. The operators are enlisted in the `<fes:SpatialOperators>` field.

Formatting all this information in a query and executing the request (`GET`) towards the service:

``` r
query = list(service = "WFS",
             request = "GetFeature",
             version = "1.1.0",
             typeName = "bodemkaart:bodemtypes",
             outputFormat = "csv",
             propertyname = as.character(paste(properties_of_interest,
                                               collapse = ",")),
             CRS = "EPSG:31370",
             CQL_FILTER = sprintf("INTERSECTS(geom,POINT(%s %s))",
                                  x_lam, y_lam)) 
result <- GET(wfs_bodemtypes, query = query)
result
```

    ## Response [https://www.dov.vlaanderen.be/geoserver/bodemkaart/bodemtypes/wfs?service=WFS&request=GetFeature&version=1.1.0&typeName=bodemkaart%3Abodemtypes&outputFormat=csv&propertyname=Drainageklasse%2CTextuurklasse%2CBodemserie%2CBodemtype&CRS=EPSG%3A31370&CQL_FILTER=INTERSECTS%28geom%2CPOINT%28173995.67%20212093.44%29%29]
    ##   Date: 2018-12-13 15:13
    ##   Status: 200
    ##   Content-Type: text/csv;charset=UTF-8
    ##   Size: 129 B
    ## FID,Bodemtype,Bodemserie,Textuurklasse,Drainageklasse
    ## bodemtypes.72727,s-Pgp3(v),Pgp,licht zandleem,"uiterst nat, gereduceerd"

The result is not yet formatted to be used as a dataframe. We need to use a small *trick* using the `textConnection` function to get from the result (bits) towards a readable output in a dataframe:

``` r
df <- read.csv(textConnection(content(result, 'text')))
kable(df)
```

| FID              | Bodemtype | Bodemserie | Textuurklasse  | Drainageklasse           |
|:-----------------|:----------|:-----------|:---------------|:-------------------------|
| bodemtypes.72727 | s-Pgp3(v) | Pgp        | licht zandleem | uiterst nat, gereduceerd |

Which indeed corresponds to the data of the coordinate.

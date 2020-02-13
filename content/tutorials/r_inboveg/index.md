---
title: "Tutorial on how to retrieve data from the INBOVEG database"
author: "Els De Bie, Hans Van Calster & Jo Loos"
date: 2020-02-11
categories: ["databases"]
tags: ["database", "queries"] 
output: 
  md_document:
    preserve_yaml: true
---

Introduction
============

The Flemish vegetation database, INBOVEG, is an application developed to
provide a repository of relevés and makes the relevés available for
future use.

INBOVEG supports different types of recordings: BioHab recordings
(protocol of Natura 2000 monitoring) and the classic relevés. The
classic relevés can stand alone, be an element of a collection or
element of a chain where the linkage is used to give information about
the relative position of recording within a series. Ample selection and
export functions toward analysis tools are provided. It also provides
standardized lists of species, habitats, life forms, scales etc.
Original observations are preserved and a full history of subsequent
identifications is saved.

Aim
===

In this tutorial we make functions available to query data directly from
the INBOVEG SQL-server database. This to avoid writing your own queries
or to copy/paste them from the access-frontend for INBOVEG.

We have provided functions to query

-   survey (INBOVEG-projects)

-   recordings (vegetation relevés)

-   metadata of recordings (header info)

-   classification (Natura2000 or local classification like BWK)

-   qualifiers (management and site characteristics)

Packages and connection
=======================

In order to run the functionalities, some R packags need to be
installed.

The main functions that we will use in this tutorial all start with
`inboveg_*`. These functions are made available by loading the
`inborutils` package.

You can install inborutils from github with:

    install.packages("devtools")
    devtools::install_github("inbo/inborutils")

This tutorial will only work for people with access to the INBO network.
As an INBO employee, you should make sure you have reading-rights for
CYDONIA, otherwise place an ICT-call.

    library(glue)
    library(DBI)
    library(assertthat)
    library(dplyr)
    library(inborutils)

The following R-code can be used to establish a connection to INBOVEG by
using 'connect\_inbo\_dbase' of the inborutils-package with the database
'Cydonia' on the inbo-sql07-prd server:

    con <- connect_inbo_dbase("D0010_00_Cydonia")

Functionality
=============

Survey information
------------------

The function `inboveg_survey` queries the INBOVEG database for survey
information (metadata about surveys) for one or more survey(s) by the
name of the survey.

### Examples

Three examples are given, this can be used as base to continue selecting
the wanted data.

Get information of a specific survey and collect data.

    survey_info <- inboveg_survey(con, 
                                  survey_name = "OudeLanden_1979", 
                                  collect = TRUE)

    survey_info

    ## # A tibble: 1 x 5
    ##      Id Name       Description                                Owner creator
    ##   <int> <chr>      <chr>                                      <chr> <chr>  
    ## 1   172 OudeLande… Verlinden A, Leys G en Slembrouck J (1979… <NA>  els_de…

Get information of all surveys. This time we will not use
`collect = TRUE`, which will return a [lazy
query](https://docs.lucee.org/guides/cookbooks/lazy_queries.html):

    allsurveys <- inboveg_survey(con)

    allsurveys

    ## # Source:   SQL [?? x 5]
    ## # Database: Microsoft SQL Server
    ## #   13.00.5598[INBO\hans_vancalster@INBO-SQL07-PRD\LIVE/D0010_00_Cydonia]
    ##       Id Name           Description                     Owner    creator   
    ##    <int> <chr>          <chr>                           <chr>    <chr>     
    ##  1     1 ZLB            Opnamen Zandleembrabant en omg… Gisèle … luc_vanhe…
    ##  2     2 Sigma_Biohab_… Biohab opnames  in Sigmagebied… Wim Mer… wim_merte…
    ##  3     3 Sigma_LSVI_20… Perceelsopnamen van volledige … wim mer… wim_merte…
    ##  4     4 MILKLIM_Alope… Standplaatsonderzoek graslande… MILKLIM  maud_raman
    ##  5     5 MILKLIM_WZ_Aa… Opnamen van PQ's in regio Aals… MILKLIM  floris_va…
    ##  6     6 MILKLIM_Hei(s… PQ's in kader van onderzoek na… MILKLIM  floris_va…
    ##  7     7 MILKLIM_Heide  Standplaatsonderzoek heide      MILKLIM  jan_woute…
    ##  8     8 MILKLIM_W&Z_L… Evaluatie maaibeheer Leieberme… MILKLIM  maud_raman
    ##  9     9 MILKLIM_W&Z_G… Vegetatieopnames in het kader … MILKLIM  luc_vanhe…
    ## 10    10 MILKLIM_Heisc… Vegetatieopnames in het kader … MILKLIM  cecile_he…
    ## # … with more rows

If only a part of the survey name is known, you can make use of
wildcards such as %.

    partsurveys <- inboveg_survey(con, 
                                  survey_name = "%MILKLIM%",
                                  collect = TRUE)

    head(partsurveys, 10)

    ## # A tibble: 10 x 5
    ##       Id Name             Description                     Owner  creator   
    ##    <int> <chr>            <chr>                           <chr>  <chr>     
    ##  1     4 MILKLIM_Alopecu… Standplaatsonderzoek graslande… MILKL… maud_raman
    ##  2     5 MILKLIM_WZ_Aals… Opnamen van PQ's in regio Aals… MILKL… floris_va…
    ##  3     6 MILKLIM_Hei(sch… PQ's in kader van onderzoek na… MILKL… floris_va…
    ##  4     7 MILKLIM_Heide    Standplaatsonderzoek heide      MILKL… jan_woute…
    ##  5     8 MILKLIM_W&Z_Lei… Evaluatie maaibeheer Leieberme… MILKL… maud_raman
    ##  6     9 MILKLIM_W&Z_Ger… Vegetatieopnames in het kader … MILKL… luc_vanhe…
    ##  7    10 MILKLIM_Heischr… Vegetatieopnames in het kader … MILKL… cecile_he…
    ##  8    11 MILKLIM_W&Z_Var… Losse opnamen in het kader van… MILKL… floris_va…
    ##  9    12 MILKLIM_W&Z_Ber… Ecologische opvolging van berm… MILKL… els_debie 
    ## 10    14 MILKLIM_W&Z_Oev… Oeveropnamen langs de Leie ter… Maud … luc_vanhe…

Recording information
---------------------

The function `inboveg_recordings` queries the INBOVEG database for
relevé information (which species were recorded in which plots and in
which vegetation layers with which cover) for one or more surveys.

### Examples

Four examples are given, this can be used as base to continue selecting
the wanted data.

Get the relevés from one survey and collect the data

    recording_heischraal2012 <- inboveg_recordings(con, 
                                          survey_name = "MILKLIM_Heischraal2012",
                                          collect = TRUE)

    head(recording_heischraal2012, 10)

    ## # A tibble: 10 x 10
    ##    Name  RecordingGivid LayerCode CoverCode OrignalName ScientificName
    ##    <chr> <chr>          <chr>     <chr>     <chr>       <chr>         
    ##  1 MILK… IV20120816113… M         5         Rhytidiade… Rhytidiadelph…
    ##  2 MILK… IV20120816113… M         5         Pseudoscle… Pseudosclerop…
    ##  3 MILK… IV20120816113… K         90        Juncus acu… Juncus acutif…
    ##  4 MILK… IV20120816113… K         90        Nardus str… Nardus strict…
    ##  5 MILK… IV20120816113… K         90        Potentilla… Potentilla er…
    ##  6 MILK… IV20120816113… K         90        Anthoxanth… Anthoxanthum …
    ##  7 MILK… IV20120816113… K         90        Molinia ca… Molinia caeru…
    ##  8 MILK… IV20120816113… K         90        Lysimachia… Lysimachia vu…
    ##  9 MILK… IV20120816113… K         90        Luzula mul… Luzula multif…
    ## 10 MILK… IV20120816113… K         90        Carex pilu… Carex pilulif…
    ## # … with 4 more variables: PhenologyCode <chr>, CoverageCode <chr>,
    ## #   PctValue <dbl>, RecordingScale <chr>

Get all recordings from MILKLIM surveys (partial matching), don't
collect

    recording_milkim <- inboveg_recordings(con,
                                  survey_name = "%MILKLIM%")

    recording_milkim

    ## # Source:   SQL [?? x 10]
    ## # Database: Microsoft SQL Server
    ## #   13.00.5598[INBO\hans_vancalster@INBO-SQL07-PRD\LIVE/D0010_00_Cydonia]
    ##    Name  RecordingGivid LayerCode CoverCode OrignalName ScientificName
    ##    <chr> <chr>          <chr>     <chr>     <chr>       <chr>         
    ##  1 MILK… IV20120802143… KH        99        Alopecurus… Alopecurus pr…
    ##  2 MILK… IV20120806123… KH        99        Lolium per… Lolium perenn…
    ##  3 MILK… IV20120806123… KH        99        Dactylis g… Dactylis glom…
    ##  4 MILK… IV20120806123… KH        99        Poa trivia… Poa trivialis…
    ##  5 MILK… IV20120806123… KH        99        Agrostis s… Agrostis stol…
    ##  6 MILK… IV20120806123… KH        99        Ranunculus… Ranunculus re…
    ##  7 MILK… IV20120806123… KH        99        Ranunculus… Ranunculus ac…
    ##  8 MILK… IV20120806123… KH        99        Avenula pu… Avenula pubes…
    ##  9 MILK… IV20120806123… KH        99        Festuca ru… Festuca rubra…
    ## 10 MILK… IV20120806123… KH        99        Cardamine … Cardamine pra…
    ## # … with more rows, and 4 more variables: PhenologyCode <chr>,
    ## #   CoverageCode <chr>, PctValue <dbl>, RecordingScale <chr>

Get recordings from several specific surveys

    recording_severalsurveys <- inboveg_recordings(con,
                    survey_name = c("MILKLIM_Heischraal2012", "NICHE Vlaanderen"),
                    multiple = TRUE,
                    collect = TRUE)

    head(recording_severalsurveys, 10)

    ## # A tibble: 10 x 10
    ##    Name  RecordingGivid LayerCode CoverCode OrignalName ScientificName
    ##    <chr> <chr>          <chr>     <chr>     <chr>       <chr>         
    ##  1 MILK… IV20120816113… M         5         Rhytidiade… Rhytidiadelph…
    ##  2 MILK… IV20120816113… M         5         Pseudoscle… Pseudosclerop…
    ##  3 MILK… IV20120816113… K         90        Juncus acu… Juncus acutif…
    ##  4 MILK… IV20120816113… K         90        Nardus str… Nardus strict…
    ##  5 MILK… IV20120816113… K         90        Potentilla… Potentilla er…
    ##  6 MILK… IV20120816113… K         90        Anthoxanth… Anthoxanthum …
    ##  7 MILK… IV20120816113… K         90        Molinia ca… Molinia caeru…
    ##  8 MILK… IV20120816113… K         90        Lysimachia… Lysimachia vu…
    ##  9 MILK… IV20120816113… K         90        Luzula mul… Luzula multif…
    ## 10 MILK… IV20120816113… K         90        Carex pilu… Carex pilulif…
    ## # … with 4 more variables: PhenologyCode <chr>, CoverageCode <chr>,
    ## #   PctValue <dbl>, RecordingScale <chr>

Get all relevés of all surveys, don't collect the data

    allrecordings <- inboveg_recordings(con)

    allrecordings

    ## # Source:   SQL [?? x 10]
    ## # Database: Microsoft SQL Server
    ## #   13.00.5598[INBO\hans_vancalster@INBO-SQL07-PRD\LIVE/D0010_00_Cydonia]
    ##    Name  RecordingGivid LayerCode CoverCode OrignalName ScientificName
    ##    <chr> <chr>          <chr>     <chr>     <chr>       <chr>         
    ##  1 ZLB   IV20120524163… B         75        Betula pen… Betula pendul…
    ##  2 ZLB   IV20120524163… B         75        Populus x … Populus x can…
    ##  3 ZLB   IV20120524163… B         75        Prunus avi… Prunus avium …
    ##  4 ZLB   IV20120524163… B         75        Fagus sylv… Fagus sylvati…
    ##  5 ZLB   IV20120524163… B         75        Acer campe… Acer campestr…
    ##  6 ZLB   IV20120524163… K         85        Fagus sylv… Fagus sylvati…
    ##  7 ZLB   IV20120524163… K         85        Athyrium f… Athyrium fili…
    ##  8 ZLB   IV20120524163… S         50        Corylus av… Corylus avell…
    ##  9 ZLB   IV20120524163… S         50        Crataegus … Crataegus mon…
    ## 10 ZLB   IV20120524163… S         50        Fraxinus e… Fraxinus exce…
    ## # … with more rows, and 4 more variables: PhenologyCode <chr>,
    ## #   CoverageCode <chr>, PctValue <dbl>, RecordingScale <chr>

Header information
------------------

The function `inboveg_header` queries the INBOVEG database for header
information (metadata for a vegetation-relevé) for one survey by the
name of the survey and the recorder type.

### Examples

Two examples are given, this can be used as base to continue selecting
the wanted data.

Get header information from a specific survey and a specific recording
type and collect the data:

    header_info <- inboveg_header(con, 
                                  survey_name = "OudeLanden_1979",
                                  rec_type = "Classic",
                                  collect = TRUE)

    head(header_info, 10)

    ## # A tibble: 10 x 11
    ##    RecordingGivid Name  UserReference LocationCode Latitude Longitude  Area
    ##    <chr>          <chr> <chr>         <chr>           <dbl>     <dbl> <dbl>
    ##  1 IV20160210164… Oude… 23            Ekeren            500       500     6
    ##  2 IV20160210163… Oude… 18            Ekeren            500       500    12
    ##  3 IV20160210162… Oude… 19            Ekeren            500       500    12
    ##  4 IV20160210161… Oude… 17            Ekeren            500       500    12
    ##  5 IV20160210160… Oude… 20            Ekeren            500       500     9
    ##  6 IV20160210155… Oude… 81            Ekeren            500       500     9
    ##  7 IV20160210153… Oude… 4             Ekeren            500       500    12
    ##  8 IV20160210142… Oude… 2             Ekeren            500       500    25
    ##  9 IV20160210140… Oude… 1             Ekeren            500       500    25
    ## 10 IV20160210121… Oude… 5             Ekeren            500       500    10
    ## # … with 4 more variables: Length <int>, Width <int>, SurveyId <int>,
    ## #   RecTypeID <int>

Get header information of all surveys, don't collect the data

    all_header_info <- inboveg_header(con)

    all_header_info

    ## # Source:   SQL [?? x 11]
    ## # Database: Microsoft SQL Server
    ## #   13.00.5598[INBO\hans_vancalster@INBO-SQL07-PRD\LIVE/D0010_00_Cydonia]
    ##    RecordingGivid Name  UserReference LocationCode Latitude Longitude  Area
    ##    <chr>          <chr> <chr>         <chr>           <dbl>     <dbl> <dbl>
    ##  1 IV20120524163… ZLB   ZLB-GW-2011-… Overijse        500      500       20
    ##  2 IV20120608135… ZLB   ZLB-GW-2011-… Overijse        500      500        3
    ##  3 IV20120608155… Sigm… wm2012-0001   Weymeerbroek    500      500       NA
    ##  4 IV20120608161… Sigm… wm2012-0002   Weymeerbroek    500      500       NA
    ##  5 IV20120608163… ZLB   ZLB-GW-2006-… Rosières        500      500      100
    ##  6 IV20120614155… ZLB   ZLB-GW-2005-… Rixensart       500      500        2
    ##  7 IV20120802135… MILK… 130           Heist op de…     51.1      4.75     9
    ##  8 IV20120802143… MILK… 131           Heist op de…     51.1      4.75     9
    ##  9 IV20120802150… MILK… 131B          Heist op de…     51.1      4.75     9
    ## 10 IV20120802153… MILK… 378           Schulens Br…     51.0      5.17     9
    ## # … with more rows, and 4 more variables: Length <int>, Width <int>,
    ## #   SurveyId <int>, RecTypeID <int>

Classification information
--------------------------

The function `inboveg_classification` queries the INBOVEG database for
information on the field classification (N2000 or BWK-code) of the
relevé for one or more survey(s) by the name of the survey.

### Examples

Two examples are given, this can be used as base to continue selecting
the wanted data.

Get a specific classification from a survey and collect the data:

    classif_info <- inboveg_classification(con, 
                                  survey_name = "MILKLIM_Heischraal2012",
                                  classif = "4010",
                                  collect = TRUE)

    head(classif_info, 10)

    ## # A tibble: 1 x 9
    ##   RecordingGivid Name  Classif ActionGroup ListName LocalClassifica…
    ##   <chr>          <chr> <chr>   <chr>       <chr>    <chr>           
    ## 1 IV20130318144… MILK… 4010    N2k         Habitat… <NA>            
    ## # … with 3 more variables: Habitattype <chr>, Cover <chr>, PctValue <dbl>

Get all surveys, all classifications, don't collect the data

    allecodes <- inboveg_classification(con)

    allecodes

    ## # Source:   SQL [?? x 9]
    ## # Database: Microsoft SQL Server
    ## #   13.00.5598[INBO\hans_vancalster@INBO-SQL07-PRD\LIVE/D0010_00_Cydonia]
    ##    RecordingGivid Name  Classif ActionGroup ListName LocalClassifica…
    ##    <chr>          <chr> <chr>   <chr>       <chr>    <chr>           
    ##  1 IV20120524163… ZLB   vc      BWK         Ecotoop… "elzen-essenbos…
    ##  2 IV20120524163… ZLB   qa      BWK         Ecotoop… "eiken-haagbeuk…
    ##  3 IV20120608155… Sigm… kd      BWK         Ecotoop… "dijk "         
    ##  4 IV20120608161… Sigm… kbj     BWK         Ecotoop… "bomenrij met d…
    ##  5 IV20120608163… ZLB   vm      BWK         Ecotoop… "mesotroof elze…
    ##  6 IV20120608135… ZLB   mk      BWK         Ecotoop… "alkalisch laag…
    ##  7 IV20120614155… ZLB   msb-    BWK         Ecotoop… "zuur laagveen …
    ##  8 IV20120802135… MILK… k(hf)   BWK         Ecotoop… "bermen, percee…
    ##  9 IV20120802135… MILK… k(hc)   BWK         Ecotoop… "bermen, percee…
    ## 10 IV20120802135… MILK… hp+     BWK         Ecotoop… "soortenrijk pe…
    ## # … with more rows, and 3 more variables: Habitattype <chr>, Cover <chr>,
    ## #   PctValue <dbl>

Qualifiers information
----------------------

This function `inboveg_qualifiers`queries the INBOVEG database for
qualifier information on recordings for one or more surveys. These
qualifiers give information on management, location description, ...

### Examples

Four examples are given, this can be used as base to continue selecting
the wanted data.

Get the qualifiers from one survey

    qualifiers_heischraal2012 <- inboveg_qualifiers(con,
                                      survey_name = "MILKLIM_Heischraal2012")

    head(qualifiers_heischraal2012, 10)

    ##                      Name     RecordingGivid UserReference
    ## 1  MILKLIM_Heischraal2012 IV2012081615083167        HS_008
    ## 2  MILKLIM_Heischraal2012 IV2012081613133274        HS_009
    ## 3  MILKLIM_Heischraal2012 IV2013041614525228        HS_035
    ## 4  MILKLIM_Heischraal2012 IV2012081609450300        HS_036
    ## 5  MILKLIM_Heischraal2012 IV2012081610204607        HS_037
    ## 6  MILKLIM_Heischraal2012 IV2012081610393743        HS_044
    ## 7  MILKLIM_Heischraal2012 IV2012081712451811        HS_052
    ## 8  MILKLIM_Heischraal2012 IV2012081611565583        HS_060
    ## 9  MILKLIM_Heischraal2012 IV2012081612200087        HS_061
    ## 10 MILKLIM_Heischraal2012 IV2012081611445288        HS_063
    ##                                            Observer QualifierType
    ## 1                    Cécile Herr en Robin Guelinckx            MQ
    ## 2                    Cécile Herr en Robin Guelinckx            MQ
    ## 3  Cécile Herr, Patrik Oosterlynck, Robin Guelinckx            MQ
    ## 4                    Cécile Herr en Robin Guelinckx            MQ
    ## 5  Cécile Herr, Robin Guelinckx, Patrik Oosterlynck            MQ
    ## 6                    Cécile Herr en Robin Guelinckx            MQ
    ## 7                                       Cécile Herr            MQ
    ## 8                                       Cécile Herr            MQ
    ## 9                                       Cécile Herr            MQ
    ## 10                                      Cécile Herr            MQ
    ##    QualifierCode Description QualifierCode Description QualifierCode
    ## 1              A        <NA>         PBuis  Peilbuizen      GUPP042A
    ## 2              A        <NA>         PBuis  Peilbuizen      GUPP043B
    ## 3              A      Active         PBuis  Peilbuizen      WALP161X
    ## 4              A        <NA>         PBuis  Peilbuizen      WALP157X
    ## 5              A        <NA>         PBuis  Peilbuizen      WALP117X
    ## 6              A        <NA>         PBuis  Peilbuizen      WALP162X
    ## 7              A        <NA>         PBuis  Peilbuizen      VOTP017X
    ## 8              A        <NA>         PBuis  Peilbuizen      LDOP014B
    ## 9              A        <NA>         PBuis  Peilbuizen      LDOP001X
    ## 10             A        <NA>         PBuis  Peilbuizen      LDOP006D
    ##    Description Elucidation NotSure ParentID  QualifierResource
    ## 1         <NA>                   0       NA               <NA>
    ## 2         <NA>                   0       NA               <NA>
    ## 3         <NA>                   0       NA RS2012060811060080
    ## 4         <NA>                   0       NA               <NA>
    ## 5         <NA>                   0       NA               <NA>
    ## 6         <NA>                   0       NA               <NA>
    ## 7         <NA>                   0       NA               <NA>
    ## 8         <NA>                   0       NA               <NA>
    ## 9         <NA>                   0       NA               <NA>
    ## 10        <NA>                   0       NA               <NA>

Get all qualifiers from MILKLIM surveys (partial matching):

    qualifiers_milkim <- inboveg_qualifiers(con,
                                            survey_name = "%MILKLIM%")

    head(qualifiers_milkim, 10)

    ##                             Name     RecordingGivid UserReference
    ## 1            MILKLIM_Alopecurion IV2012080609161322             0
    ## 2  MILKLIM_LevelII_BraunBlanquet IV2013082613200562   001_LevelII
    ## 3          MILKLIM_LevelII_Londo IV2013082711054782   001_LevelII
    ## 4  MILKLIM_LevelII_BraunBlanquet IV2013082613220113   002_LevelII
    ## 5          MILKLIM_LevelII_Londo IV2013082711080272   002_LevelII
    ## 6  MILKLIM_LevelII_BraunBlanquet IV2013082613231173   003_LevelII
    ## 7          MILKLIM_LevelII_Londo IV2013082711091698   003_LevelII
    ## 8  MILKLIM_LevelII_BraunBlanquet IV2013082613251752   004_LevelII
    ## 9          MILKLIM_LevelII_Londo IV2013082711105205   004_LevelII
    ## 10 MILKLIM_LevelII_BraunBlanquet IV2013082613300967   005_LevelII
    ##                         Observer QualifierType QualifierCode Description
    ## 1  Maud Raman en Arthur De Haeck            MQ             A      Active
    ## 2                       Onbekend            SQ         11.01        <NA>
    ## 3                       Onbekend            SQ          11.1        <NA>
    ## 4                       Onbekend            SQ         11.02        <NA>
    ## 5                       Onbekend            SQ          11.2        <NA>
    ## 6                       Onbekend            SQ         11.03        <NA>
    ## 7                 Johan Neirynck            SQ          11.3      1000-2
    ## 8                       Onbekend            SQ         11.04        <NA>
    ## 9                 Johan Neirynck            SQ          11.4      1000-1
    ## 10                      Onbekend            SQ         11.05        <NA>
    ##    QualifierCode Description QualifierCode Description Elucidation NotSure
    ## 1          PBuis  Peilbuizen      ASEP001X        <NA>                   0
    ## 2           <NA>        <NA>          <NA>        <NA>        <NA>       0
    ## 3           <NA>        <NA>          <NA>        <NA>        <NA>       0
    ## 4           <NA>        <NA>          <NA>        <NA>        <NA>       0
    ## 5           <NA>        <NA>          <NA>        <NA>        <NA>       0
    ## 6           <NA>        <NA>          <NA>        <NA>        <NA>       0
    ## 7           <NA>        <NA>          <NA>        <NA>        <NA>       0
    ## 8           <NA>        <NA>          <NA>        <NA>        <NA>       0
    ## 9           <NA>        <NA>          <NA>        <NA>        <NA>       0
    ## 10          <NA>        <NA>          <NA>        <NA>        <NA>       0
    ##    ParentID  QualifierResource
    ## 1        NA RS2012060811060080
    ## 2        NA RS2013082612251090
    ## 3        NA RS2013082612251090
    ## 4        NA RS2013082612251090
    ## 5        NA RS2013082612251090
    ## 6        NA RS2013082612251090
    ## 7        NA RS2013082612251090
    ## 8        NA RS2013082612251090
    ## 9        NA RS2013082612251090
    ## 10       NA RS2013082612251090

Get qualifiers from several specific surveys

    qualifiers_severalsurveys <- inboveg_qualifiers(con, 
                    survey_name = c("MILKLIM_Heischraal2012", "NICHE Vlaanderen"),
                    multiple = TRUE)

    head(qualifiers_severalsurveys, 10)

    ##                Name     RecordingGivid UserReference    Observer
    ## 1  NICHE Vlaanderen IV2013091209383088       1 . 3 O  Els De Bie
    ## 2  NICHE Vlaanderen IV2013091209230447       1 . 5 O  Els De Bie
    ## 3  NICHE Vlaanderen IV2013091208585526       1 . 7 D  Els De Bie
    ## 4  NICHE Vlaanderen IV2013091016243864         1.8 O  Els De Bie
    ## 5  NICHE Vlaanderen IV2013101009450362            15 Wim Mertens
    ## 6  NICHE Vlaanderen IV2013101010054825            19 Wim Mertens
    ## 7  NICHE Vlaanderen IV2013092409234825         2.1 O  Els De Bie
    ## 8  NICHE Vlaanderen IV2013092415280064           2.7  Els De Bie
    ## 9  NICHE Vlaanderen IV2013092415561030           2.8  Els De Bie
    ## 10 NICHE Vlaanderen IV2013092415460492       2.8 bis  Els De Bie
    ##    QualifierType QualifierCode Description QualifierCode Description
    ## 1             SQ      OLEP003X        <NA>          <NA>        <NA>
    ## 2             SQ      OLEP005X        <NA>          <NA>        <NA>
    ## 3             SQ      OLEP107X        <NA>          <NA>        <NA>
    ## 4             SQ      OLEP108X        <NA>          <NA>        <NA>
    ## 5             SQ      VIEP102X        <NA>          <NA>        <NA>
    ## 6             SQ      VIEP151X        <NA>          <NA>        <NA>
    ## 7             SQ      OLEP009X        <NA>          <NA>        <NA>
    ## 8             SQ      LIEP014X        <NA>          <NA>        <NA>
    ## 9             SQ      LIEP015X        <NA>          <NA>        <NA>
    ## 10            SQ      LIEP015X        <NA>          <NA>        <NA>
    ##    QualifierCode Description Elucidation NotSure ParentID
    ## 1           <NA>        <NA>        <NA>       0       NA
    ## 2           <NA>        <NA>        <NA>       0       NA
    ## 3           <NA>        <NA>        <NA>       0       NA
    ## 4           <NA>        <NA>        <NA>       0       NA
    ## 5           <NA>        <NA>        <NA>       0       NA
    ## 6           <NA>        <NA>        <NA>       0       NA
    ## 7           <NA>        <NA>        <NA>       0       NA
    ## 8           <NA>        <NA>        <NA>       0       NA
    ## 9           <NA>        <NA>        <NA>       0       NA
    ## 10          <NA>        <NA>        <NA>       0       NA
    ##     QualifierResource
    ## 1  RS2012080211350655
    ## 2  RS2012080211350655
    ## 3  RS2012080211350655
    ## 4  RS2012080211350655
    ## 5  RS2012080211350655
    ## 6  RS2012080211350655
    ## 7  RS2012080211350655
    ## 8  RS2012080211350655
    ## 9  RS2012080211350655
    ## 10 RS2012080211350655

Get all qualifiers of all surveys

    allqualifiers <- inboveg_qualifiers(con)

    head(allqualifiers,10)

    ##                           Name     RecordingGivid UserReference
    ## 1          MILKLIM_Alopecurion IV2012080609161322             0
    ## 2        BIOMON_HEIDEKWALITEIT IV2013101412532518          0002
    ## 3        BIOMON_HEIDEKWALITEIT IV2013101413031887          0003
    ## 4        BIOMON_HEIDEKWALITEIT IV2013101414182491          0004
    ## 5  BIOMON_HEIDETYPOLOGIE_LONDO IV2013092716425541          0004
    ## 6        BIOMON_HEIDEKWALITEIT IV2013101415063032          0005
    ## 7  BIOMON_HEIDETYPOLOGIE_LONDO IV2013101415262214          0006
    ## 8  BIOMON_HEIDETYPOLOGIE_LONDO IV2013101415483985          0007
    ## 9  BIOMON_HEIDETYPOLOGIE_LONDO IV2013100711104616          0008
    ## 10 BIOMON_HEIDETYPOLOGIE_LONDO IV2013100713121341          0009
    ##                         Observer QualifierType QualifierCode Description
    ## 1  Maud Raman en Arthur De Haeck            MQ             A      Active
    ## 2             Patrik Oosterlynck          <NA>          <NA>        <NA>
    ## 3             Patrik Oosterlynck          <NA>          <NA>        <NA>
    ## 4             Patrik Oosterlynck          <NA>          <NA>        <NA>
    ## 5             Patrik Oosterlynck          <NA>          <NA>        <NA>
    ## 6             Patrik Oosterlynck          <NA>          <NA>        <NA>
    ## 7             Patrik Oosterlynck          <NA>          <NA>        <NA>
    ## 8             Patrik Oosterlynck          <NA>          <NA>        <NA>
    ## 9             Patrik Oosterlynck          <NA>          <NA>        <NA>
    ## 10            Patrik Oosterlynck          <NA>          <NA>        <NA>
    ##    QualifierCode Description QualifierCode Description Elucidation NotSure
    ## 1          PBuis  Peilbuizen      ASEP001X        <NA>                   0
    ## 2           <NA>        <NA>          <NA>        <NA>        <NA>      NA
    ## 3           <NA>        <NA>          <NA>        <NA>        <NA>      NA
    ## 4           <NA>        <NA>          <NA>        <NA>        <NA>      NA
    ## 5           <NA>        <NA>          <NA>        <NA>        <NA>      NA
    ## 6           <NA>        <NA>          <NA>        <NA>        <NA>      NA
    ## 7           <NA>        <NA>          <NA>        <NA>        <NA>      NA
    ## 8           <NA>        <NA>          <NA>        <NA>        <NA>      NA
    ## 9           <NA>        <NA>          <NA>        <NA>        <NA>      NA
    ## 10          <NA>        <NA>          <NA>        <NA>        <NA>      NA
    ##    ParentID  QualifierResource
    ## 1        NA RS2012060811060080
    ## 2        NA               <NA>
    ## 3        NA               <NA>
    ## 4        NA               <NA>
    ## 5        NA               <NA>
    ## 6        NA               <NA>
    ## 7        NA               <NA>
    ## 8        NA               <NA>
    ## 9        NA               <NA>
    ## 10       NA               <NA>

More complex queries
--------------------

These functions give basis information out of INBOVEG. If more detailed
information is needed 'dplyr' is the magic word. In future more complex
functions can be build to help the inboveg-users.

Closing the connection
======================

Close the connection when done

    dbDisconnect(con)
    rm(con)

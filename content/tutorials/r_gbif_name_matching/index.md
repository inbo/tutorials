---
title: "Match scientific names with the GBIF backbone"
author: "Dirk Maes, Dimitri Brosens"
date: 2018-06-14
categories: ["r"]
tags: ["API", "webservice", "r", "gbif", "biodiversity"]
output: 
    md_document:
        preserve_yaml: true
        variant: markdown_github
---

Introduction
------------

This tutorial will explain how you can match a list of 'scientific names' to the GBIF taxonomic backbone

Important is that you have [rgbif](https://github.com/ropensci/rgbif) and [inborutils](https://inbo.github.io/inborutils/) installed and available:

``` r
library(tidyverse) # tidyverse
library(rgbif)     # To Match GBIF
library(inborutils) # wrap GBIF api data
library(knitr)
library(pander)
```

Read data file containing the scientific names
----------------------------------------------

Read file containing the scientific names you want to check against the [GBIF](https://www.gbif.org/species/search?q=) taxonomic backbone:

``` r
species_list <- read_csv("https://raw.githubusercontent.com/inbo/inbo-pyutils/master/gbif/gbif_name_match/sample.csv", trim_ws = TRUE, col_types = cols())
```

Take a look at the data:

``` r
pandoc.table(head(as.data.frame(species_list)), style = "rmarkdown")
```

    ## 
    ## 
    ## |           name            |  kingdom  |   euConcernStatus   |
    ## |:-------------------------:|:---------:|:-------------------:|
    ## |   Alopochen aegyptiaca    | Animalia  | under consideration |
    ## | Cotoneaster ganghobaensis |  Plantae  |         NA          |
    ## |    Cotoneaster hylmoei    |  Plantae  |         NA          |
    ## |  Cotoneaster x suecicus   |  Plantae  |         NA          |
    ## |   Euthamia graminifolia   |  Plantae  |  under preparation  |

Request species information
---------------------------

Match the column containing the scientificName with GBIF, using the `gbif_species_name_match` function from the [inborutils](https://inbo.github.io/inborutils/reference/gbif_species_name_match.html) package:

``` r
species_list_matched <- species_list %>% 
    gbif_species_name_match(name_col = "name") 
```

    ## [1] "All column names present"

The `name_col` argument is the column name containing the scientific names.

Take a look at the updated data:

``` r
pandoc.table(head(as.data.frame(species_list_matched)), style = "rmarkdown")
```

    ## 
    ## 
    ## |           name            |  kingdom  |   euConcernStatus   |  usageKey  |
    ## |:-------------------------:|:---------:|:-------------------:|:----------:|
    ## |   Alopochen aegyptiaca    | Animalia  | under consideration |  2498252   |
    ## | Cotoneaster ganghobaensis |  Plantae  |         NA          |  3025989   |
    ## |    Cotoneaster hylmoei    |  Plantae  |         NA          |  3025758   |
    ## |  Cotoneaster x suecicus   |  Plantae  |         NA          |  3026040   |
    ## |   Euthamia graminifolia   |  Plantae  |  under preparation  |  3092782   |
    ## 
    ## Table: Table continues below
    ## 
    ##  
    ## 
    ## |               scientificName                |  rank   |    order     |
    ## |:-------------------------------------------:|:-------:|:------------:|
    ## |    Alopochen aegyptiaca (Linnaeus, 1766)    | SPECIES | Anseriformes |
    ## | Cotoneaster ganghobaensis J.Fryer & B.Hylmö | SPECIES |   Rosales    |
    ## |  Cotoneaster hylmoei K.E.Flinck & J.Fryer   | SPECIES |   Rosales    |
    ## |        Cotoneaster suecicus G.Klotz         | SPECIES |   Rosales    |
    ## |      Euthamia graminifolia (L.) Nutt.       | SPECIES |  Asterales   |
    ## 
    ## Table: Table continues below
    ## 
    ##  
    ## 
    ## |  matchType  |    phylum    |    genus    |     class     |  confidence  |
    ## |:-----------:|:------------:|:-----------:|:-------------:|:------------:|
    ## |    EXACT    |   Chordata   |  Alopochen  |     Aves      |      98      |
    ## |    EXACT    | Tracheophyta | Cotoneaster | Magnoliopsida |      98      |
    ## |    EXACT    | Tracheophyta | Cotoneaster | Magnoliopsida |      98      |
    ## |    EXACT    | Tracheophyta | Cotoneaster | Magnoliopsida |      98      |
    ## |    EXACT    | Tracheophyta |  Euthamia   | Magnoliopsida |      98      |
    ## 
    ## Table: Table continues below
    ## 
    ##  
    ## 
    ## |  synonym  |  status  |   family   |
    ## |:---------:|:--------:|:----------:|
    ## |   FALSE   | ACCEPTED |  Anatidae  |
    ## |   FALSE   | ACCEPTED |  Rosaceae  |
    ## |   FALSE   | ACCEPTED |  Rosaceae  |
    ## |   FALSE   | ACCEPTED |  Rosaceae  |
    ## |   FALSE   | ACCEPTED | Asteraceae |

You can also specify which info (`gbif_terms`) GBIF should return. For example, return a lot of terms:

``` r
species_list %>% 
    gbif_species_name_match(name_col = "name",
                            gbif_terms = c('usageKey', 'scientificName', 
                                           'rank', 'order', 'matchType', 
                                           'phylum', 'kingdom', 'genus', 
                                           'class', 'confidence', 'synonym', 
                                           'status', 'family')) %>%
    head() %>%
    as.data.frame() %>%
    pandoc.table(style = "rmarkdown")
```

    ## [1] "All column names present"
    ## 
    ## 
    ## |           name            |  kingdom  |   euConcernStatus   |  usageKey  |
    ## |:-------------------------:|:---------:|:-------------------:|:----------:|
    ## |   Alopochen aegyptiaca    | Animalia  | under consideration |  2498252   |
    ## | Cotoneaster ganghobaensis |  Plantae  |         NA          |  3025989   |
    ## |    Cotoneaster hylmoei    |  Plantae  |         NA          |  3025758   |
    ## |  Cotoneaster x suecicus   |  Plantae  |         NA          |  3026040   |
    ## |   Euthamia graminifolia   |  Plantae  |  under preparation  |  3092782   |
    ## 
    ## Table: Table continues below
    ## 
    ##  
    ## 
    ## |               scientificName                |  rank   |    order     |
    ## |:-------------------------------------------:|:-------:|:------------:|
    ## |    Alopochen aegyptiaca (Linnaeus, 1766)    | SPECIES | Anseriformes |
    ## | Cotoneaster ganghobaensis J.Fryer & B.Hylmö | SPECIES |   Rosales    |
    ## |  Cotoneaster hylmoei K.E.Flinck & J.Fryer   | SPECIES |   Rosales    |
    ## |        Cotoneaster suecicus G.Klotz         | SPECIES |   Rosales    |
    ## |      Euthamia graminifolia (L.) Nutt.       | SPECIES |  Asterales   |
    ## 
    ## Table: Table continues below
    ## 
    ##  
    ## 
    ## |  matchType  |    phylum    |    genus    |     class     |  confidence  |
    ## |:-----------:|:------------:|:-----------:|:-------------:|:------------:|
    ## |    EXACT    |   Chordata   |  Alopochen  |     Aves      |      98      |
    ## |    EXACT    | Tracheophyta | Cotoneaster | Magnoliopsida |      98      |
    ## |    EXACT    | Tracheophyta | Cotoneaster | Magnoliopsida |      98      |
    ## |    EXACT    | Tracheophyta | Cotoneaster | Magnoliopsida |      98      |
    ## |    EXACT    | Tracheophyta |  Euthamia   | Magnoliopsida |      98      |
    ## 
    ## Table: Table continues below
    ## 
    ##  
    ## 
    ## |  synonym  |  status  |   family   |
    ## |:---------:|:--------:|:----------:|
    ## |   FALSE   | ACCEPTED |  Anatidae  |
    ## |   FALSE   | ACCEPTED |  Rosaceae  |
    ## |   FALSE   | ACCEPTED |  Rosaceae  |
    ## |   FALSE   | ACCEPTED |  Rosaceae  |
    ## |   FALSE   | ACCEPTED | Asteraceae |

or rather just a subset:

``` r
species_list %>% 
    gbif_species_name_match(name_col = "name",
                            gbif_terms = c('scientificName', 'family',
                                           'order', 'matchType')) %>%
    head() %>%
    as.data.frame() %>%    
    pandoc.table(style = "rmarkdown")
```

    ## [1] "All column names present"
    ## 
    ## 
    ## |           name            |  kingdom  |   euConcernStatus   |
    ## |:-------------------------:|:---------:|:-------------------:|
    ## |   Alopochen aegyptiaca    | Animalia  | under consideration |
    ## | Cotoneaster ganghobaensis |  Plantae  |         NA          |
    ## |    Cotoneaster hylmoei    |  Plantae  |         NA          |
    ## |  Cotoneaster x suecicus   |  Plantae  |         NA          |
    ## |   Euthamia graminifolia   |  Plantae  |  under preparation  |
    ## 
    ## Table: Table continues below
    ## 
    ##  
    ## 
    ## |               scientificName                |   family   |    order     |
    ## |:-------------------------------------------:|:----------:|:------------:|
    ## |    Alopochen aegyptiaca (Linnaeus, 1766)    |  Anatidae  | Anseriformes |
    ## | Cotoneaster ganghobaensis J.Fryer & B.Hylmö |  Rosaceae  |   Rosales    |
    ## |  Cotoneaster hylmoei K.E.Flinck & J.Fryer   |  Rosaceae  |   Rosales    |
    ## |        Cotoneaster suecicus G.Klotz         |  Rosaceae  |   Rosales    |
    ## |      Euthamia graminifolia (L.) Nutt.       | Asteraceae |  Asterales   |
    ## 
    ## Table: Table continues below
    ## 
    ##  
    ## 
    ## |  matchType  |
    ## |:-----------:|
    ## |    EXACT    |
    ## |    EXACT    |
    ## |    EXACT    |
    ## |    EXACT    |
    ## |    EXACT    |

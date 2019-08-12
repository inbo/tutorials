---
title: "Match scientific names with the GBIF Backbone Taxonomy"
author: "Dirk Maes, Dimitri Brosens, Damiano Oldoni"
date: 2018-06-14
categories: ["r"]
tags: ["api", "webservice", "r", "gbif", "biodiversity"]
output: 
    md_document:
        preserve_yaml: true
        variant: markdown_github
---

Introduction
------------

This tutorial will explain how you can match a list of *scientific
names* against the [GBIF backbone
taxonomy](https://www.gbif.org/dataset/d7dddbf4-2cf0-4f39-9b2a-bb099caae36c).

Important is that you have the most recent version of
[inborutils](https://inbo.github.io/inborutils/) installed and
available:

``` r
remotes::install_github("inbo/inborutils")   # install inborutils
```

``` r
library(tidyverse)    # To do datascience
library(rgbif)        # To lookup names in the GBIF backbone taxonomy
library(inborutils)   # To wrap GBIF API data
library(knitr)
```

Read data file containing the scientific names
----------------------------------------------

Read file containing the scientific names you want to check against the
[GBIF](https://www.gbif.org/species/search?q=) taxonomic backbone:

``` r
species_list <- read_csv("https://raw.githubusercontent.com/inbo/inbo-pyutils/master/gbif/gbif_name_match/sample.csv", trim_ws = TRUE, col_types = cols())
```

Take a look at the data:

``` r
kable(species_list)
```

| name                      | kingdom  | euConcernStatus     |
|:--------------------------|:---------|:--------------------|
| Alopochen aegyptiaca      | Animalia | under consideration |
| Cotoneaster ganghobaensis | Plantae  | NA                  |
| Cotoneaster hylmoei       | Plantae  | NA                  |
| Cotoneaster x suecicus    | Plantae  | NA                  |
| Euthamia graminifolia     | Plantae  | under preparation   |

Request taxonomic information
-----------------------------

Match the column containing the scientific name with GBIF, using the
`gbif_species_name_match` function from the
[inborutils](https://inbo.github.io/inborutils/reference/gbif_species_name_match.html)
package:

``` r
species_list_matched <- species_list %>% 
    gbif_species_name_match(name = "name") 
```

    ## [1] "All column names present"

The `name` argument is the column name containing the scientific names.
Default value: `name`. So, the code above is equivalent to:

``` r
species_list_matched <- species_list %>% 
    gbif_species_name_match() 
```

By default, `gbif_species_name_match` returns the following GBIF fields:
`usageKey`, `scientificName`, `rank`, `order`, `matchType`, `phylum`,
`kingdom`, `genus`, `class`, `confidence`, `synonym`, `status`,
`family`.

Take a look at the updated data:

``` r
kable(species_list_matched)
```

| name                      | kingdom  | euConcernStatus     |  usageKey| scientificName                              | rank    | order        | matchType | phylum       | kingdom1 | genus       | class         |  confidence| synonym | status   | family     |
|:--------------------------|:---------|:--------------------|---------:|:--------------------------------------------|:--------|:-------------|:----------|:-------------|:---------|:------------|:--------------|-----------:|:--------|:---------|:-----------|
| Alopochen aegyptiaca      | Animalia | under consideration |   2498252| Alopochen aegyptiaca (Linnaeus, 1766)       | SPECIES | Anseriformes | EXACT     | Chordata     | Animalia | Alopochen   | Aves          |          98| FALSE   | ACCEPTED | Anatidae   |
| Cotoneaster ganghobaensis | Plantae  | NA                  |   3025989| Cotoneaster ganghobaensis J.Fryer & B.Hylmö | SPECIES | Rosales      | EXACT     | Tracheophyta | Plantae  | Cotoneaster | Magnoliopsida |          98| FALSE   | ACCEPTED | Rosaceae   |
| Cotoneaster hylmoei       | Plantae  | NA                  |   3025758| Cotoneaster hylmoei K.E.Flinck & J.Fryer    | SPECIES | Rosales      | EXACT     | Tracheophyta | Plantae  | Cotoneaster | Magnoliopsida |          98| FALSE   | ACCEPTED | Rosaceae   |
| Cotoneaster x suecicus    | Plantae  | NA                  |   3026040| Cotoneaster suecicus G.Klotz                | SPECIES | Rosales      | EXACT     | Tracheophyta | Plantae  | Cotoneaster | Magnoliopsida |          98| FALSE   | ACCEPTED | Rosaceae   |
| Euthamia graminifolia     | Plantae  | under preparation   |   3092782| Euthamia graminifolia (L.) Nutt.            | SPECIES | Asterales    | EXACT     | Tracheophyta | Plantae  | Euthamia    | Magnoliopsida |          98| FALSE   | ACCEPTED | Asteraceae |

Notice that GBIF fields whose name is already used as column name are
automatically renamed by adding suffix `1`. In our case, input
data.frame `species_list` contains already a column called `kingdom`:
the GBIF kingdom values are returned in column `kingdom1`:

``` r
species_list_matched %>% select(kingdom, kingdom1)
```

    ## # A tibble: 5 x 2
    ##   kingdom  kingdom1
    ##   <chr>    <chr>   
    ## 1 Animalia Animalia
    ## 2 Plantae  Plantae 
    ## 3 Plantae  Plantae 
    ## 4 Plantae  Plantae 
    ## 5 Plantae  Plantae

You can specify which GBIF fields you would like to have:

``` r
species_list %>% 
    gbif_species_name_match(
      gbif_terms = c(
        'scientificName', 
        'family',
        'order',
        'rank',
        'matchType',
        'confidence',
        'status')) %>%
    kable()
```

    ## [1] "All column names present"

| name                      | kingdom  | euConcernStatus     | scientificName                              | family     | order        | rank    | matchType |  confidence| status   |
|:--------------------------|:---------|:--------------------|:--------------------------------------------|:-----------|:-------------|:--------|:----------|-----------:|:---------|
| Alopochen aegyptiaca      | Animalia | under consideration | Alopochen aegyptiaca (Linnaeus, 1766)       | Anatidae   | Anseriformes | SPECIES | EXACT     |          98| ACCEPTED |
| Cotoneaster ganghobaensis | Plantae  | NA                  | Cotoneaster ganghobaensis J.Fryer & B.Hylmö | Rosaceae   | Rosales      | SPECIES | EXACT     |          98| ACCEPTED |
| Cotoneaster hylmoei       | Plantae  | NA                  | Cotoneaster hylmoei K.E.Flinck & J.Fryer    | Rosaceae   | Rosales      | SPECIES | EXACT     |          98| ACCEPTED |
| Cotoneaster x suecicus    | Plantae  | NA                  | Cotoneaster suecicus G.Klotz                | Rosaceae   | Rosales      | SPECIES | EXACT     |          98| ACCEPTED |
| Euthamia graminifolia     | Plantae  | under preparation   | Euthamia graminifolia (L.) Nutt.            | Asteraceae | Asterales    | SPECIES | EXACT     |          98| ACCEPTED |

The function `inborutils::gbif_species_name_match` is a wrapper around
`rgbif::name_backbone`, so you can pass any argument of `name_backbone`.
For example, you can set `strict = TRUE` to fuzzy match only the given
names, but never a taxon in the upper classification:

``` r
species_list %>% 
    gbif_species_name_match(strict = TRUE) %>%
    kable()
```

    ## [1] "All column names present"

| name                      | kingdom  | euConcernStatus     |  usageKey| scientificName                              | rank    | order        | matchType | phylum       | kingdom1 | genus       | class         |  confidence| synonym | status   | family     |
|:--------------------------|:---------|:--------------------|---------:|:--------------------------------------------|:--------|:-------------|:----------|:-------------|:---------|:------------|:--------------|-----------:|:--------|:---------|:-----------|
| Alopochen aegyptiaca      | Animalia | under consideration |   2498252| Alopochen aegyptiaca (Linnaeus, 1766)       | SPECIES | Anseriformes | EXACT     | Chordata     | Animalia | Alopochen   | Aves          |          99| FALSE   | ACCEPTED | Anatidae   |
| Cotoneaster ganghobaensis | Plantae  | NA                  |   3025989| Cotoneaster ganghobaensis J.Fryer & B.Hylmö | SPECIES | Rosales      | EXACT     | Tracheophyta | Plantae  | Cotoneaster | Magnoliopsida |          99| FALSE   | ACCEPTED | Rosaceae   |
| Cotoneaster hylmoei       | Plantae  | NA                  |   3025758| Cotoneaster hylmoei K.E.Flinck & J.Fryer    | SPECIES | Rosales      | EXACT     | Tracheophyta | Plantae  | Cotoneaster | Magnoliopsida |          99| FALSE   | ACCEPTED | Rosaceae   |
| Cotoneaster x suecicus    | Plantae  | NA                  |   3026040| Cotoneaster suecicus G.Klotz                | SPECIES | Rosales      | EXACT     | Tracheophyta | Plantae  | Cotoneaster | Magnoliopsida |          99| FALSE   | ACCEPTED | Rosaceae   |
| Euthamia graminifolia     | Plantae  | under preparation   |   3092782| Euthamia graminifolia (L.) Nutt.            | SPECIES | Asterales    | EXACT     | Tracheophyta | Plantae  | Euthamia    | Magnoliopsida |          98| FALSE   | ACCEPTED | Asteraceae |

All accepted parameters of `name_backbone`: ‘rank’, ‘kingdom’, ‘phylum’,
‘class’, ‘order’, ‘family’, ‘genus’, ‘strict’, ‘verbose’, ‘start’,
‘limit’, ‘curlopts’. See `?name_backbone` for more details.

For Python users, there is a similar (but no longer maintained)
[function](https://github.com/inbo/inbo-pyutils/tree/master/gbif/gbif_name_match)
in `inbo-pyutils`.

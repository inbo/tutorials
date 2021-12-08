---
title: "Using `%>%` pipes in R"
description: "Using the %>% pipe functionality in R scripts"
authors: [yasmineverzelen, lienreyserhove]
date: 2018-06-14
categories: ["r"]
tags: ["tidyverse", "r"]
output: 
    md_document:
        preserve_yaml: true
        variant: markdown_github
---

``` r
library(dplyr)
```

How to use piping in R
======================

Normally, you would do this:

``` r
head(mtcars)
```

    ##                    mpg cyl disp  hp drat    wt  qsec vs am gear carb
    ## Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
    ## Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
    ## Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
    ## Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
    ## Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
    ## Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1

However, with piping, this would look different:

``` r
mtcars %>% head()
```

    ##                    mpg cyl disp  hp drat    wt  qsec vs am gear carb
    ## Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
    ## Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
    ## Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
    ## Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
    ## Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
    ## Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1

### You may wonder, what's the point?

If you need to apply multiple functions on one dataframe, piping saves you a lot of typing, and makes for tidy R code. An example:

``` r
mtcars %>% 
  mutate(dec = mpg/10) %>%
  select(mpg, dec, am) %>%
  filter(am == "1")
```

    ##     mpg  dec am
    ## 1  21.0 2.10  1
    ## 2  21.0 2.10  1
    ## 3  22.8 2.28  1
    ## 4  32.4 3.24  1
    ## 5  30.4 3.04  1
    ## 6  33.9 3.39  1
    ## 7  27.3 2.73  1
    ## 8  26.0 2.60  1
    ## 9  30.4 3.04  1
    ## 10 15.8 1.58  1
    ## 11 19.7 1.97  1
    ## 12 15.0 1.50  1
    ## 13 21.4 2.14  1

What did we do:
1. We created a new column 'dec' using `mutate()`. This column 'dec' consists of the values of column mpg divided by 10.
2. We selected the columns 'mpg', 'dec' and 'am' using `select()`.
3. We filtered for the value '1' in the column 'am' using `filter()`.

#### And all of this in **just one step**!

<img src="images/chiphooray.png" width="250" />

Now what?
---------

We have created a new column, but this column is not part of our dataframe yet!
We could do this:

``` r
mtcars <- mtcars %>% 
  mutate(dec = mpg/10)
```

**OR**... we could do this!

``` r
library(magrittr)

mtcars %<>% 
  mutate(dec = mpg/10)
```

### Soooo easy!

This has been our first introduction to piping. There is however much more to learn!
That is why you should definitely go to [this link](https://www.datacamp.com/community/tutorials/pipe-r-tutorial).

<img src="images/hooraypenguin.jpg" width="250" />

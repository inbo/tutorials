---
title: "'Zoom in' on `ggplot2` figures"
description: "Learn the difference between zooming in with scales and coordinates."
authors: [thierryo]
date: "2020-07-01"
categories: ["r"]
tags: ["r", "ggplot2"]
output: 
    md_document:
        preserve_yaml: true
        variant: gfm
---

# Original figure

``` r
library(ggplot2)
```

    ## Warning: package 'ggplot2' was built under R version 4.0.2

``` r
ggplot(mtcars, aes(x = factor(cyl), y = mpg)) + 
  geom_boxplot()
```

![](index_files/figure-gfm/unnamed-chunk-1-1.png)<!-- -->

# “Zoom in” with scales

Data points outside the limits are considered to be `NA`. Note that this
will alter all calculated geoms.

``` r
ggplot(mtcars, aes(x = factor(cyl), y = mpg)) + 
  geom_boxplot() + 
  scale_y_continuous(limits = c(20, 25))
```

    ## Warning: Removed 24 rows containing non-finite values (stat_boxplot).

![](index_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

# “Zoom in” with coord

This doesn’t affect the values:

``` r
ggplot(mtcars, aes(x = factor(cyl), y = mpg)) + 
  geom_boxplot() + 
  coord_cartesian(ylim = c(20, 25))
```

![](index_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

Note that you can use only one `coord`. Only the last one will have an
effect on the plot.

``` r
ggplot(mtcars, aes(x = factor(cyl), y = mpg)) + 
  geom_boxplot() + 
  coord_cartesian(ylim = c(20, 25)) + 
  coord_flip()
```

    ## Coordinate system already present. Adding new coordinate system, which will replace the existing one.

![](index_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

``` r
ggplot(mtcars, aes(x = factor(cyl), y = mpg)) + 
  geom_boxplot() + 
  coord_flip() + 
  coord_cartesian(ylim = c(20, 25))
```

    ## Coordinate system already present. Adding new coordinate system, which will replace the existing one.

![](index_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

Set the limits in `coord_flip` to get the effects of both.

``` r
ggplot(mtcars, aes(x = factor(cyl), y = mpg)) + 
  geom_boxplot() + 
  coord_flip(ylim = c(20, 25))
```

![](index_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

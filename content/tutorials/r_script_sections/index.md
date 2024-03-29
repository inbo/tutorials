---
title: "Headers and navigation in R code"
description: "Provide structure inside an R script using sections"
authors: [pieterjanverhelst]
date: 2018-06-14
categories: ["r"]
tags: ["tidyverse", "r"]
output: 
  md_document:
    preserve_yaml: true
    variant: gfm+footnotes
---

## Introduction

R code can become elaborate and consequently unclear or difficult to
navigate. Yet, it is possible to introduce headers and navigate through
them.

## Creating sections manually

To create a header of a section, different methods can be applied. Any
comment line which includes at least four trailing dashes (-), equal
signs (=), or hash tags (\#) automatically creates a code section.

``` r
# 1. Header 1 ####

# 2. Header 2 ----

# 3. Header 3 ====
```

On the right side of the code editor, nex to the buttons to run your
code, a button with horizontal lines can be found. When you click it,
the headers will be visible. As such, the structure of your code is
visible and allows more easily to navigate through it.

Another way of navigation is via the button with the name of the
selected header On the bottom of the code editor.

## Creating sections automatically

It is also possible to add sections automatically by clicking on the tab
**Code** and select **Insert Section…**

## Drop down

Note there is a drop down button next to each header, allowing to
collapse or expand your code. Yet, there are shortcuts to this:

1.  **Collapse** — Alt+L
2.  **Expand** — Shift+Alt+L
3.  **Collapse All** — Alt+O
4.  **Expand All** — Shift+Alt+O

## An example

Now we will illustrate its use with an example of an analysis.

Run tidyverse package

``` r
library(tidyverse)
```

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──

    ## ✓ ggplot2 3.3.5     ✓ purrr   0.3.4
    ## ✓ tibble  3.1.5     ✓ dplyr   1.0.7
    ## ✓ tidyr   1.1.4     ✓ stringr 1.4.0
    ## ✓ readr   2.0.2     ✓ forcats 0.5.1

    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

Now different manipulations will be performed on the dataset. To make
navigation through the different manipulations more straightforward, we
add sections.

``` r
# 1. Plot hindfoot length over weight per year ----

surveys <- read_csv("../data/20180222_surveys.csv") %>% 
  filter(!is.na(weight),             # remove missing weight
         !is.na(hindfoot_length),    # remove missing hindfoot_length
         !is.na(sex))                # remove missing sex

ggplot(surveys, aes(x = weight, 
                    y = hindfoot_length)) + 
  geom_point(aes(colour = species_id), alpha = 0.5) +
  ylab("hindfoot length") +
  scale_x_log10() +
  scale_color_discrete() +
  theme_dark() +
  facet_wrap(~year)

# 2. Create a heatmap of the population growth in Ghent and its districts ----

tidy_bevolking <- read_csv("../data/20180522_gent_groeiperwijk_tidy.csv")

ggplot(tidy_bevolking, aes(x = year, 
                    y = wijk)) +
  geom_tile(aes(fill = growth), color = "red") +          # fill = colour of content/pane; color = colour of edge
# scale_fill_gradient(low = "white", high = "steelblue") +
  scale_fill_distiller(type = "div") +
  theme(axis.title.x=element_blank(),
        axis.title.y=element_blank())

# 3. Place two plots in one window ----

install.packages("cowplot")
devtools::install_github("inbo/INBOtheme") # install inbo theme
library(cowplot)
library(INBOtheme)

weight_scatter <- ggplot(surveys, aes(x = weight, 
                    y = hindfoot_length)) + 
  geom_point() +
  ylab("hindfoot length")

weight_density <- ggplot(surveys, 
                           aes(x = weight, y = ..density..) ) +   # the '..' refers to internal calculations of the density
  geom_histogram() + 
  geom_density()

# two plots in one window
plot_grid(weight_scatter, weight_density, labels = c("A", "B"))
```

---
title: "R voor beginners"
description: "Handleiding, code en data ter ondersteuning van de 'R voor beginners' workshop"
authors: [ivyjansen, pieterverschelde]
date: 2019-05-03
categories: ["r"]
tags: ["r", "rstudio", "ggplot2", "rmarkdown", "dplyr", "markdown"]
---

## Doel van de cursus

Hoe maak je van je ingezamelde gegevens een reproduceerbare analyse, visualisatie en rapportage, gebruik makend van de software R en Rstudio.

- Rstudio kunnen gebruiken (Les 1a)
- Commando's uitvoeren vanuit een script (Les 1b)
- Externe databestanden inlezen in R (Les 2a)
- Gegevens visualiseren (ggplot2) (Les 2b)
- Data manipuleren in een gewenste vorm (dplyr) (Les 3)
- Reproduceerbaar analyserapport maken (Rmarkdown) + algemene vragen (Les 4)

Bovenstaande topics worden gecombineerd in een opleiding van 4 workshops. Deze opleiding is bedoeld voor mensen die nog nooit met R gewerkt hebben. In de workshops wordt het materiaal in de handleidingen al doende uitgelegd, en afgewisseld met oefeningen. Na elke workshop wordt er altijd een huistaak aangeboden, die op vrijwillige basis ingediend kan worden, en van feedback voorzien.

## R en RStudio

Introductie tot R en Rstudio

- Uitleg van alle vensters in Rstudio, en overlopen van de [user installation instructions](https://inbo.github.io/tutorials/installation/user/user_install_rstudio/)
- Werken met projecten
- Packages installeren en laden
- Coding basics in R
- Vectoren en dataframes

[Handleiding](https://inbo.github.io/tutorials/tutorials/r_beginners/src/R_en_RStudio.pdf)
[Code](https://github.com/inbo/tutorials/blob/master/content/tutorials/r_beginners/src/R_en_RStudio_code.R)
[Huistaak](https://inbo.github.io/tutorials/tutorials/r_beginners/src/R_en_RStudio_huistaak.pdf)

## Inlezen van gegevens

Introductie tot het inlezen van externe databestanden

- `readr`
- `readxl`
- `googlesheets4`

[Handleiding](https://inbo.github.io/tutorials/tutorials/r_beginners/src/data_inlezen.pdf)
[Data](https://github.com/inbo/tutorials/tree/master/content/tutorials/r_beginners/data)
[Code](https://github.com/inbo/tutorials/blob/master/content/tutorials/r_beginners/src/data_inlezen_code.R)
[Oefening](https://inbo.github.io/tutorials/tutorials/r_beginners/src/data_inlezen_oefening.pdf)

## ggplot2

Introductie tot het maken van grafieken met ggplot2

- Basis syntax
- Geoms
- Aesthetics
- Facets
- Titels
- Plot bewaren

[Handleiding](https://inbo.github.io/tutorials/tutorials/r_beginners/src/ggplot.pdf)
[Data](https://github.com/inbo/tutorials/tree/master/content/tutorials/r_beginners/data)
[Code](https://github.com/inbo/tutorials/blob/master/content/tutorials/r_beginners/src/ggplot_code.R)
[Oefening](https://inbo.github.io/tutorials/tutorials/r_beginners/src/ggplot_oefening.pdf)
[Huistaak](https://inbo.github.io/tutorials/tutorials/r_beginners/src/data_inlezen_ggplot_huistaak.pdf)

## dplyr

Introductie tot data manipulatie met dplyr

- piping
- filter, arrange, mutate, select
- group_by, summarise
- Tidy data: gather, spread

[Handleiding](https://inbo.github.io/tutorials/tutorials/r_beginners/src/dplyr.pdf)
[Data](https://github.com/inbo/tutorials/tree/master/content/tutorials/r_beginners/data)
[Code](https://github.com/inbo/tutorials/blob/master/content/tutorials/r_beginners/src/dplyr_code.R)
[Oefening](https://inbo.github.io/tutorials/tutorials/r_beginners/src/dplyr_oefening.pdf)
[Huistaak](https://inbo.github.io/tutorials/tutorials/r_beginners/src/dplyr_huistaak.pdf)

## Rmarkdown

Introductie tot het maken van een reproduceerbaar document met Rmarkdown

- Markdown syntax
- Code chunks
- Chunk opties en globale opties
- YAML header
- Tabellen

[Handleiding](https://inbo.github.io/tutorials/tutorials/r_beginners/src/Rmarkdown.pdf)
[Code](https://github.com/inbo/tutorials/blob/master/content/tutorials/r_beginners/src/Rmarkdown_oefening.txt)
[Oefening](../../html/Rmarkdown_oefening_resultaat.html)
[Figuur voor oefening](https://github.com/inbo/tutorials/blob/master/content/tutorials/r_beginners/Figuren/iris-machinelearning.png)
[Huistaak](https://inbo.github.io/tutorials/tutorials/r_beginners/src/Rmarkdown_huistaak.pdf)

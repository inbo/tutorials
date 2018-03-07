---
date: 2017-10-18T15:43:44+02:00
description: "How to set-up RStudio after installation or after an upgrade (in Dutch)"
title: Rstudio
weight: 2
---

## Na de eerste installatie

1. Start `Rstudio`
1. Kies in het menu `Tools -> Global Options`
1. In het tabblad `General`
    1. Pas de _Default working directory_ aan naar de locatie waar je `R` versie staat (`C:/R/R-3.x.y`) [^1]
    1. _Restore .RData into workspace at startup:_ `uitvinken`
    1. _Save workspace to.RData on exit:_ `Never`
1. In het tabblad _Code_
    1. Subtab _Editing_
        1. _Insert spaces for tab:_ `aanvinken`
        1. _Tab width:_ `2`
        1. _Soft-wrap R source files:_ `aanvinken`
    1. Subtab _Saving_
        1. _Default text encoding:_ `UTF-8`
    1. Subtab _Diagnostics_
        1. Alles `aanvinken`
1. In het tabblad _Appearance_ 
    1. Stel in naar eigen smaak
1. In het tabblad _Packages_
    1. _CRAN mirror:_ wijzigen naar `Global (CDN) - RStudio`
1. In het tabblad _Sweave_
    1. _Weave Rnw files using:_ `knitr`
    1. _Typeset LaTeX into PDF using:_ `XeLaTex`
1. Klik op _OK_ en herstart `RStudio`

## Configuratie van RStudio na een upgrade van R

1. Start `RStudio`
1. Kies in het menu `Tools -> Global Options`
1. Indien niet de laatste versie vermeld staat bij R version: klik op _Change_ om het aan te passen.
1. Klik op _OK_ als je een waarschuwing krijgt dat je `RStudio` moet herstarten.
1. Wijzig de initial working directory in `C:/R/R-3.x.y` [^1]
1. Klik op _OK_
1. Herstart `RStudio`

[^1]: x en y verwijzen naar het versienummer. Dus bij R-3.1.0 is x = 1 en y = 0. De working directory is in dat geval `C:/R/R-3.1.0`

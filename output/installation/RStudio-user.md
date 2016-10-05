Bijwerken van RStudio als gebruiker
================

Na de eerste installatie
------------------------

1.  Start `Rstudio` via het Start-menu
2.  Kies in het menu `Tools -> Global Options`
3.  In het tabblad `General`
    1.  Pas de *initial working directory* aan naar de locatie waar je `R` versie staat (`C:/R/R-3.x.y`)[1]
    2.  *Restore .RData into workspace at startup:* `uitvinken`
    3.  *Save workspace to.RData on exit:* `Never`

4.  In het tabblad *Code*
    1.  Subtab *Editing*
        1.  *Insert spaces for tab:* `aanvinken`
        2.  *Tab width:* `2`
        3.  *Soft-wrap R source files:* `aanvinken`

    2.  Subtab *Saving*
        1.  *Default text encoding:* `UTF-8`

    3.  Subtab *Diagnostics*
        1.  Alles `aanvinken`

5.  In het tabblad *Appearance*
    1.  Stel in naar eigen smaak

6.  In het tabblad *Packages*
    1.  *CRAN mirror:* wijzigen naar `Global (CDN) - RStudio`

7.  In het tabblad *Sweave*
    1.  *Weave Rnw files using:* `knitr`
    2.  *Typeset LaTeX into PDF using:* `XeLaTex`

8.  Klik op *OK* en herstart `RStudio`

Configuratie van RStudio na een upgrade van R
---------------------------------------------

1.  Start `RStudio`
2.  Kies in het menu `Tools -> Global Options`
3.  Indien niet de laatste versie vermeld staat bij R version: klik op *Change* om het aan te passen.
4.  Klik op *OK* als je een waarschuwing krijgt dat je `RStudio` moet herstarten.
5.  Wijzig de initial working directory in `C:/R/R-3.x.y`[2]
6.  Klik op *OK*
7.  Herstart `RStudio`

[1] x en y verwijzen naar het versienummer. Dus bij R-3.1.0 is x = 1 en y = 0. De working directory is in dat geval `C:/R/R-3.1.0`

[2] x en y verwijzen naar het versienummer. Dus bij R-3.1.0 is x = 1 en y = 0. De working directory is in dat geval `C:/R/R-3.1.0`

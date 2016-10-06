R installeren als administrator
================

Windows
-------

Installatiebestand beschikbaar via <http://cran.r-project.org/bin/windows/base/>

In de onderstaande tekst moet je in `R-3.x.y` zowel `x` als `y` vervangen door een cijfer om zo het huidige versienummer te krijgen. Dus voor versie `R-3.0.0` is `x` = 0 en `y` = 0.

### Nieuwe installatie van R

1.  Maak de map `C:\R\library` aan. Zorg dat alle gebruikers volledige toegangsrechten hebben.
2.  Voer het bestand *R-3.x.y-win.exe* uit.
3.  Kies *Nederlands* als taal voor de installatie en klik op *OK*.
4.  klik op *Volgende*.
5.  Aanvaard de licentievoorwaarden door op *Volgende* te klikken.
6.  Kies als doelmap `C:\R\R-3.x.y` en klik op *Volgende*. Je **MOET** de standaardwaarde dus aanpassen!
7.  Selecteer de gewenste componenten en klik op *Volgende*. Je **MOET** deze standaardwaarden laten staan.
8.  Opstartinstelling aanpassen: Kies `Nee` en klik op *Volgende*.
9.  Geef de map voor het start menu en klik op *Volgende*. Je mag de standaardwaarde gebruiken.
10. Vink de gewenste extra snelkoppelingen *aan* (default is ok), alle register entries *aan* en klik op *Volgende*.
11. R wordt nu geïnstalleerd. Klik op *Voltooien* als de installatie afgelopen is.
12. Ga naar `Start` en tik "Omgevingsvariabelen" in het veld ´Programma's en variabelen zoeken´. Selecteer `De omgevingsvariabelen van het systeem bewerken`. Selecteer het tabblad `Geavanceerd` en klik op de knop `Omgevingsvariabelen`. Ga na of er een systeemvariabele `R_LIBS_USER` met waarde `C:/R/library` bestaat[1]. Indien niet, maak deze aan met de knop `Nieuw`. Sluit al deze schermen via de `OK` knop.
13. Kopieer het bestand `Rprofile.site` naar `C:\R\R-3.x.y\etc` Hierbij moet je het bestaande bestand overschrijven.
14. Zorg dat de gebruiker schrijfrechten heeft voor `C:\R\R-3.x.y\library`

#### Afwijkingen t.o.v. default installatie

-   Installeren naar `C:\R\R-3.x.y` i.p.v. `C:\Program Files\R\R-3.x.y`
-   **alle** gebruikers moeten **volledige** rechten hebben in
    -   `C:\R\library`
    -   `C:\R\R-3.x.y\library`
-   Systeemvariable `R_LIBS_USER` instellen op `C:/R/library` (**verplicht forward slashes**)
-   `Rprofile.site` in `C:\R\R-3.x.y\etc` overschrijven met versie van P-schijf

**R mag niet met admininstratorrechten gestart worden.** Anders worden een aantal packages met administrator rechten geïnstalleerd waardoor de gebruiker ze niet meer kan updaten.

Start `R` als een gewone gebruiker om de configuratie te testen.

### Upgrade van een bestaande R installatie

**Deze instructies veronderstellen dat R en RStudio in het verleden reeds geïnstalleerd werden volgens de bovenstaande instructies. Indien dan niet het geval is, volg dan de instructies voor een nieuwe installatie.**

1.  Voer het bestand *R-3.x.y-win.exe* uit.
2.  Kies Nederlands als taal voor de installatie en klik op *OK*.
3.  klik op *Volgende*.
4.  Aanvaard de licentievoorwaarden door op *Volgende* te klikken.
5.  Kies als doelmap `C:\R\R-3.x.y` en klik op *Volgende*. Je **MOET** de standaardwaarde dus aanpassen!
6.  Selecteer de gewenste componenten en klik op *Volgende*. Je **MOET** deze standaardwaarden laten staan.
7.  Opstartinstelling aanpassen: Kies `Nee` en klik op *Volgende*.
8.  Geef de map voor het start menu en klik op *Volgende*. Je mag de standaardwaarde gebruiken.
9.  Vink alle extra snelkoppelingen *uit*, alle register entries *aan* en klik op *Volgende*.
10. R wordt nu geïnstalleerd. Klik op *Voltooien* als de installatie afgelopen is.
11. Rechtsklik op de snelkoppeling (in het Start menu) naar `R x64 3.x.y` en kies eigenschappen.
12. Wijzig *Beginnen in* naar `C:\R\R-3.x.y`
13. Voeg achteraan het veld *Doel* de volgende tekst toe: `--no-save --no-restore`
14. Herhaal de laatste drie stappen voor de snelkoppeling naar `R i386 3.x.y`
15. Kopieer het bestand `Rprofile.site` naar `C:\R\R-3.x.y\etc` Hierbij moet je het bestaande bestand overschrijven.
16. Zorg dat de gebruiker schrijfrechten heeft voor `C:\R\R-3.x.y\library`
17. De nieuwe R versie is klaar voor gebruik. De gebruiker moet `RStudio` bijwerken.

**R mag niet met admininstratorrechten gestart worden.** Anders worden een aantal packages met administrator rechten geïnstalleerd waardoor de gebruiker ze niet meer kan updaten.

Start `R` als een gewone gebruiker om de configuratie te testen.

### Inhoud `Rprofile.site`

    options(
      papersize = "a4",
      tab.width = 2,
      width = 80,
      help_type = "html",
      stringsAsFactors = TRUE,
      keep.source.pkgs = TRUE,
      xpinch = 300,
      ypinch = 300,
      repos = c(
        RStudio = "https://cran.rstudio.com/",
        INLA = "http://www.math.ntnu.no/inla/R/stable"
      ),
      install.packages.check.source = "yes"
    )
    if (interactive()) {
      tryCatch(
        print(fortunes::fortune()),
        error = function(e){
          invisible(NULL)
        }
      )
      warning(
    "Opgelet: vanaf nu worden character variabelen bij het inlezen automatisch
    omgezet naar factoren. Gebruik onderstaande commando aan het begin van elk
    script om terug de oude instelling te krijgen.

    options(stringsAsFactors = FALSE)

    Je kan ook expliciet het argument 'stringsAsFactors = FALSE' gebruiken bij het
    inlezen van gegevens.

    read.csv2('bestand.csv', stringsAsFactors = FALSE)
    sqlQuery(channel, query, stringsAsFactors = FALSE)
    data.frame(X = 1:10, stringsAsFactors = FALSE)

    Om deze waarschuwing niet meer te tonen, open je C:/R/R-3.x.y/etc/Rprofile.site.
    Zoek naar deze tekst en plaats # voor elke regel vanaf warning( tot )"
      )
    }

[1] Het moeten forward slashes zijn.

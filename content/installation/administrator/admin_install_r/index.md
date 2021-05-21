---
title: "Install R"
description: "Instruction for the installation of R (in Dutch)"
date: "2021-05-21"
authors: [thierryo]
categories: ["installation"]
tags: ["r", "installation"]
output: 
    md_document:
        preserve_yaml: true
        variant: gfm
---

## Windows

Installatiebestand beschikbaar via
[cloud.r-project.org](https://cloud.r-project.org/bin/windows/base)

In de onderstaande tekst moet je in `R-4.x.y` zowel `x` als `y`
vervangen door een cijfer om zo het huidige versienummer te krijgen. Dus
voor versie `R-4.0.0` is `x` = 0 en `y` = 0.

### Nieuwe installatie van R

1.  Voer het bestand *R-4.x.y-win.exe* uit.
2.  Kies *Nederlands* als taal voor de installatie en klik op *OK*.
3.  klik op *Volgende*.
4.  Aanvaard de licentievoorwaarden door op *Volgende* te klikken.
5.  Wijzig de standaarddoelmap naar `C:\R\R-4.x.y` en klik op
    *Volgende*.
6.  Selecteer de gewenste componenten en klik op *Volgende*. Je **MOET**
    deze standaardwaarden laten staan.
7.  Opstartinstelling aanpassen: Kies `Nee` en klik op *Volgende*.
8.  Geef de map voor het start menu en klik op *Volgende*. Je mag de
    standaardwaarde gebruiken.
9.  Vink de gewenste extra snelkoppelingen *aan* (default is ok), alle
    register entries *aan* en klik op *Volgende*.
10. R wordt nu geïnstalleerd. Klik op *Voltooien* als de installatie
    afgelopen is.
11. Ga naar `Start` en tik “Omgevingsvariabelen” in het veld
    `Programma's en variabelen zoeken`. Selecteer
    `De omgevingsvariabelen van het systeem bewerken`. Selecteer het
    tabblad `Geavanceerd` en klik op de knop `Omgevingsvariabelen`. Ga
    na of er een systeemvariabele `R_LIBS_USER` met waarde
    `C:/R/library` bestaat[1]. Indien niet, maak deze aan met de knop
    `Nieuw`. Sluit al deze schermen via de `OK` knop.
12. Kopieer het bestand [`Rprofile.site`](Rprofile.site) naar `etc` in
    de doelmap waar je R geïnstalleerd hebt (`C:\R\R-4.x.y`). Hierbij
    moet je het bestaande bestand overschrijven.
13. Zorg dat de gebruiker schrijfrechten heeft voor
    `C:\R\R-4.x.y\library` en `C:\R\library`.

#### Afwijkingen t.o.v. default installatie

-   Wijzig de standaarddoelmap naar `C:\R\R-4.x.y`
-   **alle** gebruikers moeten **volledige** rechten hebben in
    -   `C:\R\library`
    -   `C:\R\R-4.x.y\library`
-   Systeemvariable `R_LIBS_USER` instellen op `C:/R/library`
    (**verplicht forward slashes**)
-   [`Rprofile.site`](Rprofile.site) in `C:\R\R-4.x.y\etc` overschrijven

**R mag niet met admininstratorrechten gestart worden.** Anders worden
een aantal packages met administrator rechten geïnstalleerd waardoor de
gebruiker ze niet meer kan updaten.

Start `R` als een gewone gebruiker om de configuratie te testen.

### Upgrade van een bestaande R installatie

**Deze instructies veronderstellen dat R en RStudio in het verleden
reeds geïnstalleerd werden volgens de bovenstaande instructies. Indien
dat niet het geval is, volg dan de instructies voor een nieuwe
installatie.**

1.  Voer het bestand *R-4.x.y-win.exe* uit.
2.  Kies *Nederlands* als taal voor de installatie en klik op *OK*.
3.  klik op *Volgende*.
4.  Aanvaard de licentievoorwaarden door op *Volgende* te klikken.
5.  Wijzig de standaarddoelmap naar `C:\R\R-4.x.y` en klik op
    *Volgende*.
6.  Selecteer de gewenste componenten en klik op *Volgende*. Je **MOET**
    deze standaardwaarden laten staan.
7.  Opstartinstelling aanpassen: Kies `Nee` en klik op *Volgende*.
8.  Geef de map voor het start menu en klik op *Volgende*. Je mag de
    standaardwaarde gebruiken.
9.  Vink de gewenste extra snelkoppelingen *aan* (default is ok), alle
    register entries *aan* en klik op *Volgende*.
10. R wordt nu geïnstalleerd. Klik op *Voltooien* als de installatie
    afgelopen is.
11. Kopieer het bestand [`Rprofile.site`](Rprofile.site) naar `etc` in
    de doelmap waar je R geïnstalleerd hebt (`C:\R\R-4.x.y`). Hierbij
    moet je het bestaande bestand overschrijven.
12. Zorg dat de gebruiker schrijfrechten heeft voor
    `C:\R\R-4.x.y\library`
13. De nieuwe R versie is klaar voor gebruik. De gebruiker moet
    `RStudio` bijwerken.

**R mag niet met admininstratorrechten gestart worden.** Anders worden
een aantal packages met administrator rechten geïnstalleerd waardoor de
gebruiker ze niet meer kan updaten.

Start `R` als een gewone gebruiker om de configuratie te testen.

### Inhoud `Rprofile.site`

    options(
      papersize = "a4",
      tab.width = 2,
      width = 80,
      help_type = "html",
      keep.source.pkgs = TRUE,
      xpinch = 300,
      ypinch = 300,
      yaml.eval.expr = TRUE,
      usethis.full_name = "Research Institute for Nature and Forest",
      usethis.description = list(
        `Authors@R` = "c(
      person(
        \"Voornaam\", \"Achternaam\", role = c(\"aut\", \"cre\"),
        email = \"voornaam.achternaam@inbo.be\",
        comment = c(ORCID = \"9999-9999-9999-9999\")),
      person(
        \"Research Institute for Nature and Forest\",
        role = c(\"cph\", \"fnd\"), email = \"info@inbo.be\"))",
        License = "GPL-3",
        Language = "en-GB",
        Encoding = "UTF-8",
        Roxygen = "list(markdown = TRUE)"
      ),
      repos = c(
        CRAN = "https://cloud.r-project.org/",
        INLA = "https://inla.r-inla-download.org/R/stable"
      ),
      install.packages.check.source = "no",
      install.packages.compile.from.source = "never"
    )

    # display fortune when starting new interactive R session
    if (interactive()) {
      if (length(find.package("fortunes", quiet = TRUE)) == 0) {
        utils::install.packages("fortunes")
      }
      tryCatch(
        print(fortunes::fortune()),
        error = function(e){
          invisible(NULL)
        }
      )
    }

## Ubuntu

    sudo sh -c 'echo "deb http://cloud.r-project.org/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list'
    sudo gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
    sudo gpg -a --export E084DAB9 | apt-key add -

    sudo apt-get update
    sudo apt-get install -y r-base r-base-dev libcurl4-openssl-dev libssl-dev libssh2-1-dev libxml2-dev

[1] Het moeten forward slashes zijn.

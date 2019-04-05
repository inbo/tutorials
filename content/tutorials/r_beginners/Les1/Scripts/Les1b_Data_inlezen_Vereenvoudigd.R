### Doelstelling:
###--------------

#Dit script bevat enkele voorbeelden hoe eenvoudige dataformaten (.txt, .csv, .xlsx en .gsheet) ingelezen kunnen worden

### Voorbereiding
###----------------

#Zorg dat je de 3 databestanden "species.txt", "survey.csv", "survey.xslx" hebt, alsook de link "https://docs.google.com/spreadsheets/d/1f4vpxZdscu_8854M-z69nKT9MxQlag-4iQ1R3rJKYfY/edit?usp=sharing"

#Zorg dat je een R project hebt, met de subfolder "data" waarin je de 3 databestanden onderbrenvt (dus de folder "data" is een subfolder van de folder die je werkdirectory is). Als je met een project werkt is dit automatisch correct.

#met getwd() kan je je huidige werkdirectory terugvinden
#Via het hoofdmenu "Session" > Set Working directory > Choose ... kan je die eventueel manueel aanpassen

getwd()

#Installeer indien deze nog niet geïnstalleerd zijn volgende pakketten: readr, readxl, googlesheets

install.packages("readr")
install.packages("readxl")
install.packages("googlesheets")

### Inlezen tabgescheiden tekstbestand
###------------------------------------

#Inlezen van tekstbestanden gebeurt altijd met het readr package
#De file species.txt is een tabgescheiden file. Een tab wordt in R voorgesteld met "\t"
#andere parameteropties kan je altijd opvragen via de help

library("readr")

#We lezen de file species.txt in en bewaren deze in de R dataset dfSpecies
#Eens zo ingelezen dan kunnen we dfSpecies in R gebruiken

#inlezen zelf (tabgescheiden, niet-aanwezige-waarden worden als een leeg veld voorgesteld)
dfSpecies <- read_delim(file = "data/species.txt", 
                        delim = "\t", 
                        na = ""                    
                        )

#data bekijken
View(dfSpecies) #of in de Environment erop klikken
head(dfSpecies) #bekijk de eerste rijen


### Inlezen CSV (Europese stijl)
###------------------------------

#De Europese vorm van .csv gaat uit van een ; als scheiding en , als decimaal
#voor de europese vorm gebruiken we read_csv2, voor de Amerikaansse is dit read_csv
#De eerste 2 rijen in de csv zijn geen onderdeel van de data, die skippen we

dfSurvey <- read_csv2(file = "data/survey.csv", 
                      skip = 2)
dfSurvey
summary(dfSurvey)
View(dfSurvey)

#Je krijgt een message "Using ',' as decimal and '.' as grouping mark. Use read_delim() for more control." --> is OK

#Spijtig genoeg werden de datums niet herkend
#Dit moet met wat code opgelost worden
#via col_types zeg je dat de datum moet gehaald worden uit de kolom Datum met als formaat dag/maand/jaar.

dfSurvey <- read_csv2(file = "data/survey.csv", 
                      skip = 2, 
                      col_types = cols(Datum = col_date(format = "%d/%m/%Y")))
View(dfSurvey)
summary(dfSurvey)



###Inlezen Excel
###----------------

#Het benodigde pakket is readxl

library(readxl)

#We willen het tabblad Plot2 inlezen (dit is het eerste werkblad in Excel)
#We kunnen kiezen of we de sheetnaam of sheetnummer gebruiken
#We kunnen een range specificiëren
#Omdat het datumformaat in Excel consistent is ingevuld, wordt dit automatisch herkend


dfSurvey2 <- read_excel(path = "data/survey.xlsx", 
                        sheet = "Plot2",
                        range = "A2:D21" 
                        )
dfSurvey2
summary(dfSurvey2)

table(dfSurvey2$Sex) #controle of de geslachten juist ingevuld zijn



###Inlezen googlesheet
###-------------------

#Om googlesheets in te lezen heb je het "googlesheets" package nodig

library(googlesheets)

#Aangezien Google beveiligd is moet je jezelf autoriseren. Dit moet enkel periodiek opnieuw
#Je zal naar een browser gestuurd worden en je zal je login moeten ingeven en toegang geven aan tidyverse-googlesheets. Als je "Allow" drukt dan zal je ofwel een code krijgen, die je dan in R moet plakken, ofwel zal je de melding krijgen dat de authorisatie gelukt is en dat je gewoon terug naar R moet gaan.

gs_auth()

#Eens je authorisatie in orde is, moet je de spreasheet registreren (identificeren) via de url, key of title

my_spreadsheet <- gs_url("https://docs.google.com/spreadsheets/d/1f4vpxZdscu_8854M-z69nKT9MxQlag-4iQ1R3rJKYfY/edit?usp=sharing")

#alternatief, en iets sneller (die code zie je ook in de URL staan)
my_spreadsheet <- gs_key("1f4vpxZdscu_8854M-z69nKT9MxQlag-4iQ1R3rJKYfY")

#Nu is je spreadsheet geïdentificeerd, maar er is nog niets gedownload en nog geen data in R aangemaakt
#Het inlezen zelf gebeurt als volgt, waarbij ws het nummer of de naam van het werkblad is. Indien je de naam kiest dan moet dit in quotes staan "Sheet1"
#NA waarden worden als NULL in de googlesheet weergegeven, dus dat kan je via de parameter "na" oplossen.

dfLab <- gs_read(ss = my_spreadsheet, 
                 ws = 1, 
                 na = "NULL"
                 )
head(dfLab)
View(dfLab)





###HUISTAAK
###---------

#Lees het tweede tabblad van survey.xlsx in, maar beperkt je tot de data van Plot3b
#bewaar deze data in het object dfSurveyPlot3b

#is de data correct ingelezen?
#Wat is je oordeel over de kolom Sex?






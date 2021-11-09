## ----EenvoudigTeksbestand-----------------------------

library(readr)
bestandSP <- "data/20180222_species.csv"

#het inlezen van de csv inhoud in het R object dfSpecies
dfSpecies <- read_delim("data/20180222_species.csv", delim = ",")

#idem, maar we steken de filenaam in een R object
dfSpecies <- read_delim(bestandSP, delim = ",")

#identiek, maar het formaat is al door de functie geregeld
dfSpecies <- read_csv("data/20180222_species.csv")

#voor help
?read_delim

#Altijd alles controleren
#Kan ook door in het environment paneel het object dfSpecies
#aan te klikken of uit te vouwen
dim(dfSpecies)
head(dfSpecies)
tail(dfSpecies)
summary(dfSpecies)
str(dfSpecies)
View(dfSpecies)

#De file werd niet volledig correct ingelezen
# een NA waarde in eerste kolom die wel degelijk de waarde afkorting NA bedoelt
#Bij de view zie je dat de NA in kolom 1 cursief is in tegenstelling tot de rest
#in dit geval moet je het na argument meegeven.
#zodat de waarde NA in het bestand niet als een missende waarde aanzien wordt
dfSpecies <- read_csv("data/20180222_species.csv", na = "")



## ----TekstbestandMetOpties----------------------------

#Voorbeeld:

#De Europese vorm van .csv gaat uit van een ; als scheiding en , als decimaal
#voor de Europese vorm gebruiken we read_csv2, voor de Amerikaansse is dit read_csv
#De eerste 2 rijen in de csv zijn geen onderdeel van de data, die skippen we

#Dit is wat je krijgt via het menu
#aantal en volgorde van argumenten kan verschillen
#het pad is mogelijks het absolute pad ipv het relatieve pad zoals hieronder
dfSurvey <- read_delim("data/survey.csv",
                       delim = ";", skip = 2,
                       escape_double = FALSE,
                       col_types = cols(Datum = col_date(format = "%d/%m/%Y")),
                       locale = locale(decimal_mark = ",", grouping_mark = ""),
                       trim_ws = TRUE, skip = 2)
View(dfSurvey)
summary(dfSurvey)



## ----WegschrijvenTekstbestand-------------------------

#onderstaande alternatieven doen hetzelfde, maar write_excel_csv2 is de voorkeur
#iris is een meegeleverde dataset in R, via data(iris) zie je die in je environment
data(iris)
write_delim(iris, "data/iris.csv", delim = ";") #decimaalteken is .
write_csv2(iris, "data/iris.csv") #decimaalteken is ,
write_excel_csv2(iris, "data/iris.csv") #decimaalteken is ,



## ----ExcelInlezen-------------------------------------

library("readxl")
bestandsnaam <- "data/20190124_survey_part1.xlsx"

#als sheet kan je ook de naam gebruiken "Blad1"
dfSurvey1 <- read_excel(bestandsnaam, sheet = 1)

summary(dfSurvey1) #geen kolomnamen, allemaal characters, zelfs 1 logical
head(dfSurvey1)

#Dit kan gemakkelijk als volgt opgelost worden
dfSurvey2 <- read_excel(bestandsnaam, sheet = "Blad1", skip = 1, n_max = 19 )
summary(dfSurvey2)
str(dfSurvey2)

#Je kan ook een range specifiëren en de na-waarden instellen
dfSurvey3 <- read_excel(bestandsnaam, sheet = "Blad1", skip = 0,
                        range = "A2:D21",
                        na = c("", "#NAAM?"))
View(dfSurvey3)



## ----ExcelSheetEnRange--------------------------------

library(readxl)
#De gegevens staan in het tabblad Plot2 in de range A2:D21
dfSurvey2 <- read_excel(path = "data/survey.xlsx",
                        sheet = "Plot2",
                        range = "A2:D21"
                        )
dfSurvey2
summary(dfSurvey2)

table(dfSurvey2$Sex) #controle of de geslachten juist ingevuld zijn

?read_excel #voor meer info over de argumenten



## ----GooglesheetInlezen -------------------

 library(googlesheets4) #laden van het googlesheets package

 gs4_auth() #authorisatie (de eerste keer en dan periodiek eens nodig)
 #Let op. dit is interactief, dus de volgende code nog niet plakken

 #geef je email direct mee, dan moet je je naam niet selecteren
 #als je 0auth-token nog geldig is
 gs4_auth(email = "xxx@yyy.zzz") #e-mail adres naar je eigen adres wijzigen

 #Je kan registreren met de html van de sheet of de sheet key
 url <- "https://docs.google.com/spreadsheets/d/1f4vpxZdscu_8854M-z69nKT9MxQlag-4iQ1R3rJKYfY/edit?usp=sharing"
 #De key is onderdeel van de url
 key <- "1f4vpxZdscu_8854M-z69nKT9MxQlag-4iQ1R3rJKYfY"

 dfLab <- read_sheet(url) #zal volledig eerste sheet lezen in de url
 dfLab <- read_sheet(key) #identiek maar voor de key

 #Optioneel: Indien je de titel en sheetnamen wil kennen
 gs4_get(key) #ook hier kan je de url gebruiken

 #Je kan het inlezen meer finetunen en een sheet opgeven en optioneel ook een range
 dfLab <- read_sheet(ss = key, #pad + file
                     sheet = 1,  #worksheetnummer of "naam"
                     na = "NULL", #hoe wordt NA gecodeerd
                     range = "A1:H44" #de range (optioneel)
                     )
 head(dfLab)
 View(dfLab)

 ?read_sheet #help opvragen voor overzicht van alle argumenten



## ----BinaireBestanden---------------------------------

#Bewaar enkele geïmporteerde datasets samen in de file mijngegevens.Rdata
save(dfLab, dfSpecies, file = "mijngegevens.Rdata")

#Verwijder deze datasets, zodat deze niet meer bestaan in de R sessie
#De bestanden waaruit deze data komt verdwijnen natuurlijk niet
#Alternatief kan je R herstarten (via CTRL + SHIFT + F10)
rm(dfLab, dfSpecies)

#Lees deze opnieuw in via het binaire bestand
load(file = "mijngegevens.Rdata")

#dfLab en dfSpecies staan terug



## ----AccessInlezen------------------------------------

#!!! Werkt enkel bij 32-bit versie van R als je enkel 32-bit Office drivers hebt
#Vanaf office365 is 64-bit geen probleem

bestand <- "data/bosvitaliteit.accdb"

conn <- odbcConnectAccess2007(bestand) #voor .accdb bestanden (voor .mdb: odbcConnectAccess(bestand))
sqlTables(conn) #optioneel toon de aanwezige tabellen

#haal een volledige tabel binnen
dfTest <- sqlFetch(conn, sqtable = "qryMetingen")

#haal data binnen via een sql query
query <- "select JAAR, PRVNR, BMNR, OMTREK from tblOpnames"
dfTest <- sqlQuery(conn, query)

#sluit de connectie
odbcClose(conn) #is niet per sé nodig, maar is properder

str(dfTest)
head(dfTest)



## ----GegevensbronInlezen------------------------------

library(RODBC)
conn <- odbcConnect("Naam_Van_Mijn_Gegevensbron")

#hierop kan je dan sqlQuery of sqlFetch gebruiken,
#zoals getoond bij de connectie naar Access.



## ----DatabankInlezen --------------------
##
## library(DBI)
## library(odbc)
##
## #maak de connectie
## #die zie je in Rstudio in het paneel rechtsboven onder tabblad connections
## #zorg dat je op het INBO netwerk zit, of met vpn verbonden bent
## #de 2  basis db servers op het INBO in 2021 zijn
##     #inbo-sql08-prd.inbo.be voor data warehouses
##     #inbo-sql07-prd.inbo.be voor databanken
## con <- DBI::dbConnect(odbc::odbc(),
##                       driver = "SQL Server",
##                       server = "inbo-sql08-prd.inbo.be",
##                       database = "W0003_00_Lims")
##
## #toon de beschikbare tabellen in het dbo schema
## #op het INBO is dit schema standaard voor de tabellen
## dbListTables(con, table_type = "TABLE", schema_name = "dbo")
##
## #Lees een volledige tabel in
## dfUnits <- dbReadTable(con, "dimUnit")
## head(dfUnits)
##
## #Lees gegevens in ahv een query
## sql = "select LabSampleID, FieldSampleID, SampleType, Project from dimSample "
## sql = paste(sql, "where Project = 'I-17W001-02'")
## dfSamples <-dbGetQuery(con, sql, n = 500)
## head(dfSamples)
##
## #Optioneel: Sluit de connectie
## dbDisconnect(con)
##


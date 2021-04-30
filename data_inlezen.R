## ----setup, echo=FALSE--------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE, eval = FALSE)


## ----relatiefpad, eval = FALSE------------------------------------------------
## 
## getwd()
## 
## #data die in de werkdirectory staat
## data <- read_csv("mijndata.csv")
## 
## #data die in een subfolder van je werkdirectory staat
## data <- read_csv("subfolder/mijndata.csv")
## 
## #data die 1 folder hoger staat
## data <- read_csv("../mijndata.csv")
## 
## #data 2 folders hoger
## data <- read_csv("../../mijndata.csv")
## 
## #data die in een andere folder staat op hetzelfde niveau als je werkfolder
## data <- read_csv("../anderefolder/mijndata.csv")
## 


## ----example_speciesERR-------------------------------------------------------

#Benodigde package laden
library(readr)

#de bestandsnaam is 20180222_species.csv
#maar deze staat in de folder data in de werkdirectory

#het inlezen
#alternatief 1
dfSpecies <- read_delim("data/20180222_species.csv", delim = ",") 
#alternatief 2
bestandsnaam <- "data/20180222_species.csv"
dfSpecies <- read_delim(bestandsnaam, delim = ",")
#alternatief 3
dfSpecies <- read_csv(bestandsnaam)

#Toon de eerste/laatste 6 rijen
head(dfSpecies)
tail(dfSpecies)

#Toon de dimensies
dim(dfSpecies)

#Toon een samenvatting van de kolommen
summary(dfSpecies)

#Toon de data in een sorteerbare en filterbare tabel
#Hetzelfde als dubbelklikken op object in "Environment"
View(dfSpecies)

#Toon de inwendige structuur van de data
#Hetzelfde als het object uitvouwen in "Environment"
str(dfSpecies)

#Stukje code dat je gewoon kan repliceren, checkt gewoon het aantal ontbrekende waarden
apply(dfSpecies, 2, function(x) sum(is.na(x)))

# ---> Waar zit de fout?

?read_csv #kijk naar de parameter "na"

#Correct ingelezen:
dfSpecies <- read_csv(bestandsnaam, na = "") #ofwel na = character()



## ----surveycsv----------------------------------------------------------------

library(readr)

dfSurvey <- read_csv2(file = "data/survey.csv", 
                      skip = 2) #skip = 2 slaat de eerste 2 rijen over
dfSurvey
summary(dfSurvey)
View(dfSurvey)

#Spijtig genoeg werden de datums niet herkend
#Dit moet met wat code opgelost worden
#via col_types zeg je dat de datum moet gehaald worden 
#uit de kolom Datum met als formaat dag/maand/jaar.
dfSurvey <- read_csv2(file = "data/survey.csv", 
                      skip = 2, 
                      col_types = cols(Datum = col_date(format = "%d/%m/%Y")))
View(dfSurvey)
summary(dfSurvey)



## ----surveyxls----------------------------------------------------------------

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



## ----google, eval=FALSE-------------------------------------------------------
## library(googlesheets4) #laden van het googlesheets package
## 
## gs4_auth() #authorisatie (de eerste keer en dan periodiek eens nodig)
## #Let op. dit is interactief, dus de volgende code nog niet plakken
## 
## gs4_auth(email = "xxx@yyy.zzz") #geef je email direct mee, als je 0auth-token nog geldig is, dan werkt dit niet interactief
## 
## #Je kan registreren met de html van de sheet of de sheet key
## url <- "https://docs.google.com/spreadsheets/d/1f4vpxZdscu_8854M-z69nKT9MxQlag-4iQ1R3rJKYfY/edit?usp=sharing"
## key <- "1f4vpxZdscu_8854M-z69nKT9MxQlag-4iQ1R3rJKYfY"
## 
## dfLab <- read_sheet(url) #zal volledig eerste sheet lezen in de url
## dfLab <- read_sheet(key) #zal volledig eerste sheet lezen in de key
## 
## #Indien je de titel en sheetnamen wil kennen
## gs4_get(url) #ook hier kan je de key gebruiken
## 
## #Je kan het inlezen meer finetunen en een sheet opgeven en optioneel ook een range
## dfLab <- read_sheet(ss = key, #pad + file
##                     sheet = 1,  #worksheetnummer of "naam"
##                     na = "NULL", #hoe wordt NA gecodeerd
##                     range = "A1:H44" #de range (optioneel)
##                     )
## head(dfLab)
## View(dfLab)
## 
## ?read_sheet #help op overzicht te vinden van alle argumenten
## 


## ----binair-------------------------------------------------------------------
#Bewaar enkele geïmporteerde datasets samen in de file mijngegevens.Rdata
save(dfLab, dfSpecies, file = "mijngegevens.Rdata")

#Verwijder deze datasets, zodat deze niet meer bestaan in de R sessie
#De bestanden waaruit deze data komt verdwijnen natuurlijk niet
#Alternatief kan je R herstarten (via CTRL + SHIFT + F10)
rm(dfLab, dfSpecies)

#Lees deze opnieuw in via het binaire bestand
load(file = "mijngegevens.Rdata")

#dfLab en dfSpecies staan terug



## ----accessrodbc--------------------------------------------------------------
library(RODBC)

bestand <- "data/bosvitaliteit.accdb"

conn <- odbcConnectAccess2007(bestand)
conn #als dit -1 is, of een tekst van 2 regels dan is de connectie niet gelukt

#Toon alle aanwezige tabellen
sqlTables(conn)

#Toon enkel tabellen en views
sqlTables(conn, tableType =  c("TABLE", "VIEW")) #toon enkel tabellen en views

#Je kan de queries ook gewoon als een tabel inlezen
dfTest <- sqlFetch(conn, sqtable = "qryMetingen")
summary(dfTest)

#Dit kan ieder mogelijke query zijn die Access aankan
query <- "select JAAR, PRVNR, BMNR, OMTREK from tblOpnames"

#Hier pas haal je je data binnen
dfTest <- sqlQuery(conn, query)
summary(dfTest)

odbcClose(conn) #is altijd  properder je connecties weer af te sluiten



## ----accessdbi----------------------------------------------------------------
##Via DBI (werkt niet als je niet alle drivers hebt)

library(DBI)
library(odbc)

db_connect_string <- paste0("DBQ=", 
                        bestand, #je bestandsnaam van eerder
                        ";",
                        "Driver={Microsoft Access Driver (*.mdb, *.accdb)};"
                       )
myconn <-  dbConnect(odbc::odbc(),
                     .connection_string = db_connect_string)
myconn #indien -1 of een warning van 2 regels --> mislukt

#Hele tabel inlezen
dfOpnames2 <- dbReadTable(myconn, "tblOpnames")

#QUery inlezen
sql <- "select * from tblOpnames"
dfOpnames2 <- dbGetQuery(myconn, sql)
 


## ----dbconnectRODBC-----------------------------------------------------------

library(RODBC)

odbcDataSources() #toont de beschikbare datasources
conn <- odbcConnect("W0003_00_Lims")
conn

#Toon alle aanwezige tabellen met sqlTables, head is om te beperken tot de eerste
head(sqlTables(conn))

#Dit zijn de nuttige in INBO databases
sqlTables(conn, tableType = c("VIEW", "TABLE"), schema = "dbo")

#Hele tabel ophalen
dfDocu <- sqlFetch(conn, "vwDocumentatie", max = 1000)

sql <- "select LabSampleID, FieldSampleID, SampleType, Project "
sql <- paste(sql, "from dimSample where Project = 'I-17W001-02'")
dfSamples <- sqlQuery(conn, query =  sql)

head(dfSamples)

odbcClose(conn)



## ----dbConnectDBI-------------------------------------------------------------

library(DBI)
library(odbc)

#Connectie met het LIMS datawarehouse
con <- dbConnect(odbc::odbc(),
                 driver = "SQL Server",
                 server = "inbo-sql08-prd.inbo.be",
                 database = "W0003_00_Lims")
con

dbListTables(con, table_type = "TABLE", schema_name = "dbo")

dfUnits <- dbReadTable(con, "dimUnit")
head(dfUnits)
View(dfUnits)

sql <- "select LabSampleID, FieldSampleID, SampleType, Project"
sql <- paste(sql, "from dimSample where Project = 'I-17W001-02'")
dfSamples <- dbGetQuery(con, sql, n = 500)
head(dfSamples)
View(dfSamples)

dbDisconnect(con) #stop de connectie met de db



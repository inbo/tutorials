## ----installpackages, eval = FALSE---------------------------------------
## 
## #eenmalige installatie
## install.packages("readxl")
## #alternatief, ga in Rstudio naar het tabblad "Packages" en kies daar voor install.
## 
## #iedere keer je R opnieuw opent
## library("readxl")
## #alternatief, in het tabblad Packages vink readxl aan
## 

## ----relatiefpad, eval = FALSE-------------------------------------------
## 
## getwd()
## 
## #data die in de werkdirectory staat
## data <- read_csv("mijndata.csv")
## 
## #data die in een subfolder van je werkdirectory staat
## data <- read_csv("subfolder/mijndata.csv")
## 
## #data die in 1 folder hoger
## data <- read_csv("../mijndata.csv")
## 
## #data 2 folders hoger
## data <- read_csv("../../mijndata.csv")
## 
## #data die in een andere folder staat op hetzelfde niveau als je werkfolder
## data <- read_csv("../anderefolder/mijndata.csv")
## 
## #je kan ook absolute padnamen gebruiken
## data <- read_csv("c:/ikke/projecten/data/mijndata.csv")
## 
## #in plaats van / kan je ook altijd \\ gebruiken in Windows systemen
## #en je kan die zelfs mixen als je verwarrend wil overkomen
## data <- read_csv("c:\\ikke/projecten\\data/mijndata.csv")
## 

## ----example_species-----------------------------------------------------

library(readr)
bestandSP <- "data/20180222_species.csv"

#bewaar de filenaam in een R object (dit is niet nodig)
#Je kan die zelf laten aanvullen, bijvoorbeeld als je data/ intypt en dan op tab drukt krijg je een overzicht met beschikbare bestanden en folders


## ----example_speciesERR, eval = FALSE------------------------------------
## 
## #het inlezen
## dfSpecies <- read_delim(bestandSP) #begrijpbare foutmelding
## 
## ##Error in read_delim(bestandSP) : could not find function "read_delim"
## 

## ----example_species2, eval = TRUE---------------------------------------
dfSpecies <- read_delim(bestandSP, delim = "\t") #wtf?

dfSpecies <- read_delim(bestandSP, delim = ",") #dit lijkt er al op

dfSpecies <- read_csv(bestandSP) #alternatief

#Nakijken of de data wel juist ingelezen is

##Toon de eerste/laatste 5 rijen/de dimensies
head(dfSpecies)
tail(dfSpecies)
dim(dfSpecies)

##Toon een samenvatting van de kolommen
summary(dfSpecies)

##Toon de data in een sorteerbaar en filterbare tabel
##is hetzelfde als op het object te klikken in het "Environment" tabblad
##Als je goed kijkt kan je hier iets vreemd zien in de eerste kolom
View(dfSpecies)

##Toon de inwendige structuur van de data
##is hetzelfde als het object uitvouwen in het "Environment" tabblad
str(dfSpecies)

##Stukje code die je gewoon kan repliceren, checkt gewoon het aantal niet-aanwezige waarden
apply(dfSpecies, 2, function(x) sum(is.na(x)))

# ---> Waar zit de fout?

?read_csv #kijk naar de parameter "na"
dfSpecies <- read_csv(bestandSP, na = "") #ofwel na = character()


## ----organicfarms--------------------------------------------------------

bestandOF <- "data/sdg_02_40.tsv"

dfOrganic <- read_delim(bestandOF, delim = "\t") #\t betekent tab als scheidingsteken
dfOrganic <- read_tsv(bestandOF) #is hetzelfde

#Tevreden?
summary(dfOrganic)
View(dfOrganic)

#we verwachten numeriek, maar alles is character, dus de "na"" aanpassen
dfOrganic2 <- read_delim(bestandOF, 
                        delim = "\t", 
                        na = ": ") 
head(dfOrganic2)
View(dfOrganic2)

#cijfers krijgen soms commentaar als suffix (e, p, r)
#oplosbaar via parse_number
#onderstaande code loopt gewoon door kolom 2 tot 19 en 
#verandert de waarden naar pure getallen
#het blijft belangrijk op te verifiëren dat je geen extra NA waarden hebt gecreëerd
for (i in 2:19){
  dfOrganic2[[i]] <- parse_number(dfOrganic2[[i]])  
}

View(dfOrganic2)
summary(dfOrganic2)

#het data formaat is nu OK, maar de kolomnamen en de inhoud van de eerste kolom kan nog beter
#technieken hiervoor komen volgende lessen aan bod


## ----logger--------------------------------------------------------------
bestandL <- "data/logger1684.txt"

#Poging om het bestand in te lezen

dfLogger1 <- read_csv(bestandL)
View(dfLogger1)  #wat is het probleem?

#read_csv2 gaat uit van ";" als scheidingsteken en "," als decimaalteken
dfLogger2 <- read_csv2(bestandL) 
head(dfLogger2)
tail(dfLogger2)
View(dfLogger2)

#de eerste rijen horen niet thuis in de dataset
?read_csv2
dfLogger3 <- read_csv2(bestandL, skip = 4) 
head(dfLogger3)
#oei, de eerste rij wordt als kolomnamen gezien: 
#reden: R verwacht standaard kolomnamen (de standaardwaarde voor col_names = TRUE)
#daarnaast wordt X4 als een logical (TRUE/FALSE) gezien --> te maken met guess_max

dfLogger4 <- read_csv2(bestandL, skip = 4, col_names = FALSE)
View(dfLogger4) #bekijk de inhoud van de kolommen, en sorteer eens van klein naar groot en omgekeerd
dim(dfLogger4) #Je kan dit ook al direct zien in het "Environment tabblad"
head(dfLogger4)

#ziet er al beter uit, maar X2 wordt als character aanzien, X3 is OK, 
#X4 als logical is niet gewenst en X5 als numerieke waarde klopt ook niet
#Ook de laatste regel mag weg, want dit bevat enkel een end of file indicatie
dfLogger5 <- read_csv2(bestandL, skip = 4,
                       col_names = c("tijdstip", "begin", "midden", "einde", "clouds"),
                       na = c("", "ERROR"),
                       n_max = 1497) 
head(dfLogger5)
table(dfLogger5$clouds) #de 4+ is weggevallen uit clouds kolom en NA geworden

#Standaard wordt naar de eerste 1000 rijen gekeken om te raden welk datatype,
#maar de eerste 4+ komt bij clouds na de 1000ste rij voor
#dus het wordt als numeriek ingeschat, waardoor 4+ geen geldige waarde is en NA wordt
#Verder is er nog geen data de eerste 1000 rijen voor de kolom einde, 
#dus de functie kan hier ook niet juist raden welk datatype het is 
#en kiest bij alleen NA voor logical
dfLogger6 <- read_csv2(bestandL, skip = 4,
                       col_names = c("tijdstip", "begin", "midden", "einde", "clouds"),
                       na = c("", "ERROR"),
                       n_max = 1497, 
                       guess_max = 5000)
summary(dfLogger6)

#Alternatief kan je ook op voorhand de kolomtypes vastleggen
?read_csv #kijk onder col_types, daar kan je zien wat Tdddc betekent
dfLogger6b <- read_csv2(bestandL, skip = 4,
                       col_names = c("tijdstip", "begin", "midden", "einde", "clouds"),
                       na = c("", "ERROR"),
                       n_max = 1497, 
                       col_types = "Tdddc")
summary(dfLogger6b)

#We zijn er bijna. We hebben pech dat de datumtijd geen herkend formaat is, 
#dus dit zullen we nog moeten aanpassen
?strptime

#De datum wordt nog niet correct ingelezen, dus nog een laatste poging nodig
dfLogger7 <- read_csv2(bestandL, skip = 4,
                       na = c("", "ERROR", "#EOF"), 
                       col_names = c("tijdstip","begin","midden","einde","clouds"),
                       guess_max = 5000, 
                       col_types = cols(tijdstip = col_datetime(format = "%d/%m/%Y %H:%M"),
                                        clouds = col_factor(levels = c(1,2,3,4,"4+"))),
                       n_max = 1497) 

summary(dfLogger7)
View(dfLogger7)


## ----excel---------------------------------------------------------------

library("readxl")

bestandSV <- "data/20190124_survey_part1.xlsx"

#Naïef inlezen
dfSurvey1 <- read_excel(bestandSV, sheet = 1) #als sheet kan je ook de naam gebruiken "Blad1"
summary(dfSurvey1) #geen kolomnamen, allemaal charactervariabelen, zelfs 1 logical
head(dfSurvey1)
tail(dfSurvey1)

#Dit kan gemakkelijk opgelost worden
dfSurvey2 <- read_excel(bestandSV, sheet = "Blad1", skip = 1, n_max = 19 )
summary(dfSurvey2)

#Je kan ook een range specifiëren en de na-waarden instellen
dfSurvey3 <- read_excel(bestandSV, sheet = "Blad1", skip = 0, range = "A2:D21", 
                        na = c("", "#NAAM?"))
summary(dfSurvey3)

#Je kan ook het blad in de range specifiëren en kolommen overslaan
dfSurvey4 <- read_excel(bestandSV,  range = "Blad1!A2:F21", 
                        col_names = TRUE,
                        col_types = c("date", "text", "text", "numeric", "skip", "numeric"))
summary(dfSurvey4)


dfSurvey5 <- read_excel(bestandSV,  range = "Blad1!A2:F21", 
                        col_names = c("datum", "soort", "geslacht", "gewicht"),
                        col_types = c("date", "text", "text", "numeric", "skip", "skip"))
summary(dfSurvey5) #plotseling extra NA waarden
head(dfSurvey5)
#Als je expliciet de kolomnamen opgeeft, gaat de functie er vanuit dat 
#de eerste rij een data-rij is in plaats van kolomheader

#Hier geven we de kolomnamen expliciet op, maar dit wil zeggen dat de data maar op rij 3 begint
dfSurvey6 <- read_excel(bestandSV,  range = "Blad1!A3:F21", 
                        col_names = c("datum", "soort", "geslacht", "gewicht"),
                        col_types = c("date", "text", "text", "numeric", "skip", "skip"))
summary(dfSurvey6)
View(dfSurvey6)



## ----access, eval = TRUE-------------------------------------------------
library(RODBC)

bestand <- "data/bosvitaliteit.accdb"

conn <- odbcConnectAccess(bestand)
conn #als dit -1 is, of een tekst van 2 regels dan is de connectie niet gelukt

conn <- odbcConnectAccess2007(bestand) 
conn

#Toon de aanwezige tabellen
sqlTables(conn)
sqlTables(conn, tableType =  c("TABLE", "VIEW"))

#Je kan de queries ook gewoon als een tabel inlezen
dfTest <- sqlFetch(conn, sqtable = "qryMetingen")
summary(dfTest)

#Dit kan ieder mogelijke query zijn, zelfs zeer complex
query <- "select JAAR, PRVNR, BMNR, OMTREK from tblOpnames"

dfTest <- sqlQuery(conn, query)
summary(dfTest)
str(dfTest)

odbcClose(conn) #is altijd  properder je connecties weer af te sluiten

##Via DBI

#dit werkt bij mij niet omdat ik de stuurprogramma's voor MS Access niet heb
#De connectiecode zou er als volgt moeten uitzien

# dbq_string <- paste0("DBQ=", bestand)
# driver_string <- "Driver={Microsoft Access Driver (*.mdb, *.accdb)};"
# db_connect_string <- paste0(driver_string, dbq_string)
# 
# myconn <- DBI::dbConnect(odbc::odbc(),
#                     .connection_string = db_connect_string)
# 
# sql <- "select * from tblOpnames"
# Data <- dbGetQuery(myconn, sql)
 



## ----googlesheets, eval = TRUE-------------------------------------------

library(googlesheets)

gs_auth() #is enkel nodig als je authorisatie verlopen is

#De volgende 3 manieren hebben allemaal hetzelfde resultaat
#De key is een onderdeel van de URL, en is eigenlijk de basisidentificatie

ss_key <- gs_key("1lJWxLIyynPHGiF6GaM1I3yO0l592tMwKOFPbFwpjvYc")
ss_url <- 
  gs_url("https://docs.google.com/spreadsheets/d/1lJWxLIyynPHGiF6GaM1I3yO0l592tMwKOFPbFwpjvYc/edit#gid=0")
ss_title <- gs_title("validatie")

#Eens geregistreerd kan je de info inlezen

dfLab <- gs_read(ss_key, ws = 1)
head(dfLab)

dfLab2 <- gs_read(ss_key, ws = "Sheet1", na = c("", "NULL"), range = "A1:H44")
head(dfLab2) 
#als je in google sheets consistent bent met je datumtijd notatie,
#dan is de kans reëel dat het onmiddellijk als datumtijd ingelezen wordt, 
#indien niet zal je weer met col_types moeten werken zoals in het readr package


## ----dbconnectRODBC------------------------------------------------------

#via RODBC
library(RODBC)

odbcDataSources() #toont de beschikbare datasources
conn <- odbcConnect("W0003_00_Lims")
conn

sqlTables(conn)[1:10,1:5] #er zijn er teveel om allemaal te tonen

#Dit zijn de nuttige
sqlTables(conn, tableType = c("VIEW", "TABLE"), schema = "dbo")

dfDocu <- sqlFetch(conn, "vwDocumentatie", max = 1000)

sql <- "select LabSampleID, FieldSampleID, SampleType, Project "
sql <- paste(sql, "from dimSample where Project = 'I-17W001-02'")
dfSamples <- sqlQuery(conn, query =  sql)

head(dfSamples)

odbcClose(conn)


## ----dbConnectDBI--------------------------------------------------------

library(DBI)
library(odbc)

con <- DBI::dbConnect(odbc::odbc(),
                      driver = "SQL Server",
                      server = "inbo-sql08-prd.inbo.be",
                      database = "W0003_00_Lims")

dbListTables(con, table_type = "TABLE", schema_name = "dbo")

dfUnits <- dbReadTable(con, "dimUnit")
head(dfUnits)
View(dfUnits)

sql = "select LabSampleID, FieldSampleID, SampleType, Project from dimSample where Project = 'I-17W001-02'"
dfSamples <-dbGetQuery(con, sql, n = 500)
head(dfSamples)
View(dfSamples)

dbDisconnect(con)


## ----binair--------------------------------------------------------------
#Bewaar enkele geïmporteerde datasets samen in de file mijngegevens.Rdata
save(dfSamples, dfLogger7, file = "mijngegevens.Rdata")

#Verwijder deze datasets
rm(dfSamples, dfLogger7)

#Lees deze opnieuw in via het binaire bestand
load(file = "mijngegevens.Rdata")



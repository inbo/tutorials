
#Laadt het pakket tidyverse
library(tidyverse)

#Kijk wat je werkdirectory is, en pas die eventueel aan met setwd of het menu
getwd()

#Lees pilootstudie.csv in
#Deze code gaat er vanuit dat dit in de data folder staat in je werkdirectory
piloot <- read_csv2('data/pilootstudie.csv')

#output als data.frame
head(iris, n = 10)

#output als tibble
piloot #piloot is een tibble omdat die met read_csv2 ingelezen is


##FILTER IRIS
#---------------

##vb1: selecteer de virginicas
iris1 <- filter(iris, Species == "virginica")
head(iris1)

##vb2: 3 methoden om virginicas met Sepal>Length >= 7 te filteren
filter(iris, Species == "virginica" & Sepal.Length >= 7) #methode1
filter(iris, Species == "virginica",  Sepal.Length >= 7) #methode2
iris %>%                                                 #methode3
  filter(Species == "virginica") %>%
  filter(Sepal.Length >= 7)

##vb3: Bewaar je resultaat in een nieuwe dataset
iris2 <-
  iris %>%
  filter(Species == "virginica") %>%
  filter(Sepal.Length >= 7)

#vaak wordt gekozen om de data op dezelfde regel te zetten
#deze code doet hetzelfde als hierboven
iris2 <- iris %>%
  filter(Species == "virginica") %>%
  filter(Sepal.Length >= 7)

#De meest gebruikte methode op INBO is als volgt (identiek als hierboven)
iris2 <- iris %>%
  filter(Species == "virginica",
         Sepal.Length >= 7)
head(iris2)


##FILTER piloot data
#----------------------

##vb1: Behou enkel rijen met aanwezige Omtrek en Hoogte
piloot2 <- piloot %>%
  filter(!is.na(Omtrek) & !is.na(Hoogte))

#Kijk of er rijen verdwenen zijn
nrow(piloot)
nrow(piloot2)


##vb2: behou enkel ploeg 1, 5 en 7
piloot2 %>%
  filter(Ploeg %in% c(1, 5, 7))

#identiek maar met een logische OR
piloot2 %>%
  filter(Ploeg == 1 | Ploeg == 5 | Ploeg == 7)


## ARRANGE
#-----------

##vb1: sorteer volgens kleinste omtrek
arrange(piloot2, Omtrek)

##vb2: sorteer volgens grootste Hoogte
piloot2 %>%
  arrange(desc(Hoogte))

##vb3: Sorteer eerst om omtrek, daarna op hoogte
arrange(piloot2, Omtrek, Hoogte)

##vb4: sorteer op omtrek daarna volgens grootste Hoogte
piloot2 %>%
  arrange(Omtrek, desc(Hoogte)) %>%
  View() #toon de resultaten in het Rstudio grid


## MUTATE
#----------------------

##vb1: oppervlakte Sepal
nieuwe_iris <- mutate(iris, Sepal.Opp = Sepal.Length * Sepal.Width)
head(nieuwe_iris)

##vb2: Verhouding oppervlaktes kelk- en kroonblaadjes
#voor de leesbaarheid gebruik best nieuwe regels
iris %>%
  mutate(Sepal.Opp = Sepal.Length * Sepal.Width,
         Petal.Opp = Petal.Length * Petal.Width,
             Verhouding = Sepal.Opp / Petal.Opp) %>%
  head() #toon de eerste rijen met de nieuwe berekeningen

#Bovenstaande bewaart je resultaat niet en toont enkel een deel
#Onderstaande bewaart het resultaat als object nieuwe_iris
nieuwe_iris <- iris %>%
  mutate(Sepal.Opp = Sepal.Length * Sepal.Width,
          Petal.Opp = Petal.Length * Petal.Width,
          Verhouding = Sepal.Opp / Petal.Opp)


## SELECT
#-----------

    #selecteer alle variabelen die beginnen met Petal
select(iris, starts_with("Petal"))

    #selecteer alle variabelen die niet eindigen met Width
select(iris, -ends_with("Width"))

    #identiek als hierboven maar met .vars expliciet opgegeven
select(iris, .vars = -ends_with("Width"))

    #selecteer alle numerieke variabelen
    #.vars hoeft niet expliciet vermeld
select(iris, .vars = where(is.numeric))

    #via kolomnaamvector
kolommen <- c("Species", "Petal.Width")
select(iris, .vars = any_of(kolommen))

#selecteer enkel Species en hernoem deze als Soort
select(iris, Soort = Species)


## TRANSMUTE
#-------------

#Behou de soort als uppercase en de Petal.Area in de data
#verwijder de rest
iris %>%
  transmute(Soort = toupper(Species),
  Petal.Area = Petal.Length * Petal.Width)


## SUMMARISE pilootdata
#---------------------------

##vb1: kleinste omtrek
summarise(piloot2, Dunste = min(Omtrek))

##vb2: maximale Hoogte, aantal proefvlakken, mediaan referentie
piloot2 %>%
  summarise(HoogsteBoom = max(Hoogte),
            AantalProefVlakken = n_distinct(Proefvlak),
            MediaanRef = median(Referentie))

##vb3: gemiddelde van alle variabelen
piloot2 %>%
  summarise_all(mean)


## SUMMARISE irisdata
#---------------------------

##vb1: gemiddelde van alle numerieke variabelen
iris %>%
  summarise_if(is.numeric, mean)

##vb2; minimum en maximum van alles behalve Species
#beter met across werken
#het commando list is hier nodig voor verschillende kolommen
iris %>%
  summarise_at(vars(-Species),
               list(minimum = min,
                    maximum = max))


## GROUPED SUMMARISE IRISDATA
#----------------

##vb1: iris
iris %>%
  group_by(Species) %>%
  summarise(Aantal = n(),
            Gemiddelde = mean(Sepal.Width))


## GROUPED SUMMARISE PILOOTDATA
#------------------

##vb1
piloot2 %>%
  group_by(Proefvlak, Boom) %>%
  summarise(MinOmtrek = min(Omtrek),
            GemOmtrek = mean(Omtrek),
            MaxOmtrek = max(Omtrek),
            MinHoogte = min(Hoogte),
            GemHoogte = mean(Hoogte),
            MaxHoogte = max(Hoogte))


##vb2
piloot2 %>%
  group_by(Proefvlak, Ploeg) %>%
  summarise(Aantal = n())


## EFFECT van .GROUPS
#-----------------------

test <- piloot %>%
  group_by(Proefvlak, Boom)
test #output: Groups: Proefvlak, Boom [96] (96 combinaties boom en proefvlak)

#na de summary verdwijnt de laatste variabele in de groepering
#enkel nog:  Groups:   Proefvlak [8] blijft over
test %>%
  summarize(GemOmtrek = mean(Omtrek))
#je krijgt volgende melding boven het resultaat:
    #`summarise()` has grouped output by 'Proefvlak'.
    #You can override using the `.groups` argument.

#de groepering is volledig verdwenen
test %>%
  summarize(GemOmtrek = mean(Omtrek, na.rm = TRUE), .groups = "drop")

#de oorspronkelijke groepering op Proefvlak en Proef blijft behouden
test %>%
  summarize(GemOmtrek = mean(Omtrek, na.rm = TRUE), .groups = "keep")

#iedere rij is een aparte groep
test %>%
  summarize(GemOmtrek = mean(Omtrek, na.rm = TRUE), .groups = "rowwise")

#waarvoor 'drop_last' handig is
piloot %>%
  group_by(Proefvlak, Boom) %>%
  summarize(GemOmtrek = mean(Omtrek, na.rm = TRUE)) %>% #groepering op Boom is weg
  summarize(GemOmtrek = mean(GemOmtrek)) #dus nu per Proefvlak berekend


## DISTINCT
#-----------

#1 rij valt weg omdat die identiek is aan een andere rij
#alle kolommen worden behouden
iris %>%  distinct()

#Toon alle verschillende Sepal.Length en Species combinaties
#enkel de vermelde kolommen worden behouden
iris %>% distinct(Sepal.Length, Species)


## SLICE
#-----------

#Toon de eerste, vijfde en zevende rij
iris %>%
  slice(c(1, 5, 7))

#afgeleide functies van van slice

#Toon de 3 eerste rijen
iris %>%
  slice_head(n = 3)

#Toon de laatste 10% rijen
iris %>%
  slice_tail(prop = 0.10)

#Toon de 7 grootste Sepal.Length
iris %>%
  slice_max(Sepal.Length, n = 7)

#Toon de 7 kleinste Sepal.Length
iris %>%
  slice_min(Sepal.Length, n = 7)

#Toon de kleinste 25% Sepal.Length
iris %>%
  slice_min(Sepal.Length, prop = 0.25)

#Toon 10 willekeurige rijen
iris %>%
  slice_sample(n = 10)


## PULL
#------------

#resultaat is een vector in plaats van een dataset
iris %>% pull(Sepal.Width)

#haal alle Petal.Width op voor de  virginica's
iris %>% filter(Species == "virginica") %>% pull(Petal.Width)


## RENAME
#----------

#Hernoem species naar soortnaam
iris_soort <- iris %>%
  rename(Soortnaam = Species)
colnames(iris_soort)

#maak alle namen uppercase
iris_soort <- iris_soort %>%
  rename_with(.fn = toupper, .cols = everything())
colnames(iris_soort)


## COUNT
#-----------

#tel de volledige lengte van de dataset
count(iris)

#tel het aantal per soort
iris %>%
  count(Species)

    #identiek als hierboven (maar is een tibble door group_by)
iris %>%
  group_by(Species) %>%
  summarise(n = n())

#Tel het aantal Petal.Length > 5 voor de verschillende soorten
#en sorteer op het aantal (via sort = TRUE)
iris %>%
  count(Species, Petal.Length > 5, sort = TRUE)


## SEPARATE
#-------------------

testdata <- data.frame(Name = c("pieter_verschelde", "raisa_carmen"))
testdata

separate(testdata, col = Name, into = c("voornaam", "naam"), sep = "_")


## ACROSS
#-----------

#geef per soort de gemiddelde waarde van de Petal variabelen
iris %>%
  group_by(Species) %>%
  summarize(across(.cols = starts_with("Petal"), mean))

#bereken per soort het gemiddelde en mediaan van de Petal variabelen
iris %>% group_by(Species) %>%
  summarize(across(.cols = starts_with("Petal"),
                  list(gemiddelde = mean,
                       mediaan = median)))

#bereken de vierkantswortel van alle numerieke variabelen
iris %>%
  mutate(across(where(is.numeric), sqrt)) %>%
  slice_head(n = 5)

#je kan ook je eigen functies maken en gebruiken
cm_to_mm <- function(x) { return(x * 10)}
iris %>%
  mutate(across(where(is.numeric), cm_to_mm)) %>%
  slice_head(n = 5)

#identiek als hierboven maar door de functie inline te gebruiken
#met .x zeg je dat dat de berekening op de respectievelijke kolom moet gebeuren
iris %>%
  mutate(across(where(is.numeric), ~ .x * 10)) %>%
  slice_head(n = 5)


##MEERDERE RECORDS
#-----------------------

#maak een functie die het gemiddelde en mediaan berekent, zowel in cm als in mm
#het resultaat is een dataset met 3 kolommen: name, calc_cm en calc_mm
mean_and_median <- function(x) {
  data.frame(name = c("avg", "med"),
             calc_cm = c(mean(x), median(x)),
             calc_mm = c(mean(x * 10), median(x * 10)))
}

#voer de functie uit voor Petal.Width
iris %>%
  group_by(Species) %>%
  summarise(Resultaat = mean_and_median(Petal.Width)) %>%
  slice_head(n = 5)

#dit kan ook met across toegepast worden op meerdere variabelen
#let op, dit is een data.frame die data.frames bevat
ingewikkeld <-
  iris %>%
  group_by(Species) %>%
  summarise(across(contains("Width"), mean_and_median))

ingewikkeld

#Slechts 3 kolomnamen
#Petal.Width en Sepal.Width zijn elk data.frames binnen de data.frame ingewikkeld
colnames(ingewikkeld)

#Selecteer enkel de berekende gemiddeldes in mm voor de Sepal.Width
ingewikkeld %>%
  pull(Sepal.Width) %>% #haal eerst de Sepal.Width dataset eruit
  filter(name == "avg") %>% #behou enkel de gemiddeldes
  pull(calc_mm) #haal hieruit dat de berekening in mm


## DO
#-------

#Selecteer voor elke soort de 3 grootste Sepal.Width
# binnen do werken pipes niet
iris %>%
  group_by(Species) %>%
  do({
    resultaat <- slice_max(., Sepal.Width, n = 3, with_ties = FALSE)
    resultaat
  })


## NEST
#----------

#wat doet nest: de dataset is maar 3 rijen lang (1 rij per groep),
#maar iedere rij bevat een dataset met alle informatie
iris %>% nest_by(Species)

#bewaar in de kolom res de 3 grootste Sepal.Width per soort
#Dit geeft een kolom die een dataset is
#Je maakt die terug enkelvoudig door summarise op de kolomnaam
iris %>%
  nest_by(Species) %>%
  summarise(res = data %>%
              slice_max(Sepal.Width, n = 3, with_ties = FALSE)) %>%
  summarise(res)


## BIND ROWS
#----------------

#Maak 2 datasets en voeg aan de tweede een variabele toe
#en bind die terug samen
irisA <- iris %>%
  slice(1:3)
irisB <- iris %>%
  slice(148:150) %>%
  mutate(Opmerking = 'foutieve waarde')
bind_rows(irisA, irisB)


## BIND COLS
#----------------

#Maak 2 datasets en bindt die samen via kolommen
#Hoe omgegaan wordt met dubbele namen kan je via .name_repair regelen (zie help)
irisC <- iris %>%
  select(Species, Petal.Length) %>%
  slice(1:3)
irisD <- iris %>%
  select(Species, Sepal.Length) %>%
  slice(1:3)
bind_cols(irisC, irisD)


## JOINS
#--------------

#maak dummy datasetjes aan
df1 <- data.frame(x = 1:3, grp = letters[1:3])
df2 <- data.frame(y = 4:6, grp = letters[c(1:2, 4)])
df1
df2

#vergelijk de verschillende soorten join
df1 %>% inner_join(df2, by = "grp")
df1 %>% left_join(df2, by = "grp")
df1 %>% right_join(df2, by = "grp")
df1 %>% full_join(df2, by = "grp")
df1 %>% semi_join(df2, by = "grp")
df1 %>% anti_join(df2, by = "grp")

## PIVOT_LONGER
#-----------------

#maak een mini iris dataset aan
iris_mini <- iris %>%
  slice(c(1, 51, 101))
iris_mini

#zet om naar lang formaat
iris_mini %>%
  pivot_longer(cols = c(Sepal.Length, Sepal.Width,
                        Petal.Length, Petal.Width),
               names_to = "Meting",
               values_to = "Waarde")

#analoog
iris_mini %>%
  pivot_longer(cols = -Species, values_to = "Waarde")


#maak mini piloot dataset aan
piloot_mini <- piloot %>%
  sample_n(4)
piloot_mini

#zet om naar lang formaat
piloot_mini %>%
  pivot_longer(names_to = "Kenmerk",
               values_to = "Waarde",
              cols = c(Omtrek, Hoogte))

## PIVOT_WIDER
#-----------------

#maak een iris dataset aan in lang formaat
#splits de variabelen op in kenmerk Blad en afmeting
iris_lang <- iris %>%
  slice(c(1, 51, 101)) %>%
  pivot_longer(names_to = "Kenmerk", values_to = "Waarde", -Species) %>%
  separate(Kenmerk, into = c("Blad", "Afmeting"))
iris_lang

#iris naar breed formaat omzetten
iris_lang %>%
  pivot_wider(names_from = c(Afmeting, Blad),
              values_from = Waarde)

#maak piloot data aan in lang formaat met enkel de eerste Meting
piloot_lang <- piloot %>%
  filter(Meting == 1) %>%
  select(Proefvlak, Boom, Ploeg, Omtrek) %>%
  distinct()     # Nodig omdat er voor Ploeg 4 nog 2 records overblijven (hoogtemeting met 2 toestellen)
head(piloot_lang)


#piloot naar breed formaat omzetten
piloot_lang %>%
  pivot_wider(values_from = Omtrek,
              names_from = Ploeg)



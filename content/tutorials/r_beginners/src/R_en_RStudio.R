## ----Rekenmachine-------------------------------------
1 / 200 * 30
(59 + 73 + 2) / 3
sin(pi / 2)
sqrt(169)


## ----NieuweObjecten-----------------------------------
x <- 3 * 4
y <- sqrt(169)
z <- (x > y)
naam <- "Ivy Jansen"


## ----ObjectenVerwijderen------------------------------

#een object verwijderen
objectnaam <- "dit is een object dat ik wil verwijderen"
rm(objectnaam)

#Alle objecten verwijderen
rm(list = ls())



## ----InstallerenEnLadenPackages-----------------------
  install.packages("tidyverse") #eenmalig, quotes zijn nodig

  tekstje <- "van deze string wil ik het aantal characters tellen"
  str_count(tekstje) #werkt niet, de functie is nog niet gekend

  library(tidyverse) #telkens je een nieuwe R sessie start
  str_count(tekstje) #nu werkt het wel



## ----BijwerkenPackages--------------------------------
update.packages("tidyverse")


## ----InstallPackageFromGithub-------------------------
#eenmalige installatie
install.packages('remotes') #ook het pakket devtools kan je gebruiken

library(remotes)
install_github("inbo/INBOtheme") #pakket voor INBO figuurlayout van Thierry



## ----ObjectNamen--------------------------------------
i_use_snake_case = "aangeraden" #dit is aangeraden op het INBO
otherPeopleUseCamelCase = "veel gebruikt"
some.people.use.periods = "afgeraden"
this_is_a_really_long_name <- 2.5


## ----Hoofdlettergevoelig------------------------------
r_rocks <- 2 ^ 3
r_rock
#> Error: object 'r_rock' not found
R_rocks
#> Error: object 'R_rocks' not found


## ----EnkeleVeelgebruikteFuncties----------------------
sin(pi / 2)
sqrt(169)
seq(1, 10, length.out = 10)
seq(to = 10, from = 1, by = 1)
round(5.78)
c(3, 5, 10)


## ----EigenFunctie-------------------------------------
#definieer je eigen functie met de naam mijn_som
#argumenten x en y beiden zonder defaultwaarde
mijn_som <- function(x, y) {
  resultaat <- x + y
  return(resultaat)
}

#voer de functie uit met de objecten a en b
a <- 5
b <- 7
mijn_som(x = a, y = b)



## ----Lussen-------------------------------------------
#print voor elke waarde van i (1 tot 10) de waarde van i
for (i in 1:10) {
  resultaat <- paste("i heeft de waarde", i)
  print(resultaat)
}

#resultaat start als 0, zolang j <= 5 is, wordt telkens 2 * j eraan toegevoegd
j <- 0
resultaat <- 0
while (j <= 5) {
  print(paste0("j heeft de waarde ", j))
  resultaat <- resultaat + 2 * j
  j <- j + 1
}
print(resultaat)



## ----WaardenToekennen, eval = TRUE--------------------
waarde1 <- 3
waarde2 <- 5
waarde3 <- 7
waarde3

naam1 <- "categorie1"
naam2 <- "categorie2"
naam3 <- "categorie3"
naam3

opmerking <- "Dit is een simpele dataset"


## ----Vectoren, eval = TRUE----------------------------
waardekolom <- c(waarde1, waarde2, waarde3)
waardekolom
waardenrange <- 10:1
waardenrange
waardenrange2 <- seq(from = 1, to = 20, by = 2)
waardenrange2

namenkolom <- c(naam1, naam2, naam3)
namenkolom

meerderedimensies <- matrix(1:9, ncol = 3)
meerderedimensies


## ----Dataframes, eval = TRUE--------------------------
dataset <- data.frame(naam = namenkolom, waarde = waardekolom)
dataset


## ----Lijsten, eval = TRUE-----------------------------
lijst <- list(datasetnaam = dataset,
beschrijving = opmerking)
lijst



## ----VectorSelectie, eval = TRUE----------------------
waardekolom[2]
namenkolom[c(3, 2)]
meerderedimensies[1, 2]
waardekolom[-1]
namenkolom[-c(2, 4)]
meerderedimensies[-3, -2]
meerderedimensies[1, ]   #selecteer hele eerste rij  --> vereenvoudigd tot vector
class(meerderedimensies[1, ] )
meerderedimensies[1, , drop = FALSE] #selecteer hele eerste rij --> blijf matrix
class(meerderedimensies[1, , drop = FALSE] )
waardekolom[c(1, 2, 3, 2, 1, 2)]


## ----DataframeSelectie, eval = TRUE-------------------
dataset$waarde
dataset[[2]]
dataset[2]
dataset["waarde"]    #blijft data.frame
dataset[["waarde"]]  #conversie naar vector
dataset[3, 2]
dataset[3, 2, drop = FALSE]
class(dataset[3, 2, drop = FALSE])
dataset$waarde[2]


## ----LijstSelectie, eval = TRUE-----------------------
lijst["datasetnaam"]
class(lijst["datasetnaam"])
lijst[2]
lijst$datasetnaam
class(lijst$datasetnaam)
lijst[[2]]
lijst$datasetnaam$waarde[2]
lijst[[1]][[2]][[2]]


## ----VoorwaardelijkeSelectie--------------------------
#Toon de waarden in de waardenkolom
waardekolom

#selecteer de tweede waarde
waardekolom[2]

#is identiek, enkel het tweede element is TRUE en  wordt geselecteerd
waardekolom[c(FALSE, TRUE, FALSE)]

#Geeft TRUE indien >4 en FALSE indien <= 4
waardekolom > 4
voorwaarde <- waardekolom > 4 #is een object die de TRUE-FALSE vector bevat


#selecteer alle waarden > 4
#de elementen waarvoor waardekolom > 4 TRUE is worden geselecteerd
waardekolom[waardekolom > 4]
waardekolom[voorwaarde] #identiek

#selecteer alle kolommen, dus leeg na de komma uit de dataset
#waarvoor de naam niet "categorie2"is
dataset$naam != "categorie2" #ter illustratie: de TRUE FALSE vector

dataset[dataset$naam != "categorie2", ] #uiteindelijke selectie

#selecteer de namen waarvoor de waarde kleiner dan 4 of groter dan 6 is
#We nemen slechts 1 kolom, dus zal dit tot een vector vereenvoudigd worden
dataset$waarde < 4
dataset$waarde > 6
(dataset$waarde < 4) | (dataset$waarde > 6) #haakjes optioneel maar duidelijk
voorwaarde2 <- (dataset$waarde < 4) | (dataset$waarde > 6)

dataset[(dataset$waarde < 4) | (dataset$waarde > 6), "naam"]
dataset[voorwaarde2, "naam"] #identiek maar via tussenvariabele voorwaarde2



## ----EenvoudigPlotIris--------------------------------
data(iris) #zorg dat je de data ziet in het Environment paneel
plot(iris$Sepal.Length, iris$Sepal.Width)
plot(iris$Sepal.Length, iris$Sepal.Width, col = iris$Species)
plot(iris$Sepal.Length, iris$Sepal.Width, col = iris$Species,
     main = "Iris Sepal data", xlab = "Length", ylab = "Width")
barplot(iris$Petal.Length)


## ----MissingData--------------------------------------
heights <- c(1, 2, 4, 4, NA, 6, 8)
mean(heights)
max(heights)
mean(heights, na.rm = TRUE)
max(heights, na.rm = TRUE)
!is.na(heights)
na.omit(heights)
complete.cases(heights)
heights[!is.na(heights)]


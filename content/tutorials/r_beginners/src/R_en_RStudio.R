
library(knitr)
library(tidyverse)
library(INBOtheme)
theme_set(theme_inbo(6, transparent = "plot"))
opts_chunk$set(
  out.extra = "",
  inline = TRUE,
  echo = TRUE,
  eval = FALSE,
  cache = TRUE,
  dpi = 300,
  fig.width = 4.5,
  fig.height = 3
  )


##
1 / 200 * 30
(59 + 73 + 2) / 3
sin(pi / 2)
sqrt(169)


##
x <- 3 * 4
y <- sqrt(169)
z <- (x > y)
naam <- "Ivy Jansen"


##
object_name <- value


#
i_use_snake_case #dit is aangeraden op het INBO
otherPeopleUseCamelCase
some.people.use.periods


##
this_is_a_really_long_name <- 2.5


##
r_rocks <- 2 ^ 3


##
r_rock
#> Error: object 'r_rock' not found
R_rocks
#> Error: object 'R_rocks' not found


##
resultaat <- function_name(arg1 = val1, arg2 = val2, ...)


##
sin(pi / 2)
sqrt(169)
seq(1, 10, length.out = 10)
seq(to = 10, from = 1, by = 1)
round(5.78)


##
x <- "hello world"


##----eigenfunctie------------------------------------------------
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



##----loops-------------------------------------------------------
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



##----commandosbasis, eval = TRUE---------------------------------
waarde1 <- 3
waarde2 <- 5
waarde3 <- 7
waarde3

naam1 <- "categorie1"
naam2 <- "categorie2"
naam3 <- "categorie3"
naam3

opmerking <- "Dit is een simpele dataset"


##----commandosvectoren, eval = TRUE------------------------------
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


##----commandosdataframe, eval = TRUE-----------------------------
dataset <- data.frame(naam = namenkolom, waarde = waardekolom)
dataset


##----commandoslijst, eval = TRUE---------------------------------
lijst <- list(datasetnaam = dataset,
beschrijving = opmerking)
lijst



##----selectievector, eval = TRUE---------------------------------
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


##----selectiedataframe, eval = TRUE------------------------------
dataset$waarde
dataset[[2]]
dataset[2]
dataset["waarde"]    #blijft data.frame
dataset[["waarde"]]  #conversie naar vector
dataset[3, 2]
dataset[3, 2, drop = FALSE]
class(dataset[3, 2, drop = FALSE])
dataset$waarde[2]


##----selectielijst, eval = TRUE----------------------------------
lijst["datasetnaam"]
class(lijst["datasetnaam"])
lijst[2]
lijst$datasetnaam
class(lijst$datasetnaam)
lijst[[2]]
lijst$datasetnaam$waarde[2]
lijst[[1]][[2]][[2]]


##----voorwaardeselectie------------------------------------------
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



##----eval = TRUE-------------------------------------------------
data(iris) #zorg dat je de data ziet in het Environment paneel
plot(iris$Sepal.Length, iris$Sepal.Width)
plot(iris$Sepal.Length, iris$Sepal.Width, col = iris$Species)
plot(iris$Sepal.Length, iris$Sepal.Width, col = iris$Species,
     main = "Iris Sepal data", xlab = "Length", ylab = "Width")
barplot(iris$Petal.Length)


##----missingdata, eval = TRUE------------------------------------
heights <- c(1, 2, 4, 4, NA, 6, 8)
mean(heights)
max(heights)
mean(heights, na.rm = TRUE)
max(heights, na.rm = TRUE)
!is.na(heights)
na.omit(heights)
complete.cases(heights)
heights[!is.na(heights)]


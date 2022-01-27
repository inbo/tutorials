## ----include = FALSE-----------------------------------------------------


## ------------------------------------------------------------------------
1 / 200 * 30
(59 + 73 + 2) / 3
sin(pi / 2)
sqrt(169)


## ------------------------------------------------------------------------
x <- 3 * 4
y <- sqrt(169)
z <- (x > y)
naam <- "Ivy Jansen"


## ------------------------------------------------------------------------
object_name <- value


## ------------------------------------------------------------------------
i_use_snake_case
otherPeopleUseCamelCase
some.people.use.periods


## ------------------------------------------------------------------------
this_is_a_really_long_name <- 2.5


## ------------------------------------------------------------------------
r_rocks <- 2 ^ 3


## ------------------------------------------------------------------------
r_rock
#> Error: object 'r_rock' not found
R_rocks
#> Error: object 'R_rocks' not found


## ------------------------------------------------------------------------
function_name(arg1 = val1, arg2 = val2, ...)


## ------------------------------------------------------------------------
sin(pi / 2)
sqrt(169)
seq(1, 10)
round(5.78)


## ------------------------------------------------------------------------
x <- "hello world"


## ----commandosbasis, eval = TRUE-----------------------------------------
waarde1 <- 3
waarde2 <- 5
waarde3 <- 7
waarde3

naam1 <- "categorie1"
naam2 <- "categorie2"
naam3 <- "categorie3"
naam3

opmerking <- "Dit is een simpele dataset"


## ----commandosvectoren, eval = TRUE--------------------------------------
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


## ----commandosdataframe, eval = TRUE-------------------------------------
dataset <- data.frame(naam = namenkolom,
                      waarde = waardekolom)
dataset


## ----commandoslijst, eval = TRUE-----------------------------------------
lijst <- list(datasetnaam = dataset,
              beschrijving = opmerking)
lijst



## ----selectievector, eval = TRUE-----------------------------------------
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


## ----selectiedataframe, eval = TRUE--------------------------------------
dataset$waarde
dataset[[2]]
dataset[2]
dataset["waarde"]    #blijft data.frame
dataset[["waarde"]]  #conversie naar vector
dataset[3, 2]
dataset[3, 2, drop = FALSE]
class(dataset[3, 2, drop = FALSE])
dataset$waarde[2]


## ----selectielijst, eval = TRUE------------------------------------------
lijst["datasetnaam"]
class(lijst["datasetnaam"])
lijst[2]
lijst$datasetnaam
class(lijst$datasetnaam)
lijst[[2]]
lijst$datasetnaam$waarde[2]
lijst[[1]][[2]][[2]]


## ----eval = TRUE---------------------------------------------------------
plot(iris$Sepal.Length, iris$Sepal.Width)
plot(iris$Sepal.Length, iris$Sepal.Width, col = iris$Species)
plot(iris$Sepal.Length, iris$Sepal.Width, col = iris$Species,
     main = "Iris Sepal data", xlab = "Length", ylab = "Width")
barplot(iris$Petal.Length)


## ----missingdata, eval = TRUE--------------------------------------------
heights <- c(1, 2, 4, 4, NA, 6, 8)
mean(heights)
max(heights)
mean(heights, na.rm = TRUE)
max(heights, na.rm = TRUE)
!is.na(heights)
na.omit(heights)
complete.cases(heights)
heights[!is.na(heights)]



## ------------------------------------------------------------------------
1 / 200 * 30
(59 + 73 + 2) / 3
sin(pi / 2)
sqrt(169)

## ------------------------------------------------------------------------
sin(pi / 2)
sqrt(169)
seq(1, 10)
round(5.78)

## ------------------------------------------------------------------------
x <- 3 * 4
y <- sqrt(169)
z <- (x > y)
naam <- "Ivy Jansen"

## ------------------------------------------------------------------------
object_name <- value

## ------------------------------------------------------------------------
x <- "hello world"

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
waarde1 <- 3
waarde2 <- 5
waarde3 <- 7
waarde3
naam1 <- "categorie1"
naam2 <- "categorie2"
naam3 <- "categorie3"
naam3
opmerking <- "Dit is een simpele dataset"

## ------------------------------------------------------------------------
waardekolom <- c(waarde1, waarde2, waarde3)
waardekolom
namenkolom <- c(naam1, naam2, naam3)
namenkolom
meerderedimensies <- matrix(1:9, ncol = 3)
meerderedimensies

## ------------------------------------------------------------------------
dataset <- data.frame(naam = namenkolom, 
                      waarde = waardekolom)
dataset

## ------------------------------------------------------------------------
lijst <- list(datasetnaam = dataset, 
              beschrijving = opmerking)
lijst

## ------------------------------------------------------------------------
waardekolom[2]
namenkolom[c(3, 2)]
meerderedimensies[1, 2]

## ------------------------------------------------------------------------
waardekolom[-1]
namenkolom[-c(2, 4)]
meerderedimensies[-3, -2]

## ------------------------------------------------------------------------
waardekolom[c(1, 2, 3, 2, 1, 2)]

## ------------------------------------------------------------------------
dataset$waarde
dataset[[2]]

## ------------------------------------------------------------------------
dataset[3, 2]
dataset$waarde[2]

## ----datatypes-----------------------------------------------------------
lijst$datasetnaam
lijst[2]
lijst[[2]]

## ------------------------------------------------------------------------
lijst$datasetnaam$waarde[2]
lijst[[1]][[2]][[2]]

## ------------------------------------------------------------------------
lijst[2]
lijst[[2]]
class(dataset[[2]])
class(dataset[2])
class(lijst[2])

## ------------------------------------------------------------------------
heights <- c(1, 2, 4, 4, NA, 6, 8)
mean(heights)
max(heights)
mean(heights, na.rm = TRUE)
max(heights, na.rm = TRUE)

## ------------------------------------------------------------------------
!is.na(heights)
na.omit(heights)
complete.cases(heights)
heights[!is.na(heights)]


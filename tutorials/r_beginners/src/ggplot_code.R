
## ----LAAD DATA-----------------------------------------------------------
load("data/mijnIris.Rdata")

## ----LAAD PACKAGES-------------------------------------------------------
# library(ggplot2)
library(tidyverse)

ggplot(data = irisSepal, 
       mapping = aes(x = Length, y = Width))

## ----PUNTEN--------------------------------------------------------------
ggplot(irisSepal, aes(x = Length, y = Width)) +
  geom_point()

## ----LIJNEN--------------------------------------------------------------
ggplot(irisSepal, aes(x = Length, y = Width)) +
  geom_point() +
  geom_smooth(method = "lm", 
              level = 0.8, 
              formula = y ~ log(x))

## ----COLOR---------------------------------------------------------------
ggplot(irisSepal, aes(x = Length, y = Width, color = Species)) +
  geom_point() +
  geom_smooth(method = "lm")

## ----SHAPE---------------------------------------------------------------
ggplot(irisSepal, aes(x = Length, y = Width, shape = Species)) +
  geom_point()

## ----LINETYPE------------------------------------------------------------
ggplot(irisSepal, aes(x = Length, y = Width)) +
  geom_point() +
  geom_smooth(aes(linetype = Species), method = "lm")

## ----SIZE----------------------------------------------------------------
ggplot(irisSepal, aes(x = Length, y = Width, size = Species)) +
  geom_point() +
  geom_smooth(method = "lm")

## ----BEWAREN IN OBJECT---------------------------------------------------
p <- ggplot(irisAll, aes(x = Length, y = Width)) +
  geom_point() +
  geom_smooth(method = "lm")

## ----FACET_WRAP----------------------------------------------------------
p + facet_wrap(~ Species, ncol = 2)

## ----FACET_GRID----------------------------------------------------------
p + facet_grid(Leaf.Type ~ Species, scales = "free")
p + facet_grid(. ~ Species, scales = "free")
p + facet_grid(Leaf.Type ~ ., scales = "free")

## ----HISTOGRAM-----------------------------------------------------------
ggplot(irisSepal, aes(x = Length)) +
  geom_histogram()

ggplot(irisSepal, aes(x = Length)) +
  geom_density()

ggplot(irisSepal, aes(x = Species)) +
  geom_bar()

## ----BOXPLOT-------------------------------------------------------------
ggplot(irisSepal, aes(x = Species, y = Length)) +
  geom_boxplot()

## ----TITEL---------------------------------------------------------------
p + ggtitle("Verband tussen lengte en breedte")

## ----ASSEN---------------------------------------------------------------
p + xlab("Lengte (in mm)") + ylab("Breedte (in mm)")

## ----BEWAREN-------------------------------------------------------------
ggsave("Figuur_iris_cm.png", p, path = "output/", width = 9, height = 6, units = "cm", dpi = 100)


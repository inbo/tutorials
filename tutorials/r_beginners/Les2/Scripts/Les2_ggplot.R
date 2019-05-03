
## ----LAAD DATA-----------------------------------------------------------
load("data/iris.Sepal")
load("data/iris.Petal")
load("data/iris.All")

## ----LAAD PACKAGES-------------------------------------------------------
# library(ggplot2)
library(tidyverse)

ggplot(data = iris.Sepal, 
       mapping = aes(x = Length, y = Width))

## ----PUNTEN--------------------------------------------------------------
ggplot(iris.Sepal, aes(x = Length, y = Width)) +
  geom_point()

ggplot(iris.Sepal, aes(x = Length, y = Width)) +
  geom_point() +
  geom_smooth()

## ----LIJNEN--------------------------------------------------------------
ggplot(iris.Sepal, aes(x = Length, y = Width)) +
  geom_point() +
  geom_smooth(method = "lm", 
              level = 0.8, 
              formula = y ~ log(x))

## ----COLOR---------------------------------------------------------------
ggplot(iris.Sepal, aes(x = Length, y = Width, color = Species)) +
  geom_point() +
  geom_smooth(method = "lm")

ggplot(iris.Sepal, aes(x = Length, y = Width)) +
  geom_point(aes(color = Species)) +
  geom_smooth(method = "lm", color = "black")

## ----SHAPE---------------------------------------------------------------
ggplot(iris.Sepal, aes(x = Length, y = Width, shape = Species)) +
  geom_point()

## ----LINETYPE------------------------------------------------------------
ggplot(iris.Sepal, aes(x = Length, y = Width, color = Species)) +
  geom_point(aes(shape = Species), size = 3) +
  geom_smooth(aes(linetype = Species), size = 2, method = "lm")

ggplot(iris.Sepal, aes(x = Length, y = Width, color = Species)) +
  geom_point(aes(shape = Species), size = 3) +
  geom_smooth(aes(linetype = Species, fill = Species), 
              size = 2, method = "lm")

## ----SIZE----------------------------------------------------------------
ggplot(iris.Sepal, aes(x = Length, y = Width, size = Species)) +
  geom_point() +
  geom_smooth(method = "lm")


ggplot(mapping = aes(x = Length, y = Width)) +
  geom_point(data = iris.Sepal, 
             color = "blue") +
  geom_point(data = iris.Petal, 
             color = "red")

## ----BEWAREN IN OBJECT---------------------------------------------------
p <- ggplot(iris.All, aes(x = Length, y = Width)) +
  geom_point() +
  geom_smooth(method = "lm")

## ----FACET_WRAP----------------------------------------------------------
p + facet_wrap(~ Species, ncol = 2)

## ----FACET_GRID----------------------------------------------------------
p + facet_grid(Leaf.Type ~ Species, scales = "free")
p + facet_grid(. ~ Species, scales = "free")
p + facet_grid(Leaf.Type ~ ., scales = "free")

## ----HISTOGRAM-----------------------------------------------------------
ggplot(iris.Sepal, aes(x = Length)) +
  geom_histogram(binwidth = 0.5)
ggplot(iris.Sepal, aes(x = Length)) +
  geom_histogram(bins = 10)

ggplot(iris.Sepal, aes(x = Length)) +
  geom_density()

ggplot(iris.Sepal, aes(x = Species)) +
  geom_bar()

## ----BOXPLOT-------------------------------------------------------------
ggplot(iris.Sepal, aes(x = Species, y = Length)) +
  geom_boxplot()

## ----TITEL---------------------------------------------------------------
p + ggtitle("Verband tussen lengte en breedte")

## ----ASSEN---------------------------------------------------------------
p + xlab("Lengte (in mm)") + ylab("Breedte (in mm)")

p + labs(title = "gkrmgjqek",
         x = "jkjlsgh",
         y = "nsnfbvf")


## ----BEWAREN-------------------------------------------------------------
device_ivy <- "jpeg"
path_ivy <- "Figuren/JPEG/"

ggsave("Figuur_iris_cm", p, device = device_ivy, path = path_ivy, width = 9, height = 6, units = "cm", dpi = 100)


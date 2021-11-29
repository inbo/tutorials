## ----IrisdataInlezen--------------------

load("data/mijnIris.Rdata")

## ----InladenTidyverse---------------------------------

# library(ggplot2)
library(tidyverse)


## ----LegeBasisFiguur----------------------------------

# ggplot(data = irisSepal, mapping = aes(x = Length, y = Width))
ggplot(irisSepal, aes(x = Length, y = Width))



## ----Figuurthema--------------------------------------

# gebruik het zwart wit thema
ggplot(irisSepal, aes(x = Length, y = Width)) + theme_bw()
#als je in de console theme_ invult gevolgd door TAB zie je andere thema's



## ----Punten-------------------------------------------

ggplot(irisSepal, aes(x = Length, y = Width)) +
  geom_point()



## ----Lijnen-------------------------------------------

ggplot(irisSepal, aes(x = Length, y = Width)) +
  geom_point() +
  geom_line()



## ----LijnenGegroepeerd--------------------------------

ggplot(irisSepal, aes(x = Length, y = Width, group = Species)) +
  geom_point() +
  geom_line()



## ----LijnenVolgensDatavolgorde------------------------

ggplot(irisSepal, aes(x = Length, y = Width)) +
  geom_point() +
  geom_path()



## ----LoessSmoother------------------------------------

ggplot(irisSepal, aes(x = Length, y = Width)) +
  geom_point() +
  geom_smooth()



## ----LmSmoother---------------------------------------

ggplot(irisSepal, aes(x = Length, y = Width)) +
  geom_point() +
  geom_smooth(method = "lm")



## ----KleurPunt----------

ggplot(irisSepal, aes(x = Length, y = Width, color = Species)) +
  geom_point()



## ----KleurPuntEnLijn----------

ggplot(irisSepal, aes(x = Length, y = Width, color = Species)) +
  geom_point() +
  geom_smooth(method = "lm")



## ----KleurBinnenAes-----

ggplot(irisSepal, aes(x = Length, y = Width)) +
  geom_point(aes(color = Species)) +
  geom_smooth(method = "lm")



## ----KleurBuitenAes-----------------------------------

ggplot(irisSepal, aes(x = Length, y = Width)) +
  geom_point(color = "blue") +
  geom_smooth(color = "red", method = "lm")



## ----Symbool------------

ggplot(irisSepal, aes(x = Length, y = Width, shape = Species)) +
  geom_point()



## ----LijnType-----------

ggplot(irisSepal, aes(x = Length, y = Width)) +
  geom_point() +
  geom_smooth(aes(linetype = Species), method = "lm")



## ----Grootte----

ggplot(irisSepal, aes(x = Length, y = Width, size = Species)) +
  geom_point()



## ----Lijndikte----------

ggplot(irisSepal, aes(x = Length, y = Width, size = Species)) +
  geom_point() +
  geom_smooth(method = "lm")



## ----VasteLijndikte-----------------------------------

ggplot(irisSepal, aes(x = Length, y = Width, group = Species)) +
  geom_point() +
  geom_smooth(size = 3, method = "lm")



## ----Opvulkleur---------------------------------------

ggplot(irisSepal, aes(x = Length, y = Width)) +
  geom_point() +
  geom_smooth(fill = "yellow", method = "lm")


## ----OpvulkleurAes-----

ggplot(irisSepal, aes(x = Length, y = Width)) +
  geom_point() +
  geom_smooth(aes(fill = Species), method = "lm")



## ----Factorvariabelen---------------------------------

testdata <- data.frame(x = 1:20, y = rnorm(20), grp = rep(1:5, 4))
ggplot(testdata, aes(x = x, y = y, color = grp)) + geom_point()

testdata$fgrp <- factor(testdata$grp)
ggplot(testdata, aes(x = x, y = y, color = fgrp)) + geom_point()

testdata$fgrp2 <- factor(testdata$grp, levels = 5:1)
ggplot(testdata, aes(x = x, y = y, color = fgrp2)) + geom_point()

testdata$fgrp3 <- factor(testdata$grp, levels = 5:1,
                         labels = c("uitstekend", "goed",
                                    "voldoende", "zwak", "slecht"))
ggplot(testdata, aes(x = x, y = y, color = fgrp3)) + geom_point()



## ----CombinatieAes----

ggplot(irisSepal, aes(x = Length, y = Width, color = Species)) +
  geom_point(aes(shape = Species, size = Species)) +
  geom_smooth(aes(linetype = Species, fill = Species), size = 2, method = "lm")



## ----VerschillendeData--------------------------------
ggplot() +
  geom_point(data = irisSepal, aes(x = Length, y = Width), color = "blue") +
  geom_point(data = irisPetal, aes(x = Length, y = Width), color = "red")

## ----VerschillendeDataAlternatief-------
ggplot(mapping = aes(x = Length, y = Width)) +
   geom_point(data = irisSepal, color = "blue") +
   geom_point(data = irisPetal, color = "red")


## ----FiguurAlsObject----

p <- ggplot(irisSepal, aes(x = Length, y = Width)) +
  geom_point(aes(color = Species))
p



## ----ObjectUitbreiden-------------------

 p + geom_smooth()


## ----ObjectBewaren---------------------

p1 <- p + geom_smooth(method = "lm")
#p1 wordt niet getoond daarvoor moet je p1 printen via
p1
#ofwel
print(p1)


## ----ObjectOverschrijven----------------

p <- p + geom_smooth(aes(color = Species, fill = Species), method = "lm")



## ----basisplotvoorfacetting---------------------------

#de plot wordt bewaard in object p, maar om het te tonen moet het object tonen
#ofwel een regel met enkel de objectnaam ofwel print(p)
p <- ggplot(irisAll, aes(x = Length, y = Width)) +
  geom_point() +
  geom_smooth(method = "lm")

print(p)



## ----FacetWrap----

p + facet_wrap(~ Species)



## ----FacetWrapRijen---
p + facet_wrap(~ Species, nrow = 2)


## ----FacetWrapScales----

p + facet_wrap(~ Species, nrow = 2, scales = "free")



## ----FacetGrid----

p + facet_grid(Leaf.Type ~ Species, scales = "free")



## ----FacetGridKolom----

p + facet_grid(. ~ Species, scales = "free")



## ----FacetGridRij----

p + facet_grid(Leaf.Type ~ ., scales = "free")



## ----Histogram------------------------

ggplot(irisSepal, aes(x = Length)) +
  geom_histogram()



## ----HistogramBins----------------------

ggplot(irisSepal, aes(x = Length)) +
  geom_histogram(bins = 10)

ggplot(irisSepal, aes(x = Length)) +
  geom_histogram(binwidth = 0.25)

## ----Density------------------------------------------

ggplot(irisSepal, aes(x = Length)) +
  geom_density()



## ----Barplot------------------------------------------

#Toont het aantal irissen per soort in de dataset (is hier 3 keer 50)
ggplot(irisSepal, aes(x = Species)) +
  geom_bar()

ggplot(irisSepal, aes(x = Species, fill = Species)) +
  geom_bar()

#Maak een extra variabele aan die grote en kleine irissen onderscheid
irisSepal$grootte <- factor(iris$Sepal.Length > 5, labels = c('klein', 'groot'))

#plot deze boven elkaar
ggplot(irisSepal, aes(x = Species, fill = grootte)) +
  geom_bar(position = position_stack())

#plot deze naast elkaar
ggplot(irisSepal, aes(x = Species, fill = grootte)) +
  geom_bar(position = position_dodge())

#soms heb je de aantallen al op voorhand berekend
#dan moet je dit aantal als Y as meegeven
#en aan R zeggen dat je de waarden zelf wil gebruiken door stat = "identity"
testdata <- data.frame(cat = c("cat1", "cat2", "cat3"), N = c(10,7,12))
ggplot(testdata, aes(x = cat, y = N)) + geom_bar(stat = "identity")



## ----Boxplot------------------------------------------

ggplot(irisSepal, aes(x = "", y = Length)) +
  geom_boxplot()



## ----BoxplotMeerdereX---------------------------------

ggplot(irisSepal, aes(x = Species, y = Length)) +
    geom_boxplot()



## ----Contourlijnen------------------------------------

#voorbeeld uit ?geom_contour, data faithfuld is meegeleverd met R
head(faithfuld)
v <- ggplot(faithfuld, aes(waiting, eruptions, z = density))
v + geom_contour()

#kleur de plot ook in naast de contour
v + geom_tile(aes(fill = density)) + geom_contour(color = 'black')

#gebruik een ander kleurpalet
v + geom_tile(aes(fill = density)) + geom_contour(color = 'black') +
  scale_fill_viridis_b()


## ----Titel--------------------------------------------

p <- ggplot(irisAll, aes(x = Length, y = Width, color = Species)) +
  geom_point() +
  geom_smooth(method = "lm")
p

p + ggtitle("Verband tussen lengte en breedte")



## ----Asnamen------------------------------------------

p + xlab("Lengte (in mm)") + ylab("Breedte (in mm)")



## ----GecombineerdeLabels------------------------------

p + labs(title = "Verband tussen lengte en breedte",
         x = "Lengte (in mm)",
         y = "Breedte (in mm)",
         color = "Soort")



## ----AsLimieten---------------------------------------

#bv zet de limieten van de x-as en y-as van 0 tot 20
p + xlim(0,20) + ylim(0,20)


## ----FiguurBewaren----------------------

filenaam = "output/Mijnfiguur.png"
ggsave(filenaam, p)

#alternatief
print(p)
ggsave(filenaam)


## ----Bewaaropties-----------------------

ggsave("Figuur_iris.png", p, path = "output/",
       width = 9, height = 6, dpi = 100)
ggsave("Figuur_iris_cm.png", p, path = "output/",
       width = 9, height = 6, units = "cm", dpi = 100)
ggsave("Figuur_iris_flou.png", p, path = "output/",
       width = 15, height = 10, dpi = 10)


## ----ScalesVoorbeeld--------------------

ggplot(iris, aes(x = Sepal.Width, y = Petal.Width, color = Species)) +
  geom_point() +
  scale_color_manual(values = c(setosa = "blue",
                                versicolor = "red",
                                virginica = "orange"))
ggplot(iris, aes(x = Sepal.Width, y = Petal.Width, color = Species)) +
  geom_point() +
  scale_color_manual(values = heat.colors(3))

#als je teveel kleuren opgeeft worden enkel de eerste gebruikt
ggplot(iris, aes(x = Sepal.Width, y = Petal.Width, color = Species)) +
  geom_point() +
  scale_color_manual(values = heat.colors(5))

#hetzelfde maar nu de x-as in log10 schaal en de y-as met onze eigen tick labels
#je ziet dat de x-as niet meer gelijk verdeeld is door de log10 transformatie
ggplot(iris, aes(x = Sepal.Width, y = Petal.Width, color = Species)) +
  geom_point() +
  scale_color_manual(values = heat.colors(5)) +
  scale_x_log10() +
  #ylim(0,10) + dit werkt niet, want we definieren de y-as de regel hieronder
  scale_y_continuous(limits = c(0,10), breaks = seq(0, 10, by = 2))


## ----ThemaOverride------------------------------------

#Bijvoorbeeld om de x-as labels 90 graden te roteren
#hjust = 1 wil zeggen rechts uitlijnen (probeer eens andere waarden)
ggplot(iris, aes(x = Species, y = Sepal.Width)) + geom_boxplot() +
theme(axis.text.x = element_text(angle = 45, hjust = 1))



## ----MeerdereFigurenIneen-----------------------------

#install.packages("patchwork") #eenmalig
library(patchwork)

p1 <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point()
p2 <- ggplot(iris, aes(x = Sepal.Length)) + geom_histogram()
p3 <- ggplot(iris, aes(x = Sepal.Length)) + geom_boxplot()

#zet p1 bovenaan, p2 en p3 onderaan naast elkaar en maak de bovenste figuur dubbel zo hoog
p1 / (p2 + p3)  + plot_layout(heights = c(2, 1))



## ----Piechart-----------------------------------------

#Toon het aantal van elke soort in de iris dataset
ggplot(iris, aes(x = Species, fill = Species)) + geom_bar(width = 1) +
  coord_polar(start = 0) + theme_void()



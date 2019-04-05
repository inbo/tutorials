library(tidyverse)

## ----filter--------------------------------------------------------------
iris1 <- filter(iris, Species == "virginica")
head(iris1)

## ------------------------------------------------------------------------
filter(iris1, Sepal.Length >= 7)

## ------------------------------------------------------------------------
filter(iris, Species == "virginica" & Sepal.Length >= 7)

## ------------------------------------------------------------------------
iris %>%
  filter(Species == "virginica") %>%
  filter(Sepal.Length >= 7)

## ------------------------------------------------------------------------
piloot <- read_csv2("../data/pilootstudie.csv")
summary(piloot)

## ------------------------------------------------------------------------
piloot2 <- piloot %>%
  filter(!is.na(Omtrek) & !is.na(Hoogte))

## ------------------------------------------------------------------------
piloot2 %>%
  filter(Ploeg %in% c(1, 5, 7))






## ----arrange-------------------------------------------------------------
arrange(piloot2, Omtrek)
piloot2 %>%
  arrange(Omtrek)

## ------------------------------------------------------------------------
arrange(piloot2, desc(Hoogte))
piloot2 %>%
  arrange(desc(Hoogte))

## ------------------------------------------------------------------------
arrange(piloot2, Omtrek, Hoogte)

## ------------------------------------------------------------------------
arrange(piloot2, Hoogte, Omtrek)






## ----mutate--------------------------------------------------------------
NieuweIris <- mutate(iris, Sepal.Opp = Sepal.Length * Sepal.Width)
head(NieuweIris)

## ------------------------------------------------------------------------
iris %>%
  mutate(Sepal.Opp = Sepal.Length * Sepal.Width,
         Petal.Opp = Petal.Length * Petal.Width,
         Verhouding = Sepal.Opp / Petal.Opp) %>%
  head()






## ----select--------------------------------------------------------------
select(iris, starts_with("Petal"))
select(iris, -ends_with("Width"))

## ------------------------------------------------------------------------
select(iris, Soort = Species)






## ----summarise-----------------------------------------------------------
summarise(piloot2, Dunste = min(Omtrek))

## ------------------------------------------------------------------------
piloot2 %>%
  summarise(HoogsteBoom = max(Hoogte),
            AantalProefVlakken = n_distinct(Proefvlak),
            MediaanRef = median(Referentie))

## ------------------------------------------------------------------------
piloot2 %>%
  summarise_all(mean)

## ------------------------------------------------------------------------
iris %>%
  summarise_if(is.numeric, mean)

## ------------------------------------------------------------------------
iris %>%
  summarise_at(vars(-Species), 
               list(minimum = min, 
                    maximum = max))






## ----group_by------------------------------------------------------------
iris %>%
  group_by(Species) %>%
  summarise(Aantal = n(),
            Gemiddelde = mean(Sepal.Width))

## ------------------------------------------------------------------------
piloot2 %>%
  group_by(Proefvlak, Boom) %>%
  summarise(MinOmtrek = min(Omtrek),
            GemOmtrek = mean(Omtrek),
            MaxOmtrek = max(Omtrek),
            MinHoogte = min(Hoogte),
            GemHoogte = mean(Hoogte),
            MaxHoogte = max(Hoogte))

## ------------------------------------------------------------------------
piloot2 %>%
  group_by(Proefvlak, Ploeg) %>%
  summarise(Aantal = n())






## ----gather--------------------------------------------------------------
iris_mini <- iris %>%
  slice(c(1, 51, 101))
iris_mini

## ------------------------------------------------------------------------
iris_mini %>%
  gather(key = Kenmerk, value = Waarde, 
         Sepal.Length, Sepal.Width, Petal.Length, Petal.Width)

## ------------------------------------------------------------------------
iris_mini %>%
  gather(key = Kenmerk, value = Waarde, -Species)

## ------------------------------------------------------------------------
piloot_mini <- piloot %>%
  sample_n(4)
piloot_mini

## ------------------------------------------------------------------------
piloot_mini %>%
  gather(key = Kenmerk, value = Waarde, 
         Omtrek, Hoogte)






## ----spread--------------------------------------------------------------
iris_lang <- iris %>%
  slice(c(1, 51, 101)) %>%
  gather(key = Kenmerk, value = Waarde, -Species) %>%
  separate(Kenmerk, into = c("Blad", "Afmeting"))
iris_lang

## ------------------------------------------------------------------------
iris_lang %>%
  spread(key = Afmeting, value = Waarde)

## ------------------------------------------------------------------------
piloot_lang <- piloot %>%
  filter(Meting == 1) %>%
  select(Proefvlak, Boom, Ploeg, Omtrek) %>%
  distinct()     # Nodig omdat er voor Ploeg 4 nog 2 records overblijven (hoogtemeting met 2 toestellen)
piloot_lang

## ------------------------------------------------------------------------
piloot_lang %>%
  spread(key = Ploeg, value = Omtrek)


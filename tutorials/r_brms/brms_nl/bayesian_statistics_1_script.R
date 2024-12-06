## ----packages-------------------------------------------------------------------------------------------------------------------------
# Packages
library(GLMsData)  # datasets voor GLMs
library(tidyverse) # gegevensverwerking en visualisatie
library(brms)      # fitten van Bayesiaanse modellen
library(bayesplot) # MCMC visualisatie en posterior predictive checks
library(tidybayes) # nabewerking en visualisatie van Bayesiaanse modellen

# Conflicten tussen packages
conflicted::conflicts_prefer(dplyr::filter)
conflicted::conflicts_prefer(dplyr::lag)
conflicted::conflicts_prefer(brms::ar)
conflicted::conflicts_prefer(brms::dstudent_t)
conflicted::conflicts_prefer(brms::pstudent_t)
conflicted::conflicts_prefer(brms::qstudent_t)
conflicted::conflicts_prefer(brms::rstudent_t)
conflicted::conflict_prefer("rhat", "brms")










## -------------------------------------------------------------------------------------------------------------------------------------
y <- c(1.3, 5.2, 9.7, 12.8, 14.9)
x <- c(-2.2, -1.3, 0.3, 2.1, 4.9)
df_data <- data.frame(y = y, x = x)


## -------------------------------------------------------------------------------------------------------------------------------------
ggplot(df_data, aes(x = x, y = y)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE)
# grootte van de plot beperken


## -------------------------------------------------------------------------------------------------------------------------------------
lm1 <- lm(formula = y ~ x, data = df_data)
lm1$coefficients


## -------------------------------------------------------------------------------------------------------------------------------------
confint(lm1, level = 0.9)


## -------------------------------------------------------------------------------------------------------------------------------------
source(file = here::here("code", "brms_modeling", "mcmc_functions.R"))


## -------------------------------------------------------------------------------------------------------------------------------------
df <- expand.grid(beta_0 = seq(-1, 15, 0.5), beta_1 = seq(-3, 8, 0.5))
df$post <- NA
for (i in 1:nrow(df)) {
  df[i, "post"] <- ll.fun(beta_0 = df[i, "beta_0"],
                         b = df[i, "beta_1"]) +
                  prior.fun(beta_0 = df[i, "beta_0"],
                            beta_1 = df[i, "beta_1"])
}


## -------------------------------------------------------------------------------------------------------------------------------------
ggplot(df, aes(x = beta_0, y = beta_1, z = post)) +
  geom_raster(aes(fill = post)) + geom_contour(colour = "black") +
  scale_fill_gradientn(colours = rainbow(n = 4))


## -------------------------------------------------------------------------------------------------------------------------------------
mcmc_small <- MCMC_metro(x = x,         # vector x waarden
                         y = y,         # vector y waarden
                         N = 150,       # lengte van de MCMC
                         sigma = 1,     # stapgrootte (sd)
                         init_b0 = 12,  # initiële waarde beta_0 (intercept)
                         init_b1 = 6)   # initiële waarde beta_1 (helling)


## -------------------------------------------------------------------------------------------------------------------------------------
ggplot(df, aes(x = beta_0, y = beta_1, z = post)) +
  geom_raster(aes(fill = post)) +
  geom_contour(binwidth = 20, colour = "black") +
  scale_fill_gradientn(colours = rainbow(n = 4)) +
  geom_path(data = mcmc_small,
            aes(x = beta_0, y = beta_1, z = NA), colour = "black") +
  geom_point(data = mcmc_small,
             aes(x = beta_0, y = beta_1, z = NA), colour = "red") +
  coord_cartesian(xlim = c(-1, 14.5), ylim = c(-3, 7)) +
  theme(legend.position="none")


## -------------------------------------------------------------------------------------------------------------------------------------
mcmc_l <- MCMC_metro(x = x,
                     y = y,
                     N = 5000,
                     sigma = 1,
                     init_b0 = 12,
                     init_b1 = 6)


## -------------------------------------------------------------------------------------------------------------------------------------
p1 <- ggplot(df, aes(x = beta_0, y = beta_1, z = post)) +
  geom_raster(aes(fill = post)) +
  geom_contour(binwidth = 20, colour = "black") +
  scale_fill_gradientn(colours = rainbow(n = 4)) +
  geom_path(data = mcmc_l,
            aes(x = beta_0, y = beta_1, z = NA), colour = "black") +
  geom_point(data = mcmc_l,
             aes(x = beta_0, y = beta_1, z = NA), colour = "red") +
  coord_cartesian(xlim = c(-1, 14.5), ylim = c(-3, 7)) +
  theme(legend.position="none")

p2 <- ggplot(data = mcmc_l, aes(x = beta_0)) + geom_histogram(bins = 50) +
  scale_x_continuous(limits = c(-1, 14.5), breaks = seq(-1, 14.5, 1)) +
  theme(axis.title.x = element_blank())

p3 <- ggplot(data = mcmc_l, aes(x = beta_1)) + geom_histogram(bins = 50) +
  coord_flip() +
  scale_x_continuous(limits = c(-3, 7), breaks = seq(-3, 7, 1)) +
  theme(axis.title.y = element_blank())

empty <- ggplot()

gridExtra::grid.arrange(p2, ggplot(), p1, p3, ncol = 2, nrow = 2,
  widths = c(4, 1), heights = c(1, 4))


## -------------------------------------------------------------------------------------------------------------------------------------
ann_text <- tibble(param = c("beta_0", "beta_1"),
                   x = 210,
                   y = c(max(mcmc_l$beta_0), max(mcmc_l$beta_1)),
                   lab = "burn-in")
mcmc_l %>%
  dplyr::select(iter, beta_0, beta_1) %>%
  pivot_longer(cols = c("beta_0", "beta_1"), names_to = "param") %>%
  ggplot(aes(x = iter, y = value)) + geom_line() +
  facet_wrap(~param, nrow = 2, scales = "free_y") +
  annotate("rect",  xmin = 0, xmax = 200, ymin = -Inf, ymax = +Inf,
           alpha = 0.3, fill = "gold") +
  geom_label(data = ann_text, aes(label = lab, x = x, y = y),
             hjust = "left", vjust = "top",
             fill = "gold")


## -------------------------------------------------------------------------------------------------------------------------------------
quantile(mcmc_l$beta_0[200:5000], probs = c(0.05, 0.5, 0.95))


## -------------------------------------------------------------------------------------------------------------------------------------
quantile(mcmc_l$beta_1[200:5000], probs = c(0.05, 0.5, 0.95))








## ----data-expl-laad-data--------------------------------------------------------------------------------------------------------------
# Laad dataset in
data(ants)

# Maak kopie met kolomnamen in kleine letters
ants_df <- ants %>%
  rename(sp_rich = Srich) %>%
  rename_with(tolower)

# Hoe zien de data eruit?
glimpse(ants_df)


## ----data-expl-summary----------------------------------------------------------------------------------------------------------------
# Samenvattende statistieken dataset
summary(ants_df)


## ----data-expl-vis1-------------------------------------------------------------------------------------------------------------------
# Frequentie aantal soorten per habitat
ants_df %>%
  ggplot(aes(x = sp_rich)) +
    geom_bar() +
    scale_x_continuous(limits = c(0, NA)) +
    facet_wrap(~habitat)


## ----data-expl-vis2-------------------------------------------------------------------------------------------------------------------
# Boxplots aantal soorten per habitat
ants_df %>%
  ggplot(aes(y = sp_rich, x = habitat)) +
    geom_boxplot() +
    geom_line(aes(colour = site, group = site), alpha = 0.5) +
    geom_point(aes(colour = site, group = site)) +
    scale_y_continuous(limits = c(0, NA))


## ----data-expl-vis3-------------------------------------------------------------------------------------------------------------------
# Scatter plot aantal soorten en latitude per habitat

ants_df %>%
  ggplot(aes(y = sp_rich, x = latitude)) +
    geom_point() +
    geom_smooth(method = "loess", formula = "y ~ x", colour = "firebrick",
                level = 0.9) +
    facet_wrap(~habitat)


## ----data-expl-vis4-------------------------------------------------------------------------------------------------------------------
# Scatter plot aantal soorten en hoogte per habitat

ants_df %>%
  ggplot(aes(y = sp_rich, x = elevation)) +
    geom_point() +
    geom_smooth(method = "loess", formula = "y ~ x", colour = "firebrick",
                level = 0.9) +
    facet_wrap(~habitat)


## ----simpel-model-mcmc-par------------------------------------------------------------------------------------------------------------
# Instellen MCMC parameters
nchains <- 3           # aantal chains
niter <- 2000          # aantal iteraties (incl. burn-in, zie volgende)
burnin <- niter / 4    # aantal initiële samples om te verwijderen (= burn-in)
nparallel <- nchains   # aantal cores voor parallel computing
thinning <- 1          # verdunningsfactor (hier 1 = geen verdunning)


## ----simpel-model-fit-poisson---------------------------------------------------------------------------------------------------------
# Fit Normaal model
fit_normal1 <- brm(
  formula = sp_rich ~ habitat, # beschrijving van het model
  family = gaussian(),         # we gebruiken de Normaal verdeling
  data = ants_df,              # ingeven data
  chains = nchains,            # MCMC parameters
  warmup = burnin,
  iter = niter,
  cores = nparallel,
  thin = thinning,
  seed = 123)                  # seed voor reproduceerbare uitkomst


## ----simpel-model-colorscheme---------------------------------------------------------------------------------------------------------
# Zet kleurenpallet voor duidelijke visualisatie in bayesplot
color_scheme_set("mix-blue-red")


## -------------------------------------------------------------------------------------------------------------------------------------
# Welke parameters gaan we bekijken?
parameters <- c("b_Intercept", "b_habitatForest", "sigma")


## ----simpel-model-trace1--------------------------------------------------------------------------------------------------------------
# Visualisatie door extractie samples met as_draws_df()
as_draws_df(fit_normal1, variable = parameters) %>%
  # zet om naar lang formaat voor visualisatie
  pivot_longer(cols = all_of(parameters), names_to = "parameter",
               values_to = "value") %>%
  # visualiseer met ggplot()
  ggplot(aes(y = value, x = .iteration, colour = factor(.chain))) +
    geom_line() +
    facet_wrap(~parameter, nrow = 3, scales = "free")


## ----simpel-model-trace2--------------------------------------------------------------------------------------------------------------
# Visualisatie via Bayesplot package
mcmc_trace(fit_normal1, pars = parameters)


## ----simpel-model-posterior-density---------------------------------------------------------------------------------------------------
# code om cumulatieve kwantielen te berekenen
# bron: https://rdrr.io/cran/cumstats/src/R/cumquant.R
cumquant <- function(x, p) {
  out <- sapply(seq_along(x),
                function(k, z) quantile(z[1:k], probs = p[1], names = FALSE),
                z = x)
  return(out)
}


## ----simpel-model-cum-stat------------------------------------------------------------------------------------------------------------
# Extractie samples en bereken cumulatieve statistieken
as_draws_df(fit_normal1, variable = parameters) %>%
  mutate(across(all_of(parameters), ~cummean(.x),
                .names = "{.col}_gemiddelde"),
         across(all_of(parameters), ~cumquant(.x, 0.05),
                .names = "{.col}_q05"),
         across(all_of(parameters), ~cumquant(.x, 0.95),
                .names = "{.col}_q95")) %>%
  select(-all_of(parameters)) %>%
  # zet om naar lang formaat voor visualisatie
  pivot_longer(cols = starts_with(parameters), names_to = "name",
               values_to = "value") %>%
  # splits naam kolom op bij laatste underscore
  extract(name, into = c("parameter", "statistiek"), "(.*)_([^_]+)$") %>%
  ggplot(aes(y = value, x = .iteration, colour = factor(.chain))) +
    geom_line(aes(linetype = statistiek), linewidth = 0.8) +
    facet_wrap(~parameter, nrow = 3, scales = "free")


## ----simpel-model-posterior-density2--------------------------------------------------------------------------------------------------
# Visualisatie density plot van de posterior voor ieder van de chains apart in
# overlay. via Bayesplot package
mcmc_dens_overlay(fit_normal1, pars = parameters)


## -------------------------------------------------------------------------------------------------------------------------------------
# trace plots en posterior density voor iedere parameter
plot(fit_normal1)


## ----simpel-model-autocorrelation-----------------------------------------------------------------------------------------------------
# Visualisatie autocorrelation plots via Bayesplot package
mcmc_acf(fit_normal1, pars = parameters)


## ----simpel-model-get-Rhat------------------------------------------------------------------------------------------------------------
# Krijg R-hats
rhats_fit_normal1 <- rhat(fit_normal1)[parameters]
print(rhats_fit_normal1)


## ----simpel-model-plot-Rhat-----------------------------------------------------------------------------------------------------------
# Plot R-hats via Bayesplot package
mcmc_rhat(rhats_fit_normal1) + yaxis_text(hjust = 1)


## ----simpel-model-get-effective-sample-size-------------------------------------------------------------------------------------------
# Krijg verhoudingen effective sample size
ratios_fit_normal1 <- neff_ratio(fit_normal1)[parameters]
print(ratios_fit_normal1)


## ----simpel-model-plot- effective-sample-size-----------------------------------------------------------------------------------------
# Plot verhoudingen via Bayesplot package
mcmc_neff(ratios_fit_normal1) + yaxis_text(hjust = 1)


## ----simpel-model-fit1----------------------------------------------------------------------------------------------------------------
# Visualiseer model fit via Bayesplot package
pp_check(fit_normal1, type = "dens_overlay_grouped", ndraws = 100,
         group = "habitat")


## ----poisson-model-fit----------------------------------------------------------------------------------------------------------------
# Fit Poisson model
fit_poisson1 <- brm(
  formula = sp_rich ~ habitat, # beschrijving van het model
  family = poisson(),          # we gebruiken de Poisson verdeling
  data = ants_df,              # ingeven data
  chains = nchains,            # MCMC parameters
  warmup = burnin,
  iter = niter,
  cores = nparallel,
  thin = thinning,
  seed = 123)                  # seed voor reproduceerbare uitkomst


## ----poisson-model-convergentie-------------------------------------------------------------------------------------------------------
# Visualiseer MCMC convergentie van het Poisson model
plot(fit_poisson1)


## ----poisson-model-Rhat---------------------------------------------------------------------------------------------------------------
# Extraheer en visualiseer R-hat waarden
rhats_fit_poisson1 <- rhat(fit_poisson1)[c("b_Intercept", "b_habitatForest")]
mcmc_rhat(rhats_fit_poisson1) + yaxis_text(hjust = 1)


## ----poisson-model-fit-vis------------------------------------------------------------------------------------------------------------
# Visualiseer model fit via Bayesplot package
pp_check(fit_poisson1, type = "dens_overlay_grouped", ndraws = 100,
         group = "habitat")


## ----rand-intercept-model-fit---------------------------------------------------------------------------------------------------------
# Fit Poisson model met random intercepten per site
fit_poisson2 <- brm(
  formula = sp_rich ~ habitat + (1|site),
  family = poisson(),
  data = ants_df,
  chains = nchains,
  warmup = burnin,
  iter = niter,
  cores = nparallel,
  thin = thinning,
  seed = 123)


## ----rand-intercept-model-convergentie------------------------------------------------------------------------------------------------
# Visualiseer MCMC convergentie
plot(fit_poisson2)


## ----rand-intercept-model-rhat--------------------------------------------------------------------------------------------------------
# Extraheer en visualiseer R-hat waarden
parameters2 <- c("b_Intercept", "b_habitatForest", "sd_site__Intercept")
rhats_fit_poisson2 <- rhat(fit_poisson2)[parameters2]
mcmc_rhat(rhats_fit_poisson2) + yaxis_text(hjust = 1)


## ----rand-intercept-model-fit-vis-----------------------------------------------------------------------------------------------------
# Visualiseer model fit van het Poisson model met random intercept via
# Bayesplot package
pp_check(fit_poisson2, type = "dens_overlay_grouped", ndraws = 100,
         group = "habitat")


## ----vergelijken-loocv----------------------------------------------------------------------------------------------------------------
# Voeg leave-one-out model fit criterium toe aan model objecten
fit_normal1 <- add_criterion(fit_normal1,
                             criterion = c("loo"))
fit_poisson1 <- add_criterion(fit_poisson1,
                              criterion = c("loo"))
fit_poisson2 <- add_criterion(fit_poisson2,
                              criterion = c("loo"))


## ----vergelijken-loocv-compare--------------------------------------------------------------------------------------------------------
# Maak vergelijking leave-one-out cross-validation en print
comp_loo <- loo_compare(fit_normal1, fit_poisson1, fit_poisson2,
                        criterion = "loo")
print(comp_loo, simplify = FALSE, digits = 3)


## ----vergelijken-loocv-betrouwbaarheid------------------------------------------------------------------------------------------------
# Bereken betrouwbaarheidsinterval om modellen te vergelijken met loocv
comp_loo %>%
  as.data.frame() %>%
  select(elpd_diff, se_diff) %>%
  mutate(ll_diff = elpd_diff  + qnorm(0.05) * se_diff,
         ul_diff = elpd_diff  + qnorm(0.95) * se_diff)


## ----vergelijken-K-fold---------------------------------------------------------------------------------------------------------------
# Voeg K-fold model fit criterium toe aan model objecten
fit_normal1 <- add_criterion(fit_normal1,
                             criterion = c("kfold"),
                             K = 10,
                             folds = "stratified",
                             group = "habitat")
fit_poisson1 <- add_criterion(fit_poisson1,
                              criterion = c("kfold"),
                              K = 10,
                              folds = "stratified",
                              group = "habitat")
fit_poisson2 <- add_criterion(fit_poisson2,
                              criterion = c("kfold"),
                              K = 10,
                              folds = "stratified",
                              group = "habitat")


## ----vergelijken-K-fold-compare-------------------------------------------------------------------------------------------------------
# Maak vergelijking k-fold cross-validation en print
comp_kfold <- loo_compare(fit_normal1, fit_poisson1, fit_poisson2,
                          criterion = "kfold")
print(comp_kfold, simplify = FALSE, digits = 3)


## ----vergelijken-K-fold-betrouwbaarheid-----------------------------------------------------------------------------------------------
# Bereken betrouwbaarheidsinterval om modellen te vergelijken met K-fold CV
comp_kfold %>%
  as.data.frame() %>%
  select(elpd_diff, se_diff) %>%
  mutate(ll_diff = elpd_diff  + qnorm(0.05) * se_diff,
         ul_diff = elpd_diff  + qnorm(0.95) * se_diff)


## ----vergelijken-WAIC-----------------------------------------------------------------------------------------------------------------
# Voeg WAIC model fit criterium toe aan model objecten
fit_normal1 <- add_criterion(fit_normal1,
                             criterion = c("waic"))
fit_poisson1 <- add_criterion(fit_poisson1,
                              criterion = c("waic"))
fit_poisson2 <- add_criterion(fit_poisson2,
                              criterion = c("waic"))


## ----vergelijken-WAIC-compare---------------------------------------------------------------------------------------------------------
# Maak vergelijking waic en print
comp_waic <- loo_compare(fit_normal1, fit_poisson1, fit_poisson2,
                         criterion = "waic")
print(comp_waic, simplify = FALSE, digits = 3)


## ----vergelijken-WAIC-betrouwbaarheid-------------------------------------------------------------------------------------------------
# Bereken betrouwbaarheidsinterval om modellen te vergelijken met WAIC
comp_waic %>%
  as.data.frame() %>%
  select(waic, elpd_diff, se_diff) %>%
  mutate(ll_diff = elpd_diff  + qnorm(0.05) * se_diff,
         ul_diff = elpd_diff  + qnorm(0.95) * se_diff)


## ----resultaten-fit-poisson-----------------------------------------------------------------------------------------------------------
# Bekijk het fit object van het Poisson model met random effecten
fit_poisson2


## ----resultaten-fit-poisson-2---------------------------------------------------------------------------------------------------------
fit_poisson2 %>%
  # verzamel 1000 posterior samples voor 2 parameters in lang formaat
  gather_draws(b_Intercept, b_habitatForest, ndraws = 1000, seed = 123) %>%
  # bereken samenvattende statistieken voor elke variabele
  group_by(.variable) %>%
  summarise(min = min(.value),
            q_05 = quantile(.value, probs = 0.05),
            q_20 = quantile(.value, probs = 0.20),
            gemiddelde = mean(.value),
            mediaan = median(.value),
            q_80 = quantile(.value, probs = 0.80),
            q_95 = quantile(.value, probs = 0.95),
            max = max(.value))


## ----resultaten-fit-poisson-3---------------------------------------------------------------------------------------------------------
fit_poisson2 %>%
  # verzamel 1000 posterior samples voor 2 parameters in wijd formaat
  spread_draws(b_Intercept, b_habitatForest, ndraws = 1000, seed = 123) %>%
  # bereken gemiddelde aantallen en zet om naar lang formaat voor visualisatie
  mutate(bog = exp(b_Intercept),
         forest = exp(b_Intercept + b_habitatForest)) %>%
  pivot_longer(cols = c("bog", "forest"), names_to = "habitat",
               values_to = "sp_rich") %>%
  # visualiseer via ggplot()
  ggplot(aes(y = sp_rich, x = habitat)) +
    stat_eye(point_interval = "median_qi", .width = c(0.6, 0.9)) +
    scale_y_continuous(limits = c(0, NA))


## ----resultaten-hypothese-test--------------------------------------------------------------------------------------------------------
# Test hypothese verschil tussen habitats
hyp <- hypothesis(fit_poisson2, "habitatForest = 0", alpha = 0.1)
hyp


## ----resultaten-hypothese-test-vis----------------------------------------------------------------------------------------------------
# Plot posterior distribution hypothese
plot(hyp)


## ----resultaten-visualiseer-random-effects--------------------------------------------------------------------------------------------
# Neem het gemiddelde van sd van random effects
# om verderop aan figuur toe te voegen
sd_mean <- fit_poisson2 %>%
  spread_draws(sd_site__Intercept, ndraws = 1000, seed = 123) %>%
  summarise(mean_sd = mean(sd_site__Intercept)) %>%
  pull()

# Neem random effects en plot
fit_poisson2 %>%
  spread_draws(r_site[site,], ndraws = 1000, seed = 123) %>%
  ungroup() %>%
  mutate(site = reorder(site, r_site)) %>%
  ggplot(aes(x = r_site, y = site)) +
    geom_vline(xintercept = 0, color = "darkgrey", linewidth = 1) +
    geom_vline(xintercept = c(sd_mean * qnorm(0.05), sd_mean * qnorm(0.95)),
               color = "darkgrey", linetype = 2) +
    stat_halfeye(point_interval = "median_qi", .width = 0.9, size = 2/3,
                 fill = "cornflowerblue")


## ----vergelijking-frequentist---------------------------------------------------------------------------------------------------------
# Extraheer samenvattende statistieken Bayesiaans model
sum_fit_normal1 <- summary(fit_normal1, prob = 0.9)
verschil_moeras1 <- sum_fit_normal1$fixed$Estimate[2]
ll_verschil_moeras1 <- sum_fit_normal1$fixed$`l-90% CI`[2]
ul_verschil_moeras1 <- sum_fit_normal1$fixed$`u-90% CI`[2]

sum_fit_normal1


## ----vergelijking-frequentist-t-test--------------------------------------------------------------------------------------------------
# Voor t-test uit en extraheer samenvattende statistieken
t_test_normal1 <- t.test(sp_rich ~ habitat, data = ants_df, conf.level = 0.9)
verschil_moeras2 <- t_test_normal1$estimate[2] - t_test_normal1$estimate[1]
ll_verschil_moeras2 <- -t_test_normal1$conf.int[2]
ul_verschil_moeras2 <- -t_test_normal1$conf.int[1]

t_test_normal1


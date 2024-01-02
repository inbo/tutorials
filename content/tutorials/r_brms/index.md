---
title: "Tutorial Bayesian statistics with brms"
description: "This tutorial starts with a theoretical overview of bayesian statistics and the MCMC algorithm. Next, we fit, check, and analyse Bayesian models with the brms package."
author: [raisacarmen, wardlangeraert, toonvandaele]
date: 2024-01-02
categories: ["r", "statistics"]
tags: ["generalized linear regression", "brms", "r", "mixed models"]
---

``` r
# Packages
library(GLMsData)  # datasets foror GLMs
library(tidyverse) # data wrangling and visualising
library(brms)      # fitting Bayesian models
library(bayesplot) # visualise MCMC and posterior predictive checks
library(tidybayes) # wrangling and visualising Bayesian models

# Conflicten tussen packages
conflicted::conflicts_prefer(dplyr::filter)
conflicted::conflicts_prefer(dplyr::lag)
conflicted::conflicts_prefer(brms::ar)
conflicted::conflicts_prefer(brms::dstudent_t)
conflicted::conflicts_prefer(brms::pstudent_t)
conflicted::conflicts_prefer(brms::qstudent_t)
conflicted::conflicts_prefer(brms::rstudent_t)
conflicted::conflict_prefer("rhat", "brms")
```

# Theoretical background

## What is Bayesian statistics?

In this section we briefly review some basic principles of Bayesian
statistics. We would also like to refer to the presentation of October
24, 2023 ([infomoment
24/10/2023](https://drive.google.com/drive/folders/1MIWu8-LnhTUnKKAchjI7FEmaJ8TN_1mb)).

``` r
data.frame(
  what = c(
   "interpretation of probability",
   "used knowledge",
   "hypothesis tests",
   "terminology",
   "parameters and data"
  ),
  Frequentist = c(
    "long term relative frequency",
    "data only",
    "chance of data that is at least as extreme as the collected data",
    "p-value, confidence interval, type 1 and type 2 error ...",
    "parameters are fixed and unknown, data is random"
  ),
  Bayesian = c(
    "relative probability",
    "data and prior knowledge",
    "probability that the hypothesis is correct",
    "prior, likelihood, posterior, credible interval ...",
    "parameters are random and have a distribution, data is fixed"
  )
) %>%
  kable(booktabs = TRUE, 
        col.names = c("", "Frequentist", "Bayesian"))
```

|                               | Frequentist                                                      | Bayesian                                                     |
|:------------------------------|:-----------------------------------------------------------------|:-------------------------------------------------------------|
| interpretation of probability | long term relative frequency                                     | relative probability                                         |
| used knowledge                | data only                                                        | data and prior knowledge                                     |
| hypothesis tests              | chance of data that is at least as extreme as the collected data | probability that the hypothesis is correct                   |
| terminology                   | p-value, confidence interval, type 1 and type 2 error …          | prior, likelihood, posterior, credible interval …            |
| parameters and data           | parameters are fixed and unknown, data is random                 | parameters are random and have a distribution, data is fixed |

Why and when should you use Bayesian models?

- All frequentist models can also be approximated by a Bayesian model,
  but not all Bayesian models can be modelled in a frequentist way.
- Fit more complex models with temporal and spatial components or with
  differential equations (Ordinary Differential Equations, ODE).
- Interpretation is sometimes easier / more intuitive.
- You obtain a complete probability distribution for each parameter,
  making it easy for subsequent calculations or simulations.
- You can combine different sources of data in an integrated model.
- Include additional data / conclusions / expectations in your model
  using a prior.

### Statistical inference

Statistical inference is concerned with trying to learn something about
a (population) parameter based on data. Suppose we are interested in the
number of ant species found in a research site of a pre-specified size.
Numbers are often specified by a Poisson distribution since this
distribution only has a probability mass at positive integers.

$$ X \sim Poisson(\lambda)$$ with $X$ the number of ant species and
$\lambda$ the parameter we want to estimate. In a Poisson distribution,
there is only one parameter; $\lambda$ is equal to the mean and variance
of the distribution. We do not know the true value of $\lambda$ *a
priori*. Our model defines a collection of probability models; one for
each possible value of $\lambda$. We call this collection of models the
*likelihood*.

In the figure below we show three examples of a potential likelihood.
There are three probability density functions of Poisson distributions,
each with a different parameter $\lambda$.

``` r
likelihood <- data.frame(x = rep(seq(0, 25), 3),
                         lambda = c(rep(5, 26), rep(10, 26), rep(15, 26))) %>%
  mutate(prob = stats::dpois(x, lambda = lambda),
         lambda = as.factor(lambda))
likelihood %>%
  ggplot(aes(x = x, y = prob, color = lambda)) +
  geom_point() + 
  geom_errorbar(aes(ymin = 0, ymax = prob), width = 0) + 
  xlab("number of ant species at a site") + 
  ylab("probability mass")
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

Suppose we find 8 different species of ants on one particular site. Our
likelihood tells us that there are an infinite number of values for
$\lambda$, which gives us the result 8. The figure below shows that the
probability of $X = 8$ is different in each of the three shown Poisson
distributions.

``` r
likelihood %>%
  ggplot(aes(x = x, y = prob, color = lambda)) +
  geom_point() + 
  geom_errorbar(aes(ymin = 0, ymax = prob), width = 0) +
  geom_bar(data = likelihood %>% filter(x == 8),
           color = "grey", stat = "identity", alpha = 0.7) + 
  xlab("Number of ant species at a site") + 
  ylab("probability mass") +
  facet_grid(cols = vars(lambda))
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

Each of these models, with a different value of $\lambda$, can give us
the value of $X=8$ with a different probability.

The likelihood function gives us, for each potential value of the
parameter, the probability of the data. The figure below shows this for
our data with only one observation $x=8$.

``` r
ll <- data.frame(lambda = seq(0, 20, 0.2)) %>%
  mutate(likelihood = dpois(8, lambda))
ll %>%
  ggplot(aes(x = lambda, y = likelihood)) +
  geom_line() +
  geom_point(data = ll %>% dplyr::filter(lambda %in% c(5, 10, 15)),
             aes(color = as.factor(lambda),x = lambda, y = likelihood),
             size = 2) +
  scale_color_discrete(name = "lambda") +
  geom_vline(aes(xintercept = 8), color = "red") +
  geom_label(aes(label = "ML", x = 8, y = 0.16), fill = "red",
            alpha = 0.5)
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

With statistical inference we actually want to invert the likelihood
$p(X|\lambda) \rightarrow p(\lambda|X)$. In this way, we hope to find
out which model of all potential models is the most meaningful or
probable. Both frequentist and Bayesian methods essentially invert
$p(X|\lambda) \rightarrow p(\lambda|X)$, but the method differs.

The maximum likelihood method in frequentist statistics will choose the
value of lambda where the likelihood function is at its maximum as the
parameter estimate ($\lambda = 8$). A 90% confidence interval can then
be calculated around this parameter estimate
$(4.8 \leq \lambda \leq 14.4)$. The decision space for the parameter
$\lambda$ is thus divided into two parts: (1) values that are likely and
(2) values that are not likely.

Bayesian inference, on the other hand, uses Bayes’ rule:

$$
p(\lambda|X) = \frac{p(X|\lambda) * p(\lambda)}{p(X)}
$$

This ensures that we will have a probability for **every** potential
value of $\lambda$.

The parameters in Bayesian models therefore have a distribution. This
contrasts with frequentist inference where the solution space for
$\lambda$ is split into two parts: values that are likely or not likely.

In our example, the following meaning is given to each of the elements
in Bayes’ rule:

- $\lambda$ the average number of ant species
- $X$ the data
- $p(X|\lambda)$ the *likelihood*
- $p(\lambda)$ the *prior*
- The denominator $p(X)$ makes exact Bayesian inference difficult and
  has several interpretations:
  - Before we collect data, this is the *prior predictive distribution*
  - If we have data, this is a number that normalizes the posterior.
    This is called *evidence* or *marginal likelihood*.
- $p(\lambda|X)$ is the *posterior*. It is a probability distribution.
  This posterior is the starting point for all further analysis in
  Bayesian inference.

On this
[website](https://iupbsapps.shinyapps.io/KruschkeFreqAndBayesApp/) you
will find a nice illustration of how prior and likelihood are combined
to obtain a posterior
([tutorial](https://jkkweb.sitehost.iu.edu/KruschkeFreqAndBayesAppTutorial.html)).

**An simple example of Bayes’ rule**

Suppose you go to the doctor, and he says you test positive for a rare
disease. However, he also tells you that the test cannot always be
trusted. In Belgium, only 0.1% of all people actually have the disease.
If you have the disease, the test is positive in $\frac{99}{100}$ tests.
But even if you do not have the disease, the test will be positive in
$\frac{5}{100}$ tests. You would like to know what the probability is
that you actually have the disease, given that positive test, and you
use Bayes’ theorem and the “Law of total probability”:

$$
p(\text{you have the disease}|T^+) = \frac{p(T^+|\text{you have the disease})*p(\text{you have the disease})}{p(T^+)} \\
= \frac{p(T^+|\text{you have the disease})*p(\text{you have the disease})}{p(T^+|\text{you have the disease})*p(\text{you have the disease}) + p(T^+|\text{you do not have the disease})* p(\text{you do not have the disease)}}\\
=\frac{0.99*0.001}{0.99*0.001 + 0.05*0.9999}\\
=1.94\%
$$ Bayes’ rule allows us to update our prior knowledge about the disease
(only 0.1% have the disease in the general population) with the new
information (the data: a positive test) to obtain the posterior.
Although, at first glance, the test seems quite reliable, Bayes’ rule
shows that the probability that you have the disease, given that you
tested positive, is still quite low.

## Parameter estimation in Bayesian statistics

Remember Bayes’ rule: $$
p(\lambda|X) = \frac{p(X|\lambda) * p(\lambda)}{p(X)}
$$

We already mentioned that the denominator of this equation is very
difficult to calculate. There are three possible solutions:

- *Conjugate priors*: For some distributions and combinations of priors
  and likelihoods, it is possible to obtain an analytical solution (see
  [this list](https://en.wikipedia.org/wiki/Conjugate_prior)). However,
  this limits our options:
  - only possible for some univariate and bivariate problems
  - the conjugate priors limit the freedom to define prior knowledge
    (e.g. zero-inflation…)
- *MCMC*: we get information about the distribution by sampling it
  instead of calculating it exactly.
- *INLA*: Integrated Nested Laplace Approximation is an alternative
  to MCMC. There is no sampling, which makes the algorithm work faster.
  This is especially interesting for large or complex models.

We will focus on MCMC in this tutorial.

### What is MCMC?

MCMC stands for ‘Markov chain Monte Carlo’. A Markov chain is an
algorithm to simulate a random walk and Monte Carlo is an algorithm to
sample from the parameter space.

The posterior distribution of a parameter can be compared to a mountain
(see figure below). The top of the mountain is where the parameter value
is most likely after combining the likelihood of your data with your
prior belief. However, the location and shape of the mountain peak is
unknown. The goal of an MCMC algorithm is to efficiently explore the
mountain peak and its surroundings.

An MCMC algorithm takes random samples from the posterior and generates
a series of steps that explores the entire range of the posterior
distribution. The rules ensure that the sampler stays near the top of
the mountain the entire time. It is a random walk in the parameter space
where the posterior distribution is highest (the top of the mountain).
The size and direction of each step varies.

When taking a step uphill, the MCMC always continues. If the step is
downhill, the MCMC does not always continue. The probability of going
downhill depends on how deep the step down is. Small steps downwards are
often taken. If the step downwards is very steep, the MCMC usually will
not go into that direction and sample a new step.

The absolute height of the mountain (posterior likelihood) in itself
does not matter. Only the relative differences or shape of the mountain
matters. This means that we do not need to calculate the denominator of
Bayes’ rule, which is the reason why the algorithm is frequently used in
Bayesian statistics.

![Metropolis rules](../media/MCMC4b.png)

A simple MCMC algorithm is the Metropolis algorithm. It is described by
these formal rules:

1.  Choose a starting value for the parameter
2.  Calculate the posterior (= likelihood + prior) for that parameter
3.  Choose a new parameter value at random, but ‘close’ to the previous
    one
4.  Calculate the new posterior for that new parameter value
5.  Is the new posterior $>$ current posterior $\Rightarrow$ new value
    kept
6.  Is the new posterior $<$ current posterior $\Rightarrow$
    1)  Calculate the ratio (new posterior / previous posterior).
    2)  Accept the new value with a probability equal to the ratio (so
        the lower the new likelihood, the smaller the chance of
        acceptance).
7.  Go through 3 to 6 (several thousand times).

Since the probability of accepting or not accepting parameter values
with a lower posterior varies with the difference in posterior value, an
MCMC converges in the limit (after many iterations) to the posterior
distribution.

For simple cases, scripting MCMC algorithm is not that complex. Below is
a simple example.

A linear regression with two parameters to be estimated:

$$
\bar{Y} = \beta_0 + \beta_1 * X
$$

$\beta_0$ = intercept

$\beta_1$ = slope

Suppose we have a dataset with 5 measurements of $X$ with response $Y$.

``` r
y <- c(1.3, 5.2, 9.7, 12.8, 14.9)
x <- c(-2.2, -1.3, 0.3, 2.1, 4.9)
df_data <- data.frame(y = y, x = x)
```

``` r
ggplot(df_data, aes(x = x, y = y)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE)
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

``` r
# grootte van de plot beperken
```

A linear regression with LM yields:

``` r
lm1 <- lm(formula = y ~ x, data = df_data)
lm1$coefficients
```

    ## (Intercept)           x 
    ##    7.366086    1.860413

With confidence interval ($\alpha = 0.1$)

``` r
confint(lm1, level = 0.9)
```

    ##                  5 %     95 %
    ## (Intercept) 5.173664 9.558508
    ## x           1.032228 2.688598

We source some short functions to calculate the (log) likelihood and the
prior and to execute the MCMC metropolis algorithm.

``` r
source(file = "./source/mcmc_functions.R")
```

For this simple model with a small data set, we can calculate and plot
the posterior for a large number of combinations of ‘beta_0’ and
‘beta_1’.

``` r
df <- expand.grid(beta_0 = seq(-1, 15, 0.5), beta_1 = seq(-3, 8, 0.5))
df$post <- NA
for (i in 1:nrow(df)) {
  df[i, "post"] <- ll.fun(beta_0 = df[i, "beta_0"],
                         b = df[i, "beta_1"]) +
                  prior.fun(beta_0 = df[i, "beta_0"],
                            beta_1 = df[i, "beta_1"])
}
```

``` r
ggplot(df, aes(x = beta_0, y = beta_1, z = post)) +
  geom_raster(aes(fill = post)) + geom_contour(colour = "black") +
  scale_fill_gradientn(colours = rainbow(n = 4))
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/unnamed-chunk-11-1.png)<!-- -->

To start the MCMC, we need to choose starting values for $\beta_0$ and
$\beta_1$:

``` r
mcmc_small <- MCMC_metro(x = x,         # vector x waarden
                         y = y,         # vector y waarden
                         N = 150,       # lengte van de MCMC
                         sigma = 1,     # stapgrootte (sd)
                         init_b0 = 12,  # initiële waarde beta_0 (intercept)
                         init_b1 = 6)   # initiële waarde beta_1 (helling)
```

``` r
ggplot(df, aes(x = beta_0, y = beta_1, z = post)) +
  geom_raster(aes(fill = post)) +
  geom_contour(binwidth = 20, colour = "black") +
  scale_fill_gradientn(colours = rainbow(n = 4)) +
  geom_path(data = mcmc_small,
            aes(x = beta_0, y = beta_1, z = NA), colour = "black") +
  geom_point(data = mcmc_small,
             aes(x = beta_0, y = beta_1, z = NA), colour = "red") +
  coord_cartesian(xlim = c(-1, 14.5), ylim = c(-3, 7)) +
  theme(legend.position = "none")
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/unnamed-chunk-13-1.png)<!-- -->

The starting value is quite far from the maximum likelihood. It takes a
while for the MCMC to stabilize in the vicinity of the top of the
mountain. Therefore, the first part of the MCMC is never used. This is
called the ‘burn-in’ or ‘warm-up’.

We now run the same model, but with a much longer MCMC (more
iterations):

``` r
mcmc_l <- MCMC_metro(x = x,
                     y = y,
                     N = 5000,
                     sigma = 1,
                     init_b0 = 12,
                     init_b1 = 6)
```

``` r
p1 <- ggplot(df, aes(x = beta_0, y = beta_1, z = post)) +
  geom_raster(aes(fill = post)) +
  geom_contour(binwidth = 20, colour = "black") +
  scale_fill_gradientn(colours = rainbow(n = 4)) +
  geom_path(data = mcmc_l,
            aes(x = beta_0, y = beta_1, z = NA), colour = "black") +
  geom_point(data = mcmc_l,
             aes(x = beta_0, y = beta_1, z = NA), colour = "red") +
  coord_cartesian(xlim = c(-1, 14.5), ylim = c(-3, 7)) +
  theme(legend.position = "none")

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
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/unnamed-chunk-15-1.png)<!-- -->

The MCMC for each parameter can be displayed in a so called ‘trace plot’
where we visualise the sampled parameter values over time.

``` r
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
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/unnamed-chunk-16-1.png)<!-- -->

Summary statistics of `beta_0` (intercept)

``` r
quantile(mcmc_l$beta_0[200:5000], probs = c(0.05, 0.5, 0.95))
```

    ##       5%      50%      95% 
    ## 5.529344 7.314135 9.168863

Summary statistics of `beta_1` (slope)

``` r
quantile(mcmc_l$beta_1[200:5000], probs = c(0.05, 0.5, 0.95))
```

    ##       5%      50%      95% 
    ## 1.237901 1.842052 2.520324

The samples in the MCMC are consecutive. To obtain more independent
samples, we could save only every $x^{th}$ value of the MCMC (thinning).
This saves memory space, while increasing the quality (independence) of
the sample. The final number of iterations however should remain large
enough to correctly calculate summary statistics.

There are more sophisticated samplers such as WinBugs, Jags or Stan, but
the MCMC principles are always the same.

The **brms** package in R (see further) uses the Stan sampler by
default.

Once we know the posterior, there are several possibilities to obtain
point estimates in Bayesian inference (see also figures below):

- the posterior mean
- the posterior median
- maximum a posteriori (MAP) or the mode. The mode can sometimes be far
  from the mean and median.

There are also different options for quantifying uncertainty:

- Highest posterior density interval (HPDI): A $100*(1-\alpha)$%
  interval countains $100*(1-\alpha)$% of the posterior density. This
  can be interesting to report when dealing with asymmetric
  distributions or when is important to avoid regions with low density.
- Equal-tailed credible interval = Central posterior interval (CPI): To
  calculate a $100*(1-\alpha)$% interval, there will be
  $\frac{\alpha}{2}$ probability in both the left and right tails of the
  distribution.

For symmetric, unimodal distributions, HPDI and CPI are the same (see
first figure below). Otherwise there may be quite a difference between
the two intervals (see figures 2 and 3 below).

A good example of bimodal data is the size of stag beetles where males
are much larger than females. If we would plot the size of all stag
beetles, we would obtain something close to the second and third figure
below. The second figure below shows the HPDI. It can be seen that there
are little beetles with a size between 34.1mm and 37.5mm: this is
slightly too large for a female and too small for a male. These sizes of
beetles are therefor excluded from the HPDI. The equal-tailed credible
interval would yield two boundaries; 5% of the beetles are smaller than
the lower interval (27.4mm) and 5% are larger than the upper limit of
the interval (46.9mm) as can be seen in the third figure below. However,
there are sizes of beetles outside this interval that have a higher
posterior then some sizes that are in this interval. For example, while
27.3mm is outside the interval, it has a higher posterior density that
46.8mm which is in the interval.

``` r
# specify a unimodal, symmetric distribution
unimodal <- data.frame(
  x = seq(10, 50)
) %>%
  mutate(prob = dnorm(x, mean = 30, sd = 5),
        cum_sum = pnorm(x, mean = 30, sd = 5))
limits <- data.frame(type = c("CPI", "CPI", "HPDI", "HPDI"),
                     x = c(22, 38, 22, 38))

p1 <- ggplot(unimodal) +
  geom_line(aes(x = x, y = prob)) +
  geom_vline(data = limits, aes(xintercept = x, color = type, lty = type,
                                size = type),
             alpha = 0.7) +
  scale_color_manual(breaks = c("CPI", "HPDI"), values = c("black", "red")) +
  scale_linetype_manual(breaks = c("CPI", "HPDI"),
                        values = c("solid", "dashed"))

# specify a bimodal distribution
bimodal <- data.frame(
  x = seq(20, 60, 0.1)
) %>%
  mutate(prob = (dnorm(x, mean = 43, sd = 3) +
           dnorm(x, mean = 30, sd = 2))/2,
        cum_sum = (pnorm(x, mean = 43, sd = 3) + pnorm(x, mean = 30, sd = 2))/2)
measures <- data.frame(measures = c("mean", "mode", "median"),
                       x = c(weighted.mean(x = bimodal$x, w = bimodal$prob),
                             30, 35.2))
limits <- data.frame(type = c("CPI", "CPI", "HPDI", "HPDI", "HPDI", "HPDI"),
                     x = c(27.4, 46.9, 25.9, 34.1, 37.5, 48.5))
p2 <- ggplot(bimodal) +
  geom_vline(data = limits %>% filter(type == "HPDI"), aes(xintercept = x)) +
  geom_bar(data = bimodal %>%
             filter((x >= 25.9 & x <= 34.1) | (x >= 37.5 & x <= 48.5)),
           aes(x = x, y = prob),
           stat = "identity", color = "grey", fill = "grey") +
  ggtitle("highest posterior density interval for a bimodal distribution") +
  geom_line(aes(x = x, y = prob)) + 
  geom_vline(data = measures, aes(xintercept = x), color = "red") +
  geom_label(data = measures,
            aes(label = measures, x = x, y = c(0.1, 0.09, 0.08)), fill = "red",
            alpha = 0.5) +
  geom_hline(aes(yintercept = 0.0123), lty = 2)
p3 <- ggplot(bimodal) +
  geom_vline(data = limits %>% filter(type == "CPI"), aes(xintercept = x)) +
  geom_bar(data = bimodal %>% filter(x >= 27.4 & x <= 46.9),
           aes(x = x, y = prob),
           stat = "identity", color = "grey", fill = "grey") +
  ggtitle("equal tail credible interval for a bimodal distribution") +
  geom_line(aes(x = x, y = prob))
p1 
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/unnamed-chunk-19-1.png)<!-- -->

``` r
p2
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/unnamed-chunk-20-1.png)<!-- -->

``` r
p3
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/unnamed-chunk-21-1.png)<!-- -->

## MCMC software

There exist a number of software programs that apply MCMC for parameter
estimates. Jags, Nimble and Stan are three examples for which there is
an R interface. A [recent comparison between these
three](https://arxiv.org/pdf/2107.09357v1.pdf) shows that each of these
three has strengths and weaknesses but that Stan, overall, is the best
performer.

In this course we choose the R package
[**brms**](https://cran.r-project.org/web/packages/brms/vignettes/brms_overview.pdf)
which provides a convenient, simple interface for Stan. Some
alternatives also exist:

- [**rstan**](https://cran.r-project.org/web/packages/rstan/vignettes/rstan.html)
  is the basis of **brms**. You need **rstan** to use **brms** because
  it communicates directly with Stan. A model composed in “pure” Stan
  code can be fitted with the **rstan** package in R (so without using
  **brms**), but can be quite complex.
- [**rstanarm**](https://mc-stan.org/rstanarm/articles/index.html) is
  similar to **brms** in terms of complexity of the syntax. Moreover,
  with the **rstanarm** package you can use some pre-compiled Stan
  models. This means that fitting your model takes less time. A large
  part of the process time of **brms** goes into compiling the Stan
  program.

![Overview of various Stan software (source:
<https://jtimonen.github.io/posts/post-01/>)](software.png)

# Fitting a model with brms

## Loading the dataset and data exploration

We load a dataset on the number of ant species in New England (USA).
Type `?ants` into the console for more info.

``` r
# Load data
data(ants)

# Set column names to lower case
ants_df <- ants %>%
  rename(sp_rich = Srich) %>%
  rename_with(tolower)

# What does the data look like?
glimpse(ants_df)
```

    ## Rows: 44
    ## Columns: 5
    ## $ site      <fct> TPB, HBC, CKB, SKP, CB, RP, PK, OB, SWR, ARC, BH, QP, HAW, W…
    ## $ sp_rich   <int> 6, 16, 18, 17, 9, 15, 7, 12, 14, 9, 10, 10, 4, 5, 7, 7, 4, 6…
    ## $ habitat   <fct> Forest, Forest, Forest, Forest, Forest, Forest, Forest, Fore…
    ## $ latitude  <dbl> 41.97, 42.00, 42.03, 42.05, 42.05, 42.17, 42.19, 42.23, 42.2…
    ## $ elevation <int> 389, 8, 152, 1, 210, 78, 47, 491, 121, 95, 274, 335, 543, 32…

We have a number of sites (`site`) where the number of ant species has
been counted (`sp_rich`). Some variables are present: `habitat`,
`latitude` and `elevation`. Let’s look at some summary statistics. Two
counts were made at each site: one in a bog and one in a forest.

``` r
# Summary statistics dataset
summary(ants_df)
```

    ##       site       sp_rich         habitat      latitude       elevation    
    ##  ARC    : 2   Min.   : 2.000   Bog   :22   Min.   :41.97   Min.   :  1.0  
    ##  BH     : 2   1st Qu.: 4.000   Forest:22   1st Qu.:42.17   1st Qu.: 95.0  
    ##  CAR    : 2   Median : 6.000               Median :42.56   Median :223.0  
    ##  CB     : 2   Mean   : 7.023               Mean   :43.02   Mean   :232.7  
    ##  CHI    : 2   3rd Qu.: 8.250               3rd Qu.:44.29   3rd Qu.:353.0  
    ##  CKB    : 2   Max.   :18.000               Max.   :44.95   Max.   :543.0  
    ##  (Other):32

We visualise the data.

``` r
# Frequency of the number of species in each habitat
ants_df %>%
  ggplot(aes(x = sp_rich)) +
    geom_bar() +
    scale_x_continuous(limits = c(0, NA)) +
    facet_wrap(~habitat)
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/data-expl-vis1-1.png)<!-- -->

``` r
# Boxplots of the number of species per habitat
ants_df %>%
  ggplot(aes(y = sp_rich, x = habitat)) +
    geom_boxplot() +
    geom_line(aes(colour = site, group = site), alpha = 0.5) +
    geom_point(aes(colour = site, group = site)) +
    scale_y_continuous(limits = c(0, NA))
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/data-expl-vis2-1.png)<!-- -->

``` r
# Scatter plot of the number of species, related to the latitude per habitat
ants_df %>%
  ggplot(aes(y = sp_rich, x = latitude)) +
    geom_point() +
    geom_smooth(method = "loess", formula = "y ~ x", colour = "firebrick",
                level = 0.9) +
    facet_wrap(~habitat)
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/data-expl-vis3-1.png)<!-- -->

``` r
# Scatter plot of the number of species, related to the height per habitat
ants_df %>%
  ggplot(aes(y = sp_rich, x = elevation)) +
    geom_point() +
    geom_smooth(method = "loess", formula = "y ~ x", colour = "firebrick",
                level = 0.9) +
    facet_wrap(~habitat)
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/data-expl-vis4-1.png)<!-- -->

As an exercise, we will create a model to compare the number of species
between both habitats. From the data exploration, we already saw that
the number of species seems to be higher in forests and that sites with
a higher number in bogs often also have a higher number in forests.

## Specification of a linear regression

### Model specification

We want a model that allows us to investigate the difference in number
of ant species between bog and forest habitats. Consider the response
variable $Y$, the number of ants, and $X_{habitat}$, a dummy variable
equal to 0 for bogs and 1 for forests. We assume that $Y$ follows a
Normal distribution (equivalent to a linear regression with categorical
variable (= ANOVA)).

$$
Y \sim N(\mu, \sigma^2)
$$

with

$$
\mu = \beta_0 + \beta_1X_{habitat}
$$

So we need to estimate three parameters: $\beta_0$, $\beta_1$ and
$\sigma$. How do we specify this in **brms**?

First of all we decide which MCMC parameters we will use. Type `?brm` to
see what the default settings are for these parameters. It is
recommended to use multiple chains (`nchains`) and run them in parallel
on different cores of your computer (`nparallel`). Since this is a
relatively simple model, we don’t need many iterations and no thinning.

``` r
# Set MCMC parameters
nchains <- 3 # number of chains
niter <- 2000 # number of iterations (incl. burn-in, see next)
burnin <- niter / 4 # number of initial samples to remove (= burn-in)
nparallel <- nchains # number of cores for parallel computing
thinning <- 1 # thinning factor (here 1 = no thinning)
```

The model is fitted using the `brm()` function. The syntax is very
similar to functions used in frequentist statistics such as `lm()` and
`glm()`. The `brm()` function contains many arguments (see `?brm`).
Useful arguments that we do not use here are, for example:

- `inits` to set the initial values of MCMC algorithm. If these are not
  specified, the function uses default values.
- `prior` to provide prior distributions. If these are not specified,
  the function uses default (non-informative) priors. The argument
  `sample_prior` can be used to sample from the prior so that you can
  visualise whether the used prior meets your expectations (also useful
  for [prior predictive
  checks](https://arelbundock.com/posts/marginaleffects_priors/)) .
- `file` and `file_refit` to save the model object after it has been
  fitted. If you run the code again and the model has already been
  saved, `brm()` will simply load this model instead of refitting it.

``` r
# Fit Normal model
fit_normal1 <- brm(
  formula = sp_rich ~ habitat, # specify the model
  family = gaussian(),         # we use the Normal distribution
  data = ants_df,              # specify data
  chains = nchains,            # MCMC parameters
  warmup = burnin, 
  iter = niter,
  cores = nparallel,
  thin = thinning,
  seed = 123)                  # seed for reproducibility
```

Before we look at the results, we first check whether the model
converges well.

### MCMC convergence

There are several ways to check convergence of the MCMC algorithm for
each parameter. The burn-in samples are not taken into account. First
and foremost, you have *visual controls*.

We can obtain the MCMC samples with the `as_draws()` functions or
visualise them at once via the
[**bayesplot**](https://mc-stan.org/bayesplot/) package that is
compatible with brmsfit objects.

``` r
# Set colour palette for clear visualisation in bayesplot
color_scheme_set("mix-blue-red")
```

``` r
# Which parameters to look at?
parameters <- c("b_Intercept", "b_habitatForest", "sigma")
```

**trace plot**

Trace plots indicate how the sampling of the posterior distribution
progresses over time. The idea is that each chain converges to the same
distribution for each parameter (this is called mixing). If this plot
looks like a fuzzy caterpillar, it means the convergence is good.

``` r
# Visualisation by extracting samples with as_draws_df()
as_draws_df(fit_normal1, variable = parameters) %>%
  # long format
  pivot_longer(cols = all_of(parameters), names_to = "parameter",
               values_to = "value") %>%
  # visualise with ggplot()
  ggplot(aes(y = value, x = .iteration, colour = factor(.chain))) +
    geom_line() +
    facet_wrap(~parameter, nrow = 3, scales = "free")
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/simple-model-trace1-1.png)<!-- -->

``` r
# Visualise with bayesplot package
mcmc_trace(fit_normal1, pars = parameters)
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/simple-model-trace2-1.png)<!-- -->

**running mean/quantile/… plot**

In addition to a trace plot, we can also look at how certain statistics,
such as the average or the quantiles, vary over time (= with increasing
number of iterations). You want these statistics to stabilize after a
number of iterations because then you know that you have used enough
iterations.

``` r
# Code to calculate cumulative quantiles
# source: https://rdrr.io/cran/cumstats/src/R/cumquant.R
cumquant <- function(x, p) {
  out <- sapply(seq_along(x),
                function(k, z) quantile(z[1:k], probs = p[1], names = FALSE),
                z = x)
  return(out)
}
```

``` r
# Extract samples and calculate cumulative statistics
as_draws_df(fit_normal1, variable = parameters) %>%
  mutate(across(all_of(parameters), ~cummean(.x),
                .names = "{.col}_mean"),
         across(all_of(parameters), ~cumquant(.x, 0.05),
                .names = "{.col}_q05"),
         across(all_of(parameters), ~cumquant(.x, 0.95),
                .names = "{.col}_q95")) %>%
  select(-all_of(parameters)) %>%
  # long format for visualisation
  pivot_longer(cols = starts_with(parameters), names_to = "name",
               values_to = "value") %>%
  # split columns names at the last underscore
  extract(name, into = c("parameter", "statistic"), "(.*)_([^_]+)$") %>%
  ggplot(aes(y = value, x = .iteration, colour = factor(.chain))) +
    geom_line(aes(linetype = statistic), linewidth = 0.8) +
    facet_wrap(~parameter, nrow = 3, scales = "free")
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/simple-model-cum-stat-1.png)<!-- -->

**posterior density plot**

The shape of the posterior distributions can also be informative to
check whether the chains have converged to the same distributions. If we
see a bimodal distribution (a camel’s ridge with two peaks) for example,
then there could also be something wrong with the specification of our
model.

``` r
# Visualise density plot of the posterior for each of the chains separately
# via bayesplot package.
mcmc_dens_overlay(fit_normal1, pars = parameters)
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/simple-model-posterior-density2-1.png)<!-- -->

It is even easier to use the `plot()` function on the brmsfit object.
This immediately shows the trace plots and the posterior density plots
side by side for each parameter.

``` r
# Trace plots and posterior density for each parameter.
plot(fit_normal1)
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/unnamed-chunk-23-1.png)<!-- -->

**autocorrelation plot**

If two variables are *correlated*, it means that there is a relationship
between them. This can be a positive or negative relationship. An
example of positively correlated variables is people’s size and weight;
the taller a person is, the more they will typically weigh. An example
of negatively correlated variables is the amount of sunshine and the
moisture content in the top layer of the soil.

*Autocorrelation* can be understood as correlation between elements in a
series of values. A good example is the variation in the outside
temperature over the day. Suppose you measure the temperature every ten
minutes. The current temperature is very strongly correlated with the
temperature half an hour ago, strongly correlated with the temperature 2
hours ago and weakly correlated with the temperature 8 hours ago. To
discover the posterior, we would have to do a complete random walk
through the parameter space where the location on iteration $i$ is
completely independent of the location on iteration $i-1$. In an MCMC
there will often be some autocorrelation and it is important to check
whether this autocorrelation is not too large. The so-called lag
indicates how much correlation there is between values that are 1, 2, 3
… iterations apart. Autocorrelation can, for example, be the result of a
poorly chosen step size, a poorly chosen start location, or
multimodality in the posterior. If the autocorrelation is high, the
Markov chain will be inefficient, i.e. we will need many iterations to
obtain a good approximation of the posterior distribution (see also
effective sample size below).

If there is too much autocorrelation, thinning is often used whereby
some iterations are removed from the chain. This will reduce the
autocorrelation but also the number of posterior samples we have left.

``` r
# Visualisation of autocorrelation plots via bayesplot package
mcmc_acf(fit_normal1, pars = parameters)
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/simple-model-autocorrelation-1.png)<!-- -->

In addition to visual checks, there are also *diagnostic checks*.

**Gelman-Rubin diagnostics**

Also called $\hat{R}$ (R-hat) or potential scale reduction factor. One
way to check whether a chain has converged is to compare its behaviour
with other randomly initialized chains. The $\hat{R}$ statistic takes
the ratio of the average variance of samples within each chain to the
variance of the pooled samples across all chains. If all chains converge
to a common distribution, these ratios will equal 1. If the chains have
not converged to a common distribution, the $\hat{R}$ statistic will be
greater than 1. We can extract the $\hat{R}$ statistics via the `rhat()`
function and then visualise them if desired with the `mcmc_rhat()`
function of the **bayesplot** package.

``` r
# Get R-hats
rhats_fit_normal1 <- rhat(fit_normal1)[parameters]
print(rhats_fit_normal1)
```

    ##     b_Intercept b_habitatForest           sigma 
    ##       1.0003861       1.0004918       0.9998149

``` r
# Plot R-hats via bayesplot package
mcmc_rhat(rhats_fit_normal1) + yaxis_text(hjust = 1)
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/simple-model-plot-Rhat-1.png)<!-- -->

**effective sample size**

The effective sample size ($n_{eff}$) is an estimate of the number of
independent draws from the posterior distribution of each parameter.
Since the draws within a Markov chain are not independent when there is
autocorrelation, the effective sample size is usually smaller than the
total sample size, namely the number of iterations ($N$). The larger the
ratio $n_{eff}/N$ the better. The **bayesplot** package provides a
`neff_ratio()` extractor function. The `mcmc_neff()` function can then
be used to plot the ratios.

``` r
# Get ratio of effective sample size
ratios_fit_normal1 <- neff_ratio(fit_normal1)[parameters]
print(ratios_fit_normal1)
```

    ##     b_Intercept b_habitatForest           sigma 
    ##       0.7436946       0.6869533       0.7381539

``` r
# Plot ratio via bayesplot package
mcmc_neff(ratios_fit_normal1) + yaxis_text(hjust = 1)
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/simple-model-plot-%20effective-sample-size-1.png)<!-- -->

Other packages that may be useful for checking MCMC convergence are
[mcmcplots](https://cran.r-project.org/web/packages/mcmcplots/index.html)
and [coda](https://cran%20.r-project.org/web/packages/coda/index.html).
For these packages you must first convert the MCMC samples from your
**brms** model to an mcmc object.

    # example
    install.packages("mcmcplots")
    mcmcplots::mcmcplot(as.mcmc(fit_normal1, pars = parameters))

In general, we can conclude that MCMC convergence is good for all
parameters in our Normal model. If this were not the case, the MCMC
parameters may have to be chosen differently, for example by increasing
the number of iterations. Now that we know that the parameters have been
estimated correctly, we can check whether the model fits the data well.

### Model fit

The [posterior predictive
check](https://mc-stan.org/bayesplot/articles/graphical-ppcs.html) (PPC)
is a good way to check whether the model fits the data well. The idea
behind the PPC is that, if a model fits well, the predicted values based
on the model are very similar to the data we used to fit the model. To
generate the predictions used for PPCs, we simulate several times from
the posterior predictive distribution (the posterior distribution of the
response variable). visualisation is possible with the **bayesplot**
package. The thick line shows the data and the thin lines show different
simulations based on the model.

``` r
# Visualise model fit via bayesplot package
pp_check(fit_normal1, type = "dens_overlay_grouped", ndraws = 100, 
         group = "habitat")
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/simple-model-fit1-1.png)<!-- -->

We see that the observed data and the predictions based on our model do
not quite match. Our choice for the Normal distribution may have been
wrong. Numbers are discrete, positive values, while the Normal
distribution can predict continuous and both positive and negative
values. The Poisson distribution is a discrete distribution that is
always positive. It is often used to model numbers recorded over a given
time interval, distance, area, volume…

**Remark:**

Note that MCMC convergence and model fit are two different things. If
MCMC convergence is good, this does not necessarily mean that model fit
is also good. MCMC convergence is to check whether the MCMC algorithm
has been able to correctly approximate the distributions of the
parameters. Model fit checks whether the model we have adopted
(normality assumption, linear relationship average…) fits the data well.

## Specification of a Poisson model

### Model specification

We now assume that $Y$ now follows a Poisson distribution

$$
Y \sim Pois(\lambda)
$$

with

$$
\ln(\lambda) = \beta_0 + \beta_1X_{habitat}
$$

So we need to estimate two parameters: $\beta_0$ and $\beta_1$ We use
the same MCMC parameters as before. The only thing we need to adjust is
the choice `family = poisson()`.

``` r
# Fit Poisson model
fit_poisson1 <- brm(
  formula = sp_rich ~ habitat, # specify the model
  family = poisson(),          # we use the Poisson distribution
  data = ants_df,              # specify the data
  chains = nchains,            # MCMC parameters
  warmup = burnin, 
  iter = niter,
  cores = nparallel,
  thin = thinning,
  seed = 123)                  # seed for reproducibility
```

### MCMC convergence

Convergence looks good.

``` r
# Visualise MCMC convergence of the Poisson model
plot(fit_poisson1)
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/poisson-model-convergence-1.png)<!-- -->

``` r
# Extract and visualise R-hat values
rhats_fit_poisson1 <- rhat(fit_poisson1)[c("b_Intercept", "b_habitatForest")]
mcmc_rhat(rhats_fit_poisson1) + yaxis_text(hjust = 1)
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/poisson-model-Rhat-1.png)<!-- -->

### Model fit

We see that all predictions are now positive, but the fit is still not
perfect.

``` r
# Visualise model fit via bayesplot package
pp_check(fit_poisson1, type = "dens_overlay_grouped", ndraws = 100, 
         group = "habitat")
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/poisson-model-fit-vis-1.png)<!-- -->

### Discussion

How can we further improve model fit?

We know that each site has been visited twice. Once in bog and once in
forest. It is of course possible that the number of ants in the bog and
forest of the same site will be correlated (site effect). Indeed, this
is something we noticed during data exploration as well. Sites with
higher numbers of species in bogs often also have higher numbers in
forests and vice versa. We can correct this by adding a random intercept
for each site `... + (1|site)`.

We assume that the number of species $Y$ per site $j$ ($j = 1, ..., J$)
follows a Poisson distribution

$$
Y_j \sim Pois(\lambda_j)
$$

such that

$$
\ln(\lambda_j) = \beta_0 + \beta_1X_{habitat} + b_{0,j}
$$ with

$$
b_0 \sim N(0, \sigma_b)
$$

``` r
# Fit Poisson model with random intercept per site
fit_poisson2 <- brm(
  formula = sp_rich ~ habitat + (1|site),
  family = poisson(),
  data = ants_df,
  chains = nchains,
  warmup = burnin, 
  iter = niter,
  cores = nparallel,
  thin = thinning,
  seed = 123)#seed for reproducibility
```

Convergence looks good.

``` r
# Visualise MCMC convergence
plot(fit_poisson2)
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/rand-intercept-model-convergence-1.png)<!-- -->

``` r
# Extract and visualise R-hat values
parameters2 <- c("b_Intercept", "b_habitatForest", "sd_site__Intercept")
rhats_fit_poisson2 <- rhat(fit_poisson2)[parameters2]
mcmc_rhat(rhats_fit_poisson2) + yaxis_text(hjust = 1)
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/rand-intercept-model-rhat-1.png)<!-- -->

Model fit looks even better than before.

``` r
# Visualise model fit of the Poisson model with random intercept via
# bayesplot package
pp_check(fit_poisson2, type = "dens_overlay_grouped", ndraws = 100, 
         group = "habitat")
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/rand-intercept-model-fit-vis-1.png)<!-- -->

How can we objectively compare these models?

# Compare models

Based on the PPCs we can already see which model fits the data best.
Furthermore, there are some functions that **brms** provides to compare
different models. With the function `add_criterion()` you can add model
fit criteria to model objects. Type `?add_criterion()` to see which ones
are available. See also
<https://mc-stan.org/loo/articles/online-only/faq.html>

## Leave-one-out cross validation

Cross-validation (CV) is a family of techniques that attempts to
estimate how well a model would predict unknown data through predictions
of the model fitted to the known data. You do not necessarily have to
collect new data for this. You can split your own data into a test and
training dataset. You fit the model to the training dataset and then use
that model to estimate how well it can predict the data in the test
dataset. With leave-one-out CV (LOOCV) you leave out one observation
each time as test dataset and refit the model based on all other
observations (= training dataset).

![Figure LOOCV.](loocv.png)

``` r
# Add leave-one-out model fit criterium to model objects
fit_normal1 <- add_criterion(fit_normal1,
                             criterion = c("loo"))
fit_poisson1 <- add_criterion(fit_poisson1,
                              criterion = c("loo"))
fit_poisson2 <- add_criterion(fit_poisson2,
                              criterion = c("loo"))
```

To determine the difference between the model’s prediction based on the
training dataset with the omitted data, we must define a so-called
utility or loss function. We use the ‘expected log pointwise predictive
density’ (ELPD) here. For this tutorial, it is mainly important to
understand that this is a measure of how well your Bayesian model
predicts new data points. It is calculated by taking the log-likelihood
of each data point from the posterior predictive distribution of your
model and then averaging it. A higher ELPD indicates better model fit
and predictive accuracy. For this tutorial, it is mainly important to
understand that this is a measure of how well the model can predict
unknown data (`elpd_loo` and the standard error `se_elpd_loo`). `p_loo`
is a measure of the complexity of the model.
$\text{looic} = -2*\text{elpd_loo}$ With the function `loo_compare()`
you can compare multiple models and the difference in ELPD is also
calculated.

``` r
# Make comparison leave-one-out cross-validation and print
comp_loo <- loo_compare(fit_normal1, fit_poisson1, fit_poisson2,
                        criterion = "loo")
print(comp_loo, simplify = FALSE, digits = 3)
```

    ##              elpd_diff se_diff  elpd_loo se_elpd_loo p_loo    se_p_loo looic   
    ## fit_poisson2    0.000     0.000 -106.276    3.849      11.552    1.522  212.552
    ## fit_poisson1  -13.403     5.802 -119.679    8.319       3.714    0.888  239.358
    ## fit_normal1   -15.647     3.629 -121.923    5.301       3.013    0.842  243.846
    ##              se_looic
    ## fit_poisson2    7.698
    ## fit_poisson1   16.637
    ## fit_normal1    10.601

If you assume that this difference is normally distributed, you can
calculate a confidence interval based on the uncertainty. We see that
the second Poisson model scores best and that the other models score
significantly lower.

``` r
# Calculate confidence interval to compare models with loocv
comp_loo %>%
  as.data.frame() %>%
  select(elpd_diff, se_diff) %>%
  mutate(ll_diff = elpd_diff  + qnorm(0.05) * se_diff,
         ul_diff = elpd_diff  + qnorm(0.95) * se_diff)
```

    ##              elpd_diff  se_diff   ll_diff   ul_diff
    ## fit_poisson2   0.00000 0.000000   0.00000  0.000000
    ## fit_poisson1 -13.40293 5.802467 -22.94714 -3.858719
    ## fit_normal1  -15.64659 3.628604 -21.61511 -9.678068

## K-fold cross-validation

With K-fold cross-validation, the data is split into $K$ groups. We will
use $K = 10$ groups (= folds) here. So instead of leaving out a single
observation each time, as with leave-one-out CV, we will leave out one
$10^{th}$ of the data here. Via the arguments `folds = "stratified"` and
`group = "habitat"` we ensure that the relative frequencies of habitat
are preserved for each group. This technique will therefore be less
precise than the previous one, but will be faster to calculate if you
work with a lot of data.

![Figure K-fold CV.](k-foldcv.png)

``` r
# Add K-fold model fit criterium to model objects
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
```

We get the same statistics as before.

``` r
# Get k-fold cross-validation and print
comp_kfold <- loo_compare(fit_normal1, fit_poisson1, fit_poisson2,
                          criterion = "kfold")
print(comp_kfold, simplify = FALSE, digits = 3)
```

    ##              elpd_diff se_diff  elpd_kfold se_elpd_kfold p_kfold  se_p_kfold
    ## fit_poisson2    0.000     0.000 -106.773      4.145        12.048    1.944  
    ## fit_poisson1  -12.290     5.195 -119.063      8.156         3.097    0.939  
    ## fit_normal1   -14.619     3.258 -121.392      5.172         2.482    0.796

The results are the same, but the differences are slightly smaller than
before.

``` r
# Calculate confidence interval to compare models with K-fold CV
comp_kfold %>%
  as.data.frame() %>%
  select(elpd_diff, se_diff) %>%
  mutate(ll_diff = elpd_diff  + qnorm(0.05) * se_diff,
         ul_diff = elpd_diff  + qnorm(0.95) * se_diff)
```

    ##              elpd_diff  se_diff   ll_diff   ul_diff
    ## fit_poisson2   0.00000 0.000000   0.00000  0.000000
    ## fit_poisson1 -12.28990 5.195211 -20.83526 -3.744537
    ## fit_normal1  -14.61938 3.258315 -19.97883 -9.259928

## WAIC

The Widely Applicable Information Criterion (WAIC) does not use
cross-validation but is a computational way to estimate the ELPD. How
this happens exactly is beyond the purpose of this tutorial. It is yet
another measure to apply model selection.

``` r
# Add WAIC model fit criterion to model objects
fit_normal1 <- add_criterion(fit_normal1,
                             criterion = c("waic"))
fit_poisson1 <- add_criterion(fit_poisson1,
                              criterion = c("waic"))
fit_poisson2 <- add_criterion(fit_poisson2,
                              criterion = c("waic"))
```

We get similar results as before.

``` r
# Get waic and print
comp_waic <- loo_compare(fit_normal1, fit_poisson1, fit_poisson2,
                         criterion = "waic")
print(comp_waic, simplify = FALSE, digits = 3)
```

    ##              elpd_diff se_diff  elpd_waic se_elpd_waic p_waic   se_p_waic
    ## fit_poisson2    0.000     0.000 -105.062     3.683       10.338    1.348 
    ## fit_poisson1  -14.594     5.858 -119.656     8.312        3.691    0.882 
    ## fit_normal1   -16.833     3.624 -121.895     5.289        2.985    0.830 
    ##              waic     se_waic 
    ## fit_poisson2  210.124    7.367
    ## fit_poisson1  239.313   16.624
    ## fit_normal1   243.790   10.578

``` r
# Calculate confidence interval to compare models with WAIC
comp_waic %>%
  as.data.frame() %>%
  select(waic, elpd_diff, se_diff) %>%
  mutate(ll_diff = elpd_diff  + qnorm(0.05) * se_diff,
         ul_diff = elpd_diff  + qnorm(0.95) * se_diff)
```

    ##                  waic elpd_diff  se_diff   ll_diff    ul_diff
    ## fit_poisson2 210.1239   0.00000 0.000000   0.00000   0.000000
    ## fit_poisson1 239.3128 -14.59444 5.857609 -24.22935  -4.959532
    ## fit_normal1  243.7901 -16.83311 3.624302 -22.79456 -10.871665

## Conclusion

Both based on the PPC and the comparisons with different model selection
criteria, we can conclude that the second Poisson model with random
intercepts fits the data best. In principle, we could have expected this
based on our own intuition and the design of the study, i.e. the use of
the Poisson distribution to model numbers and the use of random
intercepts to control for a hierarchical design (habitats nested within
sites).

# Final model results

When we look at the model fit object, we see results that are similar to
results we see when we fit a frequentist model. On the one hand we get
an estimate of all parameters with their uncertainty, but on the other
hand we see that this is clearly the output of a Bayesian model. We get
information about the parameters we used for the MCMC algorithm, we get
a 95% credible interval (CI) instead of a confidence interval and we
also get the $\hat{R}$ value for each parameter as discussed earlier.

``` r
# Look at the fit object of the Poisson model with random effects
fit_poisson2
```

    ##  Family: poisson 
    ##   Links: mu = log 
    ## Formula: sp_rich ~ habitat + (1 | site) 
    ##    Data: ants_df (Number of observations: 44) 
    ##   Draws: 3 chains, each with iter = 2000; warmup = 500; thin = 1;
    ##          total post-warmup draws = 4500
    ## 
    ## Group-Level Effects: 
    ## ~site (Number of levels: 22) 
    ##               Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
    ## sd(Intercept)     0.38      0.10     0.22     0.60 1.00     1748     2738
    ## 
    ## Population-Level Effects: 
    ##               Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
    ## Intercept         1.51      0.13     1.25     1.77 1.00     2873     2723
    ## habitatForest     0.64      0.12     0.41     0.88 1.00     7102     3251
    ## 
    ## Draws were sampled using sampling(NUTS). For each parameter, Bulk_ESS
    ## and Tail_ESS are effective sample size measures, and Rhat is the potential
    ## scale reduction factor on split chains (at convergence, Rhat = 1).

A useful package for visualising the results of our final model is the
[tidybayes](https://mjskay.github.io/tidybayes/articles/tidy-brms.html)
package. Through this package, you can work with the posterior
distributions as you would work with any dataset through the
**tidyverse** package.

With the function `gather_draws()` you can take a certain number of
samples from the posterior distributions of certain parameters and
convert them into a long format table. You usually do not want to select
all posterior samples because there are sometimes unnecessarily many. By
specifying a ‘seed’ you ensure that these are the same samples every
time you run the script again. You can then calculate certain summary
statistics via the classic **dplyr** functions.

``` r
fit_poisson2 %>%
  # gather 1000 posterior samples for 2 parameters in long format
  gather_draws(b_Intercept, b_habitatForest, ndraws = 1000, seed = 123) %>%
  # calculate summary statistics for each variable
  group_by(.variable) %>%
  summarise(min = min(.value),
            q_05 = quantile(.value, probs = 0.05),
            q_20 = quantile(.value, probs = 0.20),
            mean = mean(.value),
            median = median(.value),
            q_80 = quantile(.value, probs = 0.80),
            q_95 = quantile(.value, probs = 0.95),
            max = max(.value))
```

    ## # A tibble: 2 × 9
    ##   .variable         min  q_05  q_20  mean median  q_80  q_95   max
    ##   <chr>           <dbl> <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl>
    ## 1 b_Intercept     1.04  1.29  1.40  1.51   1.52  1.63  1.74   1.97
    ## 2 b_habitatForest 0.268 0.432 0.537 0.638  0.639 0.742 0.831  1.00

Useful functions of the **tidybayes** package are also `median_qi()`,
`mean_qi()` … after `gather_draws()` which you can use instead of
`group_by()` and `summarise()` .

We would now like to visualise the estimated number of species per
habitat type with associated uncertainty. With the function
`spread_draws()` you can take a certain number of samples from the
posterior distribution and convert them into a wide format table. The
average number of species in bogs according to our model is
$\exp(\beta_0)$ and in forests $\exp(\beta_0+\beta_1)$. We show the
posterior distributions with the posterior median and 60 and 90%
credible intervals.

``` r
fit_poisson2 %>%
  # spread 1000 posterior samples for 2 parameters in wide format
  spread_draws(b_Intercept, b_habitatForest, ndraws = 1000, seed = 123) %>%
  # calculate average numbers and convert to long format for visualisation
  mutate(bog = exp(b_Intercept),
         forest = exp(b_Intercept + b_habitatForest)) %>%
  pivot_longer(cols = c("bog", "forest"), names_to = "habitat", 
               values_to = "sp_rich") %>%
  # visualise via ggplot()
  ggplot(aes(y = sp_rich, x = habitat)) +
    stat_eye(point_interval = "median_qi", .width = c(0.6, 0.9)) +
    scale_y_continuous(limits = c(0, NA))
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/resultats-fit-poisson-3-1.png)<!-- -->

In addition to `stat_eye()` you will find
[here](https://mjskay.github.io/tidybayes/articles/tidy-brms.html#other-visualizations-of-distributions-stat_slabinterval)
some nice ways to visualise posterior distributions .

We see a clear difference in the number of species between the two
habitats. Is there a significant difference between the number of
species in bogs and forests? We test the hypothesis that numbers are
equal in bogs and forests.

$$
\exp(\beta_0) = \exp(\beta_0+\beta_1)\\
\Rightarrow \beta_0 = \beta_0 + \beta_1\\
\Rightarrow \beta_1 = 0\\
$$

This can easily be done via the `hypothesis()` function of the **brms**
package. The argument `alpha` specifies the size of the credible
interval. This allows hypothesis testing in a similar way to the
frequentist null hypothesis testing framework.

``` r
# Test hypothesis difference between habitats
hyp <- hypothesis(fit_poisson2, "habitatForest = 0", alpha = 0.1)
hyp
```

    ## Hypothesis Tests for class b:
    ##            Hypothesis Estimate Est.Error CI.Lower CI.Upper Evid.Ratio Post.Prob
    ## 1 (habitatForest) = 0     0.64      0.12     0.44     0.84         NA        NA
    ##   Star
    ## 1    *
    ## ---
    ## 'CI': 80%-CI for one-sided and 90%-CI for two-sided hypotheses.
    ## '*': For one-sided hypotheses, the posterior probability exceeds 90%;
    ## for two-sided hypotheses, the value tested against lies outside the 90%-CI.
    ## Posterior probabilities of point hypotheses assume equal prior probabilities.

``` r
# Plot posterior distribution hypothesis
plot(hyp)
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/resultats-hypothesis-test-vis-1.png)<!-- -->

We can conclude that there is a significant difference since 0 is not
included in the 90% credible interval.

Finally, we visualise the random effects of the sites. We sort them from
high to low species richness.

``` r
# Take the mean of SD of random effects
# to add to figure later
sd_mean <- fit_poisson2 %>%
  spread_draws(sd_site__Intercept, ndraws = 1000, seed = 123) %>%
  summarise(mean_sd = mean(sd_site__Intercept)) %>%
  pull()

# Take random effects and plot
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
```

![](workshop_1_mcmc_en_brms_eng_files/figure-gfm/resultats-visualise-random-effects-1.png)<!-- -->

# Comparison with frequentist statistics

Let’s go back to our very first model where we used the Normal
distribution. This was equivalent to a linear regression with
categorical variable. A linear regression with categorical variable is
also called ANOVA and if there are only two groups, an ANOVA is
equivalent to a t-test. We can therefore take the opportunity to compare
the results of our first model (a Bayesian model) with the results of a
classical (frequentist) t-test.

``` r
# Extract summary statistics from the  Bayesian model
sum_fit_normal1 <- summary(fit_normal1, prob = 0.9)
diff_bog1 <- sum_fit_normal1$fixed$Estimate[2]
ll_diff_bog1 <- sum_fit_normal1$fixed$`l-90% CI`[2]
ul_diff_bog1 <- sum_fit_normal1$fixed$`u-90% CI`[2]

sum_fit_normal1
```

    ##  Family: gaussian 
    ##   Links: mu = identity; sigma = identity 
    ## Formula: sp_rich ~ habitat 
    ##    Data: ants_df (Number of observations: 44) 
    ##   Draws: 3 chains, each with iter = 2000; warmup = 500; thin = 1;
    ##          total post-warmup draws = 4500
    ## 
    ## Population-Level Effects: 
    ##               Estimate Est.Error l-90% CI u-90% CI Rhat Bulk_ESS Tail_ESS
    ## Intercept         4.84      0.80     3.53     6.16 1.00     4194     3347
    ## habitatForest     4.33      1.14     2.44     6.20 1.00     4113     3091
    ## 
    ## Family Specific Parameters: 
    ##       Estimate Est.Error l-90% CI u-90% CI Rhat Bulk_ESS Tail_ESS
    ## sigma     3.73      0.41     3.13     4.44 1.00     3925     3322
    ## 
    ## Draws were sampled using sampling(NUTS). For each parameter, Bulk_ESS
    ## and Tail_ESS are effective sample size measures, and Rhat is the potential
    ## scale reduction factor on split chains (at convergence, Rhat = 1).

``` r
# Perform t-test and extract summary statistics
t_test_normal1 <- t.test(sp_rich ~ habitat, data = ants_df, conf.level = 0.9)
diff_bog2 <- t_test_normal1$estimate[2] - t_test_normal1$estimate[1]
ll_diff_bog2 <- -t_test_normal1$conf.int[2]
ul_diff_bog2 <- -t_test_normal1$conf.int[1]

t_test_normal1
```

    ## 
    ##  Welch Two Sample t-test
    ## 
    ## data:  sp_rich by habitat
    ## t = -3.8881, df = 37.034, p-value = 0.0004043
    ## alternative hypothesis: true difference in means between group Bog and group Forest is not equal to 0
    ## 90 percent confidence interval:
    ##  -6.191854 -2.444510
    ## sample estimates:
    ##    mean in group Bog mean in group Forest 
    ##             4.863636             9.181818

We see that this indeed produces almost exactly the same results. Our
Bayesian model estimates that on average 4.326 more ant species occur in
forests than in bogs (90% credible interval: 2.439 to 6.203). The t-test
estimates that on average 4.318 more ant species occur in forests than
in bogs (90% confidence interval: 2.445 to 6.192).

# References

- Stan User Guide
  [(link)](https://mc-stan.org/docs/2_18/stan-users-guide/index.html).
- **brms** documentation
  [(link)](https://mc-stan.org/users/interfaces/brms).
- Ben Lambert has a [youtube
  channel](https://www.youtube.com/channel/UC3tFZR3eL1bDY8CqZDOQh-w)
  with a student’s guide to Bayesian statistics, a [short
  course](https://ben-lambert.com/biology/) and [detailed
  slides](https://ben-lambert.com/bayesian-lecture-slides/) on Bayesian
  statistics.
- **rstanarm** vignettes
  [(link)](https://mc-stan.org/rstanarm/articles/)
- some more useful packages that can work with brms objects
  - **posterior** useful tools for fitting Bayesian models or working
    with Bayesian model output [(link)](https://mc-stan.org/posterior/)
  - **projpred** selection of the most important explanatory variables
    in your model via projection prediction
    [(link)](https://mc-stan.org/projpred/)
  - **performance** bringing together techniques for model quality and
    fit [(link)](https://easystats.github.io/performance/)

# Likelihood function for the data (log)
ll.fun <- function(beta_0, beta_1, tau = 0.2){
  ll <- sum(dnorm(x = y, mean = beta_0 + beta_1 * x,
                  sd = sqrt(1 / tau), log = TRUE))
  return(ll)
}

# prior function (uninformative) (log)
prior.fun <- function(beta_0, beta_1, tau = 0.2){
  lp <- dnorm(x = beta_0, mean = 0, sd = sqrt(1/10^-6), log = TRUE) +
    dnorm(x = beta_1, mean = 0, sd = sqrt(1/10^-6), log = TRUE) +
    dgamma(x = tau, shape = 0.001, rate = 0.001, log = TRUE)
  return(lp)
}

# MCMC - metropolis algorithm

# N = lengte van de MCMC
# sigma = grootte van de stappen in de markov chain
# init_b0 en init_b1 = initiële waarden voor beta_0 en beta_1

MCMC_metro <- function(x, y, N = 20, sigma = 1, init_b0, init_b1){

  set.seed(56)  # Optioneel, om bij iedereen hetzelfde resultaat te bekomen.
  # We maken een lege dataframe om de output in te bewaren
  mcmc <- data.frame(iter = 1:N,     # positie in de markov chain
                     beta_0 = NA,    # intercept
                     beta_1 = NA,    # helling
                     tau = NA,       # 1/standard deviation
                     post = NA, # posterior
                     accept = NA)    # stap wel (1) of niet (0) geaccepteerd.

  mcmc$beta_0[1] <- init_b0
  mcmc$beta_1[1] <- init_b1
  mcmc$tau[1] <- 0.2  # init_tau

  # Berekening van de posterior voor de startwaarde
  mcmc$post[1] <- ll.fun(beta_0 = mcmc$beta_0[1],
                         beta_1 = mcmc$beta_1[1],
                         tau = mcmc$tau[1]) +
                  prior.fun(beta_0 = mcmc$beta_0[1],
                            beta_1 = mcmc$beta_1[1],
                            tau = mcmc$tau[1])
  mcmc$accept[1] <- 1  # De initiële parameterwaarde altijd accepteren

  for(i in 2:N){

    # Kies een nieuwe waarde uit een normale verdeling met
    # mean = vorige parameterwaarde en sd = sigma (stapgrootte)
    new_beta_0 <- rnorm(1, mean = mcmc$beta_0[i - 1], sd = sigma)
    new_beta_1 <- rnorm(1, mean = mcmc$beta_1[i - 1], sd = sigma)
    #new_tau <- rnorm(1, mean = mcmc$tau[i - 1], sd = 0.1)
    new_tau <- mcmc$tau[i -1]  #we houden tau fixed voor de eenvoud

    # Bereken de posterior voor de nieuwe parameterwaarden
    new_post <- ll.fun(beta_0 = new_beta_0,
                       beta_1 = new_beta_1,
                       tau = new_tau) +
                prior.fun(beta_0 = new_beta_0,
                          beta_1 = new_beta_1,
                          tau = new_tau)

    # Bereken de ratio van de posterios (in de log schaal is dit het verschil)
    log.ratio <- new_post - mcmc$post[i-1]

    # Als de ratio > 0 => nieuwe posterior beter = > accepteren
    if (log.ratio > 0) {
      mcmc$accept[i] <- 1
      # Als log.ratio <= 0 is de kans op accepteren afhankelijk van de log.ratio
    }else{
      if (rbinom(n = 1, size = 1, prob = exp(log.ratio))) {
        mcmc$accept[i] <- 1
      }else{
        mcmc$accept[i] <- 0
      }
    }

    # De nieuwe waarde wordt geaccepteerd
    if(mcmc$accept[i]) {
      mcmc$beta_0[i] <- new_beta_0
      mcmc$beta_1[i] <- new_beta_1
      mcmc$tau[i] <- new_tau
      mcmc$post[i] <- new_post
    }else{
      # De nieuwe waarde wordt niet geaccepteerd (de oude behouden)
      mcmc$beta_0[i] <- mcmc$beta_0[i-1]
      mcmc$beta_1[i] <- mcmc$beta_1[i-1]
      mcmc$tau[i] <- mcmc$tau[i-1]
      mcmc$post[i] <- mcmc$post[i-1]
    }
  }
  return(mcmc = mcmc)
}

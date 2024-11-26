
data {
  int<lower=1> N;                   // sample size
  vector[N] habitat_obs;            // habitat
  array[N] int<lower=0> sp_rich;    // outcome variable: number of ants
}

parameters {
  real intercept_rich;              // intercept
  real habitat_effect;              // slope
}

model {
  // priors
  intercept_rich ~ normal(0, 1);
  habitat_effect ~ normal(0, 1);

  // "posterior", "likelihood", ... give it a name!
  sp_rich ~ poisson_log(intercept_rich + habitat_effect * habitat_obs);

}

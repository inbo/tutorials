#https://learnb4ss.github.io/learnB4SS/articles/install-brms.html
#first install rstan (more detailed instructions here https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started )
install.packages("rstan", repos = "https://cloud.r-project.org/", dependencies = TRUE)
#verify the installation with:
example(stan_model, package = "rstan", run.dontrun = TRUE) #this might take a while the first time
#if the example works, install brms:
install.packages("brms")

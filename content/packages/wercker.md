+++
title= "Continuous integration"
date= 2018-03-23T11:23:07+01:00
description = "How to set up continuous integration for a package with Wercker"
+++

## Introduction

While creating a R package, 'Check' on the build pane allows to test the package for 'mistakes', but we have to hit the button actively.  Continuous integration allows to do similar checks automatically in a 'controlled environment' (Docker image) after each commit to the repository.  Using different Docker images allows to test the stability of the package on different versions of R and/or dependent packages, or on different systems (UNIX, Windows).  One could also define the exact checks to be runned.  The status checks (e.g. passing the checks or a certain coverage of the unit tests) can moreover be used as a precondition to merge a new version to a certain branch in the git-repository.

There are 3 systems for continuous integration:

- Travis, which is often used and runs on a UNIX machine

- Wercker, which also runs on a UNIX machine (which we present below)

- Appfire, which runs on a windows machine and can automatically release targeted versions to drat

## Set up continuous integration with Wercker

There are 2 major steps to set up continuous integration:

- create a Wercker.yml file in the package

- add the application (package) to Wercker.com

To be able to add a package to Wercker, one must have administrator rights on the package repository on Github.

The Wercker test environment can only be set up if the file Wercker.yml is commited to the repository, but Wercker is triggered to start checking when the application is added to wercker.com (giving an error if Wercker.yml is not commited yet).

### Wercker.yml

Add a file 'Wercker.yml' in the root of the package with:

- box: reference to a package with a Docker image that is used as a test environment.  If no specific version is specified, only the last master version is used.  Possible input: inbobmk/rstable (https://github.com/inbo/Rstable), another possibility are the rocker images (https://github.com/rocker-org/rocker).

- build: 

    - different steps to be runned, e.g. inbobmk/r-check, inbobmk/r-coverage, inbobmk/r-lint or jimhesser/r-check (https://github.com/jimhester/wercker-step-r-check)

    - if not all scripts are available in the docker image, code to add packages can be added as a first step

- after a build pipe, one can also add a deploy-pipe

An example of a simple Wercker.yml-file:

    box: inbobmk/rstable

    build:

        steps:

            - script:

                code: Rscript -e "install.packages(c('DT','plotly'), repos = 'https://cran.rstudio.com')"

            - inbobmk/r-check

            - inbobmk/r-coverage

            - inbobmk/r-lint

### Wercker.com

To add the application to http://www.wercker.com/:

- log in on the website (easiest is to log in via github) and create a username

- click on the '+' button on the right top and choose 'add application'

- select your username (next)

- select the repository of your package (next)

- choose the recommended option (next)

- you could choose to make the results publicly available and 'create'

After creation, one can under 'options':

- pick a color for the package (useful when adding more than one package)

- read information on Webhook (ensures communication between github, Wercker and other services)

- status badge: rmd-code that allows you to add Wercker-results to your own code (e.g. copy this link to the readme-file)

Hitting the personal symbol on the right top and choosing Settings allows to adjust if and when to receive email notifications.

### Code coverage

A useful tool to visualise the coverage of the package by unit tests, is codecov.  It can be added to the Wercker application by:

- login to http://www.codecov.io (via github) and copy the token

- add it to the tab Environment on http://www.wercker.com/: Key = CODECOV_TOKEN, Value = (paste the token) and tick 'Protected' to prevent it from being changed

### ¨Protected branches

Adjusting which branch tot protect by disabling force pushing and require status checks before merging, could be done on github in the tab settings/Branches.  One could require status checks to ensure all tests are passing before merging, one could require a certain (absolute) % of code coverage or one could require that the code coverage is equal to or higher than the code coverage of the previous commit (which means that adding code requires additional unit tests).

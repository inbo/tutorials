---
title: "Wercker"
date: 2018-03-23T11:23:07+01:00
description: "How to set up continuous integration for a package with Wercker"
weight: 2
---

## Set up continuous integration with Wercker

There are 2 major steps to set up continuous integration:

- create a `wercker.yml` file in the package
- add the application (package) to Wercker.com

To be able to add a package to Wercker, one must have administrator rights on the package repository on Github.

The Wercker test environment can only be set up if the file `wercker.yml` is commited to the repository, but Wercker is triggered to start checking when the application is added to wercker.com (giving an error if `wercker.yml` is not commited yet).

### wercker.yml

Add a file "wercker.yml" in the root of the package with:

- **box:** reference to a package with a [Docker](https://www.docker.com/) image that is used as a test environment.  If no specific version is specified, only the last master version is used. Which Docker image to use?
    - `inbobmk/rstable` which is an image with stable versions of R and a large number of packages (see the [README](https://github.com/inbo/Rstable)). Most of the packages which are often used at INBO are available. The version of the packages is roughly fixed to to date on which the R version in the Docker image was upgraded.
    - `rocker/verse` (https://hub.docker.com/r/rocker/verse/) which has the R, [devtools](https://www.rstudio.com/products/rpackages/devtools/) and all [tidyverse](https://www.tidyverse.org/) packages. The latest version of the image contains the latest version of the packages.
- **build:**
    - different steps to be runned
        - `inbobmk/r-check`: runs R CMD check but assumes that all dependencies are installed. Use this in combination with `inbobmk/rstable` in case you want to check your package against a stable set of packages.
        - `jimhester/r-check`: installs all missing dependencies on the fly and then runs R CMD check. This will install the latest version of the dependencies.
        - `inbobmk/r-coverage`: check which lines in the code are covered by unit tests and which are not. See our page on [code coverage](codecov.html) for more details. This assumes that the `covr` package is installed.
        - `jimhester/r-coverage`: install `covr` and run the code coverage
        - `inbobmk/r-lint`: this check the [style](http://r-pkgs.had.co.nz/style.html) of your code. Good coding style is like using correct punctuation. You can manage without it, but it sure makes things easier to read. It assumes the [`lintr`](https://github.com/jimhester/lintr) installed.
        - `jimhester/r-lint`: installs the `lintr` package and check the style of the code
    - steps are run along their order in the yaml file
    - the exection will stop when a step fails
    - if not all package are available in the docker image, code to install packages have to be added as a first step
- after a build pipe, one can also add a deploy-pipe

An example of a simple wercker.yml-file:

    box: inbobmk/rstable
    build:
        steps:
            - script:
                code: Rscript -e "install.packages(c('DT','plotly'))"
            - inbobmk/r-check
            - inbobmk/r-coverage
            - inbobmk/r-lint

### Wercker.com

To add the application to http://www.wercker.com/:

- log in on the website (easiest is to log in via github) and create a username
- click on the "+" button on the right top and choose "add application"
- select your username (next)
- select the repository of your package (next)
- choose the recommended option (next)
- you could choose to make the results publicly available and "create"

After creation, one can under "options":

- pick a color for the package (useful when adding more than one package)
- read information on Webhook (ensures communication between github, Wercker and other services)
- status badge: markdown-code that allows you to add Wercker-results to your own code (e.g. copy this link to the README-file)

Hitting the avatar on the top right and choosing "Settings" allows to adjust if and when to receive email notifications.

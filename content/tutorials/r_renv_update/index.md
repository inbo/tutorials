---
title: "Updating the renv environment of an R project"
description: "Updating R and packages in an renv environment"
authors: [florisvdh]
date: 2021-06-09
categories: ["r"]
tags: ["renv", "r", "packages"]
---

## What is `renv`?

`renv` is an R package that provides tools to save the version of R and all packages used in a particular directory with R code (e.g. an RStudio project directory), and to reproduce (recreate) this environment on another (or your future) system.
Because software versions can have important effects on the results of your work, it is important to be able to reproduce versions.

## Start using `renv`

For general advice on `renv` setup and usage, see <https://rstudio.github.io/renv>.
The functions you mostly need, are `renv::init()`, `renv::snapshot()`, `renv::status()`, `renv::restore()` (always put `renv::restore()` in the beginning of your R code).

When using git version control, you should commit all new untracked files created by `renv::init()`.
The most important file is `renv.lock`, which defines R and package versions of the project.

## Aim of this tutorial

This tutorial addresses the specific aspect of how to update R and packages in an `renv` environment and store that information in `renv.lock`.
It is typically needed while elaborating a project, because you wish to use the latest available packages and R version.

## Procedure

Our recommended approach is:

1. Update all installed packages in the default user R library of your system, i.e. outside an `renv` environment.
See [this](../../installation/user/user_install_r) tutorial.
In this way these package versions will need to be downloaded and installed only once.
You may also want to update packages from other sources, such as GitHub: use `remotes::install_github()`.
1. Update packages, and possibly R, in a project `renv` environment, and store the new state in `renv.lock`.

**To apply step 2, choose the applicable situation below.**
**We assume you already applied step 1!**

### Only updating packages (keeping same R version)

Within the project's R session (with `renv` activated):

```r
renv::upgrade() # upgrades renv, if new version is available
renv::update() # updates packages from CRAN and GitHub, within the project
renv::snapshot() # inspect the message before confirming to overwrite renv.lock
```

Note:

- To update packages in the `renv` environment, `renv` will take package copies of your user R library if the required versions are available there.
Note that the copies are stored in a [global `renv` package cache](https://rstudio.github.io/renv/articles/renv.html#cache-1), i.e. a central directory where `renv` stores packages versions for all projects where it is used, for each R `x.y` version, on an as-needed basis.
The project environment itself is based on symlinks to the particular package versions in the cache.

If you use version control, then don't forget to effectively commit the changed `renv.lock` file.

### Updating R and packages

This procedure is relevant to the `x.y` upgrades, not to the patches.
That is, when `x` or `y` change in R version `x.y.z`.
When only `z` has changed (i.e. a 'patch'), previous procedure still applies. 

Below procedure assumes:

- you already installed the new R version on your system;
- you already updated your R packages in the default user R library of your system;
- you have now started the project's R session with the new R version (with `renv` activated).

```r
renv::upgrade() # upgrades renv, if new version is available
renv::hydrate(update = "all") # populates the renv cache with copies of up to 
                              # date package versions, needed by the project
  # renv::update() should have no effect now, but running it as well won't harm 
  # to check that all packages are indeed up to date
renv::snapshot() # inspect the message before confirming to overwrite renv.lock
```

If you use version control, then don't forget to effectively commit the changed `renv.lock` file.

---
title: "Continuous integration"
date: 2017-10-18T00:25:24+02:00
description: "Introduction on continuous integration"
weight: 10
---

[Continuous integration](https://en.wikipedia.org/wiki/Continuous_integration) is a software development practice were changes to the code can be merged fast into the production version of the code. To ensure the quality of the code, the code should be checked as much as possible and the checks should be run automated.

`R CMD check` is a tool available in `R` to run a large number of checks on a package. See http://r-pkgs.had.co.nz/check.html for an overview of these checks. We recommend to run `R CMD check` with the `--as-cran` flag. This enforces the same extensive checks as required for package which are published at the [Comprehensive R Archive Network (CRAN)](https://cran.r-project.org/web/packages/policies.html). It is highly recommended that a developer makes sure that all these checks passes on his machine prior to pushing the code to the git repository. So the developer should run the checks on this machine and fix all errors and warnings.

However, we have no guarantee that all checks were run by the developer and neither that the code passed all checks. This is were automated build systems come into play. Those build systems will be trigged by GitHub whenever a developer pushes changes. Then the build system will check-out that new version and automatically run all the checks. Furthermore, it will report the results (success or failure) back to GitHub and the maintainer of the project. This works great with a workflow in which the users don't push changes into the `master` branch but into `feature` branches. The changes from a `feature` branch should only be merged into the `master` via pull requests. The pull request should only be merged when all the checks pass. GitHub makes it easy to enforce this using so called [protected branches](https://help.github.com/articles/about-protected-branches/). Different kinds of protection can be enforced: don't delete the branch, don't (force) push to the branch, only merge when the relevant checks pass, ...

At INBO we currently use 3 systems for continuous integration on R packages:

- Travis, which is often used and runs on a linux machine
- Wercker, which also runs on a linux machine
- AppVeyor, which runs on a windows machine and can automatically release targeted versions to our [drat](https://inbo.github.io/drat)

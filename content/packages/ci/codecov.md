---
title: "Code coverage"
date: 2017-10-18T00:25:24+02:00
description: "Setting up code coverage"
weight: 9
---

`R CMD check` has a large set of generic quality tests on a package. It is impossible to create generic tests that check the content of the package. E.g. does each function returns sensible results. However, `R CMD check` does run a set [unit tests](https://en.wikipedia.org/wiki/Unit_testing). These are small pieces of code written by the package developer which test the output of a specific function under specific circumstances. We highly recommend the [`testthat`](http://testthat.r-lib.org/) framework for writing unit tests.

## Combining code coverage and Wercker

A useful tool to visualise the coverage of the package by unit tests, is [codecov](http://www.codecov.io). It can be added to the Wercker application by:

- login to http://www.codecov.io (via GitHub) and copy the token
- add it to the tab Environment on http://www.wercker.com/: Key = CODECOV_TOKEN, Value = (paste the token) and tick 'Protected' to prevent it from being viewed. This makes it secure.

Note that is only makes sense when the `wercker.yaml` has a `inbobmk/r-coverage` or `jimhester/r-coverage` step.

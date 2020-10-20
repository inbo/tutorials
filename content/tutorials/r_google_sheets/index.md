---
title: "Read data from Google sheets"
description: "Extracting data directly from Google spreadsheets"
author: "Damiano Oldoni"
date: 2020-10-19
categories: ["r"]
tags: ["google", "r", "spreadsheet"]
---

## `googlesheets4`

The R package [googlesheets4](https://googlesheets4.tidyverse.org/) provides the functionality to read and write data from a Google sheet.

This package is very well documented, so we just have to provide you with the right links:

- [read sheets](https://googlesheets4.tidyverse.org/articles/articles/read-sheets.html)
- [write sheets](https://googlesheets4.tidyverse.org/articles/articles/write-sheets.html)

A complete list of vignettes can be found in the [Articles page](https://googlesheets4.tidyverse.org/articles/index.html).

## `googlesheets4` vs `googlesheets`

The package `googlesheets4` is the follower of [`googlesheets`](https://github.com/jennybc/googlesheets/blob/master/README.md) which doesn't work anymore as it is built on the outdated Sheets v3 API.
If you still have code using this package, you will get this error:

> Sign in with Google temporarily disabled for this app

Please, consider to update your code by using the new package, [googlesheets4](https://googlesheets4.tidyverse.org/). Good luck!

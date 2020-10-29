---
title: "Tutorial setup_codingclub_session()"
description: "Tutorial on how to use setup_codingclub_session() to load data and scripts to use during coding clubs."
author: "Emma Cartuyvels"
date: 2020-10-26
categories: ["r"]
tags: ["data", "r"]
---


```{r setup, include=FALSE}
knitr::opts_chunk$set(eval = FALSE)
```


Before each coding club you will usually have to download some data and some scripts.
This can be done manually by going to each of the GitHub pages but it is much easier to use the `setup_codingclub_session()` function of the `inborutils` package.

To begin make sure that you have the latest version of `inborutils` installed by running the following code:

```{r}
if (!"remotes" %in% rownames(installed.packages())) {
  install.packages("remotes")
}
remotes::install_github("inbo/inborutils")
```

Next load the library:

```{r}
library(inborutils)
```

The function takes four arguments with the following default settings:
 - session_date which is set to the present day
 - root_dir which is set to "."
 - src_rel_path which is set to "src"
 - data_rel_path which is set to "data"

```{r}
setup_codingclub_session(
  session_date = format(Sys.Date(), "%Y%m%d"),
  root_dir = ".",
  src_rel_path = "src",
  data_rel_path = "data"
)
```

So when we just run the function like this:

```{r}
setup_codingclub_session()
```

We will get the coding club materials for the date of today (if and only if today there is a coding club, otherwise there are no materials) and these materials will be saved in the `src` and `data` folders of the current working directory.


If you want to get the coding club materials for a past date, use the "YYYYMMDD" format, e.g.: 

```{r}
setup_codingclub_session("20200825")
```

If your folders are not named "src" or "data" (although we would recommend you name them as such) but for example "scripts" and "data_codingclub" you can specify this:

```{r}
setup_codingclub_session("20200326",
                         src_rel_path = "scripts",
                         data_rel_path = "data_codingclub")

```

---
title: "Styleguide R code"
description: "This style guide is a recommendation for all R code written for the Research Institute for Nature and Forest (INBO). The goal of this style guide is twofold. First of all applying the guidelines will result in readable code. Secondly, it is much easier to work together on code when everyone is using the same guidelines."
authors: [thierryo]
date: 2017-10-18T16:01:34+02:00
categories: ["styleguide"]
tags: ["styleguide", "r"]
output: 
  md_document:
    preserve_yaml: true
    variant: gfm+footnotes
---

## Scope

This style guide is a recommendation for all R code written for the
Research Institute for Nature and Forest (INBO). The goal of this style
guide is twofold. First of all applying the guidelines will result in
readable code. Secondly, it is much easier to work together on code when
everyone is using the same guidelines. It is likely that applying these
guidelines will have consequences on the current style used by many R
users at INBO. Therefore this style guide should be applied within
reason.

1.  Don’t apply the style guide to existing code.
2.  R users are free to apply the style guide to new personal R code.
3.  Using the style guide is highly recommended for new or revised R
    code intended to be distributed and used by other R users.
4.  The style guide is mandatory for new or revised R packages
    distributed by INBO.

Please note that the RStudio editor has some handy features that
automatically highlights errors against the code style in a non
intrusive way. **RStudio hints** in this document are the instructions
to activate these diagnostics in RStudio.

## Syntax

**RStudio hint**: *Tools &gt; Global options &gt; Code &gt;
Diagnostics*: Check everything

### General

-   lines should not exceed 80 characters
    -   split the command over multiple lines if the command is longer
        than 80 characters
    -   **RStudio hint**: *Tools &gt; Global options &gt; Code &gt;
        Display*: Check *Show margin* and set *Margin column* to 80
-   object names should be meaningful
-   object names should not exceed 20 characters
-   object names should be lowercase
-   use `_` to separate words in object names
    -   function names with a single dot are allowed
-   use double quotes (`"`) around characters and not single quotes
    (`'`)
-   don’t add commented code
    -   use version control if you want to keep old versions of code

``` r
# Good
example_text <- example_function(
  first_argument = "Some text",
  second_argument = "More text"
)

# Bad
some.really.long.dot.separated.name <- MyCoolFunction(FirstArgument = 'Some text', second.argument = 'More text')
```

### Whitespace

    naturallanguagesusewhitespaceandpunctuationtomaketextsmorereadableprogramminglanguagesarenoexceptiontothisrule

Natural languages use whitespace and punctuation to make texts more
readable. Programming languages are no exception to this rule.

-   don’t use tabs, use two spaces instead
    -   **RStudio hint**: *Tools &gt; Global options &gt; Code &gt;
        Editing*: Check *Insert spaces for tab* and set *Tab width* to 2
-   no space before a comma, one space after a comma
-   one space before and after an infix operator (`+`, `-`, `*`, `/`,
    `^`, `&`, `|`, `%%`, `%/%`, `%*%`, `%in%`, …)
-   no spaces a the end of a line
    -   **RStudio hint**: *Tools &gt; Global options &gt; Code &gt;
        Saving*: Check *Strip trailing horizontal whitespace when
        saving*
-   end the script file with a single blank line
    -   **RStudio hint**: *Tools &gt; Global options &gt; Code &gt;
        Saving*: Check *Ensure that source files end with newline*

### Assignments

-   only create an object when you will use it later on
-   always use `<-` for assignment
-   always put the new variable on the left and never use `->`
-   use `=` only for passing arguments in a function
-   at least one space before and at least one space after `<-` and `=`
    -   use multiple spaces if it improves readability

``` r
# Good
x <- data.frame(z = 1:10)
summary(x)

# Bad
x=data.frame(z<-1:10)
5 -> a

# Improved readability example
a   <-   5
ab  <-  10
abc <-   7
d   <- 245
```

### Brackets

R uses three types of brackets: round `(...)`, square `[...]` and curly
`{...}`.

-   no spaces after opening a bracket
-   no spaces before closing a bracket
-   no spaces before opening a bracket except:
    -   one space with control flow functions (`if`, `else`, `for`,
        `while`)
-   no spaces after closing a bracket except:
    -   one space with control flow functions (`if`, `else`, `for`,
        `while`)
-   `{` should not start on a newline and is always the end of a line
-   apply indentation when splitting long text inside brackets over
    multiple lines

``` r
# Good
y <- seq(0, 2)
if (max(y) <= 10) {
  x <- 1
} else {
  x <- 2
}
sapply(
  y,
  function(x){
    return(x)
  }
)

# Bad
y <- seq (0, 2   )
if(   max( y ) <= 10    )        
{ x <- 1 } else 
{ x <- 2 }
sapply( y , function ( x ) { return(x)})
```

### Special cases and exceptions

-   selecting rows with square brackets `df[selection, ]`
    -   this results in two conflicting rules
        1.  a single space after a comma
        2.  no space before a bracket
    -   solution in case of a short command: add `# nolint` after the
        command
        -   `df[selection, ] # nolint`
    -   solution in case of a long command: split the command over
        several lines

``` r
# Good
relevant_subset <- original_dataframe[
  original_dataframe$x > some_value | original_dataframe$y < some_other_value,
]
# Recommended dplyr alternative
relevant_subset <- original_dataframe %>%
  filter(x > some_value | y < some_other_value)

# Bad
relevant_subset <- original_dataframe[original_dataframe$x > some_value | original_dataframe$y < some_other_value, ] # nolint
```

-   a really long text
    -   text shorter than 80 characters but passed the 80 character
        limit due to the indentitation
        -   solution: remove all indentation
    -   text longer than 80 characters
        -   solution: add `# nolint` at the end of the line
-   functions from other packages with names that don’t comply with this
    style guide
    -   solution: add `# nolint` at the end of the line

**Important notice**

Adding `# nolint` at the end of a line excludes that line from the
automatic checks for coding styles. Therefore use it only when you have
no other options.

### Functions

-   always explicitly mention `return` in functions

``` r
# Good
sum <- function(x, y) {
  z <- x + y
  return(z)
}
sum <- function(x, y) {
  return(x + y)
}

# Bad
sum <- function(x, y) {
  x + y
}
```

### Validating syntax

The code below validate the syntax for an R file, an RMarkdown file or
an R package.

**RStudio hint**: Running this code within RStudio will open a *Markers*
pane, indicating the filename, line number and the kind of syntax error
that occurs. Double clicking on the error will open the file at the
correct location, making it easy to rectify the problem.

Extra hint: start correcting for the last lines and work your way
forward. This leaves the line numbers of the errors intact until you
solve them.

An example to clarify this. Suppose you have an error at line 10 and an
error at line 100. Both errors are
`lines should not be more than 80 characters`, so to solve them we have
to split the lines over multiple lines.

Let say that we start with solving line 10 by splitting it over four
lines. So the old line 10 becomes the new lines 10 to 13. Hence the old
line 11 becomes the new line 14, and the old line 100 becomes the new
line 103. When we now click on the marker for line 100, RStudio will go
the current line 100 which is the old line 97. So you end up looking for
an error at the wrong position.

Starting at the back solved this issue. In the same example we would
start by solving line 100. Let’s assume we split this over two lines. So
old line 100 because new line 100 and 101. Old line 101 becomes new line
102 but more importantly **all line numbers before 100 are unchanged**.
So clicking on the marker for line 10 will take you the current line 10
which is the old line 10.

``` r
# validate a single file
lintr::lint(filename = "file.R")
lintr::lint(filename = "file.Rmd")

# validate a package
lintr::lint_package(path = ".")
```

## Documentation

### Functions

-   Add documentation above each function with `Roxygen` markup
-   Add inline comments where relevant

#### Required Roxygen tags

``` r
#' @title Title of the helpfile
#' @description Description of the function in the helpfile
#' @param define a parameter
#' @export is the function exported by the package NAMESPACE
#' @importFrom import a function from another package
```

#### Optional Roxygen tags

``` r
#' @seealso link to other functions
#' @section section title
#' @alias other name for the topic
#' @keywords a set of standardised keywords. See file.path(R.home("doc"), "KEYWORDS")
#' @inheritParams inherit the definition of parameters from another function
#' @examples a working example of the function
#' @return a description of the output from the function
```

See <http://r-pkgs.had.co.nz/man.html#roxygen-comments> for more
information on Roxygen

#### INBO extra requirements for package DESCRIPTION

-   license: MIT or GPL-3? In case of MIT a LICENSE file should be added
    and `License: MIT` to the DESCRIPTION. In case of GPL-3 it is
    sufficient to add `License: GPL-3` to the DESCRIPTION
-   list of authors in `Authors@R` format
    -   INBO is listed as copyright holder
    -   one or more roles are atributed to each person
        -   `cre`: package maintainer (only one person)
        -   `aut`: main author (at least one person)
        -   `ctb`: contributor (if relevant)
        -   `cph`: copyright holder (must be INBO)

<Authors@R>: c(person(“Els”, “Lommelen”, email =
“<els.lommelen@inbo.be>”, role = c(“aut”, “cre”)), person(“Thierry”,
“Onkelinx”, email = “<thierry.onkelinx@inbo.be>”, role = “aut”),
person(“Anja”, “Leyman”, email = “<anja.leyman@inbo.be>”, role = “ctb”),
person(family = “Research Institute for Nature and Forest (INBO)”, email
= “<info@inbo.be>”, role = “cph”))

### How-to’s

-   Add one or more how-to’s to a package
-   Add them as RMarkdown vignettes

## File structure

### R Package

#### Functions

-   all generic R functions should be distributed as an R package
-   use `devtools::create()` to start a new pacakge
    -   **RStudio hint**: *File &gt; New project &gt; New directory &gt;
        R Package*: Type the name in *Package name*
-   keep source files compact
    -   create a separate file for each function, with the file name
        equal to the function name. This makes it easy to find the
        correct source file.
    -   exception: very short auxilary functions with related
        functionality
        -   related functions can be bundled into one R script
        -   file name is either equal to the most important function or
            describes the related functionality
-   split large functions into several subfunctions

#### Scripts

-   place scripts in the `inst` folder
    -   the scripts will be available for the user after installing the
        package
    -   the location of the scripts can be found with
        `system.file("script-name.R", package = "yourpackage")`
    -   use a relevant folder structure when adding lots of files to
        `inst`

#### Unit tests

-   use the `testthat` package for unit tests
    -   use `devtools::use_testthat()` to setup the test infrastructure
-   all unit tests are stored in `tests/testthat`
-   all files should have either a `test_` or `helper_` prefix
    -   files with `helper_` prefix contain auxiliary function for the
        tests but no tests
-   the test files will be run in alphabetical order
    -   setting the order of the files is easy by adding 3 letters to
        the prefix (eg. `test_aaa_`, `test_baa`, `test_zzz_`)
    -   3 letters offers quite some flexibility to insert new files at
        the correct location without having to rename at lot of files.
        If the first file is `test_aaa_` and the second `test_baa`, they
        you can 675 files between the two.
-   unit test files can be larger than source files
-   a unit test file can contain tests for several functions in case the
    functions are strongly related (e.g. subfunctions) and reuse test
    cases
-   each package should contain the unit for coding style as listed
    below
    -   store this in a file `tests/testthat/test_zzz_coding_style.R`
    -   add this file to `.gitignore`
        -   the coding style will be tested separately when using
            continuous integration

``` r
if (requireNamespace("lintr", quietly = TRUE)) {
  context("lints")
  test_that("Package Style", {
    lintr::expect_lint_free()
  })
}
```

#### Data

To make data available for users, they can be stored in a package in 3
different file types:

-   plain text file (`.txt`, `.csv`,…): use if
    -   your package is under version control and the data often change
    -   you want to keep track on the changes using version control
    -   consider to keep row and column order fixed
-   binary file (`.Rdata` or `.rda`): use if
    -   your dataset is large and data do not change between different
        versions
    -   you are not interested in keeping track on the exact changes
    -   you want to keep the exact format of the data (e.g. factors with
        levels) (possible in plain text with
        [git2rdata](https://inbo.github.io/git2rdata))
-   code (`.r`) generating a table: use if the data can easily be
    generated with code

Data can be stored in 3 places:

-   to make data available for loading and parsing examples, store them
    in the folder `inst/extdata`. Access this data with
    `system.file("xyz", package = "abc")`. Possible for all data types.
-   to make data available to package users, store them in the `data`
    folder. Access this data with `data(xyz)`. Possible only for data
    formats that can be handled by `data()`. Binary `.rda`-files can be
    stored by using `usethis::use_data(xyz)`.
-   to keep data internal for use by your functions, store them in the
    file `R/Sysdata.rda` by using
    `usethis::use_data(xyz, internal = TRUE)`. Access this data with
    `abc::xyz`.

(In the above examples, `xyz` are data and `abc` is the package in which
they are stored.)

Add scripts for generating these data in the folder `data-raw` and
create this folder by using `usethis::use_data_raw()` (ignores folder
during build).

### R script

-   group a long set of commands with similar functionality into a
    dedicated function
    -   e.g. `prepare_data()`, `do_analysis()`, `create_figure()`, …
-   place the user defined functions in a separate file which you
    `source()` into the main script
    -   it is better to use the same file structure as an R package
    -   consider writing a simple package in case you have a lot of
        functions

### RMarkdown

-   each chunk has only one output (figure, table, summary, …)
-   don’t mix (heavy) calculations and output in the same chunk: this is
    more interesting for caching the results
-   give chunks a relevant name: this make debugging easier and file
    name of figures and Bookdown label will be based on the chunk name
-   avoid writing code that generates Markdown
    -   use (parametrised) child documents instead
-   use the bookdown version for long reports: this makes it easy to
    split a long report into several child documents

## Recommended packages

### Data import

-   `readr`: import text files
-   `readxl`: import Excel files
-   `googlesheets`: import Google Sheets
-   `DBI`: connect to databases PostgreSQL, SQLite, MySQL, Oracle, …
-   `RODBC`: connect to databases SQL Server, Access

### Data manipulation & transformation

-   `dplyr`:
    -   subsetting observations
    -   subsetting variables
    -   changing variables
    -   aggregation
    -   combining dataframes
-   `tidyr`:
    -   changing a dataframe from wide to long format and vice versa
    -   nesting and unnesting dataframes
    -   splitting a single variable into multiple variables

### Graphics

-   `ggplot2`:all static graphics, charts and plots
-   `INBOtheme`: INBO corporate identity for `ggplot2` graphics

### Quality control

-   `lintr`: checking coding style
-   `testthat`: writing unit tests
-   `covr`: check which part of the code is not covered by unit tests

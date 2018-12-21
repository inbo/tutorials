---
title: "Read data from INBO databases (SQL Server) with R(ODBC)"
description: "Database access using R"
author: "Stijn Van Hoey"
date: 2017-02-03
categories: ["r"]
tags: ["database", "r", "data"]
output: 
    md_document:
        preserve_yaml: true
        variant: markdown_github
---



To query data from a SQL database that is already accessible using MSAccess, such a database is also accessible from R using the package [RODBC](https://cran.r-project.org/web/packages/RODBC/index.html). This package enables the link in between R and the (remote) database. After installation of the package (`install.packages('RODBC')`), the package can be loaded:


```r
library(DBI)
library(glue)
library(tidyverse)
```

For Windows users, the most important element is to know the so-called `DSN` (i.e. a registered Data Source Name). Actually, it is just the name of the database as it is known by your computer (and MS Access). The easiest way to check the `DSN` is to check the [*registered ODBC connections*](http://www.stata.com/support/faqs/data-management/configuring-odbc-win/) in the administrator tools menu. 

For Dutch-speaking Windows 7 users: 

    > Kies in het Configuratiescherm van Windows de optie Systeembeheer > Gegevensbronnen (ODBC). De optie Systeembeheer verschijnt in de categorie Systeem en onderhoud.

You should see a list similar to the list underneath, with the names of the available DSN names enlisted:
![odbc-connecties](./database-R/odbc_gegevensbron.png)

An alternative way to check the DSN name of a database already working on with Access, is to check the DSN inside MS Access (in dutch, check menu item *Koppelingsbeheer*): 
![access-dsn](./database-R/access_dsn.png)

For example, the DSN name `UserFlora` or `Cydonia-prd` can be used to query these databases and extract data from it with similar queries to the one used in MSAccess. First of all, the connection with the database need to be established, by using the `odbcConnect` function, providing the DSN name as argument:

For Windows users:


```r
my_connection <- odbcConnect("UserFlora")
```

For Linux/Mac users:


```r
my_connection <- DBI::dbConnect(odbc::odbc(), 
                                .connection_string = "Driver={ODBC Driver 17 for SQL Server};Server=inbo-sql07-prd.inbo.be;Database=D0021_00_userFlora;Trusted_Connection=yes;")
print(my_connection)
```

```
## <OdbcConnection> INBO\stijn_vanhoey@INBO-SQL07-PRD\LIVE
##   Database: D0021_00_userFlora
##   Microsoft SQL Server Version: 13.00.5216
```

Once this connection is successfully established, the database can be queried. 

**Remark for linux users:** When working in Linux, this setup requires an active *kerberos* session. More information about the setup and functionality will be provided in an upcoming tutorial.

## Get a complete table from the database

The function `dbReadTable` can be used to load an entire table from a database. For example, to extract the `tblTaxon` table from the flora database:


```r
rel_taxa <- dbReadTable(my_connection, "relTaxonTaxonGroep")
head(rel_taxa) %>% knitr::kable()
```



| ID| TaxonGroepID| TaxonID|
|--:|------------:|-------:|
|  1|            4|       1|
|  2|            4|       2|
|  3|            4|       3|
|  4|            4|       4|
|  5|            4|       5|
|  6|            4|       6|

with the connection `my_connection` made earlier is used as the first argument, the table name is the second argument.

**Remark:** If you have no idea about the size of the table you're trying to load from the database, this could be rather tricky and cumbersome. Hence, it is probably better to only extract a portion of the table using a query.

## Execute a query to the database

The function `dbGetQuery` provides more flexibilty as it can be used to try any SQL-query on the database. A complete introduction to the SQL language is out of scope here. We will focus on the application and the reusage of a query.


```r
meting <- dbGetQuery(my_connection, paste("SELECT TOP 10 * FROM dbo.tblMeting", 
                                          "WHERE COR_X IS NOT NULL"))
head(meting) %>% knitr::kable()
```



|  ID| WaarnemingID| TaxonID|MetingStatusCode |  Cor_X|  Cor_Y|CommentaarTaxon |CommentaarHabitat |CREATION_DATE |CREATION_USER |UPDATE_DATE |UPDATE_USER |
|---:|------------:|-------:|:----------------|------:|------:|:---------------|:-----------------|:-------------|:-------------|:-----------|:-----------|
|   2|        21748|    3909|GDGA             | 109948| 185379|NA              |NA                |NA            |NA            |NA          |NA          |
|  14|        45523|    3909|GDGA             | 127708| 179454|NA              |NA                |NA            |NA            |NA          |NA          |
|  15|       124394|    3909|GDGA             | 109424| 192152|NA              |NA                |NA            |NA            |NA          |NA          |
|  23|        38561|    3909|GDGA             | 128290| 179297|NA              |NA                |NA            |NA            |NA          |NA          |
|  24|       126500|    3909|GDGA             |  98714| 178373|NA              |NA                |NA            |NA            |NA          |NA          |
| 173|        73725|    3909|GDGA             | 102612| 189891|NA              |NA                |NA            |NA            |NA          |NA          |

## Create and use query templates

When you regularly use similar queries, with some minimal alterations, you do not want to copy/paste each time the entire query. It is prone to errors and you're script will become verbose. It is advisable to create query *templates*, that can be used within the `dbGetQuery` function. 

Consider the execution of the following query. We are interested in those records with valid X and Y coordinates for the measurement, based on a given dutch name:


```r
subset_meting <- dbGetQuery(my_connection, 
    "SELECT meet.COR_X
    	 , meet.Cor_Y
    	 , meet.MetingStatusCode
    	 , tax.NaamNederlands
    	 , tax.NaamWetenschappelijk
    	 , waar.IFBLHokID
    FROM  tblMeting AS meet
    	LEFT JOIN tblTaxon AS tax ON tax.ID = meet.TaxonID
    	LEFT JOIN tblWaarneming AS waar ON waar.ID = meet.WaarnemingID
    WHERE meet.Cor_X IS NOT NULL
    	AND meet.Cor_X != 0
    	AND tax.NaamNederlands LIKE 'Wilde hyacint'")
```

```
## Error in new_result(connection@ptr, statement): external pointer is not valid
```

```r
head(subset_meting) %>% knitr::kable()
```



|  COR_X|  Cor_Y|MetingStatusCode |NaamNederlands |NaamWetenschappelijk                             | IFBLHokID|
|------:|------:|:----------------|:--------------|:------------------------------------------------|---------:|
|  88720| 208327|GDGA             |Wilde hyacint  |Hyacinthoides non-scripta (L.) Chouard ex Rothm. |     11195|
|  24106| 199925|GDGA             |Wilde hyacint  |Hyacinthoides non-scripta (L.) Chouard ex Rothm. |      9601|
| 103111| 190915|GDGA             |Wilde hyacint  |Hyacinthoides non-scripta (L.) Chouard ex Rothm. |      6990|
| 118123| 183942|GDGA             |Wilde hyacint  |Hyacinthoides non-scripta (L.) Chouard ex Rothm. |      5672|
| 106107| 182343|GDGA             |Wilde hyacint  |Hyacinthoides non-scripta (L.) Chouard ex Rothm. |      5217|
| 105765| 180785|GDGA             |Wilde hyacint  |Hyacinthoides non-scripta (L.) Chouard ex Rothm. |      4830|

If we need this query regularly, but each time using a different `tax.NaamNederlands` (only the name changes), it is worthwhile to invest some time in the creation of a small custom function that uses this query as a template. Let's create a function `flora_records_on_dutch_name` that takes a valid database connection and a given dutch name and returns the relevant subset of the data for this query:


```r
flora_records_on_dutch_name <- function(dbase_connection, dutch_name) {
     dbGetQuery(dbase_connection, glue_sql(
            "SELECT meet.Cor_X
            	 , meet.COr_Y
            	 , meet.MetingStatusCode
            	 , tax.NaamNederlands
            	 , tax.NaamWetenschappelijk
            	 , waar.IFBLHokID
            FROM  dbo.tblMeting meet
            	LEFT JOIN dbo.tblTaxon AS tax ON tax.ID = meet.TaxonID
            	LEFT JOIN dbo.tblWaarneming AS waar ON waar.ID = meet.WaarnemingID
            WHERE meet.Cor_X IS NOT NULL
            	AND meet.Cor_X != 0
            	AND tax.NaamNederlands LIKE {dutch_name}",
            dutch_name = dutch_name,
            .con = dbase_connection))
}
```

Hence, instead of copy-pasting the whole query each time (which could be error-prone), we can reuse the function for different names:


```r
hyacint <- flora_records_on_dutch_name(my_connection, "Wilde hyacint")
```

```
## Error in new_result(connection@ptr, statement): external pointer is not valid
```

```r
head(hyacint) %>% knitr::kable()
```



|  Cor_X|  COr_Y|MetingStatusCode |NaamNederlands |NaamWetenschappelijk                             | IFBLHokID|
|------:|------:|:----------------|:--------------|:------------------------------------------------|---------:|
|  88720| 208327|GDGA             |Wilde hyacint  |Hyacinthoides non-scripta (L.) Chouard ex Rothm. |     11195|
|  24106| 199925|GDGA             |Wilde hyacint  |Hyacinthoides non-scripta (L.) Chouard ex Rothm. |      9601|
| 103111| 190915|GDGA             |Wilde hyacint  |Hyacinthoides non-scripta (L.) Chouard ex Rothm. |      6990|
| 118123| 183942|GDGA             |Wilde hyacint  |Hyacinthoides non-scripta (L.) Chouard ex Rothm. |      5672|
| 106107| 182343|GDGA             |Wilde hyacint  |Hyacinthoides non-scripta (L.) Chouard ex Rothm. |      5217|
| 105765| 180785|GDGA             |Wilde hyacint  |Hyacinthoides non-scripta (L.) Chouard ex Rothm. |      4830|


```r
bosanemoon <- flora_records_on_dutch_name(my_connection, "Bosanemoon")
```

```
## Error in new_result(connection@ptr, statement): external pointer is not valid
```

```r
head(bosanemoon) %>% knitr::kable()
```



|  Cor_X|  COr_Y|MetingStatusCode |NaamNederlands |NaamWetenschappelijk | IFBLHokID|
|------:|------:|:----------------|:--------------|:--------------------|---------:|
| 119247| 204936|GDGA             |Bosanemoon     |Anemone nemorosa L.  |     10234|
|  73658| 199081|GDGA             |Bosanemoon     |Anemone nemorosa L.  |      8823|
|  72752| 199010|GDGA             |Bosanemoon     |Anemone nemorosa L.  |      8824|
|  72921| 198828|GDGA             |Bosanemoon     |Anemone nemorosa L.  |      8824|
|  72874| 198735|GDGA             |Bosanemoon     |Anemone nemorosa L.  |      8824|
|  72887| 198660|GDGA             |Bosanemoon     |Anemone nemorosa L.  |      8824|

**Remark:** Do not forget to close your connection when done finished. 


```r
dbDisconnect(my_connection)
```

## The `glue_sql` function {#glue_sql}

In order to accomplish the re-usage of a query for different input names (`dutch_name`), the `glue_sql` function is used from the [glue package](https://glue.tidyverse.org/reference/glue_sql.html). The `glue_sql` function (and the more general `glue` function) provides the ability to combine text and variable values in a single charactor string (i.e. the query to execute). For each variable name required in the query (any part of your query you want to have interchangeable), a representation in the query is given by the variable name you use in R, put in between curly brackets. For example, if you have the `dutch_name` variable in R, you can use it inside the query as `{dutch_name}`:


```r
dutch_name <- 'Jan'
an_integer <- 3
a_float <- 2.8
glue('This prints a combination of a name: {dutch_name}, an integer: {an_integer} and a float value: {a_float}')
```

```
## This prints a combination of a name: Jan, an integer: 3 and a float value: 2.8
```

Whereas the `glue` function is a general function for strings, the `glue_sql` function is specifically created to setup queries to databases. More information is provided [here](https://db.rstudio.com/best-practices/run-queries-safely/#using-glue_sql) and [here](https://glue.tidyverse.org/reference/glue_sql.html).




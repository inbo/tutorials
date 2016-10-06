Read data from google sheet
================

``` r
library(googlesheets)
library(dplyr)
library(ggplot2)
```

Setup
-----

The R package [googlesheets](https://github.com/jennybc/googlesheets/blob/master/README.md) provides the functionality to retrieve data from a google sheet. Once the registration as a user is done and the permissions are granted, it enables to read and write to google sheets. Initiation of the authentification can be done with the `gs_auth` command.

``` r
gs_auth()
```

Google will ask to grant the package the permission to access your drive. This token is saved to in a file `.httr-oauth` in your current working directory. Make sure this is not part of your version control system.

Once registered, n overview of your available google sheets is provided as follows:

``` r
gs_ls()
```

    ## # A tibble: 131 × 10
    ##                 sheet_title        author  perm version
    ##                       <chr>         <chr> <chr>   <chr>
    ## 1  400+ Tools and innovati…    jeroensbox    rw     old
    ## 2  Open biodiversity data …  peter.desmet    rw     old
    ## 3   Fish tracking receivers  peter.desmet    rw     old
    ## 4      TraitsRedListSpecies     dirk.maes    rw     old
    ## 5  20150110_ramingen tim a… carlos.gooss…    rw     old
    ## 6  LifeWatch budget en uit… peter.desmet…    rw     old
    ## 7  Fish tracking transmitt…  peter.desmet    rw     old
    ## 8       T0 sources datasets sander.devis…    rw     old
    ## 9  Teambuilding_IDC_20_okt… daniel.duseu…    rw     old
    ## 10 Development Planning 20…      inbodata    rw     old
    ## # ... with 121 more rows, and 6 more variables: updated <dttm>,
    ## #   sheet_key <chr>, ws_feed <chr>, alternate <chr>, self <chr>,
    ## #   alt_key <chr>

However, as we want to be able to make the running independent from the user authentification or without needing an interactive environment. Therefor, we can store the token in a file and get the authentification from there:

``` r
# first get the token, but not caching it in a local file
token <- gs_auth(cache = FALSE)
# save the token into a file in the current directory
saveRDS(token, file = "googlesheets_token.rds")
```

Loading this later on can be done by loading the token from this file, also in non-interactive sessions such as Rmarkdown scripts.

``` r
gs_auth(token = "googlesheets_token.rds")
```

Make sure the token is savely stored within your project folder without sharing it or putting it into the version control history. If you need more power (e.g. necessity of integration services such as Travis CI), check the encryption options in [this manual](https://rawgit.com/jennybc/googlesheets/master/vignettes/managing-auth-tokens.html).

I just want to load a google spreadsheet
----------------------------------------

Consider you have the authentification. You know the name, URL or key of the spreadheet and want to read this in, well use one of the functions `gs_title()`, `gs_url()` or `gs_key()`.

As an example, I want to work on the sheet called `TraitsRedListSpecies`. Finding the spreadheet is done as follows:

``` r
redlists <- gs_title("TraitsRedListSpecies")
```

    ## Sheet successfully identified: "TraitsRedListSpecies"

An overview of the different sheets provides sufficient information to retrieve the dataset and work with them:

``` r
gs_ws_ls(redlists)
```

    ##  [1] "!Amphibians"        "BreedingBirds"      "!Butterflies"      
    ##  [4] "!CarabidBeetles"    "Dragonflies"        "!FreshwaterFishes" 
    ##  [7] "Grasshoppers"       "Ladybirds"          "!Mammals"          
    ## [10] "!Reptiles"          "!SaproxylicBeetles" "!VascularPlants"   
    ## [13] "!Waterbugs"

So, getting the `BreedingBirds` sheet into a native R object can be done by reading the specific worksheet:

``` r
breedingbirds <- redlists %>% 
        gs_read(ws = "BreedingBirds")
```

    ## Accessing worksheet titled 'BreedingBirds'.

    ## 
    Downloading: 1.2 kB     
    Downloading: 1.2 kB     
    Downloading: 2.2 kB     
    Downloading: 2.2 kB     
    Downloading: 3.4 kB     
    Downloading: 3.4 kB     
    Downloading: 4.7 kB     
    Downloading: 4.7 kB     
    Downloading: 5.5 kB     
    Downloading: 5.5 kB     
    Downloading: 5.5 kB     
    Downloading: 5.5 kB     
    Downloading: 5.5 kB     
    Downloading: 5.5 kB

    ## No encoding supplied: defaulting to UTF-8.

Inspecting the data of the sheet:

``` r
class(breedingbirds)
```

    ## [1] "tbl_df"     "tbl"        "data.frame"

``` r
head(breedingbirds)
```

    ## # A tibble: 6 × 17
    ##   TaxonomicGroup Class           Order       Family  Genus     Species
    ##            <chr> <chr>           <chr>        <chr>  <chr>       <chr>
    ## 1  BreedingBirds  Aves Accipitriformes Accipitridae Circus aeruginosus
    ## 2  BreedingBirds  Aves Accipitriformes Accipitridae Pernis    apivorus
    ## 3  BreedingBirds  Aves Accipitriformes Accipitridae  Buteo       buteo
    ## 4  BreedingBirds  Aves Accipitriformes Accipitridae Circus aeruginosus
    ## 5  BreedingBirds  Aves Accipitriformes Accipitridae  Buteo       buteo
    ## 6  BreedingBirds  Aves Accipitriformes Accipitridae Pernis    apivorus
    ## # ... with 11 more variables: Speciesname <chr>, SpeciesnameDutch <chr>,
    ## #   RLC <chr>, RLCEurope <chr>, Biome <chr>, Biotope <chr>,
    ## #   Lifespan <chr>, Mobility <chr>, Criteria <chr>, Spine <chr>,
    ## #   Trophy <chr>

We can now start working on the data, e.g. make a plot of the number of species in each biotope divided based on the RLC level:

``` r
ggplot(data = breedingbirds, aes(x = Biotope)) +
    geom_bar() + 
    facet_grid(RLC ~ .)
```

![](/home/stijn_vanhoey/githubs/inbo_tutorials/output/data-handling/googlesheet-R_files/figure-markdown_github/unnamed-chunk-12-1.png)

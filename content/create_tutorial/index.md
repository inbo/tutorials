---
title: Create tutorial
description: Guidelines to create a new tutorial
type: page
menu: sidebar
weight: -230
---

# Create and add a tutorial

First of all, thanks to consider making a new tutorial...

## TODO

De idee:

- maak Rmd (met bepaalde headers,...) -> genereer zelf .md versie
(- Rmd wordt niet bekeken door blogdown/hugo)
- alle md's -> website
  + update van de search, `node ./themes/minimo/scripts/generate-search-index-lunr.js`
  (! dat script nog te verplaatsen, zodat afzonderlijk staat)
- voor files waarbij interactieve componenten: blogdown gebruiken

https://owi.usgs.gov/blog/leaflet/
https://www.bryanwhiting.com/2018/07/debugging-leaflet-and-googlesheets-on-blogdown/
https://stackoverflow.com/questions/53464336/hugo-relative-paths-in-page-bundles

 TODO:
 - travis build script for hugo build 
 - interactive maps solution
 - tutorial about how to tutorial
 - check script if for each Rmd an equivalent md exists... (use R/build.R?)

## Header structure


### markdown file

```

---
title: "YOUR TITLE"
description: "SHORT DESCRIPTION ON TUTORIAL"
author: "YOUR NAME"
date: YYYY-MM-DD
categories: ["YOUR_CATEGORY"]
tags: ["first_tag", "second_tag", "..."]
---

# your tutorial starts here...
```


### Rmarkdown file


```
---
title: "YOUR TITLE"
description: "SHORT DESCRIPTION ON TUTORIAL"
author: "YOUR NAME"
date: YYYY-MM-DD
categories:
  - YOUR_CATEGORY
tags: ["first_tag", "second_tag", "..."]
output: 
    md_document:
        preserve_yaml: true
---

# your tutorial starts here...
```

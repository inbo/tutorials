---
title: Create tutorial
description: Guidelines to create a new tutorial
type: page
menu: sidebar
weight: -230
---

## Introduction

First of all, thanks to consider making a new tutorial! By providing a tutorial, you are actively supporting your colleagues and the wider community and making work more efficient. 

In this page, the roadmap towards a new tutorial will be explained.

## Writing a tutorial

Each tutorial is setup in a subfolder of the `content/tutorials` folder. Within this folder, different files and formats may exist as you create them, but a file with the name `index.md` will be used for the tutorials website. So, you can create the tutorial directly in markdown or create it based on a [Rmarkdown](https://rmarkdown.rstudio.com/), a [Jupyter notebook](https://jupyter.org/) or any other format, as long as there is a single markdown file with the name `index.md` in your tutorial folder. 

There are different ways to create this file. We will provide in this document specific instructions for markdown an Rmarkdown based tutorials. Still, if you got useful information or text in another format or you got stuck with the description, do not hesitate to describe your submission in a [new issue ](https://github.com/inbo/tutorials/issues/new). If you do not have a Github account, ask the [IT helpdesk](mailto:ict.helpdesk@inbo.be). We will try to support you as soon as possible. 

### markdown file

If you are directly writing your documentation in markdown syntax, you can either work online using [Github](https://github.com/inbo/tutorials) or work on your own computer while using git. 

#### Online submission

Although providing less functionalities (adding custom images is not directly supported), the Github interface provides already a powerfull interface to add new content. 

To write a new tutorial **online**, go to the INBO-tutorials Github repository and navigate to the `/content/tutorials` page, or use [this link](https://github.com/inbo/tutorials/tree/master/content/tutorials). 

Next, click the `Create new file` button

![](images/new_file.png)

You will be directed to a new page and asked to _Name your file..._ 

![](images/folder_file_name.png)

Providing this name is **very important,** so make sure:

- provide a folder name  + `/` + `index.md`
- the folder name needs to be all lowercase 
- the folder name should not have spaces, but you can use `_` to separate words
- provide a meaningful name without dates or names

For example: `r_tidy_data/index.md`, `database_query_inboveg/index.md` or `statistics_regression/index.md`

**Notice:** The moment you type the `/`, Github will guide you by translating this to a folder name. 

Next, in the edit field you can start typing your tutorial. use the `Preview` button to check how it would look like rendered on a website.

**Notice:** You can add images from online source by using the URL of the image, e.g. `![short image description](http://.../my_image.jpg)`. For example, `https://www.inbo.be/sites/all/themes/bootstrap_inbo/img/inbo/logo_nl.png` will impor the INBO logo into your document:

![](https://www.inbo.be/sites/all/themes/bootstrap_inbo/img/inbo/logo_nl.png)

If you are ready, commit your file to the website maintainers by filling in the boxes:

![](images/propose_file.png)

* `Create new file`: exchange this by a short message about the additions, e.g. _Add tutorial to explain tidy data in R_ or _Add tutorial about database queries in inboveg,..._
* `Add an optional extended description`: If you think more background info is suitable, add that in this box.
* `yourgithubnam-patch` you can replace this by the same name as your folder name above (e..g. `r_tidy_data`) to clarify your submission. 

(the checkbox will always be on `create a new branch`, this is also the required option)

Next, click `commit new file` and your submission will be reviewed by the website maintainers. If accepted, the tutorial will be automatically integrated in the tutorials website.

#### Using git

When you ever used git or Github before, either using the command line, rstudio, Github Desktop,... you can work on your computer


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
 OK - travis build script for hugo build 
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
categories/tags are lower case

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

### caveats
 - interne linken voor de bibliografie
 - interactive maps solution

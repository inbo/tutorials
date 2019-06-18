
# Tutorials

[![Build Status](https://travis-ci.org/inbo/tutorials.svg?branch=master)](https://travis-ci.org/inbo/tutorials)

This repository contains the source files for the [INBO tutorials website](https://inbo.github.io/tutorials/): a collection of instructions on the use, installation and development of research software at the Research Institute of Nature and Forest (INBO).

## Adding content

New tutorials should go in a new directory in `content/tutorials`. Use plain markdown files (`.md`) as much a possible. Use Rmarkdown files (`.Rmd`) when calculations in R are required. For more information about creating a new tutorial, check the [create tutorial](https://inbo.github.io/tutorials/create_tutorial/) page.

## Building the site

The technology used to create the website is [Hugo](https://gohugo.io/), a static website generator. Hugo will process all the markdown files - ignoring Rmd, which is why these need to be knit beforehand - and create the necessary files (html, css, js) for the website. These are served from the [`gh-pages` branch](https://github.com/inbo/tutorials/tree/gh-pages).

## Contributors

[List of contributors](https://github.com/inbo/tutorials/graphs/contributors)

## License

[MIT License](https://github.com/inbo/tutorials/blob/master/LICENSE)

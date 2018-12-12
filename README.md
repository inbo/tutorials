
# Tutorials

Here you can find the source files for the instructions on the use, installation, and development of freeware open source research software at the Research Institute of Nature and Forest (INBO). Visit <https://inbo-tutorials....> to see the rendered version.

The repository is based on [blogdown](https://bookdown.org/yihui/blogdown/). New tutorials should go in an appropriate subfolder of `content/tutorials`. Use plain markdown files (`.md`) as much a possible. Use Rmarkdown files (`.Rmd`) when calculations in R are required.

## Special cases

### Other output formats

The default blogdown output format may not be suitable. In such case place the `.Rmd` into a subfolder of `source` and add it to the [`render.R`](https://github.com/inbo/tutorials/blob/master/render.R) script.

### Long calculations

...

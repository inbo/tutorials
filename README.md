[![wercker status](https://app.wercker.com/status/28ef302cb50839bc1ff8b411c292dbd8/m/master "wercker status")](https://app.wercker.com/project/byKey/28ef302cb50839bc1ff8b411c292dbd8)

# Tutorials

Here you can find the source files for the instructions on the use, installation, and development of freeware open source research software at the Research Institute of Nature and Forest (INBO). Visit <http://inbo.github.io/tutorials> to see the rendered version.

The repository is based on [blogdown](https://bookdown.org/yihui/blogdown/). New content should go in an appropriate subfolder of `content`. Use plain markdown files (`.md`) as much a possible. Use Rmarkdown files (`.Rmd`) when calculations in R are required.

## Special cases

### Other output formats

The default blogdown output format may not be suitable. In such case place the `.Rmd` into a subfolder of `source` and add it to the [`render.R`](https://github.com/inbo/tutorials/blob/master/render.R) script.

### Long calculations

The tutorials site will be build automatically with each push. Long calculations will result in a time-out on the build server and a subsequent failure of the build. Failed builds cannot be merged with the master branch! Therefore Rmarkdown file with long calculations should be rendered manually on the authors machine. The `.Rmd` and the `.R` file to render the `.Rmd` should be placed in a subfolder of `source`. The output of the rendering should be placed in a subfolder of `content`. The prefered output format is 

```
output:
  md_document:
    variant: markdown
```

### Missing dependencies

Contact the maintainer of the repository in case your tutorials requires dependencies which are currently not available on the build server.

## How to render the source files

```
# other output formats
source("render.R")
# long calculations
source("source/data-handling/large-files-R.R")
# blogdown files
blogdown::serve_site()
```

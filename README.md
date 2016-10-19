# Tutorials

Here you can find the source files for the instructions on the use, installation, and development of freeware open source research software at the Research Institute of Nature and Forest (INBO). Visit <http://inbo.github.io/tutorials> to see the rendered version.

The repository is structured in two folders: `docs` and `source`. `source` contains all source files of the website in RMarkdown format. One should only edit these files. The `docs` folder contains the rendered version of the source files. <http://inbo.github.io/tutorials> displays the content of the `docs` folder in the HEAD of the master branch.

## How to render the source files

### Using the command line

```
rmarkdown::render_site("source")
```

### Using the RStudio GUI

Go the the _Build_ pane and click _Build Website_.

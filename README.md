[![wercker status](https://app.wercker.com/status/28ef302cb50839bc1ff8b411c292dbd8/m/master "wercker status")](https://app.wercker.com/project/byKey/28ef302cb50839bc1ff8b411c292dbd8)

# Tutorials

Here you can find the source files for the instructions on the use, installation, and development of freeware open source research software at the Research Institute of Nature and Forest (INBO). Visit <http://inbo.github.io/tutorials> to see the rendered version.

The repository is structured in two folders: `docs` and `source`. `source` contains all source files of the website in RMarkdown format. One should only edit these files. The `docs` folder contains the rendered version of the source files. <http://inbo.github.io/tutorials> displays the content of the `docs` folder in the HEAD of the master branch.

## How to render the source files

### Using the command line

```
rmarkdown::render_site("source")
```

### Using the RStudio GUI

First setup the RStudio project

1. Open RStudio
1. Create a new project: 
    1. _File > New Project > Version Control > Git_
    1. Copy the URL in _Repository URL_
    1. _Create project_
1. Go to the _Build_ pane
1. Click _More > Configure Build Tools ..._
1. Set the _Site directory_ to `source` and click _OK_

When the RStudio project is setup: Go to the _Build_ pane and click _Build Website_.

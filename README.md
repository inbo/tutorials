
# Tutorials

[![Build Status](https://travis-ci.com/inbo/tutorials.svg?branch=master)](https://travis-ci.com/inbo/tutorials)

This repository contains the source files for the [INBO tutorials website](https://inbo.github.io/tutorials/): a collection of instructions on the use, installation and development of research software at the Research Institute of Nature and Forest (INBO).

## Adding content

New tutorials should go in a new directory in `content/tutorials`. Use plain markdown files (`.md`) as much a possible. Use Rmarkdown files (`.Rmd`) when calculations in R are required. For more information about creating a new tutorial, check the [create tutorial](https://inbo.github.io/tutorials/create_tutorial/) page.

## Building the site

The technology used to create the website is [Hugo](https://gohugo.io/), a static website generator. Hugo will process all the markdown files - ignoring Rmd, which is why these need to be knit beforehand - and create the necessary files (html, css, js) for the website. These are served from the [`gh-pages` branch](https://github.com/inbo/tutorials/tree/gh-pages).

### Travis CI

[Travis](https://travis-ci.com/inbo/tutorials) will automatically run the steps above ([install Hugo, download theme, run Hugo, deploy website](.travis.yml)) for every pull request or commit to the master branch. You will see in the pull request if the build was successful. If not, [check the build logs](https://travis-ci.com/inbo/tutorials/builds) to figure out what went wrong.

### Building the site on your local computer

1. [Install hugo](https://gohugo.io/getting-started/installing/)
2. Clone the tutorials repository
3. In the cloned tutorials directory, install the theme with `git clone https://github.com/MunifTanjim/minimo.git --branch v2.7.0 themes/minimo`
4. Build and serve the site with `hugo server -D`

For more information, see [Hugo's getting started documentation](https://gohugo.io/getting-started/usage/).

### Customizing the theme

The tutorials website makes use of the Hugo theme [minimo](https://themes.gohugo.io/minimo/). This theme is not included in the repository, but [downloaded by Travis](https://github.com/inbo/tutorials/blob/c715a8ea58817d280f89133aa06645590b8e16e0/.travis.yml#L18) at build time. This avoids clutter and changes to the theme itself. To customize the theme:

1. Browse the `layouts` directory in the [minimo repository](https://github.com/MunifTanjim/minimo/tree/master/layouts) to see which template file you want to customize
2. Copy the template file to the same path in the [`layouts`](layouts/) directory of this repository
3. Edit the file to the desired effect. E.g. [this update](https://github.com/inbo/tutorials/blob/b122758ef8d98977e51335bf227a2cf8c1f6bbd7/layouts/partials/entry/meta.html#L15-L16) to the [original minimo file](https://github.com/MunifTanjim/minimo/blob/4436676dd44c767faaa4fa85f8a24527ce61ba81/layouts/partials/entry/meta.html#L15) adds a "edit this page" link for every page.
4. Hugo will now use your customized file instead of the default theme file.

For more information, see the [Hugo theme customization documentation](https://gohugo.io/getting-started/quick-start/#step-6-customize-the-theme). To test theme customization, it is best to build the site on your local computer (see above).

## Contributors

[List of contributors](https://github.com/inbo/tutorials/graphs/contributors)

## License

[Creative Commons Attribution](https://creativecommons.org/licenses/by/4.0/) for [content](content) / [MIT License](https://github.com/inbo/tutorials/blob/master/LICENSE) for source code.


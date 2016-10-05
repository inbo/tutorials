to.render <- list.files(
  path = "source",
  pattern = "\\.Rmd$",
  full.names = TRUE,
  recursive = TRUE,
  ignore.case = TRUE
)

for (i in to.render) {
  rmarkdown::render(i, output_dir = dirname(gsub("^source/", "output/", i)))
}

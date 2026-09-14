library(yaml)
list.files(
  "_extensions",
  pattern = "_extension.yml",
  full.names = TRUE,
  recursive = TRUE
) |>
  grepv(pattern = "flandersqmd") |>
  read_yaml() -> resources
resources$contributes$format$revealjs[["format-resources"]] |>
  basename() |>
  file.remove() -> hide
file.copy("output/index.html", "presentation.html", overwrite = TRUE) -> hide
list.files("output", recursive = TRUE, full.names = TRUE) |>
  file.remove() -> hide
rm(hide)
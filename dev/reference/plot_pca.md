# PCA Plot

Draw a PCA scores plot. Currently supported data types:

- `glystats_pca_res`: Result from
  [`glystats::gly_pca()`](https://glycoverse.github.io/glystats/reference/gly_pca.html).

- `SummarizedExperiment`: A
  [`glyexp::GlycomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycomicSE.html),
  [`glyexp::GlycoproteomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycoproteomicSE.html),
  or other compatible container. PCA analysis is first performed using
  [`glystats::gly_pca()`](https://glycoverse.github.io/glystats/reference/gly_pca.html),
  then the result is plotted.

## Usage

``` r
plot_pca(x, type = "individual", groups = NULL, group_col = NULL, ...)

# S3 method for class 'glystats_pca_res'
plot_pca(x, type = "individual", groups = NULL, group_col = NULL, ...)

# S3 method for class 'glyexp_experiment'
plot_pca(
  x,
  type = "individual",
  groups = NULL,
  group_col = NULL,
  stats_args = list(),
  ...
)

# S3 method for class 'SummarizedExperiment'
plot_pca(
  x,
  type = "individual",
  groups = NULL,
  group_col = NULL,
  stats_args = list(),
  ...
)
```

## Arguments

- x:

  An object to be plotted.

- type:

  The type of plot, one of "screeplot", "individual", "variables", or
  "biplot".

- groups:

  A factor or character vector specifying group membership for each
  sample. If provided, the plot will be colored by group. Only
  applicable to "individual" and "biplot" types.

- group_col:

  A character string specifying where to find the group information. If
  the result was produced from a supported Glycoverse data container,
  sample information has already been added to the result. In this case,
  you can specify the column name in the sample information tibble to be
  used for coloring.

- ...:

  Common and plot-specific options described in
  [glyvis_plot_options](https://glycoverse.github.io/glyvis/dev/reference/glyvis_plot_options.md).

- stats_args:

  A list of keyword arguments to pass to
  [`glystats::gly_pca()`](https://glycoverse.github.io/glystats/reference/gly_pca.html).

## Value

A `tidyplot` object, also inheriting from `ggplot`.

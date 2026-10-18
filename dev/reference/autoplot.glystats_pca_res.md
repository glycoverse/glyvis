# Plots for Principal Component Analysis (PCA)

Visualization for
[`glystats::gly_pca()`](https://glycoverse.github.io/glystats/reference/gly_pca.html)
results (`glystats_pca_res` object). Possible `type`s of plots:

- "screeplot": Scree plot to see the contribution of each PC.

- "individual" (default): Plot samples as individuals.

- "variables": Plot loadings for variables.

- "biplot": Biplot showing both samples and variables.

## Usage

``` r
# S3 method for class 'glystats_pca_res'
autoplot(object, type = "individual", groups = NULL, group_col = NULL, ...)
```

## Arguments

- object:

  A `glystats_pca_res` object.

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
  used for coloring. If not provided, this function will try "group".

- ...:

  Common and plot-specific options described in
  [glyvis_plot_options](https://glycoverse.github.io/glyvis/dev/reference/glyvis_plot_options.md).

## Value

A `tidyplot` object, also inheriting from `ggplot`.

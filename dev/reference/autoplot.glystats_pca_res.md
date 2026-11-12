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
autoplot(
  object,
  ...,
  type = "individual",
  groups = NULL,
  group_col = NULL,
  axes = c(1L, 2L),
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  top_n = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
)
```

## Arguments

- object:

  A `glystats_pca_res` object.

- ...:

  Must be empty. Supply plotting controls by their full argument names.

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

- axes:

  Integer vector selecting two distinct principal components.

- label:

  Whether to label samples and loading arrows. Defaults to `FALSE`.

- add_ellipse:

  Whether to add group ellipses to individual and biplot scores.

- point_size, alpha:

  Point size and opacity for individual and biplot scores.

- top_n:

  Number of loading arrows to retain in variables and biplot views.
  `NULL` retains all arrows; a positive integer selects the largest
  squared loading norms. Biplots rescale arrows by a common display
  multiplier without changing scores or explained variance.

- title:

  Optional plot title. Defaults to `NULL`.

- width, height:

  Plot-area dimensions in millimetres. `NULL` uses the tidyplots
  defaults (50 by 50 mm); `NA` fills the available graphics device.
  These are not export-page dimensions.

- fontsize:

  Base text size in points. Defaults to 9.

- family:

  Font family. Defaults to `"sans"`.

- palette:

  Color vector. A named vector maps group names to fixed colors across
  plots and subsets; unnamed palettes follow factor order. `NULL`
  selects the plot-specific default: blue-white-red for continuous
  heatmaps, directional colors for volcano and S-plots, selection colors
  for ranked dot plots, and distinct hues for other plots.

## Value

A `tidyplot` object, also inheriting from `ggplot`.

# Plots for PLS-DA

Visualization for results from
[`glystats::gly_plsda()`](https://glycoverse.github.io/glystats/reference/gly_plsda.html)
(`glystats_plsda_res` object). Possible `type`s of plots:

- "scores" (default): Plot scores for samples.

- "loadings": Plot loadings for variables.

- "vip": Plot VIP scores for variables.

- "variance": Plot explained variance for each component.

## Usage

``` r
# S3 method for class 'glystats_plsda_res'
autoplot(
  object,
  ...,
  type = "scores",
  groups = NULL,
  group_col = NULL,
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

  A `glystats_plsda_res` object.

- ...:

  Must be empty. Supply plotting controls by their full argument names.

- type:

  The type of plot, one of "loadings", "scores", "vip", or "variance".
  Defaults to "scores".

- groups:

  A factor or character vector specifying group membership for each
  sample. If provided, the plot will be colored by group. Only
  applicable to "scores" and "loadings" types.

- group_col:

  A character string specifying where to find the group information. If
  the result was produced from a supported Glycoverse data container,
  sample information has already been added to the result. In this case,
  you can specify the column name in the sample information tibble to be
  used for coloring. If not provided, this function will try "group".

- label:

  Whether to label samples in scores plots or variables in loadings
  plots. Defaults to `FALSE`.

- add_ellipse:

  Whether to add group ellipses to scores plots.

- point_size, alpha:

  Point size and opacity for scores plots.

- top_n:

  Number of variables to retain in loadings or VIP plots. `NULL` retains
  all variables; a positive integer selects the largest squared loading
  norms or VIP scores, respectively.

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
  plots and subsets; unnamed palettes follow factor order. `NULL` uses
  tidyplots palettes. Heatmaps and correlation plots use the blue,
  near-white, and red anchors of `colors_diverging_BuRd`. Volcano plots
  use grey for points that do not meet both cutoffs. Other plots use the
  tidyplots defaults for discrete and continuous values.

## Value

A `tidyplot` object, also inheriting from `ggplot`.

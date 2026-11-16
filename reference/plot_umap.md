# UMAP Plot

Draw a UMAP scores plot. Currently supported data types:

- `glystats_umap_res`: Result from
  [`glystats::gly_umap()`](https://glycoverse.github.io/glystats/reference/gly_umap.html).

- `SummarizedExperiment`: A
  [`glyexp::GlycomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycomicSE.html),
  [`glyexp::GlycoproteomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycoproteomicSE.html),
  or other compatible container. UMAP analysis is first performed using
  [`glystats::gly_umap()`](https://glycoverse.github.io/glystats/reference/gly_umap.html),
  then the result is plotted.

## Usage

``` r
plot_umap(
  x,
  ...,
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL,
  groups = NULL,
  group_col = NULL,
  stats_args = list()
)

# S3 method for class 'glystats_umap_res'
plot_umap(
  x,
  ...,
  groups = NULL,
  group_col = NULL,
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
)

# S3 method for class 'glyexp_experiment'
plot_umap(
  x,
  ...,
  groups = NULL,
  group_col = NULL,
  stats_args = list(),
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
)

# S3 method for class 'SummarizedExperiment'
plot_umap(
  x,
  ...,
  groups = NULL,
  group_col = NULL,
  stats_args = list(),
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
)
```

## Arguments

- x:

  An object to be plotted.

- ...:

  Must be empty. Supply plotting controls by their full argument names.

- label:

  Whether to label samples. Defaults to `FALSE`.

- add_ellipse:

  Whether to add group ellipses. Requires sample groups.

- point_size, alpha:

  Point size and opacity.

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

- groups:

  A factor or character vector specifying group membership for each
  sample. If provided, the plot will be colored by group.

- group_col:

  A character string specifying where to find the group information. If
  the result was produced from a supported Glycoverse data container,
  sample information has already been added to the result. In this case,
  you can specify the column name in the sample information tibble to be
  used for coloring. If not provided, this function will try "group".

- stats_args:

  A list of keyword arguments to pass to
  [`glystats::gly_umap()`](https://glycoverse.github.io/glystats/reference/gly_umap.html).

## Value

A `tidyplot` object, also inheriting from `ggplot`.

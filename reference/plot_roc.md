# ROC plot

Draw ROC curves. Only two groups are allowed. At most 10 variables can
be plotted. Currently supported data types:

- `glystats_roc_res`: Result from
  [`glystats::gly_roc()`](https://glycoverse.github.io/glystats/reference/gly_roc.html).

- `SummarizedExperiment`: A
  [`glyexp::GlycomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycomicSE.html),
  [`glyexp::GlycoproteomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycoproteomicSE.html),
  or other compatible container. ROC analysis is first performed using
  [`glystats::gly_roc()`](https://glycoverse.github.io/glystats/reference/gly_roc.html),
  then the result is plotted.

## Usage

``` r
plot_roc(
  x,
  ...,
  type = "roc",
  auc_cutoff = 0.5,
  top_n = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL,
  stats_args = list()
)

# S3 method for class 'glystats_roc_res'
plot_roc(
  x,
  ...,
  type = "roc",
  auc_cutoff = 0.5,
  top_n = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
)

# S3 method for class 'glyexp_experiment'
plot_roc(
  x,
  ...,
  type = "roc",
  auc_cutoff = 0.5,
  stats_args = list(),
  top_n = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
)

# S3 method for class 'SummarizedExperiment'
plot_roc(
  x,
  ...,
  type = "roc",
  auc_cutoff = 0.5,
  stats_args = list(),
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

- x:

  An object to be plotted.

- ...:

  Must be empty. Supply plotting controls by their full argument names.

- type:

  The type of plot, one of "dotplot" or "roc". Default is "roc".

- auc_cutoff:

  The AUC cutoff. Default is 0.5.

- top_n:

  Number of variables to retain when `type = "dotplot"`. `NULL` retains
  all variables; a positive integer selects the largest AUC values. Does
  not affect ROC curves.

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

- stats_args:

  A list of keyword arguments to pass to
  [`glystats::gly_roc()`](https://glycoverse.github.io/glystats/reference/gly_roc.html).

## Value

A `tidyplot` object, also inheriting from `ggplot`.

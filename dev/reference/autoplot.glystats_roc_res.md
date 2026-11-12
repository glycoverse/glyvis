# Plots for ROC Analysis

Visualization for results from
[`glystats::gly_roc()`](https://glycoverse.github.io/glystats/reference/gly_roc.html)
(`glystats_roc_res` objects). At most 10 variables can be plotted.

## Usage

``` r
# S3 method for class 'glystats_roc_res'
autoplot(
  object,
  ...,
  type = "dotplot",
  auc_cutoff = 0.5,
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

  A `glystats_roc_res` object.

- ...:

  Must be empty. Supply plotting controls by their full argument names.

- type:

  "dotplot" or "roc". Defaults to "dotplot". If "roc", at most 10
  variables can be plotted.

- auc_cutoff:

  The AUC cutoff. Defaults to 0.5. Only used if type is "dotplot".

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
  plots and subsets; unnamed palettes follow factor order. `NULL`
  selects the plot-specific default: blue-white-red for continuous
  heatmaps, directional colors for volcano and S-plots, selection colors
  for ranked dot plots, and distinct hues for other plots.

## Value

A `tidyplot` object, also inheriting from `ggplot`.

# Plots for Cox Proportional Hazards Model

Visualization for results from
[`glystats::gly_cox()`](https://glycoverse.github.io/glystats/reference/gly_cox.html)
(`glystats_cox_res` objects). Draw a dotchart for p-values.

## Usage

``` r
# S3 method for class 'glystats_cox_res'
autoplot(
  object,
  ...,
  p_cutoff = 0.05,
  p_col = "p_adj",
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

  A `glystats_cox_res` object.

- ...:

  Must be empty. Supply plotting controls by their full argument names.

- p_cutoff:

  The p-value cutoff. Defaults to 0.05.

- p_col:

  The column name for p-value. Defaults to "p_adj". Can also be "p_val"
  (raw p-values without multiple testing correction).

- top_n:

  Number of variables to retain. `NULL` retains all variables; a
  positive integer selects the smallest plotted p-values.

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

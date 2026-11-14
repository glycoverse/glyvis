# Plots for Correlation Analysis

Visualization for
[`glystats::gly_cor()`](https://glycoverse.github.io/glystats/reference/gly_cor.html)
results (`glystats_cor_res` objects).

## Usage

``` r
# S3 method for class 'glystats_cor_res'
autoplot(
  object,
  ...,
  label = FALSE,
  digits = 2,
  triangle = "lower",
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

  A `glystats_cor_res` object.

- ...:

  Must be empty. Supply plotting controls by their full argument names.

- label:

  Whether to display correlation coefficients in cells.

- digits:

  Number of decimal places for coefficient labels.

- triangle:

  Part of the matrix to display: `"lower"` (default), `"upper"`, or
  `"full"`. Colors always span -1 to 1.

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

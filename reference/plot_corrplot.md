# Correlation Plot

Draw a correlation matrix heatmap. Currently supported data types:

- `glystats_cor_res`: Result from
  [`glystats::gly_cor()`](https://glycoverse.github.io/glystats/reference/gly_cor.html).

- `SummarizedExperiment`: A
  [`glyexp::GlycomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycomicSE.html),
  [`glyexp::GlycoproteomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycoproteomicSE.html),
  or other compatible container. Correlation analysis is first performed
  using
  [`glystats::gly_cor()`](https://glycoverse.github.io/glystats/reference/gly_cor.html),
  then the result is plotted.

## Usage

``` r
plot_corrplot(
  x,
  ...,
  label = FALSE,
  digits = 2,
  triangle = "lower",
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL,
  stats_args = list()
)

# S3 method for class 'glystats_cor_res'
plot_corrplot(
  x,
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

# S3 method for class 'glyexp_experiment'
plot_corrplot(
  x,
  ...,
  stats_args = list(),
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

# S3 method for class 'SummarizedExperiment'
plot_corrplot(
  x,
  ...,
  stats_args = list(),
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

- x:

  An object to be plotted.

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

- stats_args:

  A list of keyword arguments to pass to
  [`glystats::gly_cor()`](https://glycoverse.github.io/glystats/reference/gly_cor.html).

## Value

A `tidyplot` object, also inheriting from `ggplot`.

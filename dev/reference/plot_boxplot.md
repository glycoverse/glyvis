# Boxplot

Draw a boxplot. Currently supported data types:

- `SummarizedExperiment`: A
  [`glyexp::GlycomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycomicSE.html),
  [`glyexp::GlycoproteomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycoproteomicSE.html),
  or other compatible container. Expression values are plotted, grouped
  by the group column, with scale-aware log transformation controlled by
  `log_transform`.

## Usage

``` r
plot_boxplot(
  x,
  ...,
  group_col = "group",
  ncol = NULL,
  label_width = 24,
  scales = "free_y",
  log_transform = NULL,
  points = TRUE,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL,
  variables = NULL
)

# S3 method for class 'glyexp_experiment'
plot_boxplot(
  x,
  ...,
  group_col = "group",
  ncol = NULL,
  label_width = 24,
  scales = "free_y",
  log_transform = NULL,
  points = TRUE,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
)

# S3 method for class 'SummarizedExperiment'
plot_boxplot(
  x,
  ...,
  group_col = "group",
  ncol = NULL,
  label_width = 24,
  scales = "free_y",
  log_transform = NULL,
  variables = NULL,
  points = TRUE,
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

- group_col:

  A character string specifying the column name in sample information
  that contains group labels. Default is "group".

- ncol:

  Number of facet columns. `NULL` chooses up to three columns.

- label_width:

  Width used to wrap facet labels without truncation.

- scales:

  Facet axis scales, passed to
  [`ggplot2::facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html).
  Defaults to `"free_y"`; use `"fixed"` for comparisons across facets.

- log_transform:

  `NULL` (default) uses recorded abundance scale metadata: raw values
  are transformed with `log2(x + 1e-6)`, while already logged values are
  unchanged. `FALSE` always uses the supplied values unchanged. `TRUE`
  requests the same transformation for raw values, but warns and is
  ignored for already logged values. This argument must be named after
  `...`.

- points:

  Whether to show observations as jittered points. Boxes show medians
  and quartiles with 1.5-IQR whiskers. Outliers are drawn separately
  only when `points = FALSE`.

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

- variables:

  A character vector of row names to plot from a `SummarizedExperiment`.
  `NULL` (the default) plots all rows. Names must exist in
  `rownames(x)`. Matching rows retain their original order; repeated
  names in `variables` do not repeat rows. The 25-variable limit applies
  after selection.

## Value

A `tidyplot` object, also inheriting from `ggplot`.

## See also

[glyvis_abundance_scale](https://glycoverse.github.io/glyvis/dev/reference/glyvis_abundance_scale.md)
for scale metadata and compatibility rules.

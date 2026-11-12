# Heatmap

Draw a heatmap from a
[`glyexp::GlycomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycomicSE.html),
[`glyexp::GlycoproteomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycoproteomicSE.html),
or other compatible `SummarizedExperiment`. Expression values use
scale-aware log transformation controlled by `log_transform`, followed
by optional row or column standardization. Before plotting,
zero-variance rows and columns are filtered out to ensure robust
clustering. Supplied `hclust` objects must match the retained rows or
columns, including their input order.

## Usage

``` r
plot_heatmap(
  x,
  ...,
  scale = "row",
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  show_rownames = FALSE,
  show_colnames = NULL,
  na_col = "grey90",
  log_transform = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
)

# S3 method for class 'glyexp_experiment'
plot_heatmap(
  x,
  ...,
  scale = "row",
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  show_rownames = FALSE,
  show_colnames = NULL,
  na_col = "grey90",
  log_transform = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
)

# S3 method for class 'SummarizedExperiment'
plot_heatmap(
  x,
  ...,
  scale = "row",
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  show_rownames = FALSE,
  show_colnames = NULL,
  na_col = "grey90",
  log_transform = NULL,
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

  A supported Glycoverse data container.

- ...:

  Must be empty. Supply plotting controls by their full argument names.

- scale:

  Standardize rows (`"row"`, the default), columns (`"column"`), or
  neither (`"none"`). Applied after and independently of
  `log_transform`.

- cluster_rows, cluster_cols:

  Whether to cluster rows or columns, or compatible `hclust` objects.
  Clustering controls order; dendrograms are not drawn. Use
  [`autoplot.glystats_hclust_res()`](https://glycoverse.github.io/glyvis/dev/reference/autoplot.glystats_hclust_res.md)
  to draw a dendrogram.

- show_rownames:

  Whether to display row labels. Defaults to `FALSE`.

- show_colnames:

  Whether to display column labels. `NULL` displays them automatically
  for at most 40 samples.

- na_col:

  Color for missing values.

- log_transform:

  `NULL` (default) uses recorded abundance scale metadata: raw values
  are transformed with `log2(x + 1e-6)`, while already logged values are
  unchanged. `FALSE` always uses the supplied values unchanged. `TRUE`
  requests the same transformation for raw values, but warns and is
  ignored for already logged values. This argument must be named after
  `...`.

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

## See also

[glyvis_abundance_scale](https://glycoverse.github.io/glyvis/dev/reference/glyvis_abundance_scale.md)
for scale metadata and compatibility rules.

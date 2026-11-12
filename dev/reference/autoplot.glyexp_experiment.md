# Plots for Glycoverse Data Containers

Visualization for
[`glyexp::GlycomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycomicSE.html),
[`glyexp::GlycoproteomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycoproteomicSE.html),
and other compatible `SummarizedExperiment` objects. Possible `type`s of
plots:

- "heatmap": (Default) Expression heatmap with columns as samples and
  rows as variables.

- "boxplot": Boxplot of expression values for each sample.

## Usage

``` r
# S3 method for class 'glyexp_experiment'
autoplot(
  object,
  ...,
  type = "heatmap",
  group_col = "group",
  log_transform = NULL,
  scale = "row",
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  show_rownames = FALSE,
  show_colnames = NULL,
  na_col = "grey90",
  points = TRUE,
  ncol = NULL,
  label_width = 24,
  scales = "free_y",
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
)

# S3 method for class 'SummarizedExperiment'
autoplot(
  object,
  ...,
  type = "heatmap",
  group_col = "group",
  log_transform = NULL,
  scale = "row",
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  show_rownames = FALSE,
  show_colnames = NULL,
  na_col = "grey90",
  points = TRUE,
  ncol = NULL,
  label_width = 24,
  scales = "free_y",
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

  A supported Glycoverse data container.

- ...:

  Must be empty. Supply plotting controls by their full argument names.

- type:

  The type of plot, one of "heatmap" (default) or "boxplot".

- group_col:

  A character string specifying where to find the group information. It
  should be a column in the sample information tibble. Defaults to
  "group". Only applicable to "boxplot".

- log_transform:

  `NULL` (default) uses recorded abundance scale metadata: raw values
  are transformed with `log2(x + 1e-6)`, while already logged values are
  unchanged. `FALSE` always uses the supplied values unchanged. `TRUE`
  requests the same transformation for raw values, but warns and is
  ignored for already logged values. This argument must be named after
  `...`.

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

- points:

  Whether to show observations as jittered points. Boxes show medians
  and quartiles with 1.5-IQR whiskers. Outliers are drawn separately
  only when `points = FALSE`.

- ncol:

  Number of facet columns. `NULL` chooses up to three columns.

- label_width:

  Width used to wrap facet labels without truncation.

- scales:

  Facet axis scales, passed to
  [`ggplot2::facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html).
  Defaults to `"free_y"`; use `"fixed"` for comparisons across facets.

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

## Details

Heatmap options (`scale`, `cluster_rows`, `cluster_cols`,
`show_rownames`, `show_colnames`, `na_col`) apply only to
`type = "heatmap"`. Boxplot options (`points`, `ncol`, `label_width`,
`scales`) apply only to `type = "boxplot"`.

For SE containers, `fortify()` returns `.sample` and `.variable` axis
identifiers and an abundance `value` column. Ordinary `sample` and
`variable` metadata are retained. Conflicting annotation names receive
numeric suffixes, with sample metadata preceding variable metadata.
Boxplot `group_col` always selects the original column in
[`colData()`](https://rdrr.io/pkg/SummarizedExperiment/man/SummarizedExperiment-class.html).
Legacy experiment fortification retains `sample` and `variable`
identifiers.

## See also

[glyvis_abundance_scale](https://glycoverse.github.io/glyvis/dev/reference/glyvis_abundance_scale.md)
for scale metadata and compatibility rules.

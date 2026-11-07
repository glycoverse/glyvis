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
  type = "heatmap",
  group_col = "group",
  ...,
  log_transform = NULL
)

# S3 method for class 'SummarizedExperiment'
autoplot(
  object,
  type = "heatmap",
  group_col = "group",
  ...,
  log_transform = NULL
)
```

## Arguments

- object:

  A supported Glycoverse data container.

- type:

  The type of plot, one of "heatmap" (default) or "boxplot".

- group_col:

  A character string specifying where to find the group information. It
  should be a column in the sample information tibble. Defaults to
  "group". Only applicable to "boxplot".

- ...:

  Common and plot-specific options described in
  [glyvis_plot_options](https://glycoverse.github.io/glyvis/dev/reference/glyvis_plot_options.md).

- log_transform:

  `NULL` (default) uses recorded abundance scale metadata: raw values
  are transformed with `log2(x + 1e-6)`, while already logged values are
  unchanged. `FALSE` always uses the supplied values unchanged. `TRUE`
  requests the same transformation for raw values, but warns and is
  ignored for already logged values. This argument must be named after
  `...`.

## Value

A `tidyplot` object, also inheriting from `ggplot`.

## See also

[glyvis_abundance_scale](https://glycoverse.github.io/glyvis/dev/reference/glyvis_abundance_scale.md)
for scale metadata and compatibility rules.

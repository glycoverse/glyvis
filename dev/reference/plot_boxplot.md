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
plot_boxplot(x, ..., log_transform = NULL)

# S3 method for class 'glyexp_experiment'
plot_boxplot(x, group_col = "group", ..., log_transform = NULL)

# S3 method for class 'SummarizedExperiment'
plot_boxplot(
  x,
  group_col = "group",
  ...,
  log_transform = NULL,
  variables = NULL
)
```

## Arguments

- x:

  An object to be plotted.

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

- group_col:

  A character string specifying the column name in sample information
  that contains group labels. Default is "group".

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

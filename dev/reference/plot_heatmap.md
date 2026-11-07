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
plot_heatmap(x, ..., log_transform = NULL)

# S3 method for class 'glyexp_experiment'
plot_heatmap(x, ..., log_transform = NULL)

# S3 method for class 'SummarizedExperiment'
plot_heatmap(x, ..., log_transform = NULL)
```

## Arguments

- x:

  A supported Glycoverse data container.

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

# Heatmap

Draw a heatmap from a
[`glyexp::GlycomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycomicSE.html),
[`glyexp::GlycoproteomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycoproteomicSE.html),
or other compatible `SummarizedExperiment`. Heatmap of log2-transformed
expression values is plotted. Before plotting, zero-variance rows and
columns are filtered out to ensure robust clustering.

## Usage

``` r
plot_heatmap(x, ...)

# S3 method for class 'glyexp_experiment'
plot_heatmap(x, ...)

# S3 method for class 'SummarizedExperiment'
plot_heatmap(x, ...)
```

## Arguments

- x:

  A supported Glycoverse data container.

- ...:

  Other arguments passed to
  [`pheatmap::pheatmap()`](https://rdrr.io/pkg/pheatmap/man/pheatmap.html).

## Value

A ggplot object.

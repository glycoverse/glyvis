# Heatmap

Draw a heatmap from a
[`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html).
Heatmap of log2-transformed expression values is plotted. Before
plotting, zero-variance rows and columns are filtered out to ensure
robust clustering.

## Usage

``` r
plot_heatmap(x, ...)

# S3 method for class 'glyexp_experiment'
plot_heatmap(x, ...)
```

## Arguments

- x:

  A
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html)
  object.

- ...:

  Other arguments passed to
  [`pheatmap::pheatmap()`](https://rdrr.io/pkg/pheatmap/man/pheatmap.html).

## Value

A ggplot object.

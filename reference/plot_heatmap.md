# Heatmap

Draw a heatmap. Currently supported data types:

- `glyexp_experiment`: Experiment created by
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html).
  Heatmap of log2-transformed expression values is plotted.

## Usage

``` r
plot_heatmap(x, ...)

# S3 method for class 'glyexp_experiment'
plot_heatmap(x, ...)
```

## Arguments

- x:

  An object to be plotted.

- ...:

  Ignored.

## Value

A ggplot object.

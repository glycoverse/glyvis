# Correlation Plot

Draw a correlation matrix heatmap. Currently supported data types:

- `glystats_cor_res`: Result from
  [`glystats::gly_cor()`](https://glycoverse.github.io/glystats/reference/gly_cor.html).

- `glyexp_experiment`: Experiment created by
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html).
  Correlation analysis is first performed using
  [`glystats::gly_cor()`](https://glycoverse.github.io/glystats/reference/gly_cor.html),
  then the result is plotted.

## Usage

``` r
plot_corrplot(x, ...)

# S3 method for class 'glystats_cor_res'
plot_corrplot(x, ...)

# S3 method for class 'glyexp_experiment'
plot_corrplot(x, stats_args = list(), ...)
```

## Arguments

- x:

  An object to be plotted.

- ...:

  Additional arguments passed to
  [`GGally::ggcorr()`](https://ggobi.github.io/ggally/reference/ggcorr.html).

- stats_args:

  A list of keyword arguments to pass to
  [`glystats::gly_cor()`](https://glycoverse.github.io/glystats/reference/gly_cor.html).

## Value

A ggplot object.

# Plots for Correlation Analysis

Visualization for
[`glystats::gly_cor()`](https://glycoverse.github.io/glystats/reference/gly_cor.html)
results (`glystats_cor_res` objects).

## Usage

``` r
# S3 method for class 'glystats_cor_res'
autoplot(object, ...)
```

## Arguments

- object:

  A `glystats_cor_res` object.

- ...:

  Other arguments passed to
  [`GGally::ggcorr()`](https://ggobi.github.io/ggally/reference/ggcorr.html).

## Value

A ggplot object.

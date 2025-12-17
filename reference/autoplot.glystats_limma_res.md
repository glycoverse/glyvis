# Plots for Limma Result

Visualization for results from
[`glystats::gly_limma()`](https://glycoverse.github.io/glystats/reference/gly_limma.html)
(`glystats_limma_res` objects). Only 2-group comparison is supported,
and a volcano plot is drawn.

## Usage

``` r
# S3 method for class 'glystats_limma_res'
autoplot(object, log2fc_cutoff = 1, p_cutoff = 0.05, p_col = "p_adj", ...)
```

## Arguments

- object:

  A `glystats_limma_res` object.

- log2fc_cutoff:

  The log2 fold change cutoff. Defaults to 1.

- p_cutoff:

  The p-value cutoff. Defaults to 0.05.

- p_col:

  The column name for p-value. Defaults to "p_adj". Can also be "p_val"
  (raw p-values without multiple testing correction).

- ...:

  Other arguments passed to underlying functions.

## Value

A ggplot object.

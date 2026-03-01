# Plots for Cox Proportional Hazards Model

Visualization for results from
[`glystats::gly_cox()`](https://glycoverse.github.io/glystats/reference/gly_cox.html)
(`glystats_cox_res` objects). Draw a dotchart for p-values.

## Usage

``` r
# S3 method for class 'glystats_cox_res'
autoplot(object, p_cutoff = 0.05, p_col = "p_adj", ...)
```

## Arguments

- object:

  A `glystats_cox_res` object.

- p_cutoff:

  The p-value cutoff. Defaults to 0.05.

- p_col:

  The column name for p-value. Defaults to "p_adj". Can also be "p_val"
  (raw p-values without multiple testing correction).

- ...:

  Ignored.

## Value

A ggplot object.

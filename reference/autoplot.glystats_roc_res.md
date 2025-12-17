# Plots for ROC Analysis

Visualization for results from
[`glystats::gly_roc()`](https://glycoverse.github.io/glystats/reference/gly_roc.html)
(`glystats_roc_res` objects). At most 10 variables can be plotted.

## Usage

``` r
# S3 method for class 'glystats_roc_res'
autoplot(object, type = "dotplot", auc_cutoff = 0.5, ...)
```

## Arguments

- object:

  A `glystats_roc_res` object.

- type:

  "dotplot" or "roc". Defaults to "dotplot". If "roc", at most 10
  variables can be plotted.

- auc_cutoff:

  The AUC cutoff. Defaults to 0.5. Only used if type is "dotplot".

- ...:

  Ignored.

## Value

A ggplot object.

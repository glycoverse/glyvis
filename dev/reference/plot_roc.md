# ROC plot

Draw ROC curves. Only two groups are allowed. At most 10 variables can
be plotted. Currently supported data types:

- `glystats_roc_res`: Result from
  [`glystats::gly_roc()`](https://glycoverse.github.io/glystats/reference/gly_roc.html).

- `glyexp_experiment`: Experiment created by
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html).
  ROC analysis is first performed using
  [`glystats::gly_roc()`](https://glycoverse.github.io/glystats/reference/gly_roc.html),
  then the result is plotted.

## Usage

``` r
plot_roc(x, type = "roc", auc_cutoff = 0.5, ...)

# S3 method for class 'glystats_roc_res'
plot_roc(x, type = "roc", auc_cutoff = 0.5, ...)

# S3 method for class 'glyexp_experiment'
plot_roc(x, type = "roc", auc_cutoff = 0.5, stats_args = list(), ...)
```

## Arguments

- x:

  An object to be plotted.

- type:

  The type of plot, one of "dotplot" or "roc". Default is "roc".

- auc_cutoff:

  The AUC cutoff. Default is 0.5.

- ...:

  Ignored.

- stats_args:

  A list of keyword arguments to pass to
  [`glystats::gly_roc()`](https://glycoverse.github.io/glystats/reference/gly_roc.html).

## Value

A ggplot object.

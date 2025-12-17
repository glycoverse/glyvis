# Plots for PLS-DA

Visualization for results from
[`glystats::gly_plsda()`](https://glycoverse.github.io/glystats/reference/gly_plsda.html)
(`glystats_plsda_res` object). Possible `type`s of plots:

- "scores" (default): Plot scores for samples.

- "loadings": Plot loadings for variables.

- "vip": Plot VIP scores for variables.

- "variance": Plot explained variance for each component.

## Usage

``` r
# S3 method for class 'glystats_plsda_res'
autoplot(object, type = "scores", groups = NULL, group_col = NULL, ...)
```

## Arguments

- object:

  A `glystats_plsda_res` object.

- type:

  The type of plot, one of "loadings", "scores", "vip", or "variance".
  Defaults to "scores".

- groups:

  A factor or character vector specifying group membership for each
  sample. If provided, the plot will be colored by group. Only
  applicable to "scores" and "loadings" types.

- group_col:

  A character string specifying where to find the group information. If
  you uses
  [`glystats::gly_plsda()`](https://glycoverse.github.io/glystats/reference/gly_plsda.html)
  on a
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html)
  to get the result, sample information has already been added to the
  result. In this case, you can specify the column name in the sample
  information tibble to be used for coloring. If not provided, this
  function will try "group".

- ...:

  Ignored.

## Value

A ggplot object.

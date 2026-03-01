# Plots for OPLS-DA

Visualization for results from
[`glystats::gly_oplsda()`](https://glycoverse.github.io/glystats/reference/gly_oplsda.html)
(`glystats_oplsda_res` object). Possible `type`s of plots:

- "scores" (default): Plot scores for samples.

- "loadings": Plot loadings for variables.

- "vip": Plot VIP scores for variables.

- "variance": Plot explained variance for each component.

- "s-plot": Plot the correlation between p1 and pcorr1.

## Usage

``` r
# S3 method for class 'glystats_oplsda_res'
autoplot(
  object,
  type = "scores",
  y_type = "o1",
  groups = NULL,
  group_col = NULL,
  ...
)
```

## Arguments

- object:

  A `glystats_oplsda_res` object.

- type:

  The type of plot, one of "loadings", "scores", "vip", "variance", or
  "s-plot". Defaults to "scores".

- y_type:

  What to plot on the y-axis when `type` is "scores" or "loadings".
  Either "p2" or "o1". Defaults to "o1".

- groups:

  A factor or character vector specifying group membership for each
  sample. If provided, the plot will be colored by group. Only
  applicable to "scores" and "loadings" types.

- group_col:

  A character string specifying where to find the group information. If
  you uses
  [`glystats::gly_oplsda()`](https://glycoverse.github.io/glystats/reference/gly_oplsda.html)
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

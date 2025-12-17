# OPLS-DA Plot

Draw a OPLS-DA scores plot. Currently supported data types:

- `glystats_oplsda_res`: Result from
  [`glystats::gly_oplsda()`](https://glycoverse.github.io/glystats/reference/gly_oplsda.html).

- `glyexp_experiment`: Experiment created by
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html).
  OPLS-DA analysis is first performed using
  [`glystats::gly_oplsda()`](https://glycoverse.github.io/glystats/reference/gly_oplsda.html),
  then the result is plotted.

## Usage

``` r
plot_oplsda(
  x,
  type = "scores",
  y_type = "o1",
  groups = NULL,
  group_col = NULL,
  ...
)

# S3 method for class 'glystats_oplsda_res'
plot_oplsda(
  x,
  type = "scores",
  y_type = "o1",
  groups = NULL,
  group_col = NULL,
  ...
)

# S3 method for class 'glyexp_experiment'
plot_oplsda(
  x,
  type = "scores",
  y_type = "o1",
  groups = NULL,
  group_col = NULL,
  stats_args = list(),
  ...
)
```

## Arguments

- x:

  An object to be plotted.

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

- stats_args:

  A list of keyword arguments to pass to
  [`glystats::gly_oplsda()`](https://glycoverse.github.io/glystats/reference/gly_oplsda.html).

## Value

A ggplot object.

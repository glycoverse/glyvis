# UMAP Plot

Draw a UMAP scores plot. Currently supported data types:

- `glystats_umap_res`: Result from
  [`glystats::gly_umap()`](https://glycoverse.github.io/glystats/reference/gly_umap.html).

- `glyexp_experiment`: Experiment created by
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html).
  UMAP analysis is first performed using
  [`glystats::gly_umap()`](https://glycoverse.github.io/glystats/reference/gly_umap.html),
  then the result is plotted.

## Usage

``` r
plot_umap(x, ...)

# S3 method for class 'glystats_umap_res'
plot_umap(x, groups = NULL, group_col = NULL, ...)

# S3 method for class 'glyexp_experiment'
plot_umap(x, groups = NULL, group_col = NULL, stats_args = list(), ...)
```

## Arguments

- x:

  An object to be plotted.

- ...:

  Ignored.

- groups:

  A factor or character vector specifying group membership for each
  sample. If provided, the plot will be colored by group.

- group_col:

  A character string specifying where to find the group information. If
  you uses
  [`glystats::gly_umap()`](https://glycoverse.github.io/glystats/reference/gly_umap.html)
  on a
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html)
  to get the result, sample information has already been added to the
  result. In this case, you can specify the column name in the sample
  information tibble to be used for coloring. If not provided, this
  function will try "group".

- stats_args:

  A list of keyword arguments to pass to
  [`glystats::gly_umap()`](https://glycoverse.github.io/glystats/reference/gly_umap.html).

## Value

A ggplot object.

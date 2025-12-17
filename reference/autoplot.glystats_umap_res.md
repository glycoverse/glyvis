# Plots for UMAP

Visualization for results from
[`glystats::gly_umap()`](https://glycoverse.github.io/glystats/reference/gly_umap.html)
(`glystats_umap_res` objects). Draw a scatter plot of UMAP coordinates.

## Usage

``` r
# S3 method for class 'glystats_umap_res'
autoplot(object, groups = NULL, group_col = NULL, ...)
```

## Arguments

- object:

  A `glystats_umap_res` object.

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

- ...:

  Ignored.

## Value

A ggplot object.

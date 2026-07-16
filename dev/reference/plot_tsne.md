# t-SNE Plot

Draw a t-SNE scores plot. Currently supported data types:

- `glystats_tsne_res`: Result from
  [`glystats::gly_tsne()`](https://glycoverse.github.io/glystats/reference/gly_tsne.html).

- `SummarizedExperiment`: A
  [`glyexp::GlycomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycomicSE.html),
  [`glyexp::GlycoproteomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycoproteomicSE.html),
  or other compatible container. t-SNE analysis is first performed using
  [`glystats::gly_tsne()`](https://glycoverse.github.io/glystats/reference/gly_tsne.html),
  then the result is plotted.

## Usage

``` r
plot_tsne(x, ...)

# S3 method for class 'glystats_tsne_res'
plot_tsne(x, groups = NULL, group_col = NULL, ...)

# S3 method for class 'glyexp_experiment'
plot_tsne(x, groups = NULL, group_col = NULL, stats_args = list(), ...)

# S3 method for class 'SummarizedExperiment'
plot_tsne(x, groups = NULL, group_col = NULL, stats_args = list(), ...)
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
  the result was produced from a supported Glycoverse data container,
  sample information has already been added to the result. In this case,
  you can specify the column name in the sample information tibble to be
  used for coloring. If not provided, this function will try "group".

- stats_args:

  A list of keyword arguments to pass to
  [`glystats::gly_tsne()`](https://glycoverse.github.io/glystats/reference/gly_tsne.html).

## Value

A ggplot object.

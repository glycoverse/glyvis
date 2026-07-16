# Boxplot

Draw a boxplot. Currently supported data types:

- `SummarizedExperiment`: A
  [`glyexp::GlycomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycomicSE.html),
  [`glyexp::GlycoproteomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycoproteomicSE.html),
  or other compatible container. Boxplots of log2-transformed expression
  values are plotted, grouped by the group column.

## Usage

``` r
plot_boxplot(x, ...)

# S3 method for class 'glyexp_experiment'
plot_boxplot(x, group_col = "group", ...)

# S3 method for class 'SummarizedExperiment'
plot_boxplot(x, group_col = "group", ...)
```

## Arguments

- x:

  An object to be plotted.

- ...:

  Ignored.

- group_col:

  A character string specifying the column name in sample information
  that contains group labels. Default is "group".

## Value

A ggplot object.

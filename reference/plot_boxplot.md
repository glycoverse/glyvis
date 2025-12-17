# Boxplot

Draw a boxplot. Currently supported data types:

- `glyexp_experiment`: Experiment created by
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html).
  Boxplots of log2-transformed expression values are plotted, grouped by
  the group column.

## Usage

``` r
plot_boxplot(x, ...)

# S3 method for class 'glyexp_experiment'
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

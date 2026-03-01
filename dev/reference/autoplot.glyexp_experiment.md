# Plots for Experiments

Visualization for
[`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html)
(`glyexp_experiment` object). Possible `type`s of plots:

- "heatmap": (Default) Expression heatmap with columns as samples and
  rows as variables.

- "boxplot": Boxplot of expression values for each sample.

## Usage

``` r
# S3 method for class 'glyexp_experiment'
autoplot(object, type = "heatmap", group_col = "group", ...)
```

## Arguments

- object:

  A `glyexp_experiment` object.

- type:

  The type of plot, one of "heatmap" (default) or "boxplot".

- group_col:

  A character string specifying where to find the group information. It
  should be a column in the sample information tibble. Defaults to
  "group". Only applicable to "boxplot".

- ...:

  Ignored.

## Value

A ggplot object.

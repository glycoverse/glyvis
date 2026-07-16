# Plots for Glycoverse Data Containers

Visualization for
[`glyexp::GlycomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycomicSE.html),
[`glyexp::GlycoproteomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycoproteomicSE.html),
and other compatible `SummarizedExperiment` objects. Possible `type`s of
plots:

- "heatmap": (Default) Expression heatmap with columns as samples and
  rows as variables.

- "boxplot": Boxplot of expression values for each sample.

## Usage

``` r
# S3 method for class 'glyexp_experiment'
autoplot(object, type = "heatmap", group_col = "group", ...)

# S3 method for class 'SummarizedExperiment'
autoplot(object, type = "heatmap", group_col = "group", ...)
```

## Arguments

- object:

  A supported Glycoverse data container.

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

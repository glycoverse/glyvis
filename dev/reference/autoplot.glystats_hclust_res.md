# Plots for Hierarchical Clustering

Draw a dendrogram on a tidyplots canvas.

## Usage

``` r
# S3 method for class 'glystats_hclust_res'
autoplot(object, rotate = FALSE, labels = TRUE, ...)
```

## Arguments

- object:

  A `glystats_hclust_res` object.

- rotate:

  Display the dendrogram horizontally.

- labels:

  Display leaf labels.

- ...:

  Common and plot-specific options described in
  [glyvis_plot_options](https://glycoverse.github.io/glyvis/dev/reference/glyvis_plot_options.md).

## Value

A `tidyplot` object, also inheriting from `ggplot`.

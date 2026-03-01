# Plots for Hierarchical Clustering

Visualization for results from
[`glystats::gly_hclust()`](https://glycoverse.github.io/glystats/reference/gly_hclust.html)
(`glystats_hclust_res` object). Draw a dendrogram.

## Usage

``` r
# S3 method for class 'glystats_hclust_res'
autoplot(object, ...)
```

## Arguments

- object:

  A `glystats_hclust_res` object.

- ...:

  Additional arguments passed to
  [`ggdendro::ggdendrogram()`](https://andrie.github.io/ggdendro/reference/ggdendrogram.html).

## Value

A ggplot object.

## See also

[`ggdendro::ggdendrogram()`](https://andrie.github.io/ggdendro/reference/ggdendrogram.html)

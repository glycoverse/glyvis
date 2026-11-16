# Plots for Hierarchical Clustering

Draw a dendrogram on a tidyplots canvas.

## Usage

``` r
# S3 method for class 'glystats_hclust_res'
autoplot(
  object,
  ...,
  rotate = FALSE,
  labels = TRUE,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
)
```

## Arguments

- object:

  A `glystats_hclust_res` object.

- ...:

  Must be empty. Supply plotting controls by their full argument names.

- rotate:

  Display the dendrogram horizontally.

- labels:

  Display leaf labels.

- title:

  Optional plot title. Defaults to `NULL`.

- width, height:

  Plot-area dimensions in millimetres. `NULL` uses the tidyplots
  defaults (50 by 50 mm); `NA` fills the available graphics device.
  These are not export-page dimensions.

- fontsize:

  Base text size in points. Defaults to 9.

- family:

  Font family. Defaults to `"sans"`.

- palette:

  Color vector. A named vector maps group names to fixed colors across
  plots and subsets; unnamed palettes follow factor order. `NULL` uses
  tidyplots palettes. Heatmaps and correlation plots use the blue,
  near-white, and red anchors of `colors_diverging_BuRd`. Volcano plots
  use grey for points that do not meet both cutoffs. Other plots use the
  tidyplots defaults for discrete and continuous values.

## Value

A `tidyplot` object, also inheriting from `ggplot`.

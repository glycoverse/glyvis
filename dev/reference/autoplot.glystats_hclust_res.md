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
  plots and subsets; unnamed palettes follow factor order. `NULL`
  selects the plot-specific default: blue-white-red for continuous
  heatmaps, directional colors for volcano and S-plots, selection colors
  for ranked dot plots, and distinct hues for other plots.

## Value

A `tidyplot` object, also inheriting from `ggplot`.

# Plots for UMAP

Visualization for results from
[`glystats::gly_umap()`](https://glycoverse.github.io/glystats/reference/gly_umap.html)
(`glystats_umap_res` objects). Draw a scatter plot of UMAP coordinates.

## Usage

``` r
# S3 method for class 'glystats_umap_res'
autoplot(
  object,
  ...,
  groups = NULL,
  group_col = NULL,
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
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

  A `glystats_umap_res` object.

- ...:

  Must be empty. Supply plotting controls by their full argument names.

- groups:

  A factor or character vector specifying group membership for each
  sample. If provided, the plot will be colored by group.

- group_col:

  A character string specifying where to find the group information. If
  the result was produced from a supported Glycoverse data container,
  sample information has already been added to the result. In this case,
  you can specify the column name in the sample information tibble to be
  used for coloring. If not provided, this function will try "group".

- label:

  Whether to label samples. Defaults to `FALSE`.

- add_ellipse:

  Whether to add group ellipses. Requires sample groups.

- point_size, alpha:

  Point size and opacity.

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

# Plots for 2-Group Differential Expression Analysis (DEA)

Visualization for results from
[`glystats::gly_ttest()`](https://glycoverse.github.io/glystats/reference/gly_ttest.html)
and
[`glystats::gly_wilcox()`](https://glycoverse.github.io/glystats/reference/gly_wilcox.html)
(`glystats_ttest_res` and `glystats_wilcox_res` objects). Draw a volcano
plot.

## Usage

``` r
# S3 method for class 'glystats_ttest_res'
autoplot(
  object,
  ...,
  log2fc_cutoff = 1,
  p_cutoff = 0.05,
  p_col = "p_adj",
  label = FALSE,
  point_size = 1.5,
  alpha = 0.7,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
)

# S3 method for class 'glystats_wilcox_res'
autoplot(
  object,
  ...,
  log2fc_cutoff = 1,
  p_cutoff = 0.05,
  p_col = "p_adj",
  label = FALSE,
  point_size = 1.5,
  alpha = 0.7,
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

  A `glystats_ttest_res` or `glystats_wilcox_res` object.

- ...:

  Must be empty. Supply plotting controls by their full argument names.

- log2fc_cutoff:

  The log2 fold change cutoff. Defaults to 1.

- p_cutoff:

  The p-value cutoff. Defaults to 0.05.

- p_col:

  The column name for p-value. Defaults to "p_adj". Can also be "p_val"
  (raw p-values without multiple testing correction).

- label:

  Whether to label variables. Defaults to `FALSE`.

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

## Fold-change availability

A volcano plot requires at least one non-missing `log2fc` value in the
selected comparison. Results with only missing fold changes produce an
informative error rather than an empty plot. This includes `logx`
results and unlogged raw-scale limma analyses, whose native estimates
are not log2 fold changes. Native estimates are never substituted for
`log2fc`. When only some fold changes are missing, the available values
are plotted without changing the supplied results.

## See also

[glyvis_plot_options](https://glycoverse.github.io/glyvis/dev/reference/glyvis_plot_options.md)
for common styling options.

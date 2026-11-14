# Customize glyvis plots with tidyplots

All `plot_*()` functions and statistical
[`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
methods return a `tidyplot`, which also inherits from `ggplot`. Continue
styling with `tidyplots::adjust_*()` functions, add components with
`tidyplots::add_*()`, or use ordinary ggplot2 layers. No global theme or
options are changed.

## Arguments

- ...:

  Must be empty. Supply plotting controls by their full argument names.

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

## Details

All plotting controls follow `...` in public function signatures. Supply
their full argument names; only the input object is positional.

Plot-specific controls are explicit named arguments of the corresponding
plotting functions and their
[`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
methods. See
[`plot_pca()`](https://glycoverse.github.io/glyvis/dev/reference/plot_pca.md),
[`plot_plsda()`](https://glycoverse.github.io/glyvis/dev/reference/plot_plsda.md),
[`plot_oplsda()`](https://glycoverse.github.io/glyvis/dev/reference/plot_oplsda.md),
[`plot_tsne()`](https://glycoverse.github.io/glyvis/dev/reference/plot_tsne.md),
[`plot_umap()`](https://glycoverse.github.io/glyvis/dev/reference/plot_umap.md),
[`plot_volcano()`](https://glycoverse.github.io/glyvis/dev/reference/plot_volcano.md),
[`plot_roc()`](https://glycoverse.github.io/glyvis/dev/reference/plot_roc.md),
[`plot_boxplot()`](https://glycoverse.github.io/glyvis/dev/reference/plot_boxplot.md),
[`plot_heatmap()`](https://glycoverse.github.io/glyvis/dev/reference/plot_heatmap.md),
[`plot_corrplot()`](https://glycoverse.github.io/glyvis/dev/reference/plot_corrplot.md),
and
[`plot_logo()`](https://glycoverse.github.io/glyvis/dev/reference/plot_logo.md)
for defaults and details. Glycan summaries document their controls in
[`plot_n_core_pie()`](https://glycoverse.github.io/glyvis/dev/reference/plot_n_core_pie.md),
[`plot_n_type_pie()`](https://glycoverse.github.io/glyvis/dev/reference/plot_n_core_pie.md),
[`plot_n_branch_pie()`](https://glycoverse.github.io/glyvis/dev/reference/plot_n_core_pie.md),
[`plot_n_branch_bar()`](https://glycoverse.github.io/glyvis/dev/reference/plot_n_core_pie.md),
[`plot_fuc_sia_pie()`](https://glycoverse.github.io/glyvis/dev/reference/plot_fuc_sia_pie.md),
[`plot_o_type_pie()`](https://glycoverse.github.io/glyvis/dev/reference/plot_o_type_pie.md),
[`plot_isomers_per_comp()`](https://glycoverse.github.io/glyvis/dev/reference/plot_isomers_per_comp.md),
[`plot_glycans_per_site()`](https://glycoverse.github.io/glyvis/dev/reference/plot_glycans_per_site.md),
[`plot_sites_per_protein()`](https://glycoverse.github.io/glyvis/dev/reference/plot_glycans_per_site.md),
and
[`plot_top10_bar()`](https://glycoverse.github.io/glyvis/dev/reference/plot_top10_bar.md).

## Migration from earlier backends

Arguments specific to factoextra, EnhancedVolcano, GGally, pheatmap, and
ggdendrogram are no longer forwarded. Unsupported arguments error
instead of being ignored. Use the documented arguments or modify the
returned tidyplot. Replace PCA `geom = "point"` with the default
`label = FALSE`, `repel = TRUE` with `label = TRUE`, and volcano
`pointSize` with `point_size`. Move ggseqlogo arguments from `...` into
`logo_args`.

## Export

Use
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html)
with explicit width, height and units, or
[`tidyplots::save_plot()`](https://jbengler.github.io/tidyplots/reference/save_plot.html).
PDF/SVG preserve vector elements and editable text; use a suitable
graphics device and inspect labels at the final physical size. Large
feature sets may require a larger output, label suppression, or an
explicitly selected subset. Automatic label repulsion may omit crowded
text but never removes the underlying observations.

## Examples

``` r
if (requireNamespace("glystats", quietly = TRUE)) {
  mat <- matrix(c(3, 8, 5, 9, 2, 7, 6, 4, 1, 5, 6, 2), nrow = 3,
    dimnames = list(paste0("V", 1:3), paste0("S", 1:4)))
  se <- SummarizedExperiment::SummarizedExperiment(assays = list(mat))
  p <- plot_pca(se, label = TRUE, point_size = 2.5, title = "PCA")
  p |> tidyplots::adjust_size(width = 80, height = 60)
}
```

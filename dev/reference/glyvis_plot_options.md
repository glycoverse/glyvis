# Customize glyvis plots with tidyplots

All `plot_*()` functions and statistical
[`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
methods return a `tidyplot`, which also inherits from `ggplot`. Continue
styling with `tidyplots::adjust_*()` functions, add components with
`tidyplots::add_*()`, or use ordinary ggplot2 layers. No global theme or
options are changed.

## Common options

Pass these named arguments through `...` in any plotting entry point:

- `title`: optional plot title.

- `width`, `height`: plot-area dimensions in millimetres; `NULL`
  (default) uses tidyplots defaults (50 by 50 mm). Set `NA` to fill the
  available graphics device. These are not export-page dimensions.

- `fontsize`: base text size in points, default 9.

- `family`: font family, default `"sans"`.

- `palette`: color vector. A named vector maps group names to fixed
  colors across different plots and subsets. Unnamed palettes follow
  factor order; use the same factor levels or a named palette for
  consistent group colors. Continuous heatmaps use blue-white-red; other
  plots use distinct hues.

## Plot-specific options

- PCA: `axes = c(1, 2)`, `label = FALSE`, `add_ellipse = FALSE`, and
  `top_n = NULL` for loading arrows. Biplots rescale arrows by a common
  display multiplier; scores and explained variance are unchanged.

- PCA, PLS-DA, OPLS-DA, t-SNE, UMAP and volcano scatter plots:
  `point_size = 2` (volcano: 1.5), `alpha = 0.8` (volcano: 0.7), and
  `label = FALSE`. Embedding score plots also accept
  `add_ellipse = FALSE`.

- Loading plots: `label = FALSE`, `top_n = NULL`. All arrows are
  retained by default. An explicit `top_n` selects the largest squared
  loading norms.

- VIP and ranked dot plots: `top_n = NULL`; an explicit positive integer
  selects the largest plotted values. All variables are retained by
  default.

- Boxplots and heatmaps: `log_transform = NULL` uses recorded scale
  metadata to log raw values with `log2(x + 1e-6)` and leave logged
  values unchanged. `FALSE` preserves the supplied values; `TRUE` warns
  and is ignored for already logged input. See
  [glyvis_abundance_scale](https://glycoverse.github.io/glyvis/dev/reference/glyvis_abundance_scale.md)
  for compatibility rules.

- Boxplots: `points = TRUE`, `ncol = NULL`, `label_width = 24`, and
  `scales = "free_y"`. Long facet labels wrap without truncation. Points
  are observations; boxes show the median and quartiles with 1.5-IQR
  whiskers. Use `scales = "fixed"` for comparisons across facets.

- Heatmaps: `scale = "row"` (also `"column"` or `"none"`),
  `cluster_rows = TRUE`, `cluster_cols = TRUE` (also `FALSE` or
  compatible `hclust` objects), `show_rownames = FALSE`,
  `show_colnames = NULL`, and `na_col = "grey90"`. Columns are labelled
  automatically up to 40 samples. Values use the selected log
  transformation, then are optionally standardized. `scale` is
  independent of `log_transform`. Clustering orders rows and columns;
  dendrograms are not drawn inside the heatmap. Use the
  hierarchical-clustering
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  method for a dendrogram.

- Correlation plots: `label = FALSE`, `digits = 2`, and
  `triangle = "lower"` (also `"upper"` or `"full"`). Colors span -1 to
  1.

- Sequence logos: pass glyph options in `logo_args`, a named list passed
  to
  [`ggseqlogo::geom_logo()`](https://rdrr.io/pkg/ggseqlogo/man/geom_logo.html),
  e.g. `list(method = "prob")`.

- N-glycan summaries:
  [`plot_n_core_pie()`](https://glycoverse.github.io/glyvis/dev/reference/plot_n_core_pie.md),
  [`plot_n_type_pie()`](https://glycoverse.github.io/glyvis/dev/reference/plot_n_core_pie.md),
  [`plot_n_branch_pie()`](https://glycoverse.github.io/glyvis/dev/reference/plot_n_core_pie.md),
  and
  [`plot_n_branch_bar()`](https://glycoverse.github.io/glyvis/dev/reference/plot_n_core_pie.md)
  accept `weight = "equal"` or `"abundance"` and pool all samples. Their
  default plot areas are 50 by 50 mm.

- Composition summaries:
  [`plot_fuc_sia_pie()`](https://glycoverse.github.io/glyvis/dev/reference/plot_fuc_sia_pie.md)
  accepts `weight = "equal"` or `"abundance"` and classifies
  fucosylation and sialylation without structures.

- O-GalNAc summaries:
  [`plot_o_type_pie()`](https://glycoverse.github.io/glyvis/dev/reference/plot_o_type_pie.md)
  uses the same weighting and accepts `core_set = "4cores"` (Core 1-4)
  or `"8cores"` (Core 1-8).

- Glycoproteomic count distributions:
  [`plot_glycans_per_site()`](https://glycoverse.github.io/glyvis/dev/reference/plot_glycans_per_site.md)
  and
  [`plot_sites_per_protein()`](https://glycoverse.github.io/glyvis/dev/reference/plot_glycans_per_site.md)
  use fixed bins `1` to `7` and `>=8`, one bar colour, and a 50 by 50 mm
  plot area. `weight = "abundance"` pools measured glycoform abundances
  across samples instead of counting entities.

- Top glycans:
  [`plot_top10_bar()`](https://glycoverse.github.io/glyvis/dev/reference/plot_top10_bar.md)
  independently ranks the ten most frequent or abundant glycans
  including and excluding oligomannose in mirrored bars, with glycan
  cartoons and the tidyplots default plot area of 50 by 50 mm.

## Migration from earlier backends

Arguments specific to factoextra, EnhancedVolcano, GGally, pheatmap, and
ggdendrogram are no longer forwarded. Unsupported arguments error
instead of being ignored. Use the options above or modify the returned
tidyplot. Replace PCA `geom = "point"` with the default `label = FALSE`,
`repel = TRUE` with `label = TRUE`, and volcano `pointSize` with
`point_size`. Move ggseqlogo arguments from `...` into `logo_args`.

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
  p <- plot_pca(se, title = "PCA", fontsize = 9)
  p |> tidyplots::adjust_size(width = 80, height = 60)
}
```

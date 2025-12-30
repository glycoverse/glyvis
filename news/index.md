# Changelog

## glyvis 0.4.5

### Minor improvements and bug fixes

- Fix the bug that
  [`plot_heatmap()`](https://glycoverse.github.io/glyvis/reference/plot_heatmap.md)
  cannot handle NA values. Now a more robust clustering method is used
  and zero-variance variables are removed.

## glyvis 0.4.4

### Minor improvements and bug fixes

- Suppress harmless warnings in
  [`plot_volcano()`](https://glycoverse.github.io/glyvis/reference/plot_volcano.md)
  and
  [`plot_pca()`](https://glycoverse.github.io/glyvis/reference/plot_pca.md).

## glyvis 0.4.3

### Minor improvements and bug fixes

- Fix the bug that
  [`plot_heatmap()`](https://glycoverse.github.io/glyvis/reference/plot_heatmap.md)
  always sends the plot to the plot panel even when the result is passed
  to a variable.

## glyvis 0.4.2

### Minor improvements and bug fixes

- Fix the bug that
  [`plot_volcano()`](https://glycoverse.github.io/glyvis/reference/plot_volcano.md)
  cannot correctly handle the `contrast` argument for
  [`glystats::gly_limma()`](https://glycoverse.github.io/glystats/reference/gly_limma.html)
  results.
- Fix the bug that
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  method for
  [`glystats::gly_limma()`](https://glycoverse.github.io/glystats/reference/gly_limma.html)
  results does not work.

## glyvis 0.4.1

### Minor improvements and bug fixes

- [`plot_volcano()`](https://glycoverse.github.io/glyvis/reference/plot_volcano.md)
  now supports
  [`glystats::gly_limma()`](https://glycoverse.github.io/glystats/reference/gly_limma.html)
  results with multiple contrasts.
- Use `pheatmap` and `ggplotify` in
  [`plot_heatmap()`](https://glycoverse.github.io/glyvis/reference/plot_heatmap.md)
  to plot heatmaps.
- Remove
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  for `glystats_wgcna_res` objects for now. It will be re-implemented in
  the future with more features.

## glyvis 0.4.0

We redesign most `plot_xxx()` functions to make them more flexible.
Previously, these functions only accepts a
[`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html)
object. Now, they also accept corresponding `glystats` results, to be
more intuitive and convenient.

We also redesign the argument passing strategies in `plot_xxx()`
functions, making clear separation between underlying statistical
functions and plotting functions.

### New features

- Add
  [`plot_oplsda()`](https://glycoverse.github.io/glyvis/reference/plot_oplsda.md)
  to plot OPLS-DA plot from
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html)
  or
  [`glystats::gly_oplsda()`](https://glycoverse.github.io/glystats/reference/gly_oplsda.html)
  results.
- Add
  [`plot_plsda()`](https://glycoverse.github.io/glyvis/reference/plot_plsda.md)
  to plot PLS-DA plot from
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html)
  or
  [`glystats::gly_plsda()`](https://glycoverse.github.io/glystats/reference/gly_plsda.html)
  results.
- Add
  [`plot_enrich()`](https://glycoverse.github.io/glyvis/reference/plot_enrich.md)
  to plot dotplot, barplot, or network plot from
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html)
  or `glystats` enrichment functions
  ([`glystats::gly_enrich_go()`](https://glycoverse.github.io/glystats/reference/gly_enrich_go.html),
  [`glystats::gly_enrich_kegg()`](https://glycoverse.github.io/glystats/reference/gly_enrich_go.html),
  [`glystats::gly_enrich_reactome()`](https://glycoverse.github.io/glystats/reference/gly_enrich_go.html)).
- [`plot_corrplot()`](https://glycoverse.github.io/glyvis/reference/plot_corrplot.md)
  now supports
  [`glystats::gly_cor()`](https://glycoverse.github.io/glystats/reference/gly_cor.html)
  results.
- [`plot_pca()`](https://glycoverse.github.io/glyvis/reference/plot_pca.md)
  now supports
  [`glystats::gly_pca()`](https://glycoverse.github.io/glystats/reference/gly_pca.html)
  results.
- [`plot_roc()`](https://glycoverse.github.io/glyvis/reference/plot_roc.md)
  now supports
  [`glystats::gly_roc()`](https://glycoverse.github.io/glystats/reference/gly_roc.html)
  results.
- [`plot_tsne()`](https://glycoverse.github.io/glyvis/reference/plot_tsne.md)
  now supports
  [`glystats::gly_tsne()`](https://glycoverse.github.io/glystats/reference/gly_tsne.html)
  results.
- [`plot_umap()`](https://glycoverse.github.io/glyvis/reference/plot_umap.md)
  now supports
  [`glystats::gly_umap()`](https://glycoverse.github.io/glystats/reference/gly_umap.html)
  results.
- [`plot_volcano()`](https://glycoverse.github.io/glyvis/reference/plot_volcano.md)
  now supports
  [`glystats::gly_ttest()`](https://glycoverse.github.io/glystats/reference/gly_ttest.html),
  [`glystats::gly_wilcox()`](https://glycoverse.github.io/glystats/reference/gly_wilcox.html),
  or
  [`glystats::gly_limma()`](https://glycoverse.github.io/glystats/reference/gly_limma.html)
  results.
- Add a `stats_args` parameter to
  [`plot_corrplot()`](https://glycoverse.github.io/glyvis/reference/plot_corrplot.md),
  [`plot_pca()`](https://glycoverse.github.io/glyvis/reference/plot_pca.md),
  [`plot_roc()`](https://glycoverse.github.io/glyvis/reference/plot_roc.md),
  [`plot_tsne()`](https://glycoverse.github.io/glyvis/reference/plot_tsne.md),
  [`plot_umap()`](https://glycoverse.github.io/glyvis/reference/plot_umap.md),
  and
  [`plot_volcano()`](https://glycoverse.github.io/glyvis/reference/plot_volcano.md),
  to support specifying arguments for underlying glystats functions.
- `...` in all `plot_xxx()` functions is passed to underlying plotting
  functions (if any).

### Minor improvements and bug fixes

- Add descriptions about supported data types in the documentation of
  all `plot_xxx()` functions.
- Fix some inconsistent argument passiing in `plot_xxx()` functions.

## glyvis 0.3.1

### Minor improvements and bug fixes

- Fix bugs introduced by the breaking changes in `glyexp` 0.10.0.

## glyvis 0.3.0

### New features

- Add a `test` parameter to
  [`plot_volcano()`](https://glycoverse.github.io/glyvis/reference/plot_volcano.md)
  to specify the statistical test type.
- Add
  [`plot_boxplot()`](https://glycoverse.github.io/glyvis/reference/plot_boxplot.md)
  to plot grouped boxplots for experiment objects.
- ROC curves can be plotted for
  [`glystats::gly_roc()`](https://glycoverse.github.io/glystats/reference/gly_roc.html)
  results using
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  now.
- Add
  [`plot_roc()`](https://glycoverse.github.io/glyvis/reference/plot_roc.md)
  to plot ROC curves directly from experiment objects.

### Minor improvements and bug fixes

- Better volcano plots using `EnhancedVolcano` package.
- Fix the inconsistent behaviour of plotting experiment objects with
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html).
  Previously, boxplots were actually plotted when `type = "barplot"`.
  Now boxplots grouped by the group column are plotted, faceted by
  variables, when `type = "boxplot"`.
- Use
  [`rlang::check_installed()`](https://rlang.r-lib.org/reference/is_installed.html)
  for better optional dependency checking.

## glyvis 0.2.1

### Minor improvements and bug fixes

- Adapt to the breaking changes in `glystats` v0.5.0.

## glyvis 0.2.0

### New features

- Add
  [`plot_logo()`](https://glycoverse.github.io/glyvis/reference/plot_logo.md)
  to plot logo plots for glycosites.

### Minor improvements and bug fixes

- Re-export
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  from `ggplot2` to prevent the ‘could not find function “autoplot”’
  error when `ggplot2` is not loaded.
- Add a Get Started vignette.

## glyvis 0.1.2

### Minor improvements and bug fixes

- Update dependencies to depend on release versions of glycoverse
  packages.

## glyvis 0.1.1

### Minor improvements and bug fixes

- Fix bugs in tests introduced by `glyexp` v0.8.0.

## glyvis 0.1.0

- First release.

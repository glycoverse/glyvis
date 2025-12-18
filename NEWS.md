# glyvis (development version)

# glyvis 0.4.2

## Minor improvements and bug fixes

* Fix the bug that `plot_volcano()` cannot correctly handle the `contrast` argument for `glystats::gly_limma()` results.
* Fix the bug that `autoplot()` method for `glystats::gly_limma()` results does not work.

# glyvis 0.4.1

## Minor improvements and bug fixes

* `plot_volcano()` now supports `glystats::gly_limma()` results with multiple contrasts.
* Use `pheatmap` and `ggplotify` in `plot_heatmap()` to plot heatmaps.
* Remove `autoplot()` for `glystats_wgcna_res` objects for now. It will be re-implemented in the future with more features.

# glyvis 0.4.0

We redesign most `plot_xxx()` functions to make them more flexible. Previously, these functions only accepts a `glyexp::experiment()` object. Now, they also accept corresponding `glystats` results, to be more intuitive and convenient.

We also redesign the argument passing strategies in `plot_xxx()` functions, making clear separation between underlying statistical functions and plotting functions.

## New features

* Add `plot_oplsda()` to plot OPLS-DA plot from `glyexp::experiment()` or `glystats::gly_oplsda()` results.
* Add `plot_plsda()` to plot PLS-DA plot from `glyexp::experiment()` or `glystats::gly_plsda()` results.
* Add `plot_enrich()` to plot dotplot, barplot, or network plot from `glyexp::experiment()` or `glystats` enrichment functions (`glystats::gly_enrich_go()`, `glystats::gly_enrich_kegg()`, `glystats::gly_enrich_reactome()`).
* `plot_corrplot()` now supports `glystats::gly_cor()` results.
* `plot_pca()` now supports `glystats::gly_pca()` results.
* `plot_roc()` now supports `glystats::gly_roc()` results.
* `plot_tsne()` now supports `glystats::gly_tsne()` results.
* `plot_umap()` now supports `glystats::gly_umap()` results.
* `plot_volcano()` now supports `glystats::gly_ttest()`, `glystats::gly_wilcox()`, or `glystats::gly_limma()` results.
* Add a `stats_args` parameter to `plot_corrplot()`, `plot_pca()`, `plot_roc()`, `plot_tsne()`, `plot_umap()`, and `plot_volcano()`, to support specifying arguments for underlying glystats functions.
* `...` in all `plot_xxx()` functions is passed to underlying plotting functions (if any).

## Minor improvements and bug fixes

* Add descriptions about supported data types in the documentation of all `plot_xxx()` functions.
* Fix some inconsistent argument passiing in `plot_xxx()` functions.

# glyvis 0.3.1

## Minor improvements and bug fixes

* Fix bugs introduced by the breaking changes in `glyexp` 0.10.0.

# glyvis 0.3.0

## New features

* Add a `test` parameter to `plot_volcano()` to specify the statistical test type.
* Add `plot_boxplot()` to plot grouped boxplots for experiment objects.
* ROC curves can be plotted for `glystats::gly_roc()` results using `autoplot()` now.
* Add `plot_roc()` to plot ROC curves directly from experiment objects.

## Minor improvements and bug fixes

* Better volcano plots using `EnhancedVolcano` package.
* Fix the inconsistent behaviour of plotting experiment objects with `autoplot()`. Previously, boxplots were actually plotted when `type = "barplot"`. Now boxplots grouped by the group column are plotted, faceted by variables, when `type = "boxplot"`.
* Use `rlang::check_installed()` for better optional dependency checking.

# glyvis 0.2.1

## Minor improvements and bug fixes

* Adapt to the breaking changes in `glystats` v0.5.0.

# glyvis 0.2.0

## New features

* Add `plot_logo()` to plot logo plots for glycosites.

## Minor improvements and bug fixes

* Re-export `autoplot()` from `ggplot2` to prevent the 'could not find function "autoplot"' error when `ggplot2` is not loaded.
* Add a Get Started vignette.

# glyvis 0.1.2

## Minor improvements and bug fixes

* Update dependencies to depend on release versions of glycoverse packages.

# glyvis 0.1.1

## Minor improvements and bug fixes

* Fix bugs in tests introduced by `glyexp` v0.8.0.

# glyvis 0.1.0

* First release.

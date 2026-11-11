# glyvis (development version)

* New `plot_fuc_sia_pie()` summarizes four fucosylation/sialylation categories from `glycan_composition`, with distinct composition or site-specific glycoform counts, optional pooled abundance weighting, and text annotations. Sialylation includes both NeuAc and NeuGc. (#28)
* New `plot_o_type_pie()` plots O-GalNAc core distributions with glycan cartoons, equal or abundance weighting, and `core_set = "4cores"` (Core 1–4) or `"8cores"` (Core 1–8). (#27)

* New `plot_top10_bar()` shows the top ten N-glycans in glycoproteomic data by site-specific glycoform count or pooled abundance, with independently ranked mirrored bars including and excluding oligomannose, glycan cartoons, and the default glyvis colours. (#30)

* New `plot_glycans_per_site()` and `plot_sites_per_protein()` summarize GlycoproteomicSE glycan and site counts in fixed bins from 1 through 7 and >=8, with optional pooled abundance weighting. Glycan counts prefer structures and fall back to compositions with a message when structural annotations are absent or incomplete. (#26)

* New `plot_n_core_pie()`, `plot_n_type_pie()`, and `plot_n_branch_bar()` summarize N-glycan core, type, and branch distributions with glydraw cartoons, using distinct glycan/site-specific glycoform counts or pooled abundances calculated with glydet. Branch bars use one colour and are ordered from highest to lowest value. (#26)

* `plot_boxplot()` gains a `variables` argument to select SummarizedExperiment rows by name before applying the 25-variable limit. (#25)

* `plot_logo()` now explains UniProt sequence lookup failures and suggests retrying or using a local FASTA, while retaining the original error for diagnosis.

# glyvis 0.8.0

## Breaking changes

* `plot_*()` and `autoplot()` now return composable `tidyplot` objects; arguments specific to the former plotting backends error, so use the common options in `?glyvis_plot_options` or tidyplots adjustment functions instead, and pass logo geometry options in `logo_args`. (#8)
* `plot_heatmap()` retains clustering order but no longer embeds dendrograms; use the hierarchical-clustering `autoplot()` method to display a tree. (#8)

## New features

* Boxplots, heatmaps, and their container `autoplot()` methods accept `log_transform = NULL`. Raw or legacy inputs use `log2(x + 1e-6)` instead of `log2(x + 1)` by default; recorded `log`, `log2`, `log10`, and `logx` values are not logged twice. `FALSE` preserves input values, while `TRUE` warns and is ignored for already logged inputs. Labels now reflect the selected scale.
* `plot_*()` and `autoplot()` use tidyplots with its default 50 by 50 mm plot areas, consistent typography, palettes, white backgrounds, and common styling options; named palettes preserve group colors across subsets. (#8)
* `plot_boxplot()` shows individual observations, removes redundant legends, wraps long facet labels, and accepts facet layout options. (#8)
* `plot_heatmap()` uses symmetric color limits for standardized values, preserves missing cells, and hides column labels automatically above 40 samples. (#8)
* `plot_pca()` and other score plots emphasize observations with optional labels and ellipses; loading and ranked plots retain all variables unless `top_n` is explicitly supplied. (#8)

## Minor improvements and bug fixes

* SE fortification uses `.sample` and `.variable` axis IDs and preserves ordinary annotations. Direct boxplots select grouping values from `colData`, including `sample` or columns that collide with plotting fields; legacy experiment output is unchanged. (#23)
* Statistical plots support glystats results with `.variable` and `.sample` identity columns, retaining ordinary `variable`/`sample` annotations and compatibility with saved legacy results. (#22)
* Fortifying experiment containers joins annotations by position, avoiding row multiplication and metadata misalignment when sample or feature names are duplicated.
* Volcano plots now fail clearly when the selected comparison has no available `log2fc` values, including `logx` results and raw-scale limma analyses, instead of returning an empty plot. Partially missing fold changes remain supported.
* Container-based limma volcano plots now require a contrast when multiple comparisons are present and honor an explicit `contrast`, matching the result-based plotting method.
* `plot_boxplot()` now plots log2-transformed abundance values with a matching axis label. (#7)
* `plot_corrplot()` and correlation `autoplot()` methods now display the supplied correlation coefficients without recomputing correlations; `plot_corrplot()` forwards plotting options. (#7)
* `plot_heatmap()` now allows supplied options to override defaults, including row labels, scaling, clustering, and missing-value colors. (#7)
* `plot_pca()` now forwards explicit groups, group columns, and plotting options consistently across supported inputs. (#7)

# glyvis 0.7.2

* Documentation now recommends `GlycomicSE` and `GlycoproteomicSE` containers for Stage II of glycoverse/glyexp#15. (#6)

# glyvis 0.7.1

* `plot_logo()` now recognizes glycoproteomics experiments consistently across legacy and current `glyexp` containers.

# glyvis 0.7.0

## New features

* Experiment visualization methods now accept `SummarizedExperiment` inputs, including `GlycomicSE` and `GlycoproteomicSE`; `plot_logo()` remains limited to glycoproteomics data. (#5)

## Breaking changes

* Remove enrichment plotting functions and methods because the corresponding `glystats::gly_enrich_*()` functions have been removed. (#4)

## Minor improvements and bug fixes

* `plot_corrplot()` now preserves feature labels that are not syntactic R identifiers.

# glyvis 0.6.0

## Breaking changes

* Remove stale `autoplot()` methods for `glystats_cc_res` and `glystats_wgcna_res` objects because the corresponding `glystats` functions have been removed.

# glyvis 0.5.1

## Minor improvements and bug fixes

* Update dependency strategy to use the r-universe repo.

# glyvis 0.5.0

## New features

* `plot_logo()` now fetches protein sequences from Uniprot automatically if a fasta file is not provided.

# glyvis 0.4.5

## Minor improvements and bug fixes

* Fix the bug that `plot_heatmap()` cannot handle NA values. Now a more robust clustering method is used and zero-variance variables are removed.

# glyvis 0.4.4

## Minor improvements and bug fixes

* Suppress harmless warnings in `plot_volcano()` and `plot_pca()`.

# glyvis 0.4.3

## Minor improvements and bug fixes

* Fix the bug that `plot_heatmap()` always sends the plot to the plot panel even when the result is passed to a variable.

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

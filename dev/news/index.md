# Changelog

## glyvis (development version)

- Plots use the tidyplots default palettes, with blue–white–red from
  [`tidyplots::colors_diverging_BuRd`](https://jbengler.github.io/tidyplots/reference/colors_diverging_blue2red.html)
  for heatmaps and correlation plots, and grey for unchanged points in
  volcano plots. (#34)

- [`plot_heatmap()`](https://glycoverse.github.io/glyvis/dev/reference/plot_heatmap.md)
  and container
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  methods gain `row_cluster_tree` and `col_cluster_tree`, both
  defaulting to `TRUE`, to display clustering trees independently of
  clustering order. (#33)

- All public plotting controls now follow `...` and must be supplied by
  their full argument names; replace positional calls such as
  `plot_pca(x, "biplot")` with `plot_pca(x, type = "biplot")`. (#32)

- Plot-specific options are now explicit named arguments in `plot_*()`
  functions and their
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  methods, with defaults and descriptions in each help page. Common
  styling options are also explicit arguments, share documentation via
  `@inheritParams`, and unused arguments in `...` now error at the
  plotting entry point. (#32)

- New
  [`plot_isomers_per_comp()`](https://glycoverse.github.io/glyvis/dev/reference/plot_isomers_per_comp.md)
  counts distinct annotated structures per composition across samples,
  proteins, and sites, using fixed bins from 1 through 7 and \>=8 with
  optional pooled abundance weighting. (#31)

- New
  [`plot_n_branch_pie()`](https://glycoverse.github.io/glyvis/dev/reference/plot_n_core_pie.md)
  summarizes N-glycans by antenna count using equal glycan/site-specific
  glycoform counts or pooled abundance weights, with fixed
  core-and-antenna cartoons for zero to four antennae. (#29)

- New
  [`plot_fuc_sia_pie()`](https://glycoverse.github.io/glyvis/dev/reference/plot_fuc_sia_pie.md)
  summarizes four fucosylation/sialylation categories from
  `glycan_composition`, with distinct composition or site-specific
  glycoform counts, optional pooled abundance weighting, and text
  annotations. Sialylation includes both NeuAc and NeuGc. (#28)

- New
  [`plot_o_type_pie()`](https://glycoverse.github.io/glyvis/dev/reference/plot_o_type_pie.md)
  plots O-GalNAc core distributions with glycan cartoons, equal or
  abundance weighting, and `core_set = "4cores"` (Core 1–4) or
  `"8cores"` (Core 1–8). (#27)

- New
  [`plot_top10_bar()`](https://glycoverse.github.io/glyvis/dev/reference/plot_top10_bar.md)
  shows the top ten N-glycans in glycoproteomic data by site-specific
  glycoform count or pooled abundance, with independently ranked
  mirrored bars including and excluding oligomannose, glycan cartoons,
  and the default glyvis colours. (#30)

- New
  [`plot_glycans_per_site()`](https://glycoverse.github.io/glyvis/dev/reference/plot_glycans_per_site.md)
  and
  [`plot_sites_per_protein()`](https://glycoverse.github.io/glyvis/dev/reference/plot_glycans_per_site.md)
  summarize GlycoproteomicSE glycan and site counts in fixed bins from 1
  through 7 and \>=8, with optional pooled abundance weighting. Glycan
  counts prefer structures and fall back to compositions with a message
  when structural annotations are absent or incomplete. (#26)

- New
  [`plot_n_core_pie()`](https://glycoverse.github.io/glyvis/dev/reference/plot_n_core_pie.md),
  [`plot_n_type_pie()`](https://glycoverse.github.io/glyvis/dev/reference/plot_n_core_pie.md),
  and
  [`plot_n_branch_bar()`](https://glycoverse.github.io/glyvis/dev/reference/plot_n_core_pie.md)
  summarize N-glycan core, type, and branch distributions with glydraw
  cartoons, using distinct glycan/site-specific glycoform counts or
  pooled abundances calculated with glydet. Branch bars use one colour
  and are ordered from highest to lowest value. (#26)

- [`plot_boxplot()`](https://glycoverse.github.io/glyvis/dev/reference/plot_boxplot.md)
  gains a `variables` argument to select SummarizedExperiment rows by
  name before applying the 25-variable limit. (#25)

- [`plot_logo()`](https://glycoverse.github.io/glyvis/dev/reference/plot_logo.md)
  now explains UniProt sequence lookup failures and suggests retrying or
  using a local FASTA, while retaining the original error for diagnosis.

## glyvis 0.8.0

### Breaking changes

- `plot_*()` and
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  now return composable `tidyplot` objects; arguments specific to the
  former plotting backends error, so use the common options in
  [`?glyvis_plot_options`](https://glycoverse.github.io/glyvis/dev/reference/glyvis_plot_options.md)
  or tidyplots adjustment functions instead, and pass logo geometry
  options in `logo_args`. (#8)
- [`plot_heatmap()`](https://glycoverse.github.io/glyvis/dev/reference/plot_heatmap.md)
  retains clustering order but no longer embeds dendrograms; use the
  hierarchical-clustering
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  method to display a tree. (#8)

### New features

- Boxplots, heatmaps, and their container
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  methods accept `log_transform = NULL`. Raw or legacy inputs use
  `log2(x + 1e-6)` instead of `log2(x + 1)` by default; recorded `log`,
  `log2`, `log10`, and `logx` values are not logged twice. `FALSE`
  preserves input values, while `TRUE` warns and is ignored for already
  logged inputs. Labels now reflect the selected scale.
- `plot_*()` and
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  use tidyplots with its default 50 by 50 mm plot areas, consistent
  typography, palettes, white backgrounds, and common styling options;
  named palettes preserve group colors across subsets. (#8)
- [`plot_boxplot()`](https://glycoverse.github.io/glyvis/dev/reference/plot_boxplot.md)
  shows individual observations, removes redundant legends, wraps long
  facet labels, and accepts facet layout options. (#8)
- [`plot_heatmap()`](https://glycoverse.github.io/glyvis/dev/reference/plot_heatmap.md)
  uses symmetric color limits for standardized values, preserves missing
  cells, and hides column labels automatically above 40 samples. (#8)
- [`plot_pca()`](https://glycoverse.github.io/glyvis/dev/reference/plot_pca.md)
  and other score plots emphasize observations with optional labels and
  ellipses; loading and ranked plots retain all variables unless `top_n`
  is explicitly supplied. (#8)

### Minor improvements and bug fixes

- SE fortification uses `.sample` and `.variable` axis IDs and preserves
  ordinary annotations. Direct boxplots select grouping values from
  `colData`, including `sample` or columns that collide with plotting
  fields; legacy experiment output is unchanged. (#23)
- Statistical plots support glystats results with `.variable` and
  `.sample` identity columns, retaining ordinary `variable`/`sample`
  annotations and compatibility with saved legacy results. (#22)
- Fortifying experiment containers joins annotations by position,
  avoiding row multiplication and metadata misalignment when sample or
  feature names are duplicated.
- Volcano plots now fail clearly when the selected comparison has no
  available `log2fc` values, including `logx` results and raw-scale
  limma analyses, instead of returning an empty plot. Partially missing
  fold changes remain supported.
- Container-based limma volcano plots now require a contrast when
  multiple comparisons are present and honor an explicit `contrast`,
  matching the result-based plotting method.
- [`plot_boxplot()`](https://glycoverse.github.io/glyvis/dev/reference/plot_boxplot.md)
  now plots log2-transformed abundance values with a matching axis
  label. (#7)
- [`plot_corrplot()`](https://glycoverse.github.io/glyvis/dev/reference/plot_corrplot.md)
  and correlation
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  methods now display the supplied correlation coefficients without
  recomputing correlations;
  [`plot_corrplot()`](https://glycoverse.github.io/glyvis/dev/reference/plot_corrplot.md)
  forwards plotting options. (#7)
- [`plot_heatmap()`](https://glycoverse.github.io/glyvis/dev/reference/plot_heatmap.md)
  now allows supplied options to override defaults, including row
  labels, scaling, clustering, and missing-value colors. (#7)
- [`plot_pca()`](https://glycoverse.github.io/glyvis/dev/reference/plot_pca.md)
  now forwards explicit groups, group columns, and plotting options
  consistently across supported inputs. (#7)

## glyvis 0.7.2

- Documentation now recommends `GlycomicSE` and `GlycoproteomicSE`
  containers for Stage II of glycoverse/glyexp#15. (#6)

## glyvis 0.7.1

- [`plot_logo()`](https://glycoverse.github.io/glyvis/dev/reference/plot_logo.md)
  now recognizes glycoproteomics experiments consistently across legacy
  and current `glyexp` containers.

## glyvis 0.7.0

### New features

- Experiment visualization methods now accept `SummarizedExperiment`
  inputs, including `GlycomicSE` and `GlycoproteomicSE`;
  [`plot_logo()`](https://glycoverse.github.io/glyvis/dev/reference/plot_logo.md)
  remains limited to glycoproteomics data. (#5)

### Breaking changes

- Remove enrichment plotting functions and methods because the
  corresponding `glystats::gly_enrich_*()` functions have been removed.
  (#4)

### Minor improvements and bug fixes

- [`plot_corrplot()`](https://glycoverse.github.io/glyvis/dev/reference/plot_corrplot.md)
  now preserves feature labels that are not syntactic R identifiers.

## glyvis 0.6.0

### Breaking changes

- Remove stale
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  methods for `glystats_cc_res` and `glystats_wgcna_res` objects because
  the corresponding `glystats` functions have been removed.

## glyvis 0.5.1

### Minor improvements and bug fixes

- Update dependency strategy to use the r-universe repo.

## glyvis 0.5.0

### New features

- [`plot_logo()`](https://glycoverse.github.io/glyvis/dev/reference/plot_logo.md)
  now fetches protein sequences from Uniprot automatically if a fasta
  file is not provided.

## glyvis 0.4.5

### Minor improvements and bug fixes

- Fix the bug that
  [`plot_heatmap()`](https://glycoverse.github.io/glyvis/dev/reference/plot_heatmap.md)
  cannot handle NA values. Now a more robust clustering method is used
  and zero-variance variables are removed.

## glyvis 0.4.4

### Minor improvements and bug fixes

- Suppress harmless warnings in
  [`plot_volcano()`](https://glycoverse.github.io/glyvis/dev/reference/plot_volcano.md)
  and
  [`plot_pca()`](https://glycoverse.github.io/glyvis/dev/reference/plot_pca.md).

## glyvis 0.4.3

### Minor improvements and bug fixes

- Fix the bug that
  [`plot_heatmap()`](https://glycoverse.github.io/glyvis/dev/reference/plot_heatmap.md)
  always sends the plot to the plot panel even when the result is passed
  to a variable.

## glyvis 0.4.2

### Minor improvements and bug fixes

- Fix the bug that
  [`plot_volcano()`](https://glycoverse.github.io/glyvis/dev/reference/plot_volcano.md)
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

- [`plot_volcano()`](https://glycoverse.github.io/glyvis/dev/reference/plot_volcano.md)
  now supports
  [`glystats::gly_limma()`](https://glycoverse.github.io/glystats/reference/gly_limma.html)
  results with multiple contrasts.
- Use `pheatmap` and `ggplotify` in
  [`plot_heatmap()`](https://glycoverse.github.io/glyvis/dev/reference/plot_heatmap.md)
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
  [`plot_oplsda()`](https://glycoverse.github.io/glyvis/dev/reference/plot_oplsda.md)
  to plot OPLS-DA plot from
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html)
  or
  [`glystats::gly_oplsda()`](https://glycoverse.github.io/glystats/reference/gly_oplsda.html)
  results.
- Add
  [`plot_plsda()`](https://glycoverse.github.io/glyvis/dev/reference/plot_plsda.md)
  to plot PLS-DA plot from
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html)
  or
  [`glystats::gly_plsda()`](https://glycoverse.github.io/glystats/reference/gly_plsda.html)
  results.
- Add `plot_enrich()` to plot dotplot, barplot, or network plot from
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html)
  or `glystats` enrichment functions (`glystats::gly_enrich_go()`,
  `glystats::gly_enrich_kegg()`, `glystats::gly_enrich_reactome()`).
- [`plot_corrplot()`](https://glycoverse.github.io/glyvis/dev/reference/plot_corrplot.md)
  now supports
  [`glystats::gly_cor()`](https://glycoverse.github.io/glystats/reference/gly_cor.html)
  results.
- [`plot_pca()`](https://glycoverse.github.io/glyvis/dev/reference/plot_pca.md)
  now supports
  [`glystats::gly_pca()`](https://glycoverse.github.io/glystats/reference/gly_pca.html)
  results.
- [`plot_roc()`](https://glycoverse.github.io/glyvis/dev/reference/plot_roc.md)
  now supports
  [`glystats::gly_roc()`](https://glycoverse.github.io/glystats/reference/gly_roc.html)
  results.
- [`plot_tsne()`](https://glycoverse.github.io/glyvis/dev/reference/plot_tsne.md)
  now supports
  [`glystats::gly_tsne()`](https://glycoverse.github.io/glystats/reference/gly_tsne.html)
  results.
- [`plot_umap()`](https://glycoverse.github.io/glyvis/dev/reference/plot_umap.md)
  now supports
  [`glystats::gly_umap()`](https://glycoverse.github.io/glystats/reference/gly_umap.html)
  results.
- [`plot_volcano()`](https://glycoverse.github.io/glyvis/dev/reference/plot_volcano.md)
  now supports
  [`glystats::gly_ttest()`](https://glycoverse.github.io/glystats/reference/gly_ttest.html),
  [`glystats::gly_wilcox()`](https://glycoverse.github.io/glystats/reference/gly_wilcox.html),
  or
  [`glystats::gly_limma()`](https://glycoverse.github.io/glystats/reference/gly_limma.html)
  results.
- Add a `stats_args` parameter to
  [`plot_corrplot()`](https://glycoverse.github.io/glyvis/dev/reference/plot_corrplot.md),
  [`plot_pca()`](https://glycoverse.github.io/glyvis/dev/reference/plot_pca.md),
  [`plot_roc()`](https://glycoverse.github.io/glyvis/dev/reference/plot_roc.md),
  [`plot_tsne()`](https://glycoverse.github.io/glyvis/dev/reference/plot_tsne.md),
  [`plot_umap()`](https://glycoverse.github.io/glyvis/dev/reference/plot_umap.md),
  and
  [`plot_volcano()`](https://glycoverse.github.io/glyvis/dev/reference/plot_volcano.md),
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
  [`plot_volcano()`](https://glycoverse.github.io/glyvis/dev/reference/plot_volcano.md)
  to specify the statistical test type.
- Add
  [`plot_boxplot()`](https://glycoverse.github.io/glyvis/dev/reference/plot_boxplot.md)
  to plot grouped boxplots for experiment objects.
- ROC curves can be plotted for
  [`glystats::gly_roc()`](https://glycoverse.github.io/glystats/reference/gly_roc.html)
  results using
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  now.
- Add
  [`plot_roc()`](https://glycoverse.github.io/glyvis/dev/reference/plot_roc.md)
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
  [`plot_logo()`](https://glycoverse.github.io/glyvis/dev/reference/plot_logo.md)
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

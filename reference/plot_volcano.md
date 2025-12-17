# Volcano Plot

Draw a volcano plot. Currently supported data types:

- `glystats_ttest_res`: Result from
  [`glystats::gly_ttest()`](https://glycoverse.github.io/glystats/reference/gly_ttest.html).

- `glystats_wilcox_res`: Result from
  [`glystats::gly_wilcox()`](https://glycoverse.github.io/glystats/reference/gly_wilcox.html).

- `glystats_limma_res`: Result from
  [`glystats::gly_limma()`](https://glycoverse.github.io/glystats/reference/gly_limma.html).
  Only two-group comparisons are supported.

- `glyexp_experiment`: Experiment created by
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html).
  Differential expression analysis is first performed using
  [`glystats::gly_ttest()`](https://glycoverse.github.io/glystats/reference/gly_ttest.html),
  [`glystats::gly_wilcox()`](https://glycoverse.github.io/glystats/reference/gly_wilcox.html),
  or
  [`glystats::gly_limma()`](https://glycoverse.github.io/glystats/reference/gly_limma.html)
  (controlled by the `test` argument), then the result is plotted.

## Usage

``` r
plot_volcano(x, log2fc_cutoff = 1, p_cutoff = 0.05, p_col = "p_adj", ...)

# S3 method for class 'glyexp_experiment'
plot_volcano(
  x,
  log2fc_cutoff = 1,
  p_cutoff = 0.05,
  p_col = "p_adj",
  test = "limma",
  stats_args = list(),
  ...
)

# S3 method for class 'glystats_ttest_res'
plot_volcano(x, log2fc_cutoff = 1, p_cutoff = 0.05, p_col = "p_adj", ...)

# S3 method for class 'glystats_wilcox_res'
plot_volcano(x, log2fc_cutoff = 1, p_cutoff = 0.05, p_col = "p_adj", ...)

# S3 method for class 'glystats_limma_res'
plot_volcano(
  x,
  contrast,
  log2fc_cutoff = 1,
  p_cutoff = 0.05,
  p_col = "p_adj",
  ...
)
```

## Arguments

- x:

  An object to be plotted.

- log2fc_cutoff:

  The log2 fold change cutoff. Defaults to 1.

- p_cutoff:

  The p-value cutoff. Defaults to 0.05.

- p_col:

  The column name for p-value. Defaults to "p_adj". Can also be "p_val"
  (raw p-values without multiple testing correction).

- ...:

  Other arguments passed to
  [`EnhancedVolcano::EnhancedVolcano()`](https://rdrr.io/pkg/EnhancedVolcano/man/EnhancedVolcano.html).

- test:

  "ttest", "wilcox", or "limma". Default is "limma".

- stats_args:

  A list of keyword arguments to pass to
  [`glystats::gly_ttest()`](https://glycoverse.github.io/glystats/reference/gly_ttest.html),
  [`glystats::gly_wilcox()`](https://glycoverse.github.io/glystats/reference/gly_wilcox.html),
  or
  [`glystats::gly_limma()`](https://glycoverse.github.io/glystats/reference/gly_limma.html).

- contrast:

  A character string specifying the contrast to plot, in the format of
  "group1_vs_group2".

## Value

A ggplot object.

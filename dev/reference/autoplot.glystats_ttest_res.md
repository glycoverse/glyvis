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
autoplot(object, log2fc_cutoff = 1, p_cutoff = 0.05, p_col = "p_adj", ...)

# S3 method for class 'glystats_wilcox_res'
autoplot(object, log2fc_cutoff = 1, p_cutoff = 0.05, p_col = "p_adj", ...)
```

## Arguments

- object:

  A `glystats_ttest_res` or `glystats_wilcox_res` object.

- log2fc_cutoff:

  The log2 fold change cutoff. Defaults to 1.

- p_cutoff:

  The p-value cutoff. Defaults to 0.05.

- p_col:

  The column name for p-value. Defaults to "p_adj". Can also be "p_val"
  (raw p-values without multiple testing correction).

- ...:

  Ignored.

## Value

A ggplot object.

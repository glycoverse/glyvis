# Plots for Multi-Group Differential Expression Analysis (DEA)

Visualization for `glystats_anova_res` and `glystats_kruskal_res`. Draw
a dotchart for p-values.

## Usage

``` r
# S3 method for class 'glystats_anova_res'
autoplot(object, p_cutoff = 0.05, p_col = "p_adj", ...)

# S3 method for class 'glystats_kruskal_res'
autoplot(object, p_cutoff = 0.05, p_col = "p_adj", ...)
```

## Arguments

- object:

  A `glystats_anova_res` or `glystats_kruskal_res` object.

- p_cutoff:

  The p-value cutoff. Defaults to 0.05.

- p_col:

  The column name for p-value. Defaults to "p_adj". Can also be "p_val"
  (raw p-values without multiple testing correction).

- ...:

  Other arguments passed to underlying functions.

## Value

A ggplot object.

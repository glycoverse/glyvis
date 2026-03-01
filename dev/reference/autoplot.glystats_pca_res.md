# Plots for Principal Component Analysis (PCA)

Visualization for
[`glystats::gly_pca()`](https://glycoverse.github.io/glystats/reference/gly_pca.html)
results (`glystats_pca_res` object). Possible `type`s of plots:

- "screeplot": Scree plot to see the contribution of each PC.

- "individual" (default): Plot samples as individuals.

- "variables": Plot loadings for variables.

- "biplot": Biplot showing both samples and variables.

## Usage

``` r
# S3 method for class 'glystats_pca_res'
autoplot(object, type = "individual", groups = NULL, group_col = NULL, ...)
```

## Arguments

- object:

  A `glystats_pca_res` object.

- type:

  The type of plot, one of "screeplot", "individual", "variables", or
  "biplot".

- groups:

  A factor or character vector specifying group membership for each
  sample. If provided, the plot will be colored by group. Only
  applicable to "individual" and "biplot" types. Passed to the
  `habillage` paramter of
  [`factoextra::fviz_pca_ind()`](https://rdrr.io/pkg/factoextra/man/fviz_pca.html)
  or
  [`factoextra::fviz_pca_biplot()`](https://rdrr.io/pkg/factoextra/man/fviz_pca.html).

- group_col:

  A character string specifying where to find the group information. If
  you uses
  [`glystats::gly_pca()`](https://glycoverse.github.io/glystats/reference/gly_pca.html)
  on a
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html)
  to get the result, sample information has already been added to the
  result. In this case, you can specify the column name in the sample
  information tibble to be used for coloring. If not provided, this
  function will try "group".

- ...:

  Other arguments passed to factoextra functions.

  - For "screeplot", see
    [`factoextra::fviz_screeplot()`](https://rdrr.io/pkg/factoextra/man/eigenvalue.html).

  - For "individual", see
    [`factoextra::fviz_pca_ind()`](https://rdrr.io/pkg/factoextra/man/fviz_pca.html).

  - For "variables", see
    [`factoextra::fviz_pca_var()`](https://rdrr.io/pkg/factoextra/man/fviz_pca.html).

  - For "biplot", see
    [`factoextra::fviz_pca_biplot()`](https://rdrr.io/pkg/factoextra/man/fviz_pca.html).

## Value

A ggplot object.

## See also

[`factoextra::fviz_screeplot()`](https://rdrr.io/pkg/factoextra/man/eigenvalue.html),
[`factoextra::fviz_pca_ind()`](https://rdrr.io/pkg/factoextra/man/fviz_pca.html),
[`factoextra::fviz_pca_var()`](https://rdrr.io/pkg/factoextra/man/fviz_pca.html),
[`factoextra::fviz_pca_biplot()`](https://rdrr.io/pkg/factoextra/man/fviz_pca.html)

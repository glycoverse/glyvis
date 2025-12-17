# PCA Plot

Draw a PCA scores plot. Currently supported data types:

- `glystats_pca_res`: Result from
  [`glystats::gly_pca()`](https://glycoverse.github.io/glystats/reference/gly_pca.html).

- `glyexp_experiment`: Experiment created by
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html).
  PCA analysis is first performed using
  [`glystats::gly_pca()`](https://glycoverse.github.io/glystats/reference/gly_pca.html),
  then the result is plotted.

## Usage

``` r
plot_pca(x, type = "individual", groups = NULL, group_col = NULL, ...)

# S3 method for class 'glystats_pca_res'
plot_pca(x, type = "individual", groups = NULL, group_col = NULL, ...)

# S3 method for class 'glyexp_experiment'
plot_pca(
  x,
  type = "individual",
  groups = NULL,
  group_col = NULL,
  stats_args = list(),
  ...
)
```

## Arguments

- x:

  An object to be plotted.

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

  A character string specifying where to find the group information.

- ...:

  Additional arguments passed to underlying factoextra functions:

  - type = "screeplot":
    [`factoextra::fviz_screeplot()`](https://rdrr.io/pkg/factoextra/man/eigenvalue.html).

  - type = "individual":
    [`factoextra::fviz_pca_ind()`](https://rdrr.io/pkg/factoextra/man/fviz_pca.html).

  - type = "variables":
    [`factoextra::fviz_pca_var()`](https://rdrr.io/pkg/factoextra/man/fviz_pca.html).

  - type = "biplot":
    [`factoextra::fviz_pca_biplot()`](https://rdrr.io/pkg/factoextra/man/fviz_pca.html).

- stats_args:

  A list of keyword arguments to pass to
  [`glystats::gly_pca()`](https://glycoverse.github.io/glystats/reference/gly_pca.html).

## Value

A ggplot object.

## See also

[`factoextra::fviz_screeplot()`](https://rdrr.io/pkg/factoextra/man/eigenvalue.html),
[`factoextra::fviz_pca_ind()`](https://rdrr.io/pkg/factoextra/man/fviz_pca.html),
[`factoextra::fviz_pca_var()`](https://rdrr.io/pkg/factoextra/man/fviz_pca.html),
[`factoextra::fviz_pca_biplot()`](https://rdrr.io/pkg/factoextra/man/fviz_pca.html)

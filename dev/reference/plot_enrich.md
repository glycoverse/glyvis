# Plot Enrichment Analysis Results

Draw a enrichment analysis result plot. Currently supported data types:

- `glystats_go_ora_res`: Result from
  [`glystats::gly_enrich_go()`](https://glycoverse.github.io/glystats/reference/gly_enrich_go.html).

- `glystats_kegg_ora_res`: Result from
  [`glystats::gly_enrich_kegg()`](https://glycoverse.github.io/glystats/reference/gly_enrich_go.html).

- `glystats_reactome_ora_res`: Result from
  [`glystats::gly_enrich_reactome()`](https://glycoverse.github.io/glystats/reference/gly_enrich_go.html).

- `glyexp_experiment`: Experiment created by
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html).
  Enrichment analysis is first performed using
  [`glystats::gly_enrich_go()`](https://glycoverse.github.io/glystats/reference/gly_enrich_go.html),
  [`glystats::gly_enrich_kegg()`](https://glycoverse.github.io/glystats/reference/gly_enrich_go.html),
  or
  [`glystats::gly_enrich_reactome()`](https://glycoverse.github.io/glystats/reference/gly_enrich_go.html),
  then the result is plotted.

## Usage

``` r
plot_enrich(x, type = "dotplot", ...)

# S3 method for class 'glystats_go_ora_res'
plot_enrich(x, type = "dotplot", ...)

# S3 method for class 'glystats_kegg_ora_res'
plot_enrich(x, type = "dotplot", ...)

# S3 method for class 'glystats_reactome_ora_res'
plot_enrich(x, type = "dotplot", ...)

# S3 method for class 'glyexp_experiment'
plot_enrich(x, type = "dotplot", enrich_type = "go", stats_args = list(), ...)
```

## Arguments

- x:

  An object to be plotted.

- type:

  The type of plot, one of "dotplot" (default), "barplot", or "network".

- ...:

  Additional arguments passed to underlying functions:

  - "dotplot":
    [`enrichplot::dotplot()`](https://rdrr.io/pkg/enrichplot/man/dotplot.html)

  - "barplot":
    [`enrichplot::barplot.enrichResult()`](https://rdrr.io/pkg/enrichplot/man/barplot.enrichResult.html)

  - "network":
    [`enrichplot::emapplot()`](https://rdrr.io/pkg/enrichplot/man/emapplot.html)

- enrich_type:

  The type of enrichment analysis, one of "go" (default), "kegg", or
  "reactome".

- stats_args:

  A list of keyword arguments to pass to
  [`glystats::gly_enrich_go()`](https://glycoverse.github.io/glystats/reference/gly_enrich_go.html),
  [`glystats::gly_enrich_kegg()`](https://glycoverse.github.io/glystats/reference/gly_enrich_go.html),
  or
  [`glystats::gly_enrich_reactome()`](https://glycoverse.github.io/glystats/reference/gly_enrich_go.html).

## Value

A ggplot object.

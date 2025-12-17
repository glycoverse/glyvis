# Plots for Enrichment Analysis

Visualization for results from
[`glystats::gly_enrich_go()`](https://glycoverse.github.io/glystats/reference/gly_enrich_go.html),
[`glystats::gly_enrich_kegg()`](https://glycoverse.github.io/glystats/reference/gly_enrich_go.html),
and
[`glystats::gly_enrich_reactome()`](https://glycoverse.github.io/glystats/reference/gly_enrich_go.html)
(`glystats_go_ora_res`, `glystats_kegg_ora_res`, and
`glystats_reactome_ora_res` objects). Possible `type`s of plots:

- "dotplot" (default): Dotplot showing p-value, gene counts, and gene
  ratios.

- "barplot": Barplot showing p-values and gene counts.

- "network": Network plot showing terms and their relationships.

## Usage

``` r
# S3 method for class 'glystats_go_ora_res'
autoplot(object, type = "dotplot", ...)

# S3 method for class 'glystats_kegg_ora_res'
autoplot(object, type = "dotplot", ...)

# S3 method for class 'glystats_reactome_ora_res'
autoplot(object, type = "dotplot", ...)
```

## Arguments

- object:

  A `glystats_go_ora_res`, `glystats_kegg_ora_res`, or
  `glystats_reactome_ora_res` object.

- type:

  The type of plot, one of "dotplot" (default), "barplot", or "network".

- ...:

  Other arguments passed to underlying functions
  ([`enrichplot::dotplot()`](https://rdrr.io/pkg/enrichplot/man/dotplot.html)
  for "dotplot",
  [`enrichplot::barplot.enrichResult()`](https://rdrr.io/pkg/enrichplot/man/barplot.enrichResult.html)
  for "barplot", and
  [`enrichplot::emapplot()`](https://rdrr.io/pkg/enrichplot/man/emapplot.html)
  for "network")

## Value

A ggplot object.

## See also

[`enrichplot::dotplot()`](https://rdrr.io/pkg/enrichplot/man/dotplot.html),
[`enrichplot::barplot.enrichResult()`](https://rdrr.io/pkg/enrichplot/man/barplot.enrichResult.html),
[`enrichplot::emapplot()`](https://rdrr.io/pkg/enrichplot/man/emapplot.html)

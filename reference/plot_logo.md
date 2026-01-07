# Logo Plot

Draw a logo plot for all glycosites. Positions with insufficient
flanking amino acids will be padded with "X". Currently supported data
types:

- `glyexp_experiment`: Experiment created by
  [`glyexp::experiment()`](https://glycoverse.github.io/glyexp/reference/experiment.html).
  Logo plot of glycosylation sites is plotted.

## Usage

``` r
plot_logo(x, n_aa = 5L, fasta = NULL, tax_id = 9606L, ...)

# S3 method for class 'glyexp_experiment'
plot_logo(x, n_aa = 5L, fasta = NULL, tax_id = 9606L, ...)
```

## Arguments

- x:

  An object to be plotted.

- n_aa:

  The number of amino acids to the left and right of the glycosylation
  site. For example, if `n_aa = 5`, the resulting sequence will contain
  11 amino acids.

- fasta:

  The path to the FASTA file containing protein sequences. If
  [`glyclean::add_site_seq()`](https://glycoverse.github.io/glyclean/reference/add_site_seq.html)
  has been called on the experiment, this argument can be omitted. When
  `site_sequence` is missing and `fasta` is `NULL`, UniProt.ws is used
  to fetch protein sequences automatically.

- tax_id:

  The NCBI taxonomy ID used for UniProt.ws lookups. Defaults to 9606.

- ...:

  Additional arguments passed to
  [`ggseqlogo::ggseqlogo()`](https://rdrr.io/pkg/ggseqlogo/man/ggseqlogo.html).

## Value

A ggplot object.

## See also

[`ggseqlogo::ggseqlogo()`](https://rdrr.io/pkg/ggseqlogo/man/ggseqlogo.html)

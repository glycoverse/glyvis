# Logo Plot

Draw a logo plot for all glycosites. Positions with insufficient
flanking amino acids will be padded with "X". Currently supported data
types:

- `SummarizedExperiment`: A
  [`glyexp::GlycoproteomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycoproteomicSE.html)
  or other compatible glycoproteomics container. Logo plot of
  glycosylation sites is plotted.

## Usage

``` r
plot_logo(
  x,
  ...,
  n_aa = 5L,
  fasta = NULL,
  tax_id = 9606L,
  logo_args = list(),
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
)

# S3 method for class 'glyexp_experiment'
plot_logo(
  x,
  ...,
  n_aa = 5L,
  fasta = NULL,
  tax_id = 9606L,
  logo_args = list(),
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
)

# S3 method for class 'GlycoproteomicSE'
plot_logo(
  x,
  ...,
  n_aa = 5L,
  fasta = NULL,
  tax_id = 9606L,
  logo_args = list(),
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
)
```

## Arguments

- x:

  An object to be plotted.

- ...:

  Must be empty. Supply plotting controls by their full argument names.

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

- logo_args:

  Named list of glyph options passed to
  [`ggseqlogo::geom_logo()`](https://rdrr.io/pkg/ggseqlogo/man/geom_logo.html),
  for example `list(method = "prob")`. An explicit
  `logo_args$col_scheme` takes precedence over `palette`.

- title:

  Optional plot title. Defaults to `NULL`.

- width, height:

  Plot-area dimensions in millimetres. `NULL` uses the tidyplots
  defaults (50 by 50 mm); `NA` fills the available graphics device.
  These are not export-page dimensions.

- fontsize:

  Base text size in points. Defaults to 9.

- family:

  Font family. Defaults to `"sans"`.

- palette:

  Color vector. A named vector maps group names to fixed colors across
  plots and subsets; unnamed palettes follow factor order. `NULL` uses
  tidyplots palettes. Heatmaps and correlation plots use the blue,
  near-white, and red anchors of `colors_diverging_BuRd`. Volcano plots
  use grey for points that do not meet both cutoffs. Other plots use the
  tidyplots defaults for discrete and continuous values.

## Value

A `tidyplot` object, also inheriting from `ggplot`.

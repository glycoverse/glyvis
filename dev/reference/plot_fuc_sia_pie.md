# Fucosylation and sialylation distribution

Classify glycans using only their composition and pool all samples.

## Usage

``` r
plot_fuc_sia_pie(
  x,
  ...,
  weight = "equal",
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

  A
  [`glyexp::GlycomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycomicSE.html)
  or
  [`glyexp::GlycoproteomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycoproteomicSE.html)
  with `glycan_composition` row annotations. Legacy `glyexp_experiment`
  objects are also supported. No structure or glycan-type metadata is
  required.

- ...:

  Must be empty. Supply plotting controls by their full argument names.

- weight:

  Either `"equal"` (default) or `"abundance"`. Equal weighting counts
  distinct compositions, or distinct combinations of `protein`,
  `protein_site`, and composition for glycoproteomics. Abundance
  weighting sums raw, linear-scale abundances across all rows and
  samples, including duplicate measurements. Missing abundances are
  omitted; negative and infinite values and recorded non-raw scales are
  rejected.

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

A `tidyplot`, also inheriting from `ggplot`, with `category`, `value`,
and `proportion` in its `data`. All four categories are retained,
including zero-valued categories. Proportions use the total eligible
count or abundance as the denominator.

## Details

Categories are ordered as `Fuc+, Sia+`, `Fuc+, Sia-`, `Fuc-, Sia+`, and
`Fuc-, Sia-`. Fucose is inferred from `dHex` (including concrete Fuc);
sialic acid includes both `NeuAc` and `NeuGc`. Counts greater than zero
indicate presence. This does not distinguish core from antennal fucose.
Each sector is annotated with its Fuc/Sia category and percentage.
Missing compositions are excluded with a warning. Invalid compositions
raise an error. Equal weighting counts annotations regardless of assay
missingness. No sample-wise normalization is applied. Empty eligible
input and non-positive total abundance raise an error.

## Examples

``` r
if (requireNamespace("glyrepr", quietly = TRUE)) {
  plot_fuc_sia_pie(glyexp::real_experiment2)
}
```

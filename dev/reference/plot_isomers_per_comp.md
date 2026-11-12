# Distribution of isomers per glycan composition

Count distinct annotated structures within each glycan composition
across all samples and draw a single-colour bar plot with bins `1` to
`7` and `>=8`.

## Usage

``` r
plot_isomers_per_comp(
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
  with `glycan_composition` and `glycan_structure` row annotations.

- ...:

  Must be empty. Supply plotting controls by their full argument names.

- weight:

  Either `"equal"` (default), counting compositions in each bin, or
  `"abundance"`, summing their abundances across all eligible rows and
  samples using
  [`glydet::wsum()`](https://glycoverse.github.io/glydet/reference/wsum.html).
  Abundance weighting requires finite, non-negative, raw linear-scale
  abundances; missing values are omitted.

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
  plots and subsets; unnamed palettes follow factor order. `NULL`
  selects the plot-specific default: blue-white-red for continuous
  heatmaps, directional colors for volcano and S-plots, selection colors
  for ranked dot plots, and distinct hues for other plots.

## Value

A `tidyplot`, also inheriting from `ggplot`. Its `data` contains ordered
`category` bins, `count` (number of compositions), and `value` (the
plotted count or pooled abundance).

## Details

Bars use the first colour in `palette`. The default plot area is 50 by
50 mm.

The bar at `2` counts compositions with exactly two distinct annotated
structures. Structure identity uses the character representation of
`glycan_structure`, as in
[`plot_glycans_per_site()`](https://glycoverse.github.io/glyvis/dev/reference/plot_glycans_per_site.md).
Counts are pooled across proteins and sites, so repeated structures do
not increase isomer counts. Duplicate measurements contribute their
abundance in abundance mode. No protein, site, or glycan-type annotation
is required.

Rows missing either composition or structure are excluded with a
warning, including their abundance. Compositions with no remaining
structures are omitted; empty input or absence of eligible rows raises
an error. Bin assignments depend on annotations regardless of zero or
missing assay values. No sample-wise normalization is performed. All
eight bins are retained, including empty bins.

## Examples

``` r
plot_isomers_per_comp(glyexp::real_experiment2)
```

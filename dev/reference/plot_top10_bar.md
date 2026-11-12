# Top ten glycans by site-specific glycoform count or abundance

Draw mirrored horizontal bars with glycan cartoons at their outer ends.
The left side includes oligomannose; the right side excludes it. Each
side independently selects up to ten glycans, ranked from highest to
lowest from top to bottom, on a shared quantitative scale.

## Usage

``` r
plot_top10_bar(
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
  [`glyexp::GlycoproteomicSE()`](https://glycoverse.github.io/glyexp/reference/GlycoproteomicSE.html)
  with `glycan_structure`, `protein`, and `protein_site` row annotations
  and `glycan_type = "N"` in metadata. Glycomics, plain
  `SummarizedExperiment`, and legacy containers are rejected.

- ...:

  Must be empty. Supply plotting controls by their full argument names.

- weight:

  Either `"equal"` (default), counting distinct combinations of protein,
  site, and glycan structure, or `"abundance"`, summing linear-scale
  glycoform abundances across all rows and samples. Duplicate
  measurements count once in equal mode and contribute their summed
  abundance otherwise.

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

A `tidyplot`, also inheriting from `ggplot`. Its `data` contains
`glycan_structure`, `type`, `value`, `side`, and `rank`. Values are
always non-negative; `signed_value` gives their mirrored plotting
coordinates.

## Details

The plot area uses the tidyplots default (50 by 50 mm). The first two
default glyvis colours identify the left and right sides. Cartoon sizes
adapt to the plot dimensions supplied here. No title is added unless
`title` is supplied.

Classification uses
[`glydet::n_glycan_type()`](https://glycoverse.github.io/glydet/reference/n_glycan_type.html)
with `merge_mannose = TRUE`: oligomannose includes paucimannose and
high-mannose. Missing structures and structures without an N-glycan core
are excluded with a warning; invalid structures or ambiguous
classifications raise an error. Ties are resolved by canonical structure
string. If fewer than ten glycans are available, all are shown; an empty
right side is labelled explicitly.

Equal weighting uses annotations regardless of zero or missing
abundance. Abundance weighting requires non-negative finite values on a
recorded raw scale (missing scale metadata is treated as raw). Missing
values are omitted; all-zero or entirely missing eligible abundance
raises an error. No sample-wise normalization is applied.

## Examples

``` r
if (all(vapply(c("glydet", "glydraw", "glymotif", "glyparse", "glyrepr"),
               requireNamespace, logical(1), quietly = TRUE))) {
  plot_top10_bar(glyexp::real_experiment)
  plot_top10_bar(glyexp::real_experiment, weight = "abundance")
}
```

# N-glycan core, type, and branch distributions

Summarize an N-glycan experiment across all samples, with glycan
cartoons drawn by
[`glydraw::geom_glycan()`](https://glycoverse.github.io/glydraw/reference/geom_glycan.html).

## Usage

``` r
plot_n_core_pie(
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

plot_n_type_pie(
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

plot_n_branch_pie(
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

plot_n_branch_bar(
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
  with `glycan_structure` in its row annotations and `glycan_type = "N"`
  in its metadata. Legacy `glyexp_experiment` objects are also
  supported.

- ...:

  Must be empty. Supply plotting controls by their full argument names.

- weight:

  Either `"equal"` (default) or `"abundance"`. Equal weighting counts
  distinct glycan structures in glycomics, or distinct combinations of
  `protein`, `protein_site`, and glycan structure in glycoproteomics.
  Abundance weighting uses
  [`glydet::wsum()`](https://glycoverse.github.io/glydet/reference/wsum.html)
  to sum the original linear-scale abundances over all rows and samples.
  Duplicate measurements contribute their summed abundance. Missing
  abundances are omitted; negative or infinite values and recorded
  non-raw scales are rejected.

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
`category`, `value`, `proportion`, and `glycan_structure`. Proportions
use the total count or abundance of eligible N-glycoforms as the
denominator. Pies retain zero-valued categories in `data` and in their
cartoon labels.

## Details

The default plot area is 50 by 50 mm. Pie annotations scale with the
panel size; core labels are split across lines to avoid crowding.

`plot_n_core_pie()` separates core fucosylation and bisecting GlcNAc
into four combinations. Antennal fucose does not count as core fucose.
`plot_n_type_pie()` uses
[`glydet::n_glycan_type()`](https://glycoverse.github.io/glydet/reference/n_glycan_type.html)
with `merge_mannose = TRUE`, labelled `oligomannose`, `hybrid`, and
`complex`. Thus oligomannose includes both paucimannose and high-mannose
glycans. Type cartoons are representative structures, not complete
definitions. `plot_n_branch_pie()` groups glycans by
[`glydet::n_antennae()`](https://glycoverse.github.io/glydet/reference/n_glycan_type.html),
counting GlcNAc antennae attached to the core mannoses, excluding
bisecting GlcNAc. Observed antenna counts (including zero) are ordered
numerically. Each cartoon for zero to four antennae is a fixed
core-and-antenna motif with unspecified linkages. Higher counts use the
first input structure. Observed categories with zero total abundance
remain visible. `plot_n_branch_bar()` extracts branch motifs through
[`glymotif::extract_branch_motif()`](https://glycoverse.github.io/glymotif/reference/extract_branch_motif.html)
and matches them with
[`glymotif::branch_motifs()`](https://glycoverse.github.io/glymotif/reference/branch_motifs.html),
preserving the distinction between antennal and bisecting GlcNAc. Each
glycan or site-specific glycoform contributes at most once to each
branch type, even if it has repeated identical arms. Different branch
types can overlap, so bar proportions need not sum to one. Cartoons
above the bars show the extracted branches, without the core. Bars are
ordered from highest to lowest value and share one colour (the first
colour in `palette`, when supplied). Pie annotations follow their
sectors and move apart when crowded. Bar limits reserve space for the
actual cartoon heights.

Missing structures and structures without the N-glycan core are excluded
with a warning. Invalid structure strings raise an error. Reducing-end
alditol status is ignored for classification, but retained when
identifying distinct glycoforms. Equal weighting counts annotated
glycoforms regardless of assay missingness or zero abundance. No
sample-wise normalization is applied. All-zero or entirely missing total
abundance raises an error.

## Examples

``` r
if (all(vapply(c("glydet", "glydraw", "glymotif", "glyparse", "glyrepr"),
               requireNamespace, logical(1), quietly = TRUE))) {
  plot_n_core_pie(glyexp::real_experiment2)
  plot_n_type_pie(glyexp::real_experiment2, weight = "abundance")
  plot_n_branch_pie(glyexp::real_experiment2)
  plot_n_branch_bar(glyexp::real_experiment2)
}
#> Warning: Excluded 1 row with missing structures or without a selected N-glycan core.
#> Warning: Excluded 1 row with missing structures or without a selected N-glycan core.
#> Warning: Excluded 1 row with missing structures or without a selected N-glycan core.
#> Warning: Excluded 1 row with missing structures or without a selected N-glycan core.
```

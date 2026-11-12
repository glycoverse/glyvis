#' O-GalNAc core distribution
#'
#' Summarize O-GalNAc cores across all samples, with glycan cartoons.
#'
#' @param x A [glyexp::GlycomicSE()] or [glyexp::GlycoproteomicSE()] with
#'   `glycan_structure` row annotations and `glycan_type = "O"` metadata.
#'   Legacy `glyexp_experiment` objects are also supported.
#' @inheritParams plot_n_type_pie
#' @param core_set Either `"4cores"` (default), showing Core 1-4, or
#'   `"8cores"`, showing Core 1-8.
#' @details
#' Cores are matched at the reducing end using monosaccharide identities and
#' linkages. Core 2 takes precedence over Core 1, and Core 4 over Core 3;
#' both branched cores take precedence over Core 6. Extended cores are included.
#' Missing structures and structures not matching the selected core set are
#' excluded with a warning. Invalid structure strings raise an error.
#' Reducing-end alditol status is ignored for classification but retained for
#' distinct glycoform counting. Weighting follows [plot_n_type_pie()].
#' @returns A `tidyplot`, also inheriting from `ggplot`. Its `data` contains
#'   `category`, `value`, `proportion`, and `glycan_structure`. Proportions use
#'   only glycoforms matching the selected cores as the denominator. All selected
#'   cores retain their cartoon labels, including zero-valued categories.
#' @examples
#' if (all(vapply(c("glydet", "glydraw", "glymotif", "glyparse", "glyrepr"),
#'                requireNamespace, logical(1), quietly = TRUE))) {
#'   structures <- glyrepr::o_glycan_core_1()
#'   x <- glyexp::GlycomicSE(
#'     matrix(1, 1, 1),
#'     rowData = S4Vectors::DataFrame(
#'       glycan_structure = structures,
#'       glycan_composition = glyrepr::as_glycan_composition(structures)
#'     ),
#'     metadata = list(glycan_type = "O")
#'   )
#'   plot_o_type_pie(x)
#'   plot_o_type_pie(x, core_set = "8cores")
#' }
#' @export
plot_o_type_pie <- function(
  x,
  ...,
  weight = "equal",
  core_set = "4cores"
) {
  checkmate::assert_choice(core_set, c("4cores", "8cores"))
  input <- .n_plot_input(x, weight, core_set = core_set)
  n <- if (core_set == "4cores") 4L else 8L
  df <- .n_plot_summary(
    input,
    outer(.o_core_index(input$glycans), seq_len(n), `==`),
    paste("Core", seq_len(n)),
    .o_core_cartoons()[seq_len(n)]
  )
  .n_pie(df, ...)
}

.o_core_cartoons <- function() {
  c(
    "Gal(b1-3)GalNAc(a1-",
    "Gal(b1-3)[GlcNAc(b1-6)]GalNAc(a1-",
    "GlcNAc(b1-3)GalNAc(a1-",
    "GlcNAc(b1-3)[GlcNAc(b1-6)]GalNAc(a1-",
    "GalNAc(a1-3)GalNAc(a1-",
    "GlcNAc(b1-6)GalNAc(a1-",
    "GalNAc(a1-6)GalNAc(a1-",
    "Gal(a1-3)GalNAc(a1-"
  )
}

.o_core_index <- function(glycans) {
  membership <- glymotif::have_motifs(
    glycans,
    .o_core_cartoons(),
    alignments = "core"
  )
  # Remove subcore matches before checking for ambiguous classifications.
  membership[membership[, 2] %in% TRUE, c(1, 6)] <- FALSE
  membership[membership[, 4] %in% TRUE, c(3, 6)] <- FALSE
  apply(membership, 1, \(matches) {
    index <- which(matches %in% TRUE)
    if (length(index) == 1L) index else NA_integer_
  })
}

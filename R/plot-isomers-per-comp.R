#' Distribution of isomers per glycan composition
#'
#' Count distinct annotated structures within each glycan composition across
#' all samples and draw a single-colour bar plot with bins `1` to `7` and `>=8`.
#'
#' @param x A [glyexp::GlycomicSE()] or [glyexp::GlycoproteomicSE()] with
#'   `glycan_composition` and `glycan_structure` row annotations.
#' @param weight Either `"equal"` (default), counting compositions in each
#'   bin, or `"abundance"`, summing their abundances across all eligible rows
#'   and samples using [glydet::wsum()]. Abundance weighting requires finite,
#'   non-negative, raw linear-scale abundances; missing values are omitted.
#' @param ... Common appearance options in [glyvis_plot_options]. Bars use
#'   the first colour in `palette`. The default plot area is 50 by 50 mm.
#'
#' @details
#' The bar at `2` counts compositions with exactly two distinct annotated
#' structures. Structure identity uses the character representation of
#' `glycan_structure`, as in [plot_glycans_per_site()]. Counts are pooled
#' across proteins and sites, so repeated structures do not increase isomer
#' counts. Duplicate measurements contribute their abundance in abundance
#' mode. No protein, site, or glycan-type annotation is required.
#'
#' Rows missing either composition or structure are excluded with a warning,
#' including their abundance. Compositions with no remaining structures are
#' omitted; empty input or absence of eligible rows raises an error. Bin
#' assignments depend on annotations regardless of zero or missing assay
#' values. No sample-wise normalization is performed. All eight bins are
#' retained, including empty bins.
#'
#' @returns A `tidyplot`, also inheriting from `ggplot`. Its `data` contains
#'   ordered `category` bins, `count` (number of compositions), and `value`
#'   (the plotted count or pooled abundance).
#' @examples
#' plot_isomers_per_comp(glyexp::real_experiment2)
#' @export
plot_isomers_per_comp <- function(
  x,
  ...,
  weight = "equal"
) {
  checkmate::assert_multi_class(x, c("GlycomicSE", "GlycoproteomicSE"))
  checkmate::assert_choice(weight, c("equal", "abundance"))
  info <- tibble::as_tibble(SummarizedExperiment::rowData(x))
  if (!nrow(info)) {
    cli::cli_abort("No glycan rows remain.")
  }
  missing <- setdiff(c("glycan_composition", "glycan_structure"), names(info))
  if (length(missing)) {
    cli::cli_abort("Missing row annotations: {.field {missing}}.")
  }
  keep <- .glyco_annotation_present(info$glycan_composition) &
    .glyco_annotation_present(info$glycan_structure)
  if (!all(keep)) {
    cli::cli_warn(
      "Excluded {sum(!keep)} row{?s} with missing glycan composition or structure annotations."
    )
  }
  if (!any(keep)) {
    cli::cli_abort("No eligible glycan annotations remain.")
  }
  rows <- tibble::tibble(
    composition = as.character(info$glycan_composition[keep]),
    structure = as.character(info$glycan_structure[keep]),
    row_index = which(keep)
  )
  entities <- rows |>
    dplyr::group_by(.data$composition) |>
    dplyr::summarise(
      size = dplyr::n_distinct(.data$structure),
      .groups = "drop"
    )
  df <- .glycoproteomic_count_summary(x, weight, rows, entities, "composition")
  .glycoproteomic_count_bar(
    df,
    weight,
    "Isomers per composition",
    "Number of compositions",
    ...
  )
}

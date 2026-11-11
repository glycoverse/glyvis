#' Fucosylation and sialylation distribution
#'
#' Classify glycans using only their composition and pool all samples.
#'
#' @param x A [glyexp::GlycomicSE()] or [glyexp::GlycoproteomicSE()] with
#'   `glycan_composition` row annotations. Legacy `glyexp_experiment` objects
#'   are also supported. No structure or glycan-type metadata is required.
#' @param weight Either `"equal"` (default) or `"abundance"`. Equal weighting
#'   counts distinct compositions, or distinct combinations of `protein`,
#'   `protein_site`, and composition for glycoproteomics. Abundance weighting
#'   sums raw, linear-scale abundances across all rows and samples, including
#'   duplicate measurements. Missing abundances are omitted; negative and
#'   infinite values and recorded non-raw scales are rejected.
#' @param ... Common appearance options described in [glyvis_plot_options].
#' @details
#' Categories are ordered as `Fuc+, Sia+`, `Fuc+, Sia-`, `Fuc-, Sia+`, and
#' `Fuc-, Sia-`. Fucose is inferred from `dHex` (including concrete Fuc);
#' sialic acid includes both `NeuAc` and `NeuGc`. Counts greater than zero
#' indicate presence. This does not distinguish core from antennal fucose.
#' Each sector is annotated with its Fuc/Sia category and percentage.
#' Missing compositions are excluded with a warning. Invalid compositions
#' raise an error. Equal weighting counts annotations regardless of assay
#' missingness. No sample-wise normalization is applied. Empty eligible input
#' and non-positive total abundance raise an error.
#' @returns A `tidyplot`, also inheriting from `ggplot`, with `category`,
#'   `value`, and `proportion` in its `data`. All four categories are retained,
#'   including zero-valued categories. Proportions use the total eligible
#'   count or abundance as the denominator.
#' @examples
#' if (requireNamespace("glyrepr", quietly = TRUE)) {
#'   plot_fuc_sia_pie(glyexp::real_experiment2)
#' }
#' @export
plot_fuc_sia_pie <- function(x, weight = "equal", ...) {
  checkmate::assert_choice(weight, c("equal", "abundance"))
  checkmate::assert_multi_class(
    x,
    c("GlycomicSE", "GlycoproteomicSE", "glyexp_experiment")
  )
  rlang::check_installed("glyrepr", version = "1.2.0")
  info <- .get_var_info(x)
  proteomics <- if (inherits(x, "glyexp_experiment")) {
    meta <- glyexp::get_meta_data(x)
    checkmate::assert_choice(meta$exp_type, c("glycomics", "glycoproteomics"))
    meta$exp_type == "glycoproteomics"
  } else {
    methods::is(x, "GlycoproteomicSE")
  }
  required <- c(
    "glycan_composition",
    if (proteomics) c("protein", "protein_site")
  )
  missing <- setdiff(required, names(info))
  if (length(missing)) {
    cli::cli_abort("Missing row annotations: {.field {missing}}.")
  }
  keep <- .glyco_annotation_present(info$glycan_composition)
  if (!all(keep)) {
    cli::cli_warn(
      "Excluded {sum(!keep)} row{?s} with missing glycan compositions."
    )
  }
  if (!any(keep)) {
    cli::cli_abort("No eligible glycan compositions remain.")
  }
  info <- info[keep, , drop = FALSE]
  composition <- glyrepr::as_glycan_composition(info$glycan_composition)
  if (
    proteomics &&
      any(
        !.glyco_annotation_present(info$protein) |
          !.glyco_annotation_present(info$protein_site)
      )
  ) {
    cli::cli_abort("Protein and protein_site annotations must be complete.")
  }
  fuc <- glyrepr::count_mono(composition, "dHex") > 0
  sia <- (glyrepr::count_mono(composition, "NeuAc") +
    glyrepr::count_mono(composition, "NeuGc")) >
    0
  index <- ifelse(fuc, 0L, 2L) + ifelse(sia, 1L, 2L)
  if (anyNA(index)) {
    cli::cli_abort("Some glycan compositions could not be classified.")
  }
  if (weight == "equal") {
    keys <- data.frame(composition = as.character(composition))
    if (proteomics) {
      keys <- cbind(keys, as.data.frame(info[c("protein", "protein_site")]))
    }
    weights <- as.numeric(!duplicated(keys))
  } else {
    if (.resolve_plot_transformation(x, FALSE)$input_scale != "raw") {
      cli::cli_abort(
        "Abundance weighting requires raw, linear-scale abundances."
      )
    }
    abundance <- .get_expr_mat(x)[keep, , drop = FALSE]
    if (any(is.infinite(abundance) | abundance < 0, na.rm = TRUE)) {
      cli::cli_abort("Abundances must be non-negative and finite, or missing.")
    }
    weights <- rowSums(abundance, na.rm = TRUE)
  }
  total <- sum(weights)
  if (!is.finite(total) || total <= 0) {
    cli::cli_abort(
      "The total eligible count or abundance must be positive and finite."
    )
  }
  labels <- c("Fuc+, Sia+", "Fuc+, Sia-", "Fuc-, Sia+", "Fuc-, Sia-")
  values <- vapply(seq_along(labels), \(i) sum(weights[index == i]), numeric(1))
  df <- tibble::tibble(
    category = factor(labels, levels = labels),
    value = values,
    proportion = values / total
  )
  .n_pie(df, ...)
}

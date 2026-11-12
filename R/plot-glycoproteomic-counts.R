#' Distributions of glycans per site and sites per protein
#'
#' Draw single-colour bar plots with fixed bins `1`, `2`, `3`, `4`, `5`,
#' `6`, `7`, and `>=8`, pooling the annotations across all samples.
#'
#' @param x A [glyexp::GlycoproteomicSE()] object. Other containers, including
#'   plain `SummarizedExperiment` and legacy experiments, are not accepted.
#' @param weight Either `"equal"` (default), counting sites or proteins in each
#'   bin, or `"abundance"`, summing their glycoform abundances over all rows and
#'   samples with [glydet::wsum()]. Abundance weighting requires non-negative,
#'   finite, linear-scale abundances; missing values are omitted. These sums
#'   describe measured glycoforms, not independently measured protein abundance.
#' @param glycan_col Row-annotation column identifying glycans. With `NULL`
#'   (default), complete `glycan_structure` annotations are used. If structures
#'   are absent or incomplete, a message is printed and `glycan_composition`
#'   is used for the whole experiment, so structure and composition identifiers
#'   are never mixed. Supply a column name to select it explicitly.
#' @param ... Common appearance options in [glyvis_plot_options]. Bars use the
#'   first colour in `palette`. The default plot area is 50 by 50 mm.
#'
#' @details
#' `plot_glycans_per_site()` counts distinct glycans at each combination of
#'   `protein` and `protein_site`. In equal mode, the bar at `2` is the number
#'   of sites carrying exactly two distinct glycans.
#' `plot_sites_per_protein()` counts distinct `protein_site` positions within
#'   each protein. In equal mode, the bar at `2` is the number of proteins
#'   with exactly two annotated glycosites. Glycan annotations are not needed
#'   for this plot, and neither plot is restricted to N-glycans.
#'
#' Duplicate measurements do not increase glycan or site counts. Their
#' abundances are summed in abundance mode. Bin assignments use annotations
#' regardless of zero or missing assay values; no sample-wise normalization
#' is performed. All eight bins are retained, including empty bins.
#'
#' Protein and site identifiers must be complete. For the glycans-per-site
#' plot, rows missing the selected glycan annotation are excluded with a
#' warning, including their abundance; sites with no remaining rows are omitted.
#' Empty input or absence of eligible rows raises an error.
#'
#' @returns A `tidyplot`, also inheriting from `ggplot`. Its `data` contains
#'   ordered `category` bins, `count` (number of sites or proteins), and
#'   `value` (the plotted count or pooled abundance).
#' @examples
#' plot_glycans_per_site(glyexp::real_experiment)
#' plot_sites_per_protein(glyexp::real_experiment)
#' if (requireNamespace("glydet", quietly = TRUE)) {
#'   plot_sites_per_protein(glyexp::real_experiment, weight = "abundance")
#' }
#' @export
plot_glycans_per_site <- function(
  x,
  ...,
  weight = "equal",
  glycan_col = NULL
) {
  input <- .glycoproteomic_count_input(x, weight)
  info <- input$info
  if (is.null(glycan_col)) {
    complete_structure <- "glycan_structure" %in%
      names(info) &&
      all(.glyco_annotation_present(info$glycan_structure))
    glycan_col <- if (complete_structure) {
      "glycan_structure"
    } else {
      "glycan_composition"
    }
    if (!complete_structure) {
      cli::cli_inform(
        "Glycan structures are absent or incomplete; using {.field glycan_composition} to count glycans."
      )
    }
  }
  checkmate::assert_string(glycan_col, min.chars = 1)
  if (!glycan_col %in% names(info)) {
    cli::cli_abort("Missing row annotation: {.field {glycan_col}}.")
  }
  keep <- .glyco_annotation_present(info[[glycan_col]])
  if (!all(keep)) {
    cli::cli_warn(
      "Excluded {sum(!keep)} row{?s} with missing {.field {glycan_col}} annotations."
    )
  }
  if (!any(keep)) {
    cli::cli_abort("No eligible glycan annotations remain.")
  }
  rows <- input$rows[keep, , drop = FALSE]
  rows$glycan <- as.character(info[[glycan_col]][keep])
  entities <- rows |>
    dplyr::group_by(.data$protein, .data$protein_site) |>
    dplyr::summarise(size = dplyr::n_distinct(.data$glycan), .groups = "drop")
  df <- .glycoproteomic_count_summary(
    x,
    weight,
    rows,
    entities,
    c("protein", "protein_site")
  )
  .glycoproteomic_count_bar(
    df,
    weight,
    "Glycans per site",
    "Number of sites",
    ...
  )
}

#' @rdname plot_glycans_per_site
#' @export
plot_sites_per_protein <- function(
  x,
  ...,
  weight = "equal"
) {
  input <- .glycoproteomic_count_input(x, weight)
  entities <- input$rows |>
    dplyr::distinct(.data$protein, .data$protein_site) |>
    dplyr::count(.data$protein, name = "size")
  df <- .glycoproteomic_count_summary(
    x,
    weight,
    input$rows,
    entities,
    "protein"
  )
  .glycoproteomic_count_bar(
    df,
    weight,
    "Sites per protein",
    "Number of proteins",
    ...
  )
}

.glyco_annotation_present <- function(x) {
  text <- as.character(x)
  !is.na(x) & !is.na(text) & nzchar(trimws(text))
}

.glycoproteomic_count_input <- function(x, weight) {
  checkmate::assert_class(x, "GlycoproteomicSE")
  checkmate::assert_choice(weight, c("equal", "abundance"))
  info <- tibble::as_tibble(SummarizedExperiment::rowData(x))
  if (!nrow(info)) {
    cli::cli_abort("No glycoproteomic rows remain.")
  }
  missing <- setdiff(c("protein", "protein_site"), names(info))
  if (length(missing)) {
    cli::cli_abort("Missing row annotations: {.field {missing}}.")
  }
  if (
    any(
      !.glyco_annotation_present(info$protein) |
        !.glyco_annotation_present(info$protein_site)
    )
  ) {
    cli::cli_abort("Protein and protein_site annotations must be complete.")
  }
  rows <- tibble::tibble(
    protein = info$protein,
    protein_site = info$protein_site,
    row_index = seq_len(nrow(info))
  )
  list(info = info, rows = rows)
}

.glycoproteomic_count_summary <- function(x, weight, rows, entities, keys) {
  bins <- c(as.character(1:7), ">=8")
  count <- tabulate(pmin(entities$size, 8L), nbins = 8L)
  value <- as.numeric(count)
  if (weight == "abundance") {
    rlang::check_installed("glydet", version = "0.14.0")
    if (.resolve_plot_transformation(x, FALSE)$input_scale != "raw") {
      cli::cli_abort(
        "Abundance weighting requires raw, linear-scale abundances."
      )
    }
    abundance <- .get_expr_mat(x)[rows$row_index, , drop = FALSE]
    if (any(is.infinite(abundance) | abundance < 0, na.rm = TRUE)) {
      cli::cli_abort("Abundances must be non-negative and finite, or missing.")
    }
    row_bins <- rows |>
      dplyr::left_join(entities, by = keys) |>
      dplyr::pull("size") |>
      pmin(8L)
    weighted_sum <- glydet::wsum(.data$.present)
    value <- vapply(
      seq_along(bins),
      function(i) {
        sum(weighted_sum(
          abundance,
          tibble::tibble(.present = as.numeric(row_bins == i))
        ))
      },
      numeric(1)
    )
    if (any(!is.finite(value))) {
      cli::cli_abort("Pooled abundances must be finite.")
    }
  }
  tibble::tibble(
    category = factor(bins, levels = bins),
    count = count,
    value = value
  )
}

.glycoproteomic_count_bar <- function(
  df,
  weight,
  xlab,
  ylab,
  width = 50,
  height = 50,
  palette = NULL,
  ...
) {
  p <- .glyvis_plot(
    df,
    "category",
    "value",
    width = width,
    height = height,
    palette = palette,
    ...
  )
  y_scale <- p$scales$get_scales("y")
  y_scale$expand <- expansion(mult = c(0, 0.06))
  if (weight == "equal") {
    y_scale$breaks <- function(limits) {
      breaks <- pretty(limits)
      breaks[breaks >= 0 & breaks == floor(breaks)]
    }
  }
  p +
    geom_col(
      fill = if (is.null(palette)) glyvis_colors[1] else palette[[1]],
      width = 0.65
    ) +
    labs(
      x = xlab,
      y = if (weight == "equal") ylab else "Pooled glycoform abundance"
    ) +
    theme(legend.position = "none")
}

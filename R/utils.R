.assert_exp_type <- function(exp, type) {
  if (glyexp::get_exp_type(exp) != type) {
    cli::cli_abort(c(
      "The experiment type must be {.val {type}}.",
      "i" = "Current experiment type: {.val {glyexp::get_exp_type(exp)}}"
    ))
  }
}

#' Extract the expression matrix from a supported experiment container
#'
#' @param exp A `glyexp_experiment` or `SummarizedExperiment` object.
#'
#' @returns A numeric matrix with variables in rows and samples in columns.
#' @noRd
.get_expr_mat <- function(exp) {
  if (methods::is(exp, "SummarizedExperiment")) {
    return(as.matrix(SummarizedExperiment::assay(exp, 1)))
  }
  glyexp::get_expr_mat(exp)
}

#' Extract sample information from a supported experiment container
#'
#' @inheritParams .get_expr_mat
#'
#' @returns A tibble with a `sample` identifier column.
#' @noRd
.get_sample_info <- function(exp) {
  if (methods::is(exp, "SummarizedExperiment")) {
    return(.as_info_tibble(
      SummarizedExperiment::colData(exp),
      "sample",
      colnames(exp)
    ))
  }
  glyexp::get_sample_info(exp)
}

#' Extract variable information from a supported experiment container
#'
#' @inheritParams .get_expr_mat
#'
#' @returns A tibble with a `variable` identifier column.
#' @noRd
.get_var_info <- function(exp) {
  if (methods::is(exp, "SummarizedExperiment")) {
    return(.as_info_tibble(
      SummarizedExperiment::rowData(exp),
      "variable",
      rownames(exp)
    ))
  }
  glyexp::get_var_info(exp)
}

#' Convert row or column data to an identifier-bearing tibble
#'
#' @param info A data-frame-like object containing row or column metadata.
#' @param id The identifier column name.
#' @param ids Identifiers stored in the container dimnames.
#'
#' @returns A tibble with `id` as its first column.
#' @noRd
.as_info_tibble <- function(info, id, ids) {
  info <- tibble::as_tibble(info)
  if (id %in% colnames(info)) {
    return(info)
  }
  if (is.null(ids)) {
    ids <- as.character(seq_len(nrow(info)))
  }
  id_info <- tibble::tibble(ids)
  colnames(id_info) <- id
  dplyr::bind_cols(id_info, info)
}

#' Fortify a supported experiment container
#'
#' @inheritParams .get_expr_mat
#'
#' @returns A long-form tibble containing abundance and row/column metadata.
#' @noRd
.fortify_experiment <- function(exp) {
  expr_mat <- .get_expr_mat(exp)
  variables <- rownames(expr_mat)
  samples <- colnames(expr_mat)
  if (is.null(variables)) {
    variables <- as.character(seq_len(nrow(expr_mat)))
  }
  if (is.null(samples)) {
    samples <- as.character(seq_len(ncol(expr_mat)))
  }

  tibble::tibble(sample = rep(samples, times = nrow(expr_mat))) |>
    dplyr::left_join(.get_sample_info(exp), by = "sample") |>
    dplyr::mutate(
      variable = rep(variables, each = ncol(expr_mat)),
      value = as.vector(t(expr_mat))
    ) |>
    dplyr::left_join(.get_var_info(exp), by = "variable") |>
    dplyr::relocate("value", .after = dplyr::last_col())
}

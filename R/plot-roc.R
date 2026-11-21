#' ROC plot
#'
#' Draw ROC curves.
#' Only two groups are allowed.
#' At most 10 variables can be shown in a ROC curve plot.
#' Currently supported data types:
#' - `glystats_roc_res`: Result from [glystats::gly_roc()].
#' - `SummarizedExperiment`: A [glyexp::GlycomicSE()],
#'   [glyexp::GlycoproteomicSE()], or other compatible container.
#'   ROC analysis is first performed using [glystats::gly_roc()],
#'   then the result is plotted.
#'
#' @param x An object to be plotted.
#' @param type The type of plot, one of "dotplot" or "roc". Default is "roc".
#' @param auc_cutoff The AUC cutoff. Default is 0.5.
#' @param variables A character vector of feature identifiers to display, or
#'   `NULL` for the existing unfiltered behavior. Identifiers come from
#'   `.variable` in current results and `variable` in legacy results.
#'   Unknown identifiers error; repeated identifiers do not repeat curves or
#'   points. Selection retains the result row order and does not recompute ROC
#'   statistics. Select up to 10 features to plot curves from a larger input.
#' @param top_n Number of variables to retain when `type = "dotplot"`. `NULL`
#'   retains all variables; a positive integer selects the largest AUC values
#'   after applying `variables`.
#'   Does not affect ROC curves.
#' @inheritParams glyvis_plot_options
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
plot_roc <- function(
  x,
  ...,
  type = "roc",
  auc_cutoff = 0.5,
  top_n = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL,
  stats_args = list(),
  variables = NULL
) {
  rlang::check_dots_empty()
  UseMethod("plot_roc")
}

#' @rdname plot_roc
#' @export
plot_roc.glystats_roc_res <- function(
  x,
  ...,
  type = "roc",
  auc_cutoff = 0.5,
  top_n = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL,
  variables = NULL
) {
  rlang::check_dots_empty()
  .plot_roc(
    x,
    type = type,
    auc_cutoff = auc_cutoff,
    ...,
    title = title,
    width = width,
    height = height,
    fontsize = fontsize,
    family = family,
    palette = palette,
    top_n = top_n,
    variables = variables
  )
}

#' @rdname plot_roc
#' @param stats_args A list of keyword arguments to pass to [glystats::gly_roc()].
#' @export
plot_roc.glyexp_experiment <- function(
  x,
  ...,
  type = "roc",
  auc_cutoff = 0.5,
  stats_args = list(),
  top_n = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL,
  variables = NULL
) {
  rlang::check_dots_empty()
  checkmate::assert_choice(type, c("dotplot", "roc"))
  checkmate::assert_number(auc_cutoff, lower = 0, upper = 1)
  if (is.null(variables) && nrow(x) > 10) {
    cli::cli_abort(c(
      "Number of variables must be less than or equal to 10.",
      "x" = "Current number of variables: {.val {nrow(x)}}",
      "i" = "Use {.arg variables} to select features to plot."
    ))
  }
  roc_res <- rlang::exec(glystats::gly_roc, x, !!!stats_args)
  .plot_roc(
    roc_res,
    type = type,
    auc_cutoff = auc_cutoff,
    ...,
    title = title,
    width = width,
    height = height,
    fontsize = fontsize,
    family = family,
    palette = palette,
    top_n = top_n,
    variables = variables
  )
}

#' @rdname plot_roc
#' @export
plot_roc.SummarizedExperiment <- function(
  x,
  ...,
  type = "roc",
  auc_cutoff = 0.5,
  stats_args = list(),
  top_n = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL,
  variables = NULL
) {
  rlang::check_dots_empty()
  checkmate::assert_choice(type, c("dotplot", "roc"))
  checkmate::assert_number(auc_cutoff, lower = 0, upper = 1)
  if (is.null(variables) && nrow(x) > 10) {
    cli::cli_abort(c(
      "Number of variables must be less than or equal to 10.",
      "x" = "Current number of variables: {.val {nrow(x)}}",
      "i" = "Use {.arg variables} to select features to plot."
    ))
  }
  roc_res <- rlang::exec(glystats::gly_roc, x, !!!stats_args)
  .plot_roc(
    roc_res,
    type = type,
    auc_cutoff = auc_cutoff,
    ...,
    title = title,
    width = width,
    height = height,
    fontsize = fontsize,
    family = family,
    palette = palette,
    top_n = top_n,
    variables = variables
  )
}

#' Internal function to plot ROC plot
#' @param roc_res A `glystats_roc_res` object.
#' @param type The type of plot, one of "dotplot" or "roc".
#' @param auc_cutoff The AUC cutoff.
#' @inheritParams glyvis_plot_options
#' @noRd
.plot_roc <- function(
  roc_res,
  type,
  auc_cutoff,
  ...,
  top_n = NULL,
  variables = NULL
) {
  checkmate::assert_choice(type, c("dotplot", "roc"))
  checkmate::assert_number(auc_cutoff, lower = 0, upper = 1)
  switch(
    type,
    dotplot = .plot_roc_dotplot(
      roc_res,
      auc_cutoff,
      ...,
      top_n = top_n,
      variables = variables
    ),
    roc = .plot_roc_curves(roc_res, ..., variables = variables)
  )
}

#' Internal function to plot ROC dotplot
#' @param roc_res A `glystats_roc_res` object.
#' @param auc_cutoff The AUC cutoff.
#' @inheritParams glyvis_plot_options
#' @noRd
.plot_roc_dotplot <- function(roc_res, auc_cutoff, ..., variables = NULL) {
  id_col <- .result_id_column(roc_res, "variable")
  df <- .select_result_variables(roc_res$tidy_result$auc, id_col, variables) %>%
    dplyr::mutate(
      candidate = .data$auc >= auc_cutoff
    )
  .glyvis_dotchart(
    df,
    x = id_col,
    y = "auc",
    ...
  ) +
    geom_hline(yintercept = auc_cutoff, linetype = "dashed", alpha = 0.7) +
    labs(x = "Variable", y = "ROC AUC")
}

#' Internal function to plot ROC curves
#' @param roc_res A `glystats_roc_res` object.
#' @inheritParams glyvis_plot_options
#' @noRd
.plot_roc_curves <- function(roc_res, ..., variables = NULL) {
  id_col <- .result_id_column(roc_res, "variable")
  auc <- .select_result_variables(roc_res$tidy_result$auc, id_col, variables)
  if (nrow(auc) > 10) {
    cli::cli_abort(c(
      "Number of variables must be less than or equal to 10 when {.arg type} is {.val roc}.",
      "x" = "Current number of variables: {.val {nrow(auc)}}",
      "i" = "Select features with {.arg variables} or use {.arg type} = {.val dotplot}."
    ))
  }
  coords <- roc_res$tidy_result$coords
  if (!is.null(variables)) {
    coords <- coords[coords[[id_col]] %in% auc[[id_col]], , drop = FALSE]
  }
  .glyvis_roc(coords, id_col = id_col, ...)
}

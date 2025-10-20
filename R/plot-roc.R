#' ROC plot
#'
#' Draw ROC curves.
#' Only two groups are allowed.
#' At most 10 variables can be plotted.
#' Currently supported data types:
#' - `glystats_roc_res`: Result from [glystats::gly_roc()].
#' - `glyexp_experiment`: Experiment created by [glyexp::experiment()].
#'   ROC analysis is first performed using [glystats::gly_roc()],
#'   then the result is plotted.
#'
#' @param x An object to be plotted.
#' @param type The type of plot, one of "dotplot" or "roc". Default is "roc".
#' @param auc_cutoff The AUC cutoff. Default is 0.5.
#' @param ... Ignored.
#'
#' @returns A ggplot object.
#' @export
plot_roc <- function(x, type = "roc", auc_cutoff = 0.5, ...) {
  UseMethod("plot_roc")
}

#' @rdname plot_roc
#' @export
plot_roc.glystats_roc_res <- function(x, type = "roc", auc_cutoff = 0.5, ...) {
  .plot_roc(x, type = type, auc_cutoff = auc_cutoff)
}

#' @rdname plot_roc
#' @param group_col A character string specifying the column name of the grouping variable.
#'   Defaults to "group".
#' @export
plot_roc.glyexp_experiment <- function(x, type = "roc", auc_cutoff = 0.5, group_col = "group", ...) {
  checkmate::assert_string(group_col)
  checkmate::assert_choice(type, c("dotplot", "roc"))
  checkmate::assert_number(auc_cutoff, lower = 0, upper = 1)
  if (nrow(x) > 10) {
    cli::cli_abort(c(
      "Number of variables must be less than or equal to 10.",
      "x" = "Current number of variables: {.val {nrow(x)}}",
      "i" = "Try to filter the experiment before plotting."
    ))
  }
  roc_res <- glystats::gly_roc(x, group_col = group_col)
  .plot_roc(roc_res, type = type, auc_cutoff = auc_cutoff)
}

#' Internal function to plot ROC plot
#' @param roc_res A `glystats_roc_res` object.
#' @param type The type of plot, one of "dotplot" or "roc".
#' @param auc_cutoff The AUC cutoff.
#' @param ... Other arguments passed to [.glyvis_dotchart()] or [.glyvis_roc()].
#' @noRd
.plot_roc <- function(roc_res, type, auc_cutoff, ...) {
  checkmate::assert_choice(type, c("dotplot", "roc"))
  checkmate::assert_number(auc_cutoff, lower = 0, upper = 1)
  switch(type,
    dotplot = .plot_roc_dotplot(roc_res, auc_cutoff, ...),
    roc = .plot_roc_curves(roc_res, ...)
  )
}

#' Internal function to plot ROC dotplot
#' @param roc_res A `glystats_roc_res` object.
#' @param auc_cutoff The AUC cutoff.
#' @param ... Other arguments passed to [.glyvis_dotchart()].
#' @noRd
.plot_roc_dotplot <- function(roc_res, auc_cutoff, ...) {
  df <- roc_res$tidy_result$auc %>%
    dplyr::mutate(
      candidate = .data$auc >= auc_cutoff,
      point_color = dplyr::if_else(.data$candidate, glyvis_colors[1], "lightgrey")
    )
  .glyvis_dotchart(df, x = "variable", y = "auc") +
    geom_hline(yintercept = auc_cutoff, linetype = "dashed", alpha = 0.7) +
    labs(x = "Variable", y = "ROC AUC")
}

#' Internal function to plot ROC curves
#' @param roc_res A `glystats_roc_res` object.
#' @param ... Other arguments passed to [.glyvis_roc()].
#' @noRd
.plot_roc_curves <- function(roc_res, ...) {
  if (nrow(roc_res$tidy_result$auc) > 10) {
    cli::cli_abort(c(
      "Number of variables must be less than or equal to 10 when {.arg type} is {.val roc}.",
      "x" = "Current number of variables: {.val {nrow(roc_res$tidy_result$auc)}}",
      "i" = "Use {.arg type} = {.val dotplot}."
    ))
  }
  .glyvis_roc(roc_res$tidy_result$coords)
}
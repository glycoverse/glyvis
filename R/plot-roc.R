#' ROC plot
#'
#' Plot ROC curves for all variables in an experiment.
#' Only two groups are allowed.
#' At most 10 variables can be plotted.
#'
#' @param exp A `glyexp::experiment()` object with no more than 10 variables.
#' @param group_col A character string specifying the column name of the grouping variable.
#'   Defaults to "group".
#'
#' @returns A ggplot object.
#' @export
plot_roc <- function(exp, group_col = "group") {
  checkmate::assert_class(exp, "glyexp_experiment")
  checkmate::assert_string(group_col)
  if (nrow(exp) > 10) {
    cli::cli_abort(c(
      "Number of variables must be less than or equal to 10.",
      "x" = "Current number of variables: {.val {nrow(exp)}}",
      "i" = "Try to filter the experiment before plotting."
    ))
  }
  glystats::gly_roc(exp, group_col = group_col) |>
    autoplot(type = "roc")
}
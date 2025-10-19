#' Plots for Experiments
#'
#' Visualization for [glyexp::experiment()] (`glyexp_experiment` object).
#' Possible `type`s of plots:
#' - "heatmap": (Default) Expression heatmap with columns as samples and rows as variables.
#' - "boxplot": Boxplot of expression values for each sample.
#'
#' @param object A `glyexp_experiment` object.
#' @param type The type of plot, one of "heatmap" (default) or "boxplot".
#' @param group_col A character string specifying where to find the group information.
#'   It should be a column in the sample information tibble. Defaults to "group".
#'   Only applicable to "boxplot".
#' @param ... Ignored.
#'
#' @returns A ggplot object.
#' @export
autoplot.glyexp_experiment <- function(object, type = "heatmap", group_col = "group", ...) {
  checkmate::assert_choice(type, c("heatmap", "boxplot"))
  checkmate::assert_string(group_col)
  switch(
    type,
    heatmap = .plot_exp_heatmap(object, ...),
    boxplot = .plot_exp_boxplot(object, group_col, ...)
  )
}

#' @export
fortify.glyexp_experiment <- function(model, data, ...) {
  tibble::as_tibble(model)
}
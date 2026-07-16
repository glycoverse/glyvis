#' Plots for Glycoverse Data Containers
#'
#' Visualization for [glyexp::GlycomicSE()], [glyexp::GlycoproteomicSE()],
#' and other compatible `SummarizedExperiment` objects.
#' Possible `type`s of plots:
#' - "heatmap": (Default) Expression heatmap with columns as samples and rows as variables.
#' - "boxplot": Boxplot of expression values for each sample.
#'
#' @param object A supported Glycoverse data container.
#' @param type The type of plot, one of "heatmap" (default) or "boxplot".
#' @param group_col A character string specifying where to find the group information.
#'   It should be a column in the sample information tibble. Defaults to "group".
#'   Only applicable to "boxplot".
#' @param ... Ignored.
#'
#' @returns A ggplot object.
#' @export
autoplot.glyexp_experiment <- function(
  object,
  type = "heatmap",
  group_col = "group",
  ...
) {
  checkmate::assert_choice(type, c("heatmap", "boxplot"))
  checkmate::assert_string(group_col)
  switch(
    type,
    heatmap = .plot_exp_heatmap(object, ...),
    boxplot = .plot_exp_boxplot(object, group_col, ...)
  )
}

#' @rdname autoplot.glyexp_experiment
#' @export
autoplot.SummarizedExperiment <- function(
  object,
  type = "heatmap",
  group_col = "group",
  ...
) {
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
  .fortify_experiment(model)
}

#' @export
fortify.SummarizedExperiment <- function(model, data, ...) {
  .fortify_experiment(model)
}

#' Plots for Experiments
#'
#' Visualization for [glyexp::experiment()] (`glyexp_experiment` object).
#' Possible `type`s of plots:
#' - "barplot" (default): Barplot of expression values for each sample.
#' - "heatmap": Expression heatmap with columns as samples and rows as variables.
#'
#' @param object A `glyexp_experiment` object.
#' @param type The type of plot, one of "heatmap" (default) or "barplot".
#' @param ... Ignored.
#'
#' @returns A ggplot object.
#' @export
autoplot.glyexp_experiment <- function(object, type = "barplot", ...) {
  checkmate::assert_choice(type, c("heatmap", "barplot"))
  switch(
    type,
    heatmap = .plot_exp_heatmap(object, ...),
    barplot = .plot_exp_barplot(object, ...)
  )
}

#' @export
fortify.glyexp_experiment <- function(model, data, ...) {
  model %>%
    glyexp::get_expr_mat() %>%
    as.data.frame() %>%
    tibble::rownames_to_column("variable") %>%
    tidyr::pivot_longer(-"variable", names_to = "sample", values_to = "value") %>%
    dplyr::mutate(value = log2(.data$value + 1))
}

.plot_exp_heatmap <- function(object, ...) {
  df <- object %>%
    fortify.glyexp_experiment() %>%
    dplyr::mutate(value = as.double(scale(.data$value)), .by = "variable")

  .glyvis_heatmap(df, x = "sample", y = "variable", value = "value") +
    labs(fill = expression(log[2]("Int.")))
}

.plot_exp_barplot <- function(object, ...) {
  df <- object %>%
    fortify.glyexp_experiment()

  .glyvis_boxplot(df, x = "sample", value = "value") +
    labs(x = "Sample", y = expression(log[2]("Int.")))
}

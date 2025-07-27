#' Plots for Experiments
#'
#' Visualization for [glyexp::experiment()].
#' Possible `type`s of plots:
#' - "barplot" (default): Barplot of expression values for each sample.
#' - "heatmap": Expression heatmap with columns as samples and rows as variables.
#'
#' @param object A [glyexp::experiment()] object.
#' @param type The type of plot, one of "heatmap" (default) or "barplot".
#' @param ... Other arguments passed to underlying functions
#'   ([tidyplots::add_boxplot()] for barplot, [tidyplots::add_heatmap()] for heatmap).
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
  object %>%
    fortify.glyexp_experiment() %>%
    dplyr::mutate(value = as.double(scale(.data$value)), .by = "variable") %>%
    tidyplot(x = .data$sample, y = .data$variable, color = .data$value) %>%
    add_heatmap(rotate_labels = 90)
}

.plot_exp_barplot <- function(object, ...) {
  object %>%
    fortify.glyexp_experiment() %>%
    tidyplot(x = .data$sample, y = .data$value) %>%
    add_boxplot() %>%
    adjust_x_axis(rotate_labels = 90)
}

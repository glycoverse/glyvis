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

.plot_exp_heatmap <- function(object, ...) {
  df <- object %>%
    fortify.glyexp_experiment() %>%
    dplyr::mutate(value = as.double(scale(.data$value)), .by = "variable")

  .glyvis_heatmap(df, x = "sample", y = "variable", value = "value") +
    labs(fill = expression(log[2]("Int.")))
}

.plot_exp_boxplot <- function(object, group_col, ...) {
  # We don't want to plot too many variables.
  if (nrow(object) > 25) {
    cli::cli_abort(c(
      "The number of variables must be less than or equal to 25 for boxplot.",
      "x" = "Current number of variables: {.val {nrow(object)}}",
      "i" = "Consider filtering variables with conditions or using heatmap."
    ))
  }

  # Check if the group column is in the sample information tibble.
  if (!group_col %in% colnames(object$sample_info)) {
    cli::cli_abort(c(
      "Can't find column {.field {group_col}} in the sample information tibble.",
      "i" = "Available columns: {.field {colnames(object$sample_info)}}"
    ))
  }

  df <- object %>%
    fortify.glyexp_experiment()

  .glyvis_boxplot(df, x = group_col, value = "value", group = group_col) +
    labs(x = "Group", y = expression(log[2]("Expr."))) +
    facet_wrap(~ variable, scales = "free_y")
}

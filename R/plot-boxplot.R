#' Boxplot
#'
#' Draw a boxplot.
#' Currently supported data types:
#' - `SummarizedExperiment`: A [glyexp::GlycomicSE()],
#'   [glyexp::GlycoproteomicSE()], or other compatible container.
#'   Boxplots of log2(expression + 1) values are plotted, grouped by the group column.
#'
#' @param x An object to be plotted.
#' @param ... Common and plot-specific options described in [glyvis_plot_options].
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
plot_boxplot <- function(x, ...) {
  UseMethod("plot_boxplot")
}

#' @rdname plot_boxplot
#' @param group_col A character string specifying the column name in sample information
#'   that contains group labels. Default is "group".
#' @export
plot_boxplot.glyexp_experiment <- function(x, group_col = "group", ...) {
  .plot_exp_boxplot(x, group_col, ...)
}

#' @rdname plot_boxplot
#' @export
plot_boxplot.SummarizedExperiment <- function(x, group_col = "group", ...) {
  .plot_exp_boxplot(x, group_col, ...)
}

#' Internal function to plot boxplot
#' @param exp A `glyexp_experiment` object.
#' @param group_col A character string specifying the column name in sample information
#'   that contains group labels. Default is "group".
#' @param ... Common and plot-specific options described in [glyvis_plot_options].
#' @noRd
.plot_exp_boxplot <- function(
  exp,
  group_col,
  ncol = NULL,
  label_width = 24,
  scales = "free_y",
  ...
) {
  # We don't want to plot too many variables.
  if (nrow(exp) > 25) {
    cli::cli_abort(c(
      "The number of variables must be less than or equal to 25 for boxplot.",
      "x" = "Current number of variables: {.val {nrow(exp)}}",
      "i" = "Consider filtering variables with conditions or using heatmap."
    ))
  }

  # Check if the group column is in the sample information tibble.
  sample_info <- .get_sample_info(exp)
  if (!group_col %in% colnames(sample_info)) {
    cli::cli_abort(c(
      "Can't find column {.field {group_col}} in the sample information tibble.",
      "i" = "Available columns: {.field {colnames(sample_info)}}"
    ))
  }

  df <- .fortify_experiment(exp) |>
    dplyr::mutate(value = log2(.data$value + 1))

  if (is.null(ncol)) {
    ncol <- min(3L, ceiling(sqrt(nrow(exp))))
  }
  checkmate::assert_count(label_width, positive = TRUE)
  .glyvis_boxplot(df, x = group_col, value = "value", group = group_col, ...) +
    labs(x = "Group", y = expression(log[2]("Expr." + 1))) +
    facet_wrap(
      ~variable,
      scales = scales,
      ncol = ncol,
      labeller = as_labeller(function(x) .glyvis_wrap(x, label_width))
    )
}

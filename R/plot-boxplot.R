#' Boxplot
#'
#' Draw a boxplot.
#' Currently supported data types:
#' - `glyexp_experiment`: Experiment created by [glyexp::experiment()].
#'   Boxplots of log2-transformed expression values are plotted, grouped by the group column.
#'
#' @param x An object to be plotted.
#' @param ... Ignored.
#'
#' @returns A ggplot object.
#' @export
plot_boxplot <- function(x, ...) {
  UseMethod("plot_boxplot")
}

#' @rdname plot_boxplot
#' @param group_col A character string specifying the column name in sample information
#'   that contains group labels. Default is "group".
#' @export
plot_boxplot.glyexp_experiment <- function(x, group_col = "group", ...) {
  .plot_exp_boxplot(x, group_col)
}

#' Internal function to plot boxplot
#' @param exp A `glyexp_experiment` object.
#' @param group_col A character string specifying the column name in sample information
#'   that contains group labels. Default is "group".
#' @param ... Other arguments passed to [.glyvis_boxplot()].
#' @noRd
.plot_exp_boxplot <- function(exp, group_col, ...) {
  # We don't want to plot too many variables.
  if (nrow(exp) > 25) {
    cli::cli_abort(c(
      "The number of variables must be less than or equal to 25 for boxplot.",
      "x" = "Current number of variables: {.val {nrow(exp)}}",
      "i" = "Consider filtering variables with conditions or using heatmap."
    ))
  }

  # Check if the group column is in the sample information tibble.
  if (!group_col %in% colnames(exp$sample_info)) {
    cli::cli_abort(c(
      "Can't find column {.field {group_col}} in the sample information tibble.",
      "i" = "Available columns: {.field {colnames(exp$sample_info)}}"
    ))
  }

  df <- exp %>%
    fortify.glyexp_experiment()

  .glyvis_boxplot(df, x = group_col, value = "value", group = group_col) +
    labs(x = "Group", y = expression(log[2]("Expr."))) +
    facet_wrap(~ variable, scales = "free_y")
}
#' Boxplot
#'
#' Draw a boxplot from a [glyexp::experiment()].
#' There should be a group column in the sample information tibble.
#'
#' @param exp A `glyexp_experiment` object.
#' @param group_col A character string specifying the column name in sample information
#'   that contains group labels. Default is "group".
#'
#' @returns A ggplot object.
#' @export
plot_boxplot <- function(exp, group_col = "group") {
  autoplot(exp, type = "boxplot", group_col = group_col)
}
#' Heatmap
#'
#' Draw a heatmap.
#' Currently supported data types:
#' - `glyexp_experiment`: Experiment created by [glyexp::experiment()].
#'   Heatmap of log2-transformed expression values is plotted.
#'
#' @param x An object to be plotted.
#' @param ... Ignored.
#'
#' @returns A ggplot object.
#' @export
plot_heatmap <- function(x, ...) {
  UseMethod("plot_heatmap")
}

#' @rdname plot_heatmap
#' @export
plot_heatmap.glyexp_experiment <- function(x, ...) {
  .plot_exp_heatmap(x)
}

#' Internal function to plot heatmap
#' @param exp A `glyexp_experiment` object.
#' @param ... Other arguments passed to [.glyvis_heatmap()].
#' @noRd
.plot_exp_heatmap <- function(exp, ...) {
  df <- exp %>%
    fortify.glyexp_experiment() %>%
    dplyr::mutate(value = as.double(scale(.data$value)), .by = "variable")

  .glyvis_heatmap(df, x = "sample", y = "variable", value = "value") +
    labs(fill = expression(log[2]("Int.")))
}
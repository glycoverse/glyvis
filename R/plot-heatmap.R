#' Heatmap Plot
#'
#' Draw a heatmap from a [glyexp::experiment()].
#'
#' @param exp A `glyexp_experiment` object.
#'
#' @returns A ggplot object.
#' @export
plot_heatmap <- function(exp) {
  autoplot(exp, type = "heatmap")
}
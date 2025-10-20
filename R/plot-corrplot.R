#' Correlation Plot
#'
#' Draw a correlation matrix heatmap.
#' Currently supported data types:
#' - `glystats_cor_res`: Result from [glystats::gly_cor()].
#' - `glyexp_experiment`: Experiment created by [glyexp::experiment()].
#'   Correlation analysis is first performed using [glystats::gly_cor()],
#'   then the result is plotted.
#'
#' @param x An object to be plotted.
#' @param on A character string specifying what to correlate. Either "variable" (default) to correlate
#'   variables/features, or "sample" to correlate samples/observations.
#' @param ... Additional arguments passed to [GGally::ggcorr()].
#'
#' @returns A ggplot object.
#' @export
plot_corrplot <- function(x, ...) {
  UseMethod("plot_corrplot")
}

#' @rdname plot_corrplot
#' @export
plot_corrplot.glystats_cor_res <- function(x, ...) {
  .plot_corrplot(x)
}

#' @rdname plot_corrplot
#' @export
plot_corrplot.glyexp_experiment <- function(x, on = "variable", ...) {
  cor_res <- glystats::gly_cor(x, on = on)
  .plot_corrplot(cor_res)
}

#' Internal function to plot correlation matrix
#' @param cor_res A `glystats_cor_res` object.
#' @param ... Other arguments passed to [GGally::ggcorr()].
#' @noRd
.plot_corrplot <- function(cor_res, ...) {
  rlang::check_installed("GGally")
  GGally::ggcorr(cor_res$raw_result$r, ...)
}
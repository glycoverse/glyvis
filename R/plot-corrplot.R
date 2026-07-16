#' Correlation Plot
#'
#' Draw a correlation matrix heatmap.
#' Currently supported data types:
#' - `glystats_cor_res`: Result from [glystats::gly_cor()].
#' - `SummarizedExperiment`: A [glyexp::GlycomicSE()],
#'   [glyexp::GlycoproteomicSE()], or other compatible container.
#'   Correlation analysis is first performed using [glystats::gly_cor()],
#'   then the result is plotted.
#'
#' @param x An object to be plotted.
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
#' @param stats_args A list of keyword arguments to pass to [glystats::gly_cor()].
#' @export
plot_corrplot.glyexp_experiment <- function(x, stats_args = list(), ...) {
  cor_res <- rlang::exec(glystats::gly_cor, x, !!!stats_args)
  .plot_corrplot(cor_res)
}

#' @rdname plot_corrplot
#' @export
plot_corrplot.SummarizedExperiment <- function(x, stats_args = list(), ...) {
  cor_res <- rlang::exec(glystats::gly_cor, x, !!!stats_args)
  .plot_corrplot(cor_res)
}

#' Internal function to plot correlation matrix
#' @param cor_res A `glystats_cor_res` object.
#' @param ... Other arguments passed to [GGally::ggcorr()].
#' @noRd
.plot_corrplot <- function(cor_res, ...) {
  rlang::check_installed("GGally")

  correlation <- cor_res$raw_result$r
  feature_names <- colnames(correlation)
  safe_feature_names <- make.names(feature_names, unique = TRUE)
  dimnames(correlation) <- list(safe_feature_names, safe_feature_names)

  plot <- GGally::ggcorr(correlation, ...)
  diagonal_layer <- length(plot$layers)
  plot$layers[[diagonal_layer]]$data$diagLabel <- feature_names

  plot
}

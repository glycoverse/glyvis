#' Plots for Correlation Analysis
#'
#' Visualization for [glystats::gly_cor()] results (`glystats_cor_res` objects).
#'
#' @param object A `glystats_cor_res` object.
#' @param ... Other arguments passed to [GGally::ggcorr()].
#'
#' @returns A ggplot object.
#' @export
autoplot.glystats_cor_res <- function(object, ...) {
  rlang::check_installed("GGally")
  GGally::ggcorr(object$raw_result$r, ...)
}

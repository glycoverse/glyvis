#' Plots for Correlation Analysis
#'
#' Visualization for [glystats::gly_cor()] results (`glystats_cor_res` objects).
#'
#' @param object A `glystats_cor_res` object.
#' @param ... Common and plot-specific options described in [glyvis_plot_options].
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
autoplot.glystats_cor_res <- function(object, ...) {
  .plot_corrplot(object, ...)
}

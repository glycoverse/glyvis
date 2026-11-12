#' Plots for Correlation Analysis
#'
#' Visualization for [glystats::gly_cor()] results (`glystats_cor_res` objects).
#'
#' @param object A `glystats_cor_res` object.
#' @inheritParams plot_corrplot
#' @param ... Common styling options described in [glyvis_plot_options].
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
autoplot.glystats_cor_res <- function(
  object,
  ...,
  label = FALSE,
  digits = 2,
  triangle = "lower"
) {
  .plot_corrplot(
    object,
    ...,
    label = label,
    digits = digits,
    triangle = triangle
  )
}

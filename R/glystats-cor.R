#' Plots for Correlation Analysis
#'
#' Visualization for [glystats::gly_cor()] results (`glystats_cor_res` objects).
#'
#' @param object A `glystats_cor_res` object.
#' @inheritParams plot_corrplot
#' @inheritParams glyvis_plot_options
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
autoplot.glystats_cor_res <- function(
  object,
  ...,
  label = FALSE,
  digits = 2,
  triangle = "lower",
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
) {
  rlang::check_dots_empty()
  .plot_corrplot(
    object,
    ...,
    title = title,
    width = width,
    height = height,
    fontsize = fontsize,
    family = family,
    palette = palette,
    label = label,
    digits = digits,
    triangle = triangle
  )
}

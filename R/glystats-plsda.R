#' Plots for PLS-DA
#'
#' Visualization for results from [glystats::gly_plsda()] (`glystats_plsda_res` object).
#' Possible `type`s of plots:
#' - "scores" (default): Plot scores for samples.
#' - "loadings": Plot loadings for variables.
#' - "vip": Plot VIP scores for variables.
#' - "variance": Plot explained variance for each component.
#'
#' @param object A `glystats_plsda_res` object.
#' @param type The type of plot, one of "loadings", "scores", "vip", or "variance". Defaults to "scores".
#' @param groups A factor or character vector specifying group membership for each sample.
#'   If provided, the plot will be colored by group.
#'   Only applicable to "scores" and "loadings" types.
#' @param group_col A character string specifying where to find the group information.
#'   If the result was produced from a supported Glycoverse data container,
#'   sample information has already been added to the result.
#'   In this case, you can specify the column name in the sample information tibble
#'   to be used for coloring.
#'   If not provided, this function will try "group".
#' @inheritParams plot_plsda
#' @param ... Common styling options described in [glyvis_plot_options].
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
autoplot.glystats_plsda_res <- function(
  object,
  type = "scores",
  groups = NULL,
  group_col = NULL,
  ...,
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  top_n = NULL
) {
  .plot_plsda(
    object,
    type,
    groups,
    group_col,
    ...,
    label = label,
    add_ellipse = add_ellipse,
    point_size = point_size,
    alpha = alpha,
    top_n = top_n
  )
}

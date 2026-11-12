#' Plots for Principal Component Analysis (PCA)
#'
#' Visualization for [glystats::gly_pca()] results (`glystats_pca_res` object).
#' Possible `type`s of plots:
#' - "screeplot": Scree plot to see the contribution of each PC.
#' - "individual" (default): Plot samples as individuals.
#' - "variables": Plot loadings for variables.
#' - "biplot": Biplot showing both samples and variables.
#'
#' @param object A `glystats_pca_res` object.
#' @param type The type of plot, one of "screeplot", "individual", "variables", or "biplot".
#' @param groups A factor or character vector specifying group membership for each sample.
#'   If provided, the plot will be colored by group.
#'   Only applicable to "individual" and "biplot" types.
#' @param group_col A character string specifying where to find the group information.
#'   If the result was produced from a supported Glycoverse data container,
#'   sample information has already been added to the result.
#'   In this case, you can specify the column name in the sample information tibble
#'   to be used for coloring.
#'   If not provided, this function will try "group".
#' @inheritParams plot_pca
#' @inheritParams glyvis_plot_options
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
autoplot.glystats_pca_res <- function(
  object,
  ...,
  type = "individual",
  groups = NULL,
  group_col = NULL,
  axes = c(1L, 2L),
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  top_n = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
) {
  rlang::check_dots_empty()
  .plot_pca(
    object,
    type = type,
    groups = groups,
    group_col = group_col,
    ...,
    title = title,
    width = width,
    height = height,
    fontsize = fontsize,
    family = family,
    palette = palette,
    axes = axes,
    label = label,
    add_ellipse = add_ellipse,
    point_size = point_size,
    alpha = alpha,
    top_n = top_n
  )
}

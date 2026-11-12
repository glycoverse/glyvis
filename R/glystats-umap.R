#' Plots for UMAP
#'
#' Visualization for results from [glystats::gly_umap()] (`glystats_umap_res` objects).
#' Draw a scatter plot of UMAP coordinates.
#'
#' @param object A `glystats_umap_res` object.
#' @param groups A factor or character vector specifying group membership for each sample.
#'   If provided, the plot will be colored by group.
#' @param group_col A character string specifying where to find the group information.
#'   If the result was produced from a supported Glycoverse data container,
#'   sample information has already been added to the result.
#'   In this case, you can specify the column name in the sample information tibble
#'   to be used for coloring.
#'   If not provided, this function will try "group".
#' @inheritParams plot_umap
#' @inheritParams glyvis_plot_options
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
autoplot.glystats_umap_res <- function(
  object,
  ...,
  groups = NULL,
  group_col = NULL,
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
) {
  rlang::check_dots_empty()
  .plot_umap(
    object,
    groups = groups,
    group_col = group_col,
    ...,
    title = title,
    width = width,
    height = height,
    fontsize = fontsize,
    family = family,
    palette = palette,
    label = label,
    add_ellipse = add_ellipse,
    point_size = point_size,
    alpha = alpha
  )
}

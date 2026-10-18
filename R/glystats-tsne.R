#' Plots for t-SNE
#'
#' Visualization for results from [glystats::gly_tsne()] (`glystats_tsne_res` objects).
#' Draw a scatter plot of t-SNE coordinates.
#'
#' @param object A `glystats_tsne_res` object.
#' @param groups A factor or character vector specifying group membership for each sample.
#'   If provided, the plot will be colored by group.
#' @param group_col A character string specifying where to find the group information.
#'   If the result was produced from a supported Glycoverse data container,
#'   sample information has already been added to the result.
#'   In this case, you can specify the column name in the sample information tibble
#'   to be used for coloring.
#'   If not provided, this function will try "group".
#' @param ... Common and plot-specific options described in [glyvis_plot_options].
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
autoplot.glystats_tsne_res <- function(
  object,
  groups = NULL,
  group_col = NULL,
  ...
) {
  .plot_tsne(object, groups = groups, group_col = group_col, ...)
}

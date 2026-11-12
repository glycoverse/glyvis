#' t-SNE Plot
#'
#' Draw a t-SNE scores plot.
#' Currently supported data types:
#' - `glystats_tsne_res`: Result from [glystats::gly_tsne()].
#' - `SummarizedExperiment`: A [glyexp::GlycomicSE()],
#'   [glyexp::GlycoproteomicSE()], or other compatible container.
#'   t-SNE analysis is first performed using [glystats::gly_tsne()],
#'   then the result is plotted.
#'
#' @param x An object to be plotted.
#' @param label Whether to label samples. Defaults to `FALSE`.
#' @param add_ellipse Whether to add group ellipses. Requires sample groups.
#' @param point_size,alpha Point size and opacity.
#' @param ... Common styling options described in [glyvis_plot_options].
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
plot_tsne <- function(
  x,
  ...,
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8
) {
  UseMethod("plot_tsne")
}

#' @rdname plot_tsne
#' @param groups A factor or character vector specifying group membership for each sample.
#'   If provided, the plot will be colored by group.
#' @param group_col A character string specifying where to find the group information.
#'   If the result was produced from a supported Glycoverse data container,
#'   sample information has already been added to the result.
#'   In this case, you can specify the column name in the sample information tibble
#'   to be used for coloring.
#'   If not provided, this function will try "group".
#' @export
plot_tsne.glystats_tsne_res <- function(
  x,
  groups = NULL,
  group_col = NULL,
  ...,
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8
) {
  .plot_tsne(
    x,
    groups = groups,
    group_col = group_col,
    ...,
    label = label,
    add_ellipse = add_ellipse,
    point_size = point_size,
    alpha = alpha
  )
}

#' @rdname plot_tsne
#' @param stats_args A list of keyword arguments to pass to [glystats::gly_tsne()].
#' @export
plot_tsne.glyexp_experiment <- function(
  x,
  groups = NULL,
  group_col = NULL,
  stats_args = list(),
  ...,
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8
) {
  tsne_res <- rlang::exec(glystats::gly_tsne, x, !!!stats_args)
  .plot_tsne(
    tsne_res,
    groups = groups,
    group_col = group_col,
    ...,
    label = label,
    add_ellipse = add_ellipse,
    point_size = point_size,
    alpha = alpha
  )
}

#' @rdname plot_tsne
#' @export
plot_tsne.SummarizedExperiment <- function(
  x,
  groups = NULL,
  group_col = NULL,
  stats_args = list(),
  ...,
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8
) {
  tsne_res <- rlang::exec(glystats::gly_tsne, x, !!!stats_args)
  .plot_tsne(
    tsne_res,
    groups = groups,
    group_col = group_col,
    ...,
    label = label,
    add_ellipse = add_ellipse,
    point_size = point_size,
    alpha = alpha
  )
}

.plot_tsne <- function(tsne_res, groups = NULL, group_col = NULL, ...) {
  .validate_group_args(groups, group_col)
  groups <- .prepare_groups(tsne_res, groups, group_col)

  df <- tsne_res$tidy_result
  df$group <- groups
  .glyvis_scatter(
    df,
    "tsne1",
    "tsne2",
    group = if (is.null(groups)) NULL else "group",
    label_col = .result_id_column(tsne_res, "sample"),
    ...
  )
}

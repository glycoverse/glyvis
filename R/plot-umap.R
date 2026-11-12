#' UMAP Plot
#'
#' Draw a UMAP scores plot.
#' Currently supported data types:
#' - `glystats_umap_res`: Result from [glystats::gly_umap()].
#' - `SummarizedExperiment`: A [glyexp::GlycomicSE()],
#'   [glyexp::GlycoproteomicSE()], or other compatible container.
#'   UMAP analysis is first performed using [glystats::gly_umap()],
#'   then the result is plotted.
#'
#' @param x An object to be plotted.
#' @inheritParams plot_tsne
#' @inheritParams glyvis_plot_options
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
plot_umap <- function(
  x,
  ...,
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL,
  groups = NULL,
  group_col = NULL,
  stats_args = list()
) {
  rlang::check_dots_empty()
  UseMethod("plot_umap")
}

#' @rdname plot_umap
#' @param groups A factor or character vector specifying group membership for each sample.
#'   If provided, the plot will be colored by group.
#' @param group_col A character string specifying where to find the group information.
#'   If the result was produced from a supported Glycoverse data container,
#'   sample information has already been added to the result.
#'   In this case, you can specify the column name in the sample information tibble
#'   to be used for coloring.
#'   If not provided, this function will try "group".
#' @export
plot_umap.glystats_umap_res <- function(
  x,
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
    x,
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

#' @rdname plot_umap
#' @param stats_args A list of keyword arguments to pass to [glystats::gly_umap()].
#' @export
plot_umap.glyexp_experiment <- function(
  x,
  ...,
  groups = NULL,
  group_col = NULL,
  stats_args = list(),
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
  umap_res <- rlang::exec(glystats::gly_umap, x, !!!stats_args)
  .plot_umap(
    umap_res,
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

#' @rdname plot_umap
#' @export
plot_umap.SummarizedExperiment <- function(
  x,
  ...,
  groups = NULL,
  group_col = NULL,
  stats_args = list(),
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
  umap_res <- rlang::exec(glystats::gly_umap, x, !!!stats_args)
  .plot_umap(
    umap_res,
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

.plot_umap <- function(umap_res, groups = NULL, group_col = NULL, ...) {
  .validate_group_args(groups, group_col)
  groups <- .prepare_groups(umap_res, groups, group_col)

  df <- umap_res$tidy_result
  df$group <- groups
  .glyvis_scatter(
    df,
    "umap1",
    "umap2",
    group = if (is.null(groups)) NULL else "group",
    label_col = .result_id_column(umap_res, "sample"),
    ...
  )
}

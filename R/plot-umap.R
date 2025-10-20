#' UMAP Plot
#'
#' Draw a UMAP scores plot.
#' Currently supported data types:
#' - `glystats_umap_res`: Result from [glystats::gly_umap()].
#' - `glyexp_experiment`: Experiment created by [glyexp::experiment()].
#'   UMAP analysis is first performed using [glystats::gly_umap()],
#'   then the result is plotted.
#'
#' @param x An object to be plotted.
#' @param ... Ignored.
#'
#' @returns A ggplot object.
#' @export
plot_umap <- function(x, ...) {
  UseMethod("plot_umap")
}

#' @rdname plot_umap
#' @param groups A factor or character vector specifying group membership for each sample.
#'   If provided, the plot will be colored by group.
#' @param group_col A character string specifying where to find the group information.
#'   If you uses [glystats::gly_umap()] on a [glyexp::experiment()] to get the result,
#'   sample information has already been added to the result.
#'   In this case, you can specify the column name in the sample information tibble
#'   to be used for coloring.
#'   If not provided, this function will try "group".
#' @export
plot_umap.glystats_umap_res <- function(x, groups = NULL, group_col = NULL, ...) {
  .plot_umap(x, groups = groups, group_col = group_col)
}

#' @rdname plot_umap
#' @export
plot_umap.glyexp_experiment <- function(x, groups = NULL, group_col = NULL, ...) {
  umap_res <- glystats::gly_umap(x)
  .plot_umap(umap_res, groups = groups, group_col = group_col)
}

.plot_umap <- function(umap_res, groups = NULL, group_col = NULL) {
  .validate_group_args(groups, group_col)
  groups <- .prepare_groups(umap_res, groups, group_col)

  df <- umap_res$tidy_result
  df$group <- groups
  .glyvis_scatter(df, "umap1", "umap2", group = "group")
}
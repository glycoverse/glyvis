#' t-SNE Plot
#'
#' Draw a t-SNE scores plot.
#' Currently supported data types:
#' - `glystats_tsne_res`: Result from [glystats::gly_tsne()].
#' - `glyexp_experiment`: Experiment created by [glyexp::experiment()].
#'   t-SNE analysis is first performed using [glystats::gly_tsne()],
#'   then the result is plotted.
#'
#' @param x An object to be plotted.
#' @param ... Ignored.
#'
#' @returns A ggplot object.
#' @export
plot_tsne <- function(x, ...) {
  UseMethod("plot_tsne")
}

#' @rdname plot_tsne
#' @param groups A factor or character vector specifying group membership for each sample.
#'   If provided, the plot will be colored by group.
#' @param group_col A character string specifying where to find the group information.
#'   If you uses [glystats::gly_tsne()] on a [glyexp::experiment()] to get the result,
#'   sample information has already been added to the result.
#'   In this case, you can specify the column name in the sample information tibble
#'   to be used for coloring.
#'   If not provided, this function will try "group".
#' @export
plot_tsne.glystats_tsne_res <- function(x, groups = NULL, group_col = NULL, ...) {
  .plot_tsne(x, groups = groups, group_col = group_col)
}

#' @rdname plot_tsne
#' @export
plot_tsne.glyexp_experiment <- function(x, groups = NULL, group_col = NULL, ...) {
  tsne_res <- glystats::gly_tsne(x)
  .plot_tsne(tsne_res, groups = groups, group_col = group_col)
}

.plot_tsne <- function(tsne_res, groups = NULL, group_col = NULL) {
  .validate_group_args(groups, group_col)
  groups <- .prepare_groups(tsne_res, groups, group_col)

  df <- tsne_res$tidy_result
  df$group <- groups
  .glyvis_scatter(df, "tsne1", "tsne2", group = "group")
}
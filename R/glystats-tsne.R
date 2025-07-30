#' Plots for t-SNE
#'
#' Visualization for results from [glystats::gly_tsne()] (`glystats_tsne_res` objects).
#' Draw a scatter plot of t-SNE coordinates.
#'
#' @param object A `glystats_tsne_res` object.
#' @param groups A factor or character vector specifying group membership for each sample.
#'   If provided, the plot will be colored by group.
#' @param group_col A character string specifying where to find the group information.
#'   If you uses [glystats::gly_tsne()] on a [glyexp::experiment()] to get the result,
#'   sample information has already been added to the result.
#'   In this case, you can specify the column name in the sample information tibble
#'   to be used for coloring.
#'   If not provided, this function will try "group".
#' @param ... Ignored.
#'
#' @returns A ggplot object.
#' @export
autoplot.glystats_tsne_res <- function(object, groups = NULL, group_col = NULL, ...) {
  checkmate::assert(
    checkmate::check_factor(groups),
    checkmate::check_character(groups),
    checkmate::check_null(groups)
  )
  checkmate::assert_string(group_col, null.ok = TRUE)

  groups <- .prepare_groups(object, groups, group_col)

  df <- object$tidy_result
  df$group <- groups
  .glyvis_scatter(df, "tsne1", "tsne2", group = "group")
}
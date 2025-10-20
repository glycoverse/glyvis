#' PLS-DA Plot
#'
#' Draw a PLS-DA scores plot.
#' Currently supported data types:
#' - `glystats_plsda_res`: Result from [glystats::gly_plsda()].
#' - `glyexp_experiment`: Experiment created by [glyexp::experiment()].
#'   PLS-DA analysis is first performed using [glystats::gly_plsda()],
#'   then the result is plotted.
#'
#' @param x An object to be plotted.
#' @param type The type of plot, one of "loadings", "scores", "vip", or "variance". Defaults to "scores".
#' @param groups A factor or character vector specifying group membership for each sample.
#'   If provided, the plot will be colored by group.
#'   Only applicable to "scores" and "loadings" types.
#' @param group_col A character string specifying where to find the group information.
#'   If you uses [glystats::gly_plsda()] on a [glyexp::experiment()] to get the result,
#'   sample information has already been added to the result.
#'   In this case, you can specify the column name in the sample information tibble
#'   to be used for coloring.
#'   If not provided, this function will try "group".
#' @param ... Ignored.
#'
#' @returns A ggplot object.
#' @export
plot_plsda <- function(x, type = "scores", groups = NULL, group_col = NULL, ...) {
  UseMethod("plot_plsda")
}

#' @rdname plot_plsda
#' @export
plot_plsda.glystats_plsda_res <- function(x, type = "scores", groups = NULL, group_col = NULL, ...) {
  .plot_plsda(x, type, groups, group_col, ...)
}

#' @rdname plot_plsda
#' @param stats_args A list of keyword arguments to pass to [glystats::gly_plsda()].
#' @export
plot_plsda.glyexp_experiment <- function(x, type = "scores", groups = NULL, group_col = NULL, stats_args = list(), ...) {
  plsda_res <- rlang::exec(glystats::gly_plsda, x, !!!stats_args)
  .plot_plsda(plsda_res, type, groups, group_col, ...)
}

.plot_plsda <- function(object, type = "scores", groups = NULL, group_col = NULL, ...) {
  checkmate::assert_choice(type, c("loadings", "scores", "vip", "variance"))
  .validate_group_args(groups, group_col)

  # The `samples` tibble of `gly_plsda()` has similar structure as `gly_pca()`,
  # so we can reuse the same group extractor.
  groups <- .prepare_groups(object, groups, group_col)

  switch(
    type,
    scores = .plot_oplsda_scores(object, "p2", groups),
    loadings = .plot_oplsda_loadings(object, "p2"),
    vip = .plot_oplsda_vip(object),
    variance = .plot_oplsda_variance(object)
  )
}
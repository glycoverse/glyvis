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
#'   If you uses [glystats::gly_plsda()] on a [glyexp::experiment()] to get the result,
#'   sample information has already been added to the result.
#'   In this case, you can specify the column name in the sample information tibble
#'   to be used for coloring.
#'   If not provided, this function will try "group".
#' @param ... Ignored.
#'
#' @returns A ggplot object.
#' @export
autoplot.glystats_plsda_res <- function(object, type = "scores", groups = NULL, group_col = NULL, ...) {
  checkmate::assert_choice(type, c("loadings", "scores", "vip", "variance"))
  checkmate::assert(
    checkmate::check_factor(groups),
    checkmate::check_character(groups),
    checkmate::check_null(groups)
  )
  checkmate::assert_string(group_col, null.ok = TRUE)

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
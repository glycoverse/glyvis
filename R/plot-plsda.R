#' PLS-DA Plot
#'
#' Draw a PLS-DA scores plot.
#' Currently supported data types:
#' - `glystats_plsda_res`: Result from [glystats::gly_plsda()].
#' - `SummarizedExperiment`: A [glyexp::GlycomicSE()],
#'   [glyexp::GlycoproteomicSE()], or other compatible container.
#'   PLS-DA analysis is first performed using [glystats::gly_plsda()],
#'   then the result is plotted.
#'
#' @param x An object to be plotted.
#' @param type The type of plot, one of "loadings", "scores", "vip", or "variance". Defaults to "scores".
#' @param groups A factor or character vector specifying group membership for each sample.
#'   If provided, the plot will be colored by group.
#'   Only applicable to "scores" and "loadings" types.
#' @param group_col A character string specifying where to find the group information.
#'   If the result was produced from a supported Glycoverse data container,
#'   sample information has already been added to the result.
#'   In this case, you can specify the column name in the sample information tibble
#'   to be used for coloring.
#'   If not provided, this function will try "group".
#' @param label Whether to label samples in scores plots or variables in loadings
#'   plots. Defaults to `FALSE`.
#' @param add_ellipse Whether to add group ellipses to scores plots.
#' @param point_size,alpha Point size and opacity for scores plots.
#' @param top_n Number of variables to retain in loadings or VIP plots. `NULL`
#'   retains all variables; a positive integer selects the largest squared
#'   loading norms or VIP scores, respectively.
#' @param ... Common styling options described in [glyvis_plot_options].
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
plot_plsda <- function(
  x,
  ...,
  type = "scores",
  groups = NULL,
  group_col = NULL,
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  top_n = NULL
) {
  UseMethod("plot_plsda")
}

#' @rdname plot_plsda
#' @export
plot_plsda.glystats_plsda_res <- function(
  x,
  ...,
  type = "scores",
  groups = NULL,
  group_col = NULL,
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  top_n = NULL
) {
  .plot_plsda(
    x,
    type,
    groups,
    group_col,
    ...,
    label = label,
    add_ellipse = add_ellipse,
    point_size = point_size,
    alpha = alpha,
    top_n = top_n
  )
}

#' @rdname plot_plsda
#' @param stats_args A list of keyword arguments to pass to [glystats::gly_plsda()].
#' @export
plot_plsda.glyexp_experiment <- function(
  x,
  ...,
  type = "scores",
  groups = NULL,
  group_col = NULL,
  stats_args = list(),
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  top_n = NULL
) {
  plsda_res <- rlang::exec(glystats::gly_plsda, x, !!!stats_args)
  .plot_plsda(
    plsda_res,
    type,
    groups,
    group_col,
    ...,
    label = label,
    add_ellipse = add_ellipse,
    point_size = point_size,
    alpha = alpha,
    top_n = top_n
  )
}

#' @rdname plot_plsda
#' @export
plot_plsda.SummarizedExperiment <- function(
  x,
  ...,
  type = "scores",
  groups = NULL,
  group_col = NULL,
  stats_args = list(),
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  top_n = NULL
) {
  plsda_res <- rlang::exec(glystats::gly_plsda, x, !!!stats_args)
  .plot_plsda(
    plsda_res,
    type,
    groups,
    group_col,
    ...,
    label = label,
    add_ellipse = add_ellipse,
    point_size = point_size,
    alpha = alpha,
    top_n = top_n
  )
}

.plot_plsda <- function(
  object,
  type = "scores",
  groups = NULL,
  group_col = NULL,
  ...,
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  top_n = NULL
) {
  checkmate::assert_choice(type, c("loadings", "scores", "vip", "variance"))
  .validate_group_args(groups, group_col)

  # The `samples` tibble of `gly_plsda()` has similar structure as `gly_pca()`,
  # so we can reuse the same group extractor.
  groups <- .prepare_groups(object, groups, group_col)

  switch(
    type,
    scores = .plot_oplsda_scores(
      object,
      "p2",
      groups,
      ...,
      label = label,
      add_ellipse = add_ellipse,
      point_size = point_size,
      alpha = alpha
    ),
    loadings = .plot_oplsda_loadings(
      object,
      "p2",
      ...,
      label = label,
      top_n = top_n
    ),
    vip = .plot_oplsda_vip(object, ..., top_n = top_n),
    variance = .plot_oplsda_variance(object, ...)
  )
}

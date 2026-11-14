#' OPLS-DA Plot
#'
#' Draw a OPLS-DA scores plot.
#' Currently supported data types:
#' - `glystats_oplsda_res`: Result from [glystats::gly_oplsda()].
#' - `SummarizedExperiment`: A [glyexp::GlycomicSE()],
#'   [glyexp::GlycoproteomicSE()], or other compatible container.
#'   OPLS-DA analysis is first performed using [glystats::gly_oplsda()],
#'   then the result is plotted.
#'
#' @param x An object to be plotted.
#' @param type The type of plot, one of "loadings", "scores", "vip", "variance", or "s-plot". Defaults to "scores".
#' @param y_type What to plot on the y-axis when `type` is "scores" or "loadings". Either "p2" or "o1". Defaults to "o1".
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
#'   and S-plots. Defaults to `FALSE`.
#' @param add_ellipse Whether to add group ellipses to scores plots.
#' @param point_size,alpha Point size and opacity for scores and S-plots.
#' @param top_n Number of variables to retain in loadings or VIP plots. `NULL`
#'   retains all variables; a positive integer selects the largest squared
#'   loading norms or VIP scores, respectively.
#' @inheritParams glyvis_plot_options
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
plot_oplsda <- function(
  x,
  ...,
  type = "scores",
  y_type = "o1",
  groups = NULL,
  group_col = NULL,
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  top_n = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL,
  stats_args = list()
) {
  rlang::check_dots_empty()
  UseMethod("plot_oplsda")
}

#' @rdname plot_oplsda
#' @export
plot_oplsda.glystats_oplsda_res <- function(
  x,
  ...,
  type = "scores",
  y_type = "o1",
  groups = NULL,
  group_col = NULL,
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  top_n = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
) {
  rlang::check_dots_empty()
  .plot_oplsda(
    x,
    type,
    y_type,
    groups,
    group_col,
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
    alpha = alpha,
    top_n = top_n
  )
}

#' @rdname plot_oplsda
#' @param stats_args A list of keyword arguments to pass to [glystats::gly_oplsda()].
#' @export
plot_oplsda.glyexp_experiment <- function(
  x,
  ...,
  type = "scores",
  y_type = "o1",
  groups = NULL,
  group_col = NULL,
  stats_args = list(),
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  top_n = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
) {
  rlang::check_dots_empty()
  oplsda_res <- rlang::exec(glystats::gly_oplsda, x, !!!stats_args)
  .plot_oplsda(
    oplsda_res,
    type,
    y_type,
    groups,
    group_col,
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
    alpha = alpha,
    top_n = top_n
  )
}

#' @rdname plot_oplsda
#' @export
plot_oplsda.SummarizedExperiment <- function(
  x,
  ...,
  type = "scores",
  y_type = "o1",
  groups = NULL,
  group_col = NULL,
  stats_args = list(),
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  top_n = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
) {
  rlang::check_dots_empty()
  oplsda_res <- rlang::exec(glystats::gly_oplsda, x, !!!stats_args)
  .plot_oplsda(
    oplsda_res,
    type,
    y_type,
    groups,
    group_col,
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
    alpha = alpha,
    top_n = top_n
  )
}

.plot_oplsda <- function(
  object,
  type = "scores",
  y_type = "o1",
  groups = NULL,
  group_col = NULL,
  ...,
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  top_n = NULL
) {
  checkmate::assert_choice(
    type,
    c("loadings", "scores", "vip", "variance", "s-plot")
  )
  checkmate::assert_choice(y_type, c("p2", "o1"))
  .validate_group_args(groups, group_col)

  # The `samples` tibble of `gly_oplsda()` has similar structure as `gly_pca()`,
  # so we can reuse the same group extractor.
  groups <- .prepare_groups(object, groups, group_col)

  switch(
    type,
    scores = .plot_oplsda_scores(
      object,
      y_type,
      groups,
      ...,
      label = label,
      add_ellipse = add_ellipse,
      point_size = point_size,
      alpha = alpha
    ),
    loadings = .plot_oplsda_loadings(
      object,
      y_type,
      ...,
      label = label,
      top_n = top_n
    ),
    vip = .plot_oplsda_vip(object, ..., top_n = top_n),
    variance = .plot_oplsda_variance(object, ...),
    "s-plot" = .plot_oplsda_splot(
      object,
      ...,
      label = label,
      point_size = point_size,
      alpha = alpha
    )
  )
}

.plot_oplsda_scores <- function(object, y_type, groups, ...) {
  df <- object$tidy_result$samples
  if (y_type == "o1") {
    .assert_oplsda_o1_exist(df)
  } else {
    .assert_oplsda_p2_exist(df)
  }
  df$group <- groups
  .glyvis_scatter(
    df,
    "p1",
    y_type,
    if (is.null(groups)) NULL else "group",
    label_col = .result_id_column(object, "sample"),
    ...
  ) +
    labs(
      x = "Predictive component 1",
      y = if (y_type == "o1") {
        "Orthogonal component 1"
      } else {
        "Predictive component 2"
      }
    )
}

.plot_oplsda_loadings <- function(object, y_type, ...) {
  df <- object$tidy_result$variables
  if (y_type == "o1") {
    .assert_oplsda_o1_exist(df)
  } else {
    .assert_oplsda_p2_exist(df)
  }
  .glyvis_loadings(
    df,
    "p1",
    y_type,
    label_col = .result_id_column(object, "variable"),
    ...
  ) +
    labs(
      x = "Predictive loading 1",
      y = if (y_type == "o1") "Orthogonal loading 1" else "Predictive loading 2"
    ) +
    coord_equal()
}

.plot_oplsda_vip <- function(object, top_n = NULL, ...) {
  .glyvis_barplot(
    object$tidy_result$vip,
    .result_id_column(object, "variable"),
    "vip",
    ordered = TRUE,
    top_n = top_n,
    ...
  ) +
    coord_flip() +
    labs(x = "Variable", y = "VIP score")
}

.plot_oplsda_variance <- function(object, ...) {
  .glyvis_barplot(
    object$tidy_result$variance,
    "component",
    "prop_var_explained",
    ...
  ) +
    labs(x = "Component", y = "Proportion of variance explained")
}

.plot_oplsda_splot <- function(
  object,
  palette = NULL,
  ...
) {
  df <- object$tidy_result$variables
  df$direction <- factor(
    ifelse(
      df$pcorr1 > 0.5,
      "Positive",
      ifelse(df$pcorr1 < -0.5, "Negative", "Other")
    ),
    levels = c("Negative", "Other", "Positive")
  )
  .glyvis_scatter(
    df,
    "p1",
    "pcorr1",
    "direction",
    label_col = .result_id_column(object, "variable"),
    palette = palette,
    ...
  ) |>
    tidyplots::add_reference_lines(y = c(-0.5, 0.5), color = "grey60") |>
    tidyplots::add(labs(x = "Predictive loading 1", y = "Correlation with p1"))
}

.assert_oplsda_o1_exist <- function(df) {
  if (!"o1" %in% colnames(df)) {
    cli::cli_abort(c(
      "Can't find orthogonal component scores (o1) in the result.",
      "i" = "This happens when you set `ortho_i` to 0, or to NA and the model didn't benefit from orthogonal components."
    ))
  }
}

.assert_oplsda_p2_exist <- function(df) {
  if (!"p2" %in% colnames(df)) {
    cli::cli_abort(c(
      "Can't find predictive component scores (p2) in the result.",
      "i" = "Did you forget to set {.arg pred_i} to 2 or higher in {.fn glystats::gly_oplsda}?"
    ))
  }
}

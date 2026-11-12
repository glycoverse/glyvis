#' Plots for Glycoverse Data Containers
#'
#' Visualization for [glyexp::GlycomicSE()], [glyexp::GlycoproteomicSE()],
#' and other compatible `SummarizedExperiment` objects.
#' Possible `type`s of plots:
#' - "heatmap": (Default) Expression heatmap with columns as samples and rows as variables.
#' - "boxplot": Boxplot of expression values for each sample.
#'
#' @param object A supported Glycoverse data container.
#' @param type The type of plot, one of "heatmap" (default) or "boxplot".
#' @param group_col A character string specifying where to find the group information.
#'   It should be a column in the sample information tibble. Defaults to "group".
#'   Only applicable to "boxplot".
#' @inheritParams plot_heatmap
#' @inheritParams plot_boxplot
#' @param ... Common styling options described in [glyvis_plot_options].
#' @inheritParams glyvis_abundance_scale
#' @seealso [glyvis_abundance_scale] for scale metadata and compatibility rules.
#'
#' @details Heatmap options (`scale`, `cluster_rows`, `cluster_cols`,
#'   `show_rownames`, `show_colnames`, `na_col`) apply only to `type = "heatmap"`.
#'   Boxplot options (`points`, `ncol`, `label_width`, `scales`) apply only to
#'   `type = "boxplot"`.
#'
#'   For SE containers, `fortify()` returns `.sample` and `.variable`
#'   axis identifiers and an abundance `value` column. Ordinary `sample` and
#'   `variable` metadata are retained. Conflicting annotation names receive
#'   numeric suffixes, with sample metadata preceding variable metadata.
#'   Boxplot `group_col` always selects the original column in `colData()`.
#'   Legacy experiment fortification retains `sample` and `variable` identifiers.
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
autoplot.glyexp_experiment <- function(
  object,
  type = "heatmap",
  group_col = "group",
  ...,
  log_transform = NULL,
  scale = "row",
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  show_rownames = FALSE,
  show_colnames = NULL,
  na_col = "grey90",
  points = TRUE,
  ncol = NULL,
  label_width = 24,
  scales = "free_y"
) {
  checkmate::assert_choice(type, c("heatmap", "boxplot"))
  checkmate::assert_string(group_col)
  plot_args <- switch(
    type,
    heatmap = list(
      scale = scale,
      cluster_rows = cluster_rows,
      cluster_cols = cluster_cols,
      show_rownames = show_rownames,
      show_colnames = show_colnames,
      na_col = na_col
    ),
    boxplot = list(
      points = points,
      ncol = ncol,
      label_width = label_width,
      scales = scales
    )
  )
  # Unspecified controls retain renderer defaults, preserving positional ... calls.
  plot_args <- plot_args[intersect(names(plot_args), names(match.call()))]
  switch(
    type,
    heatmap = rlang::exec(
      .plot_exp_heatmap,
      object,
      ...,
      log_transform = log_transform,
      !!!plot_args
    ),
    boxplot = rlang::exec(
      .plot_exp_boxplot,
      object,
      group_col,
      ...,
      log_transform = log_transform,
      !!!plot_args
    )
  )
}

#' @rdname autoplot.glyexp_experiment
#' @export
autoplot.SummarizedExperiment <- function(
  object,
  type = "heatmap",
  group_col = "group",
  ...,
  log_transform = NULL,
  scale = "row",
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  show_rownames = FALSE,
  show_colnames = NULL,
  na_col = "grey90",
  points = TRUE,
  ncol = NULL,
  label_width = 24,
  scales = "free_y"
) {
  checkmate::assert_choice(type, c("heatmap", "boxplot"))
  checkmate::assert_string(group_col)
  plot_args <- switch(
    type,
    heatmap = list(
      scale = scale,
      cluster_rows = cluster_rows,
      cluster_cols = cluster_cols,
      show_rownames = show_rownames,
      show_colnames = show_colnames,
      na_col = na_col
    ),
    boxplot = list(
      points = points,
      ncol = ncol,
      label_width = label_width,
      scales = scales
    )
  )
  # Unspecified controls retain renderer defaults, preserving positional ... calls.
  plot_args <- plot_args[intersect(names(plot_args), names(match.call()))]
  switch(
    type,
    heatmap = rlang::exec(
      .plot_exp_heatmap,
      object,
      ...,
      log_transform = log_transform,
      !!!plot_args
    ),
    boxplot = rlang::exec(
      .plot_exp_boxplot,
      object,
      group_col,
      ...,
      log_transform = log_transform,
      !!!plot_args
    )
  )
}

#' @export
fortify.glyexp_experiment <- function(model, data, ...) {
  .fortify_experiment(model)
}

#' @export
fortify.SummarizedExperiment <- function(model, data, ...) {
  .fortify_experiment(model)
}

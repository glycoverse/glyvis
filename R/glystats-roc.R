#' Plots for ROC Analysis
#'
#' Visualization for results from [glystats::gly_roc()] (`glystats_roc_res` objects).
#' At most 10 variables can be plotted.
#'
#' @param object A `glystats_roc_res` object.
#' @param type "dotplot" or "roc". Defaults to "dotplot".
#'   If "roc", at most 10 variables can be plotted.
#' @param auc_cutoff The AUC cutoff. Defaults to 0.5. Only used if type is "dotplot".
#' @inheritParams plot_roc
#' @inheritParams glyvis_plot_options
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
autoplot.glystats_roc_res <- function(
  object,
  ...,
  type = "dotplot",
  auc_cutoff = 0.5,
  top_n = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
) {
  rlang::check_dots_empty()
  .plot_roc(
    object,
    type,
    auc_cutoff,
    ...,
    title = title,
    width = width,
    height = height,
    fontsize = fontsize,
    family = family,
    palette = palette,
    top_n = top_n
  )
}

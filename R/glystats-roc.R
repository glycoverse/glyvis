#' Plots for ROC Analysis
#'
#' Visualization for results from [glystats::gly_roc()] (`glystats_roc_res` objects).
#' At most 10 variables can be plotted.
#'
#' @param object A `glystats_roc_res` object.
#' @param type "dotplot" or "roc". Defaults to "dotplot".
#'   If "roc", at most 10 variables can be plotted.
#' @param auc_cutoff The AUC cutoff. Defaults to 0.5. Only used if type is "dotplot".
#' @param ... Ignored.
#'
#' @returns A ggplot object.
#' @export
autoplot.glystats_roc_res <- function(object, type = "dotplot", auc_cutoff = 0.5, ...) {
  .plot_roc(object, type, auc_cutoff)
}
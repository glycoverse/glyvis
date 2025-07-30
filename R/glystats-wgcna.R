#' Plots for WGCNA
#'
#' Visualization for results from [glystats::gly_wgcna()] (`glystats_wgcna_res` objects).
#' Draw a heatmap of eigenvalues.
#'
#' @param object A `glystats_wgcna_res` object.
#' @param ... Ignored.
#'
#' @returns A ggplot object.
#' @export
autoplot.glystats_wgcna_res <- function(object, ...) {
  .glyvis_heatmap(object$tidy_result$eigenvalues, "sample", "module", "eigenvalue")
}
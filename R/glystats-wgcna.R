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
  cli::cli_abort("{.fn autoplot} for {.cls glystats_wgcna_res} objects is not implemented yet.")
}
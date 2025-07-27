#' Plots for Hierarchical Clustering
#'
#' Visualization for results from [glystats::gly_hclust()] (`glystats_hclust_res` object).
#' Draw a dendrogram.
#'
#' @param object A `glystats_hclust_res` object.
#' @param ... Additional arguments passed to [ggdendro::ggdendrogram()].
#'
#' @returns A ggplot object.
#' @seealso [ggdendro::ggdendrogram()]
#' @export
autoplot.glystats_hclust_res <- function(object, ...) {
  .check_pkg_available("ggdendro")
  ggdendro::ggdendrogram(object$raw_result, ...)
}
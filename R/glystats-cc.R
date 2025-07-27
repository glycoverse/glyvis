#' Plots for Consensus Clustering
#'
#' Raise an error for now.
#' Suggest users to use `output_file` parameter in `gly_consensus_clustering()` instead.
#'
#' @param object A `glystats_cc_res` object.
#' @param ... Other arguments passed to underlying functions.
#'
#' @returns A ggplot object.
#' @export
autoplot.glystats_cc_res <- function(object, ...) {
  cli::cli_abort(c(
    "Can't plot consensus clustering results currectly.",
    "i" = "Use {.fn gly_consensus_clustering} with {.arg output_file} parameter to save the plot to a pdf file."
  ))
}
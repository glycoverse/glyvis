#' Plots for Enrichment Analysis
#'
#' Visualization for results from [glystats::gly_enrich_go()], [glystats::gly_enrich_kegg()], and [glystats::gly_enrich_reactome()]
#' (`glystats_go_ora_res`, `glystats_kegg_ora_res`, and `glystats_reactome_ora_res` objects).
#' Possible `type`s of plots:
#' - "dotplot" (default): Dotplot showing p-value, gene counts, and gene ratios.
#' - "barplot": Barplot showing p-values and gene counts.
#' - "network": Network plot showing terms and their relationships.
#'
#' @param object A `glystats_go_ora_res`, `glystats_kegg_ora_res`, or `glystats_reactome_ora_res` object.
#' @param type The type of plot, one of "dotplot" (default), "barplot", or "network".
#' @param ... Other arguments passed to underlying functions
#'   ([enrichplot::dotplot()] for "dotplot", [enrichplot::barplot.enrichResult()] for "barplot", and [enrichplot::emapplot()] for "network")
#'
#' @returns A ggplot object.
#' @seealso [enrichplot::dotplot()], [enrichplot::barplot.enrichResult()], [enrichplot::emapplot()]
#' @export
autoplot.glystats_go_ora_res <- function(object, type = "dotplot", ...) {
  .plot_enrich(object, type, ...)
}

#' @rdname autoplot.glystats_go_ora_res
#' @export
autoplot.glystats_kegg_ora_res <- function(object, type = "dotplot", ...) {
  .plot_enrich(object, type, ...)
}

#' @rdname autoplot.glystats_go_ora_res
#' @export
autoplot.glystats_reactome_ora_res <- function(object, type = "dotplot", ...) {
  .plot_enrich(object, type, ...)
}

#' @importFrom graphics barplot
.plot_enrich <- function(object, type, ...) {
  .check_pkg_available("enrichplot")
  checkmate::assert_choice(type, c("dotplot", "barplot", "network"))
  switch(
    type,
    dotplot = enrichplot::dotplot(object$raw_result, ...),
    barplot = barplot(object$raw_result, ...),
    network = enrichplot::emapplot(enrichplot::pairwise_termsim(object$raw_result), ...)
  )
}

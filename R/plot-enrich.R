#' Plot Enrichment Analysis Results
#'
#' Draw a enrichment analysis result plot.
#' Currently supported data types:
#' - `glystats_go_ora_res`: Result from [glystats::gly_enrich_go()].
#' - `glystats_kegg_ora_res`: Result from [glystats::gly_enrich_kegg()].
#' - `glystats_reactome_ora_res`: Result from [glystats::gly_enrich_reactome()].
#' - `glyexp_experiment`: Experiment created by [glyexp::experiment()].
#'   Enrichment analysis is first performed using [glystats::gly_enrich_go()], [glystats::gly_enrich_kegg()],
#'   or [glystats::gly_enrich_reactome()], then the result is plotted.
#'
#' @param x An object to be plotted.
#' @param type The type of plot, one of "dotplot" (default), "barplot", or "network".
#' @param ... Additional arguments passed to underlying functions:
#'   - "dotplot": [enrichplot::dotplot()]
#'   - "barplot": [enrichplot::barplot.enrichResult()]
#'   - "network": [enrichplot::emapplot()]
#'
#' @returns A ggplot object.
#' @export
plot_enrich <- function(x, type = "dotplot", ...) {
  UseMethod("plot_enrich")
}

#' @rdname plot_enrich
#' @export
plot_enrich.glystats_go_ora_res <- function(x, type = "dotplot", ...) {
  .plot_enrich(x, type, ...)
}

#' @rdname plot_enrich
#' @export
plot_enrich.glystats_kegg_ora_res <- function(x, type = "dotplot", ...) {
  .plot_enrich(x, type, ...)
}

#' @rdname plot_enrich
#' @export
plot_enrich.glystats_reactome_ora_res <- function(x, type = "dotplot", ...) {
  .plot_enrich(x, type, ...)
}

#' @rdname plot_enrich
#' @param enrich_type The type of enrichment analysis, one of "go" (default), "kegg", or "reactome".
#' @param stats_args A list of keyword arguments to pass to [glystats::gly_enrich_go()],
#'   [glystats::gly_enrich_kegg()], or [glystats::gly_enrich_reactome()].
#' @export
plot_enrich.glyexp_experiment <- function(x, type = "dotplot", enrich_type = "go", stats_args = list(), ...) {
  f <- switch(enrich_type,
    go = glystats::gly_enrich_go,
    kegg = glystats::gly_enrich_kegg,
    reactome = glystats::gly_enrich_reactome
  )
  enrich_res <- rlang::exec(f, x, !!!stats_args)
  .plot_enrich(enrich_res, type, ...)
}

.plot_enrich <- function(object, type, ...) {
  rlang::check_installed("enrichplot")
  checkmate::assert_choice(type, c("dotplot", "barplot", "network"))
  switch(
    type,
    dotplot = enrichplot::dotplot(object$raw_result, ...),
    barplot = barplot(object$raw_result, ...),
    network = enrichplot::emapplot(enrichplot::pairwise_termsim(object$raw_result), ...)
  )
}
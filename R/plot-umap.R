#' UMAP Plot
#'
#' This function accepts a [glyexp::experiment()],
#' performs UMAP using [glystats::gly_umap()],
#' and plots the UMAP scores plot.
#'
#' @param exp A [glyexp::experiment()] object.
#' @param ... Additional arguments passed to [glystats::gly_umap()].
#'
#' @returns A ggplot object.
#' @export
plot_umap <- function(exp, ...) {
  autoplot(glystats::gly_umap(exp, ...))
}

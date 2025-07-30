#' t-SNE Plot
#'
#' This function accepts a [glyexp::experiment()],
#' performs t-SNE using [glystats::gly_tsne()],
#' and plots the t-SNE scores plot.
#'
#' @param exp A [glyexp::experiment()] object.
#' @param ... Additional arguments passed to [glystats::gly_tsne()].
#'
#' @returns A ggplot object.
#' @export
plot_tsne <- function(exp, ...) {
  autoplot(glystats::gly_tsne(exp, ...))
}

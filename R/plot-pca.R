#' PCA Plot
#'
#' This function accepts a [glyexp::experiment()],
#' performs PCA using [glystats::gly_pca()],
#' and plots the PCA scores plot.
#'
#' @param exp A [glyexp::experiment()] object.
#' @param ... Additional arguments passed to [glystats::gly_pca()].
#'
#' @returns A ggplot object.
#' @export
plot_pca <- function(exp, ...) {
  autoplot(glystats::gly_pca(exp, ...), type = "individual")
}

#' Correlation Plot
#'
#' This function accepts a [glyexp::experiment()],
#' performs correlation analysis using [glystats::gly_cor()],
#' and plots a correlation matrix heatmap.
#'
#' @param exp A [glyexp::experiment()] object.
#' @param on A character string specifying what to correlate. Either "variable" (default) to correlate
#'   variables/features, or "sample" to correlate samples/observations.
#' @param ... Additional arguments passed to [glystats::gly_cor()] and [autoplot()].
#'
#' @returns A ggplot object.
#' @export
plot_corrplot <- function(exp, on = "variable", ...) {
  checkmate::assert_class(exp, "glyexp_experiment")
  checkmate::assert_choice(on, c("variable", "sample"))
  
  cor_res <- glystats::gly_cor(exp, on = on, ...)
  autoplot(cor_res, ...)
}

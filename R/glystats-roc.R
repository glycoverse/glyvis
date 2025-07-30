#' Plots for ROC Analysis
#'
#' Visualization for results from [glystats::gly_roc()] (`glystats_roc_res` objects).
#' Draw a dotchart for AUC values.
#'
#' @param object A `glystats_roc_res` object.
#' @param auc_cutoff The AUC cutoff. Defaults to 0.5.
#' @param ... Ignored.
#'
#' @returns A ggplot object.
#' @export
autoplot.glystats_roc_res <- function(object, auc_cutoff = 0.5, ...) {
  checkmate::assert_number(auc_cutoff, lower = 0, upper = 1)
  df <- object$tidy_result$auc %>%
    dplyr::mutate(
      candidate = .data$auc >= auc_cutoff,
      point_color = dplyr::if_else(.data$candidate, glyvis_colors[1], "lightgrey")
    )
  .glyvis_dotchart(df, x = "variable", y = "auc") +
    geom_hline(yintercept = auc_cutoff, linetype = "dashed", alpha = 0.7) +
    labs(x = "Variable", y = "ROC AUC")
}
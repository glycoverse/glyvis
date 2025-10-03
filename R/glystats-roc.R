#' Plots for ROC Analysis
#'
#' Visualization for results from [glystats::gly_roc()] (`glystats_roc_res` objects).
#' At most 10 variables can be plotted.
#'
#' @param object A `glystats_roc_res` object.
#' @param type "dotplot" or "roc". Defaults to "dotplot".
#'   If "roc", at most 10 variables can be plotted.
#' @param auc_cutoff The AUC cutoff. Defaults to 0.5. Only used if type is "dotplot".
#' @param ... Ignored.
#'
#' @returns A ggplot object.
#' @export
autoplot.glystats_roc_res <- function(object, type = "dotplot", auc_cutoff = 0.5, ...) {
  checkmate::assert_choice(type, c("dotplot", "roc"))
  checkmate::assert_number(auc_cutoff, lower = 0, upper = 1)
  if (type == "dotplot") {
    df <- object$tidy_result$auc %>%
      dplyr::mutate(
        candidate = .data$auc >= auc_cutoff,
        point_color = dplyr::if_else(.data$candidate, glyvis_colors[1], "lightgrey")
      )
    .glyvis_dotchart(df, x = "variable", y = "auc") +
      geom_hline(yintercept = auc_cutoff, linetype = "dashed", alpha = 0.7) +
      labs(x = "Variable", y = "ROC AUC")
  } else {
    if (nrow(object$tidy_result$auc) > 10) {
      cli::cli_abort(c(
        "Number of variables must be less than or equal to 10 when {.arg type} is {.val roc}.",
        "x" = "Current number of variables: {.val {nrow(object$tidy_result$auc)}}",
        "i" = "Use {.arg type} = {.val dotplot}."
      ))
    }
    .glyvis_roc(object$tidy_result$coords)
  }
}
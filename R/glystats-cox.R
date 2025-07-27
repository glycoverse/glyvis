#' Plots for Cox Proportional Hazards Model
#'
#' Visualization for results from [glystats::gly_cox()] (`glystats_cox_res` objects).
#' Draw a lolipop plot for p-values.
#'
#' @param object A `glystats_cox_res` object.
#' @param p_cutoff The p-value cutoff. Defaults to 0.05.
#' @param p_col The column name for p-value. Defaults to "p_adj".
#'   Can also be "p" (raw p-values without multiple testing correction).
#' @param ... Other arguments passed to underlying functions.
#'
#' @returns A ggplot object.
#' @export
autoplot.glystats_cox_res <- function(
  object,
  p_cutoff = 0.05,
  p_col = "p_adj",
  ...
) {
  checkmate::assert_number(p_cutoff, lower = 0)
  checkmate::assert_choice(p_col, c("p", "p_adj"))

  df <- object$tidy_result %>%
    dplyr::mutate(
      neglog10p = -log10(.data[[p_col]]),
      candidate = .data[[p_col]] < p_cutoff,
      point_color = dplyr::if_else(.data$candidate, glyvis_colors[1], "lightgrey")
    )

  .glyvis_lolipop(df, x = "variable", y = "neglog10p") +
    geom_hline(yintercept = -log10(p_cutoff), linetype = "dashed", alpha = 0.7) +
    labs(
      x = "Variable",
      y = expression(-Log[10]~italic(P)~adjusted)
    )
}

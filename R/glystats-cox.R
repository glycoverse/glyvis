#' Plots for Cox Proportional Hazards Model
#'
#' Visualization for results from [glystats::gly_cox()] (`glystats_cox_res` objects).
#' Draw a dotchart for p-values.
#'
#' @param object A `glystats_cox_res` object.
#' @param p_cutoff The p-value cutoff. Defaults to 0.05.
#' @param p_col The column name for p-value. Defaults to "p_adj".
#'   Can also be "p_val" (raw p-values without multiple testing correction).
#' @param ... Common and plot-specific options described in [glyvis_plot_options].
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
autoplot.glystats_cox_res <- function(
  object,
  p_cutoff = 0.05,
  p_col = "p_adj",
  ...
) {
  checkmate::assert_number(p_cutoff, lower = 0)
  checkmate::assert_choice(p_col, c("p_val", "p_adj"))

  df <- object$tidy_result %>%
    dplyr::mutate(
      neglog10p = -log10(pmax(.data[[p_col]], .Machine$double.xmin)),
      candidate = .data[[p_col]] < p_cutoff,
      point_color = dplyr::if_else(
        .data$candidate,
        glyvis_colors[1],
        "lightgrey"
      )
    )

  .glyvis_dotchart(df, x = "variable", y = "neglog10p", ...) +
    geom_hline(
      yintercept = -log10(p_cutoff),
      linetype = "dashed",
      alpha = 0.7
    ) +
    labs(
      x = "Variable",
      y = if (p_col == "p_adj") {
        expression(-log[10] ~ italic(P) ~ adjusted)
      } else {
        expression(-log[10] ~ italic(P))
      }
    )
}

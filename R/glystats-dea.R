#' Plots for 2-Group Differential Expression Analysis (DEA)
#'
#' Visualization for results from [glystats::gly_ttest()] and [glystats::gly_wilcox()]
#' (`glystats_ttest_res` and `glystats_wilcox_res` objects).
#' Draw a volcano plot.
#'
#' @param object A `glystats_ttest_res` or `glystats_wilcox_res` object.
#' @param log2fc_cutoff The log2 fold change cutoff. Defaults to 1.
#' @param p_cutoff The p-value cutoff. Defaults to 0.05.
#' @param p_col The column name for p-value. Defaults to "p_adj".
#'   Can also be "p_val" (raw p-values without multiple testing correction).
#' @param ... Ignored.
#'
#' @returns A ggplot object.
#' @export
autoplot.glystats_ttest_res <- function(
  object,
  log2fc_cutoff = 1,
  p_cutoff = 0.05,
  p_col = "p_adj",
  ...
) {
  .plot_volcano(object, log2fc_cutoff, p_cutoff, p_col, ...)
}

#' @rdname autoplot.glystats_ttest_res
#' @export
autoplot.glystats_wilcox_res <- function(
  object,
  log2fc_cutoff = 1,
  p_cutoff = 0.05,
  p_col = "p_adj",
  ...
) {
  .plot_volcano(object, log2fc_cutoff, p_cutoff, p_col, ...)
}

#' Plots for Multi-Group Differential Expression Analysis (DEA)
#'
#' Visualization for `glystats_anova_res` and `glystats_kruskal_res`.
#' Draw a dotchart for p-values.
#'
#' @param object A `glystats_anova_res` or `glystats_kruskal_res` object.
#' @param p_cutoff The p-value cutoff. Defaults to 0.05.
#' @param p_col The column name for p-value. Defaults to "p_adj".
#'   Can also be "p_val" (raw p-values without multiple testing correction).
#' @param ... Other arguments passed to underlying functions.
#' @returns A ggplot object.
#' @export
autoplot.glystats_anova_res <- function(
  object,
  p_cutoff = 0.05,
  p_col = "p_adj",
  ...
) {
  .plot_multigroup_dea(object, p_cutoff, p_col, ...)
}

#' @rdname autoplot.glystats_anova_res
#' @export
autoplot.glystats_kruskal_res <- function(
  object,
  p_cutoff = 0.05,
  p_col = "p_adj",
  ...
) {
  .plot_multigroup_dea(object, p_cutoff, p_col, ...)
}

#' Plots for Limma Result
#'
#' Visualization for results from [glystats::gly_limma()] (`glystats_limma_res` objects).
#' Only 2-group comparison is supported, and a volcano plot is drawn.
#'
#' @param object A `glystats_limma_res` object.
#' @param log2fc_cutoff The log2 fold change cutoff. Defaults to 1.
#' @param p_cutoff The p-value cutoff. Defaults to 0.05.
#' @param p_col The column name for p-value. Defaults to "p_adj".
#'   Can also be "p_val" (raw p-values without multiple testing correction).
#' @param ... Other arguments passed to underlying functions.
#'
#' @returns A ggplot object.
#' @export
autoplot.glystats_limma_res <- function(
  object,
  log2fc_cutoff = 1,
  p_cutoff = 0.05,
  p_col = "p_adj",
  ...
) {
  .plot_volcano_limma(object, log2fc_cutoff, p_cutoff, p_col, ...)
}

.plot_multigroup_dea <- function(object, p_cutoff, p_col, ...) {
  checkmate::assert_number(p_cutoff, lower = 0)
  checkmate::assert_choice(p_col, c("p_val", "p_adj"))

  df <- object$tidy_result$main_test %>%
    dplyr::mutate(
      neglog10p = -log10(.data[[p_col]]),
      candidate = .data[[p_col]] < p_cutoff,
      point_color = dplyr::if_else(.data$candidate, glyvis_colors[1], "lightgrey")
    )

  .glyvis_dotchart(df, x = "variable", y = "neglog10p") +
    geom_hline(yintercept = -log10(p_cutoff), linetype = "dashed", alpha = 0.7) +
    labs(
      x = "Variable",
      y = expression(-Log[10]~italic(P)~adjusted)
    )
}
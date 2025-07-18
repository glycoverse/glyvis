#' Plots for 2-Group Differential Expression Analysis (DEA)
#'
#' Visualization for `glystats_dea_res_ttest` and `glystats_dea_res_wilcoxon`.
#' Draw a volcano plot.
#'
#' @param object A `glystats_dea_res_ttest` or `glystats_dea_res_wilcoxon` object.
#' @param log2fc_cutoff The log2 fold change cutoff. Defaults to 1.
#' @param p_cutoff The p-value cutoff. Defaults to 0.05.
#' @param p_col The column name for p-value. Defaults to "p_adj".
#'   Can also be "p" (raw p-values without multiple testing correction).
#' @param up_color The color for up-regulated candidates. Defaults to "#FF7777".
#' @param down_color The color for down-regulated candidates. Defaults to "#7DA8E6".
#' @param ... Other arguments passed to underlying functions.
#' @returns A ggplot object.
#' @export
autoplot.glystats_dea_res_ttest <- function(
  object,
  log2fc_cutoff = 1,
  p_cutoff = 0.05,
  p_col = "p_adj",
  up_color = "#D55E00",
  down_color = "#56B4E9",
  ...
) {
  .plot_2group_dea(object, log2fc_cutoff, p_cutoff, p_col, up_color, down_color, ...)
}

#' @rdname autoplot.glystats_dea_res_ttest
#' @export
autoplot.glystats_dea_res_wilcoxon <- function(
  object,
  log2fc_cutoff = 1,
  p_cutoff = 0.05,
  p_col = "p_adj",
  up_color = "#D55E00",
  down_color = "#56B4E9",
  ...
) {
  .plot_2group_dea(object, log2fc_cutoff, p_cutoff, p_col, up_color, down_color, ...)
}

#' Plots for Multi-Group Differential Expression Analysis (DEA)
#'
#' Visualization for `glystats_dea_res_anova` and `glystats_dea_res_kruskal`.
#' Draw a lolipop plot for p-values.
#'
#' @param object A `glystats_dea_res_anova` or `glystats_dea_res_kruskal` object.
#' @param p_cutoff The p-value cutoff. Defaults to 0.05.
#' @param p_col The column name for p-value. Defaults to "p_adj".
#'   Can also be "p" (raw p-values without multiple testing correction).
#' @param ... Other arguments passed to underlying functions.
#' @returns A ggplot object.
#' @export
autoplot.glystats_dea_res_anova <- function(
  object,
  p_cutoff = 0.05,
  p_col = "p_adj",
  ...
) {
  .plot_multigroup_dea(object, p_cutoff, p_col, ...)
}

#' @rdname autoplot.glystats_dea_res_anova
#' @export
autoplot.glystats_dea_res_kruskal <- function(
  object,
  p_cutoff = 0.05,
  p_col = "p_adj",
  ...
) {
  .plot_multigroup_dea(object, p_cutoff, p_col, ...)
}

.plot_2group_dea <- function(object, log2fc_cutoff, p_cutoff, p_col, up_color, down_color, ...) {
  checkmate::assert_number(log2fc_cutoff, lower = 0)
  checkmate::assert_number(p_cutoff, lower = 0)
  checkmate::assert_choice(p_col, c("p", "p_adj"))
  checkmate::assert_string(up_color)
  checkmate::assert_string(down_color)

  df <- object %>%
    dplyr::mutate(
      neglog10p = -log10(.data[[p_col]]),
      direction = dplyr::if_else(.data$log2fc > 0, "up", "down", NA),
      candidate = abs(.data$log2fc) >= log2fc_cutoff & .data[[p_col]] < p_cutoff,
      point_color = dplyr::case_when(
        !.data$candidate ~ "lightgrey",
        .data$candidate & .data$direction == "up" ~ up_color,
        .data$candidate & .data$direction == "down" ~ down_color,
        TRUE ~ "lightgrey"
      )
    )

  ggplot(df, aes(x = .data$log2fc, y = .data$neglog10p)) +
    geom_point(aes(color = .data$point_color)) +
    scale_color_identity() +
    geom_vline(xintercept = c(-log2fc_cutoff, log2fc_cutoff), linetype = "dashed", alpha = 0.7) +
    geom_hline(yintercept = -log10(p_cutoff), linetype = "dashed", alpha = 0.7) +
    theme_classic() +
    labs(
      x = expression(Log[2]~fold~change),
      y = expression(-Log[10]~italic(P)~adjusted)
    )
}

.plot_multigroup_dea <- function(object, p_cutoff, p_col, ...) {
  checkmate::assert_number(p_cutoff, lower = 0)
  checkmate::assert_choice(p_col, c("p", "p_adj"))

  df <- object %>%
    dplyr::mutate(
      neglog10p = -log10(.data[[p_col]]),
      candidate = .data[[p_col]] < p_cutoff,
      point_color = dplyr::if_else(.data$candidate, glyvis_colors[1], "lightgrey")
    )

  ggplot(df, aes(x = .data$variable, y = .data$neglog10p)) +
    geom_point(aes(color = .data$point_color)) +
    scale_color_identity() +
    geom_hline(yintercept = -log10(p_cutoff), linetype = "dashed", alpha = 0.7) +
    theme_classic() +
    theme(
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank()
    ) +
    labs(
      x = "Variable",
      y = expression(-Log[10]~italic(P)~adjusted)
    )
}
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
  up_color = "#FF7777",
  down_color = "#7DA8E6",
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
  up_color = "#FF7777",
  down_color = "#7DA8E6",
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
#' @param sig_color The color for significant candidates. Defaults to "#FF7777".
#' @param ... Other arguments passed to underlying functions.
#' @returns A ggplot object.
#' @export
autoplot.glystats_dea_res_anova <- function(
  object,
  p_cutoff = 0.05,
  p_col = "p_adj",
  sig_color = "#FF7777",
  ...
) {
  .plot_multigroup_dea(object, p_cutoff, p_col, sig_color, ...)
}

#' @rdname autoplot.glystats_dea_res_anova
#' @export
autoplot.glystats_dea_res_kruskal <- function(
  object,
  p_cutoff = 0.05,
  p_col = "p_adj",
  sig_color = "#FF7777",
  ...
) {
  .plot_multigroup_dea(object, p_cutoff, p_col, sig_color, ...)
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
    )
  df %>%
    tidyplot(x = .data$log2fc, y = .data$neglog10p) %>%
    add_data_points(data = filter_rows(!.data$candidate),
                    color = "lightgrey") %>%
    add_data_points(data = filter_rows(.data$candidate, .data$direction == "up"),
                    color = up_color) %>%
    add_data_points(data = filter_rows(.data$candidate, .data$direction == "down"),
                    color = down_color) %>%
    add_reference_lines(x = c(-log2fc_cutoff, log2fc_cutoff), y = -log10(p_cutoff)) %>%
    adjust_x_axis_title("$Log[2]~fold~change$") %>%
    adjust_y_axis_title("$-Log[10]~italic(P)~adjusted$")
}

.plot_multigroup_dea <- function(object, p_cutoff, p_col, sig_color, ...) {
  checkmate::assert_number(p_cutoff, lower = 0)
  checkmate::assert_choice(p_col, c("p", "p_adj"))

  df <- object %>%
    dplyr::mutate(
      neglog10p = -log10(.data[[p_col]]),
      candidate = .data[[p_col]] < p_cutoff,
    )
  df %>%
    tidyplot(x = .data$variable, y = .data$neglog10p) %>%
    add_data_points(data = filter_rows(!.data$candidate),
                    color = "lightgrey") %>%
    add_data_points(data = filter_rows(.data$candidate),
                    color = sig_color) %>%
    add_reference_lines(y = -log10(p_cutoff)) %>%
    adjust_y_axis_title("$-Log[10]~italic(P)~adjusted$") %>%
    remove_x_axis_ticks() %>%
    remove_x_axis_labels()
}
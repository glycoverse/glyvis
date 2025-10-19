#' Volcano Plot
#'
#' Draw a volcano plot.
#'
#' @param x An object to be plotted.
#' @param log2fc_cutoff The log2 fold change cutoff. Defaults to 1.
#' @param p_cutoff The p-value cutoff. Defaults to 0.05.
#' @param p_col The column name for p-value. Defaults to "p_adj".
#'   Can also be "p_val" (raw p-values without multiple testing correction).
#' @param ... Other arguments passed to [EnhancedVolcano::EnhancedVolcano()].
#'
#' @returns A ggplot object.
#' @export
plot_volcano <- function(x, log2fc_cutoff = 1, p_cutoff = 0.05, p_col = "p_adj", ...) {
  UseMethod("plot_volcano")
}

#' @rdname plot_volcano
#' @param group_col A character string specifying the column name in sample information
#'   that contains group labels. Default is "group".
#' @param test "ttest", "wilcox", or "limma". Default is "limma".
#' @param ref_group A character string specifying the reference group.
#'   If NULL (default), the first level of the group factor is used as the reference.
#' @param p_adj_method A character string specifying the method to adjust p-values.
#'   See `p.adjust.methods` for available methods. Default is "BH".
#'   If NULL, no adjustment is performed.
#' @export
plot_volcano.glyexp_experiment <- function(
  x,
  log2fc_cutoff = 1,
  p_cutoff = 0.05,
  p_col = "p_adj",
  group_col = "group",
  test = "limma",
  ref_group = NULL,
  p_adj_method = "BH",
  ...
) {
  checkmate::assert_string(group_col)
  checkmate::assert_choice(test, c("ttest", "wilcox", "limma"))
  checkmate::assert_choice(p_adj_method, stats::p.adjust.methods, null.ok = TRUE)
  checkmate::assert_string(ref_group, null.ok = TRUE)

  if ((group_col %in% colnames(x$sample_info)) && length(unique(x$sample_info[[group_col]])) != 2) {
    n_levels <- length(unique(x$sample_info[[group_col]]))
    level_values <- unique(x$sample_info[[group_col]])
    cli::cli_abort(c(
      "The group column must have exactly 2 levels for volcano plot.",
      "x" = "Found {.val {n_levels}} levels: {.val {level_values}}."
    ))
  }
  if (is.null(p_adj_method)) {
    p_col <- "p_val"
    cli::cli_alert_info("No p-value adjustment method specified. Using raw p-values.")
  }

  dea_res <- switch(test,
    "ttest" = glystats::gly_ttest(x, group_col, p_adj_method, ref_group),
    "wilcox" = glystats::gly_wilcox(x, group_col, p_adj_method, ref_group),
    "limma" = glystats::gly_limma(x, group_col, p_adj_method, ref_group)
  )
  .plot_volcano(dea_res, log2fc_cutoff, p_cutoff, p_col)
}

.plot_volcano <- function(dea_res, log2fc_cutoff, p_cutoff, p_col) {
  checkmate::assert_number(log2fc_cutoff, lower = 0)
  checkmate::assert_number(p_cutoff, lower = 0)
  checkmate::assert_choice(p_col, c("p_val", "p_adj"))
  .glyvis_volcano(dea_res$tidy_result, p_col, "log2fc", p_cutoff, log2fc_cutoff)
}
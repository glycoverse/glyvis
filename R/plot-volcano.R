#' Volcano Plot
#'
#' This function accepts a [glyexp::experiment()],
#' performs differential expression analysis using [glystats::gly_limma()],
#' and plots a volcano plot.
#' There should be only two groups.
#'
#' @param exp A [glyexp::experiment()] object.
#' @param group_col A character string specifying the column name in sample information
#'   that contains group labels. Default is "group".
#' @param p_adj_method A character string specifying the method to adjust p-values.
#'   See `p.adjust.methods` for available methods. Default is "BH".
#'   If NULL, no adjustment is performed.
#' @param ref_group A character string specifying the reference group.
#'   If NULL (default), the first level of the group factor is used as the reference.
#'
#' @returns A ggplot object.
#' @export
plot_volcano <- function(exp, group_col = "group", p_adj_method = "BH", ref_group = NULL) {
  checkmate::assert_class(exp, "glyexp_experiment")
  checkmate::assert_string(group_col)
  checkmate::assert_choice(p_adj_method, stats::p.adjust.methods, null.ok = TRUE)
  checkmate::assert_string(ref_group, null.ok = TRUE)

  if ((group_col %in% colnames(exp$sample_info)) && length(unique(exp$sample_info[[group_col]])) != 2) {
    n_levels <- length(unique(exp$sample_info[[group_col]]))
    level_values <- unique(exp$sample_info[[group_col]])
    cli::cli_abort(c(
      "The group column must have exactly 2 levels for volcano plot.",
      "x" = "Found {.val {n_levels}} levels: {.val {level_values}}."
    ))
  }

  limma_res <- glystats::gly_limma(exp, group_col, p_adj_method, ref_group)
  p_col <- if (is.null(p_adj_method)) "p" else "p_adj"
  autoplot(limma_res, p_col = p_col)
}
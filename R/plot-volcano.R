#' Volcano Plot
#'
#' Draw a volcano plot.
#' Currently supported data types:
#' - `glystats_ttest_res`: Result from [glystats::gly_ttest()].
#' - `glystats_wilcox_res`: Result from [glystats::gly_wilcox()].
#' - `glystats_limma_res`: Result from [glystats::gly_limma()].
#'   Only two-group comparisons are supported.
#' - `glyexp_experiment`: Experiment created by [glyexp::experiment()].
#'   Differential expression analysis is first performed using [glystats::gly_ttest()],
#'   [glystats::gly_wilcox()], or [glystats::gly_limma()]
#'   (controlled by the `test` argument), then the result is plotted.
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
#' @param test "ttest", "wilcox", or "limma". Default is "limma".
#' @param stats_args A list of keyword arguments to pass to [glystats::gly_ttest()],
#'   [glystats::gly_wilcox()], or [glystats::gly_limma()].
#' @export
plot_volcano.glyexp_experiment <- function(
  x,
  log2fc_cutoff = 1,
  p_cutoff = 0.05,
  p_col = "p_adj",
  test = "limma",
  stats_args = list(),
  ...
) {
  checkmate::assert_choice(test, c("ttest", "wilcox", "limma"))

  dea_res <- switch(test,
    "ttest" = rlang::exec(glystats::gly_ttest, x, !!!stats_args),
    "wilcox" = rlang::exec(glystats::gly_wilcox, x, !!!stats_args),
    "limma" = rlang::exec(glystats::gly_limma, x, !!!stats_args)
  )
  .plot_volcano(dea_res, log2fc_cutoff, p_cutoff, p_col, ...)
}

#' @rdname plot_volcano
#' @export
plot_volcano.glystats_ttest_res <- function(x, log2fc_cutoff = 1, p_cutoff = 0.05, p_col = "p_adj", ...) {
  .plot_volcano(x, log2fc_cutoff, p_cutoff, p_col, ...)
}

#' @rdname plot_volcano
#' @export
plot_volcano.glystats_wilcox_res <- function(x, log2fc_cutoff = 1, p_cutoff = 0.05, p_col = "p_adj", ...) {
  .plot_volcano(x, log2fc_cutoff, p_cutoff, p_col, ...)
}

#' @rdname plot_volcano
#' @param contrast A character string specifying the contrast to plot, in the format of "group1_vs_group2".
#'   Must be one of the contrasts in the result.
#'   When there is only one contrast (two-group comparison), it can be NULL (default).
#' @export
plot_volcano.glystats_limma_res <- function(x, log2fc_cutoff = 1, p_cutoff = 0.05, p_col = "p_adj", contrast = NULL, ...) {
  .plot_volcano_limma(x, log2fc_cutoff, p_cutoff, p_col, contrast, ...)
}

.plot_volcano_limma <- function(x, log2fc_cutoff, p_cutoff, p_col, contrast, ...) {
  checkmate::assert_string(contrast, null.ok = TRUE)
  contrasts <- unique(paste0(x$tidy_result$ref_group, "_vs_", x$tidy_result$test_group))
  if (length(contrasts) > 1 && is.null(contrast)) {
    cli::cli_abort(c(
      "{.arg contrast} is required when there are multiple contrasts in the result.",
      "i" = "Available contrasts: {.val {contrasts}}."
    ))
  }
  if (is.null(contrast)) {  # only one contrast
    contrast <- contrasts[1]
  }
  if (stringr::str_count(contrast, "_vs_") != 1) {
    cli::cli_abort("Invalid contrast format: {.val {contrast}}. Expected format: {.val group1_vs_group2}")
  }
  parts <- stringr::str_split_1(contrast, "_vs_")
  ref_group <- parts[1]
  test_group <- parts[2]
  tidy_res <- x$tidy_result
  if (!ref_group %in% tidy_res$ref_group) {
    cli::cli_abort(c(
      "Cannot find reference group {.val {ref_group}} in the result.",
      "i" = "Available reference groups: {.val {unique(tidy_res$ref_group)}}."
    ))
  }
  if (!test_group %in% tidy_res$test_group) {
    cli::cli_abort(c(
      "Cannot find test group {.val {test_group}} in the result.",
      "i" = "Available test groups: {.val {unique(tidy_res$test_group)}}."
    ))
  }
  tidy_res <- tidy_res |>
    dplyr::filter(.data$ref_group == .env$ref_group, .data$test_group == .env$test_group)
  .glyvis_volcano(tidy_res, p_col, "log2fc", p_cutoff, log2fc_cutoff, ...)
}

.plot_volcano <- function(dea_res, log2fc_cutoff, p_cutoff, p_col, ...) {
  checkmate::assert_number(log2fc_cutoff, lower = 0)
  checkmate::assert_number(p_cutoff, lower = 0)
  checkmate::assert_choice(p_col, c("p_val", "p_adj"))
  .glyvis_volcano(dea_res$tidy_result, p_col, "log2fc", p_cutoff, log2fc_cutoff, ...)
}
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
#' @export
plot_volcano.glystats_limma_res <- function(x, log2fc_cutoff = 1, p_cutoff = 0.05, p_col = "p_adj", ...) {
  .plot_volcano_limma(x, log2fc_cutoff, p_cutoff, p_col, ...)
}

.plot_volcano_limma <- function(x, log2fc_cutoff, p_cutoff, p_col, ...) {
  contrasts <- unique(paste0(x$tidy_result$ref_group, "_vs_", x$tidy_result$test_group))
  if (length(contrasts) > 1) {
    cli::cli_abort(c(
      "Number of contrasts must be exactly 1 for limma result.",
      "x" = "Found {.val {length(contrasts)}} contrasts: {.val {contrasts}}.",
      "i" = "Maybe you want to filter the experiment to two groups first by using {.fn glyexp::filter_obs()}?"
    ))
  }
  x$tidy_result$contrast <- contrasts
  .glyvis_volcano(x$tidy_result, p_col, "log2fc", p_cutoff, log2fc_cutoff, ...)
}

.plot_volcano <- function(dea_res, log2fc_cutoff, p_cutoff, p_col, ...) {
  checkmate::assert_number(log2fc_cutoff, lower = 0)
  checkmate::assert_number(p_cutoff, lower = 0)
  checkmate::assert_choice(p_col, c("p_val", "p_adj"))
  .glyvis_volcano(dea_res$tidy_result, p_col, "log2fc", p_cutoff, log2fc_cutoff, ...)
}
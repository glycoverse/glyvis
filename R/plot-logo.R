#' Logo Plot
#'
#' Draw a logo plot for all glycosites.
#' Positions with insufficient flanking amino acids will be padded with "X".
#' Currently supported data types:
#' - `glyexp_experiment`: Experiment created by [glyexp::experiment()].
#'   Logo plot of glycosylation sites is plotted.
#'
#' @param x An object to be plotted.
#' @param n_aa The number of amino acids to the left and right of the glycosylation site.
#'   For example, if `n_aa = 5`, the resulting sequence will contain 11 amino acids.
#' @param fasta The path to the FASTA file containing protein sequences.
#'   If `glyclean::add_site_seq()` has been called on the experiment,
#'   this argument can be omitted.
#' @param ... Additional arguments passed to [ggseqlogo::ggseqlogo()].
#'
#' @returns A ggplot object.
#' @seealso [ggseqlogo::ggseqlogo()]
#' @export
plot_logo <- function(x, n_aa = 5L, fasta = NULL, ...) {
  UseMethod("plot_logo")
}

#' @rdname plot_logo
#' @export
plot_logo.glyexp_experiment <- function(x, n_aa = 5L, fasta = NULL, ...) {
  .plot_exp_logo(x, n_aa, fasta, ...)
}

#' Internal function to plot logo plot
#' @param exp A `glyexp_experiment` object.
#' @param n_aa The number of amino acids to the left and right of the glycosylation site.
#'   For example, if `n_aa = 5`, the resulting sequence will contain 11 amino acids.
#' @param fasta The path to the FASTA file containing protein sequences.
#'   If `glyclean::add_site_seq()` has been called on the experiment,
#'   this argument can be omitted.
#' @param ... Other arguments passed to [ggseqlogo::ggseqlogo()].
#' @noRd
.plot_exp_logo <- function(exp, n_aa, fasta, ...) {
  rlang::check_installed("ggseqlogo")
  checkmate::assert_class(exp, "glyexp_experiment")
  checkmate::assert_integerish(n_aa, len = 1, lower = 0)
  checkmate::assert_string(fasta, null.ok = TRUE)
  .assert_exp_type(exp, "glycoproteomics")

  if (!"site_sequence" %in% colnames(exp$var_info)) {
    if (is.null(fasta)) {
      cli::cli_abort(c(
        "{.arg fasta} is required to add site sequence information.",
        "i" = "Or call {.fn glyclean::add_site_seq} on the experiment before calling {.fn plot_logo}."
      ))
    }
    rlang::check_installed("glyclean")
    exp <- glyclean::add_site_seq(exp, fasta, n_aa)
  }

  seq <- unique(exp$var_info$site_sequence)
  ggseqlogo::ggseqlogo(seq, ...)
}
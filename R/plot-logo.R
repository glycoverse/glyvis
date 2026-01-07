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
#'   this argument can be omitted. When `site_sequence` is missing and `fasta`
#'   is `NULL`, UniProt.ws is used to fetch protein sequences automatically.
#' @param tax_id The NCBI taxonomy ID used for UniProt.ws lookups. Defaults to 9606.
#' @param ... Additional arguments passed to [ggseqlogo::ggseqlogo()].
#'
#' @returns A ggplot object.
#' @seealso [ggseqlogo::ggseqlogo()]
#' @export
plot_logo <- function(x, n_aa = 5L, fasta = NULL, tax_id = 9606L, ...) {
  UseMethod("plot_logo")
}

#' @rdname plot_logo
#' @export
plot_logo.glyexp_experiment <- function(x, n_aa = 5L, fasta = NULL, tax_id = 9606L, ...) {
  .plot_exp_logo(x, n_aa, fasta, tax_id, ...)
}

#' Internal function to plot logo plot
#' @param exp A `glyexp_experiment` object.
#' @param n_aa The number of amino acids to the left and right of the glycosylation site.
#'   For example, if `n_aa = 5`, the resulting sequence will contain 11 amino acids.
#' @param fasta The path to the FASTA file containing protein sequences.
#'   If `glyclean::add_site_seq()` has been called on the experiment,
#'   this argument can be omitted. When `site_sequence` is missing and `fasta`
#'   is `NULL`, UniProt.ws is used to fetch protein sequences automatically.
#' @param tax_id The NCBI taxonomy ID used for UniProt.ws lookups. Defaults to 9606.
#' @param ... Other arguments passed to [ggseqlogo::ggseqlogo()].
#' @noRd
.plot_exp_logo <- function(exp, n_aa, fasta, tax_id, ...) {
  rlang::check_installed("ggseqlogo")
  checkmate::assert_class(exp, "glyexp_experiment")
  checkmate::assert_integerish(n_aa, len = 1, lower = 0)
  checkmate::assert_string(fasta, null.ok = TRUE)
  checkmate::assert_integerish(tax_id, len = 1, lower = 1)
  .assert_exp_type(exp, "glycoproteomics")

  if (!"site_sequence" %in% colnames(exp$var_info)) {
    if (is.null(fasta)) {
      exp <- .add_site_seq_uniprot(exp, n_aa, tax_id)
    } else {
      rlang::check_installed("glyclean")
      exp <- glyclean::add_site_seq(exp, fasta, n_aa)
    }
  }

  seq <- unique(exp$var_info$site_sequence)
  ggseqlogo::ggseqlogo(seq, ...)
}

.add_site_seq_uniprot <- function(exp, n_aa, tax_id) {
  rlang::check_installed("UniProt.ws")

  required_cols <- c("protein", "protein_site")
  missing_cols <- setdiff(required_cols, colnames(exp$var_info))
  if (length(missing_cols) > 0) {
    cli::cli_abort(c(
      "UniProt.ws requires {.var {missing_cols}} column{?s} to add site sequence information.",
      "i" = "Provide {.arg fasta} or precompute site sequences with {.fn glyclean::add_site_seq}."
    ))
  }

  proteins <- unique(exp$var_info$protein)
  if (anyNA(proteins) || any(!nzchar(proteins))) {
    cli::cli_abort("{.var protein} must contain non-missing accessions for UniProt lookup.")
  }
  checkmate::assert_integerish(exp$var_info$protein_site, lower = 1, any.missing = FALSE)

  uniprot <- UniProt.ws::UniProt.ws(taxId = tax_id)
  seq_tbl <- UniProt.ws::select(
    uniprot,
    keys = proteins,
    columns = "sequence",
    keytype = "UniProtKB"
  )
  seq_tbl <- seq_tbl[!is.na(seq_tbl$Sequence), , drop = FALSE]
  seq_tbl <- seq_tbl[!duplicated(seq_tbl$From), , drop = FALSE]
  if (nrow(seq_tbl) == 0) {
    cli::cli_abort("UniProt.ws did not return any sequences for the requested accessions.")
  }

  seq_map <- stats::setNames(seq_tbl$Sequence, seq_tbl$From)
  missing <- setdiff(proteins, names(seq_map))
  if (length(missing) > 0) {
    cli::cli_abort(c(
      "UniProt.ws did not return sequences for {length(missing)} accession{?s}.",
      "i" = "Missing accessions: {paste(missing, collapse = ', ')}."
    ))
  }

  exp$var_info$site_sequence <- purrr::map2_chr(
    exp$var_info$protein,
    exp$var_info$protein_site,
    ~ .build_site_seq(seq_map[[.x]], .y, n_aa, .x)
  )
  exp
}

.build_site_seq <- function(seq, site, n_aa, protein) {
  seq_len <- nchar(seq)
  if (site > seq_len) {
    cli::cli_abort(c(
      "Protein site {site} exceeds sequence length ({seq_len}) for {.val {protein}}.",
      "i" = "Check {.var protein_site} against the UniProt sequence."
    ))
  }
  start <- site - n_aa
  end <- site + n_aa
  left_pad <- max(0L, 1L - start)
  right_pad <- max(0L, end - seq_len)
  core <- substr(seq, max(1L, start), min(seq_len, end))
  paste0(strrep("X", left_pad), core, strrep("X", right_pad))
}

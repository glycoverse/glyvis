#' Statistical analysis dependencies for container plots
#'
#' @name glyvis_analysis_dependencies
#' @description
#' Container methods for [plot_pca()], [plot_tsne()], [plot_umap()],
#' [plot_plsda()], [plot_oplsda()], [plot_corrplot()], [plot_roc()], and
#' [plot_volcano()] delegate statistical analysis to the optional glystats
#' package. Install an up-to-date glystats together with glyvis.
#'
#' @details
#' Logged inputs (`"log"`, `"log2"`, `"log10"`, and `"logx"`) require the
#' scale-aware glystats implementation, including its protection against
#' `log_transform = TRUE` applying another logarithm. glystats 0.13.0 does
#' not provide this contract. Development builds before and after this change
#' share version 0.13.0.9000, so a version number alone cannot establish
#' compatibility. glyvis checks the public analysis behavior with a tiny,
#' deterministic synthetic input before passing logged user data to glystats.
#' Incompatible installations fail with an upgrade instruction, before the
#' requested analysis runs. Input scale metadata is also validated before
#' analysis, without guessing a scale from abundance values.
#'
#' A compatible development version is available from
#' `remotes::install_github("glycoverse/glystats")`. Restart R after updating
#' a loaded package. The suggested minimum remains the installable 0.13.0
#' release for raw-data and precomputed-result workflows; logged-data analyses
#' additionally require the behavioral contract above. Do not relabel logged
#' data as `"raw"` to bypass the check.
#' Raw inputs and older objects without scale metadata retain their existing
#' analysis behavior. Plotting an already computed statistical result does
#' not rerun analysis and does not require this compatibility check. The
#' [plot_boxplot()] and [plot_heatmap()] container methods manage their own
#' scales and do not depend on glystats.
#' @seealso [glyvis_abundance_scale()]
NULL

.run_glystats_analysis <- function(x, analysis, stats_args) {
  input_scale <- .resolve_plot_transformation(x, NULL)$input_scale
  if (!requireNamespace("glystats", quietly = TRUE)) {
    cli::cli_abort(c(
      "Package {.pkg glystats} is required for this container plot.",
      "i" = 'Install it with {.code remotes::install_github("glycoverse/glystats")}.'
    ))
  }
  if (input_scale != "raw" && !.glystats_supports_logged_inputs()) {
    cli::cli_abort(c(
      "Installed {.pkg glystats} cannot safely analyze logged inputs for this container plot.",
      "i" = 'Update with {.code remotes::install_github("glycoverse/glystats")} and restart R.',
      "i" = 'Version 0.13.0 and earlier development builds do not provide the required scale handling.',
      "i" = 'Keep the correct input scale; do not relabel transformed values as raw.'
    ), class = "glyvis_incompatible_glystats")
  }
  rlang::exec(getExportedValue("glystats", analysis), x, !!!stats_args)
}

.glystats_supports_logged_inputs <- function() {
  # Use the public contract, not private glystats helpers or a version that
  # several incompatible development builds share. This probe never uses user
  # data, needs no optional analysis backend, and does not alter the RNG state.
  probe <- SummarizedExperiment::SummarizedExperiment(
    assays = list(abundance = matrix(
      c(-2, 1, 0, 3, 2, -1, 4, 2), nrow = 2,
      dimnames = list(c("v1", "v2"), paste0("s", seq_len(4)))
    )),
    metadata = list(scale = "logx")
  )
  tryCatch({
    result <- suppressWarnings(glystats::gly_pca(
      probe, scale = FALSE, add_info = FALSE, log_transform = TRUE
    ))
    preprocessing <- result$preprocessing
    identical(preprocessing$input_scale, "logx") &&
      identical(preprocessing$analysis_scale, "logx") &&
      identical(preprocessing$log_transform, FALSE) &&
      identical(preprocessing$transformation, "none")
  }, error = function(e) FALSE)
}

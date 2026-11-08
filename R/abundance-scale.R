#' Abundance scales in boxplots and heatmaps
#'
#' @name glyvis_abundance_scale
#' @param log_transform `NULL` (default) uses recorded abundance scale metadata:
#'   raw values are transformed with `log2(x + 1e-6)`, while already logged values
#'   are unchanged. `FALSE` always uses the supplied values unchanged. `TRUE`
#'   requests the same transformation for raw values, but warns and is ignored
#'   for already logged values. This argument must be named after `...`.
#'
#' @details
#' [plot_boxplot()], [plot_heatmap()], and the experiment-container
#' [autoplot.glyexp_experiment()] methods read `S4Vectors::metadata(x)$scale`
#' for `SummarizedExperiment` inputs or `x$meta_data$scale` for legacy
#' `glyexp_experiment` inputs. Supported scales are `"raw"`, `"log"` (natural
#' logarithm), `"log2"`, `"log10"`, and `"logx"` (logged coordinates without
#' a known ordinary-log base, including centered log-ratios). Missing scale
#' metadata is treated as `"raw"` for compatibility with older objects.
#' An explicitly present invalid scale, including `NULL`, is an error.
#' The scale is never inferred from numeric values or other metadata.
#'
#' Already logged values retain their recorded scale, even with negative or
#' zero coordinates. No base conversion or recovery of original abundances is
#' attempted. Labels describe the operation actually applied or the recorded
#' input scale; `FALSE` does not relabel raw input as logged. Inputs and their
#' metadata are never modified.
#'
#' Heatmap `scale` independently controls row/column standardization, and
#' boxplot `scales` controls facet axes. Heatmap filtering and clustering use
#' the selected values before optional standardization. Standardized heatmaps
#' use a Z-score legend; unstandardized heatmaps show the abundance scale.
#'
#' This selection follows the scale-aware `log_transform` convention in
#' glystats. Raw values use `log2(x + 1e-6)`: the small fixed pseudocount
#' keeps zero abundances finite while reducing distortion of small positive
#' abundances compared with adding 1. Plots of statistical results do not
#' transform their inputs again.
#' For container plots that run a glystats analysis (for example,
#' [plot_pca()]), set analysis options through `stats_args`, such as
#' `stats_args = list(log_transform = FALSE)`.
#'
#' @examples
#' values <- matrix(c(0, 2, 4, 8, 1, 3, 6, 9), nrow = 2,
#'                  dimnames = list(c("A", "B"), paste0("S", 1:4)))
#' exp <- SummarizedExperiment::SummarizedExperiment(
#'   assays = list(abundance = values),
#'   colData = S4Vectors::DataFrame(group = c("A", "A", "B", "B")),
#'   metadata = list(scale = "raw")
#' )
#' plot_boxplot(exp) # log2(x + 1e-6)
#' plot_boxplot(exp, log_transform = FALSE) # unchanged raw values
#' SummarizedExperiment::assay(exp) <- log2(values + 1e-6)
#' S4Vectors::metadata(exp)$scale <- "log2"
#' plot_heatmap(exp, scale = "none") # no second logarithm
NULL

.resolve_plot_transformation <- function(exp, log_transform) {
  checkmate::assert_logical(
    log_transform,
    len = 1,
    any.missing = FALSE,
    null.ok = TRUE
  )
  meta <- if (methods::is(exp, "SummarizedExperiment")) {
    S4Vectors::metadata(exp)
  } else {
    glyexp::get_meta_data(exp)
  }
  input_scale <- if ("scale" %in% names(meta)) meta[["scale"]] else "raw"
  if (
    !checkmate::test_choice(
      input_scale,
      c("raw", "log", "log2", "log10", "logx")
    )
  ) {
    cli::cli_abort(
      'Metadata `scale` must be "raw", "log", "log2", "log10", or "logx".'
    )
  }
  input_scale <- unname(input_scale)
  is_raw <- identical(input_scale, "raw")
  if (!is_raw && isTRUE(log_transform)) {
    cli::cli_warn(
      c(
        "{.arg log_transform = TRUE} is ignored because the input already uses scale {.val {input_scale}}.",
        "i" = "Using the supplied values without another logarithm."
      ),
      class = "glyvis_already_logged"
    )
  }
  list(
    input_scale = input_scale,
    log_transform = is_raw && (is.null(log_transform) || isTRUE(log_transform))
  )
}

.abundance_label <- function(transformation, boxplot = FALSE) {
  if (transformation$log_transform) {
    return(
      if (boxplot) {
        expression(log[2]("Expr." + 1e-6))
      } else {
        "log2(abundance + 1e-6)"
      }
    )
  }
  abundance <- if (boxplot) "Expr." else "Abundance"
  if (transformation$input_scale == "raw") {
    return(abundance)
  }
  scale <- if (transformation$input_scale == "log") {
    "natural-log"
  } else {
    transformation$input_scale
  }
  paste0(abundance, " (", scale, " scale)")
}

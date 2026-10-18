#' Heatmap
#'
#' Draw a heatmap from a [glyexp::GlycomicSE()],
#' [glyexp::GlycoproteomicSE()], or other compatible `SummarizedExperiment`.
#' Heatmap of log2-transformed expression values is plotted.
#' Before plotting, zero-variance rows and columns are filtered out
#' to ensure robust clustering. Supplied `hclust` objects must match the
#' retained rows or columns, including their input order.
#'
#' @param x A supported Glycoverse data container.
#' @param ... Common and plot-specific options described in [glyvis_plot_options].
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
plot_heatmap <- function(x, ...) {
  UseMethod("plot_heatmap")
}

#' @rdname plot_heatmap
#' @export
plot_heatmap.glyexp_experiment <- function(x, ...) {
  .plot_exp_heatmap(x, ...)
}

#' @rdname plot_heatmap
#' @export
plot_heatmap.SummarizedExperiment <- function(x, ...) {
  .plot_exp_heatmap(x, ...)
}

#' Internal function to plot heatmap
#' @param exp A `glyexp_experiment` object.
#' @param ... Common and plot-specific options described in [glyvis_plot_options].
#' @noRd
.plot_exp_heatmap <- function(
  exp,
  scale = "row",
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  show_rownames = FALSE,
  show_colnames = NULL,
  na_col = "grey90",
  palette = c("#2166AC", "#F7F7F7", "#B2182B"),
  ...
) {
  checkmate::assert_choice(scale, c("row", "column", "none"))
  checkmate::assert_flag(show_rownames)
  checkmate::assert_flag(show_colnames, null.ok = TRUE)
  mat <- .get_expr_mat(exp)
  if (is.null(rownames(mat))) {
    rownames(mat) <- paste0("Variable ", seq_len(nrow(mat)))
  }
  if (is.null(colnames(mat))) {
    colnames(mat) <- paste0("Sample ", seq_len(ncol(mat)))
  }
  mat <- .filter_zero_variance(log2(mat + 1))$mat
  if (!nrow(mat) || !ncol(mat)) {
    cli::cli_abort(
      "No variable rows or columns remain after zero-variance filtering."
    )
  }
  row_tree <- .heatmap_tree(cluster_rows, mat, "row")
  col_tree <- .heatmap_tree(cluster_cols, mat, "col")
  if (scale == "row") {
    mat <- t(.scale_heatmap_columns(t(mat)))
  }
  if (scale == "column") {
    mat <- .scale_heatmap_columns(mat)
  }
  rows <- if (inherits(row_tree, "hclust")) {
    row_tree$order
  } else {
    seq_len(nrow(mat))
  }
  cols <- if (inherits(col_tree, "hclust")) {
    col_tree$order
  } else {
    seq_len(ncol(mat))
  }
  df <- data.frame(
    sample = factor(
      rep(colnames(mat), each = nrow(mat)),
      levels = colnames(mat)[cols]
    ),
    variable = factor(
      rep(rownames(mat), ncol(mat)),
      levels = rev(rownames(mat)[rows])
    ),
    value = as.vector(mat)
  )
  p <- .glyvis_plot(
    df,
    "sample",
    "variable",
    "value",
    palette = palette,
    ...
  ) |>
    tidyplots::add_heatmap(rotate_labels = 90)
  limits <- if (scale != "none") {
    bound <- max(abs(mat), na.rm = TRUE)
    if (!is.finite(bound) || bound == 0) {
      bound <- 1
    }
    c(-bound, bound)
  } else {
    NULL
  }
  p <- tidyplots::adjust_colors(p, palette, limits = limits, na.value = na_col)
  if (!show_rownames) {
    p <- tidyplots::remove_y_axis_labels(p)
  }
  if (is.null(show_colnames)) {
    show_colnames <- ncol(mat) <= 40
  }
  if (!show_colnames) {
    p <- tidyplots::remove_x_axis_labels(p)
  }
  p +
    labs(
      x = NULL,
      y = NULL,
      fill = if (scale == "none") "log2(abundance + 1)" else "Z score",
      color = if (scale == "none") "log2(abundance + 1)" else "Z score"
    ) +
    theme(axis.ticks = element_blank(), legend.position = "right")
}

.scale_heatmap_columns <- function(mat) {
  center <- colMeans(mat, na.rm = TRUE)
  spread <- apply(mat, 2, stats::sd, na.rm = TRUE)
  sweep(sweep(mat, 2, center, "-"), 2, spread, "/")
}

.heatmap_tree <- function(tree, mat, by) {
  arg <- if (by == "row") "cluster_rows" else "cluster_cols"
  labels <- if (by == "row") rownames(mat) else colnames(mat)
  .validate_heatmap_tree(tree, labels, length(labels), arg)
  if (inherits(tree, "hclust")) {
    return(tree)
  }
  checkmate::assert_flag(tree)
  if (tree) .robust_hclust(mat, by) else FALSE
}

#' Filter out rows and columns with zero variance
#'
#' Rows/columns with zero variance (all values identical) will cause NA
#' correlations during clustering. This function removes them and warns
#' the user about which samples/variables were removed.
#'
#' @param mat A numeric matrix.
#' @returns A list with `mat` (filtered matrix), `removed_rows`, and `removed_cols`.
#' @noRd
.filter_zero_variance <- function(mat) {
  # Calculate variance for each row (ignoring NA)
  row_vars <- apply(mat, 1, stats::var, na.rm = TRUE)
  zero_var_rows <- is.na(row_vars) | row_vars == 0
  removed_rows <- rownames(mat)[zero_var_rows]

  # Calculate variance for each column (ignoring NA)
  col_vars <- apply(mat, 2, stats::var, na.rm = TRUE)
  zero_var_cols <- is.na(col_vars) | col_vars == 0
  removed_cols <- colnames(mat)[zero_var_cols]

  # Warn about removed rows (variables)
  if (length(removed_rows) > 0) {
    cli::cli_warn(c(
      "Removed {length(removed_rows)} variable{?s} with zero variance from heatmap:",
      "i" = "Variables: {.val {removed_rows}}"
    ))
  }

  # Warn about removed columns (samples)
  if (length(removed_cols) > 0) {
    cli::cli_warn(c(
      "Removed {length(removed_cols)} sample{?s} with zero variance from heatmap:",
      "i" = "Samples: {.val {removed_cols}}"
    ))
  }

  # Filter the matrix
  mat <- mat[!zero_var_rows, !zero_var_cols, drop = FALSE]

  list(
    mat = mat,
    removed_rows = removed_rows,
    removed_cols = removed_cols
  )
}

#' Robust hierarchical clustering that handles NA values
#'
#' Computes correlation-based distance using pairwise complete observations,
#' then performs hierarchical clustering. This allows clustering even when
#' the data contains NA values.
#'
#' @param mat A numeric matrix.
#' @param by Either "row" or "col" to cluster by rows or columns.
#' @param method Clustering method passed to `hclust()`. Default is "complete".
#' @returns An `hclust` object, or `FALSE` if clustering is not possible.
#' @noRd
.robust_hclust <- function(mat, by = c("row", "col"), method = "complete") {
  by <- match.arg(by)

  # Transpose if clustering by rows (cor() works on columns)
  if (by == "row") {
    mat <- t(mat)
  }

  # Check if there are enough items to cluster
  if (ncol(mat) < 2) {
    return(FALSE)
  }

  # Calculate correlation matrix with pairwise complete observations
  cor_mat <- stats::cor(mat, use = "pairwise.complete.obs", method = "pearson")

  # Handle cases where correlation cannot be computed (all NA)
  if (any(is.na(cor_mat))) {
    # Replace NA correlations with 0 (treat as uncorrelated)
    cor_mat[is.na(cor_mat)] <- 0
  }

  # Convert correlation to distance (1 - correlation)
  dist_mat <- stats::as.dist(1 - cor_mat)

  # Perform hierarchical clustering
  stats::hclust(dist_mat, method = method)
}

.validate_heatmap_tree <- function(tree, labels, size, arg) {
  if (!inherits(tree, "hclust")) {
    return(invisible(NULL))
  }
  if (
    !identical(sort(tree$order), seq_len(size)) ||
      (!is.null(tree$labels) && !identical(tree$labels, labels))
  ) {
    cli::cli_abort(c(
      "{.arg {arg}} must match the retained heatmap dimensions and their input order.",
      "i" = "Zero-variance rows and columns are removed before plotting.",
      "i" = "Rebuild the tree using the retained rows or columns in input order, or omit {.arg {arg}} to compute it automatically."
    ))
  }
  invisible(NULL)
}

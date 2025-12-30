#' Heatmap
#'
#' Draw a heatmap from a [glyexp::experiment()].
#' Heatmap of log2-transformed expression values is plotted.
#' Before plotting, zero-variance rows and columns are filtered out
#' to ensure robust clustering.
#'
#' @param x A [glyexp::experiment()] object.
#' @param ... Other arguments passed to `pheatmap::pheatmap()`.
#'
#' @returns A ggplot object.
#' @export
plot_heatmap <- function(x, ...) {
  UseMethod("plot_heatmap")
}

#' @rdname plot_heatmap
#' @export
plot_heatmap.glyexp_experiment <- function(x, ...) {
  .plot_exp_heatmap(x, ...)
}

#' Internal function to plot heatmap
#' @param exp A `glyexp_experiment` object.
#' @param ... Other arguments passed to `pheatmap::pheatmap()`.
#' @noRd
.plot_exp_heatmap <- function(exp, ...) {
  mat <- log2(exp$expr_mat + 1)

  # Filter out zero-variance rows and columns
  filtered <- .filter_zero_variance(mat)
  mat <- filtered$mat

  # Use robust clustering that handles NA values
  row_clust <- .robust_hclust(mat, by = "row")
  col_clust <- .robust_hclust(mat, by = "col")

  p <- pheatmap::pheatmap(
    mat,
    scale = "row",
    show_rownames = FALSE,
    silent = TRUE,
    cluster_rows = row_clust,
    cluster_cols = col_clust,
    na_col = "grey",
    ...
  )
  ggplotify::as.ggplot(p)
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
#' Heatmap
#'
#' Draw a heatmap.
#' Currently supported data types:
#' - `glyexp_experiment`: Experiment created by [glyexp::experiment()].
#'   Heatmap of log2-transformed expression values is plotted.
#'
#' @param x An object to be plotted.
#' @param ... Ignored.
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
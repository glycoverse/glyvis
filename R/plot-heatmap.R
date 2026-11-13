#' Heatmap
#'
#' Draw a heatmap from a [glyexp::GlycomicSE()],
#' [glyexp::GlycoproteomicSE()], or other compatible `SummarizedExperiment`.
#' Expression values use scale-aware log transformation controlled by
#' `log_transform`, followed by optional row or column standardization.
#' Before plotting, zero-variance rows and columns are filtered out
#' to ensure robust clustering. Supplied `hclust` objects must match the
#' retained rows or columns, including their input order.
#'
#' @param x A supported Glycoverse data container.
#' @param scale Standardize rows (`"row"`, the default), columns (`"column"`),
#'   or neither (`"none"`). Applied after and independently of `log_transform`.
#' @param cluster_rows,cluster_cols Whether to cluster rows or columns, or
#'   compatible `hclust` objects. Clustering controls the heatmap order.
#' @param row_cluster_tree,col_cluster_tree Whether to display the row or column
#'   clustering tree. Both default to `TRUE`. Hiding a tree preserves clustering
#'   order. No tree is drawn when clustering for that axis is disabled or cannot
#'   be computed.
#' @param show_rownames Whether to display row labels. Defaults to `FALSE`.
#' @param show_colnames Whether to display column labels. `NULL` displays them
#'   automatically for at most 40 samples.
#' @param na_col Color for missing values.
#' @inheritParams glyvis_plot_options
#' @inheritParams glyvis_abundance_scale
#' @seealso [glyvis_abundance_scale] for scale metadata and compatibility rules.
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @examples
#' mat <- matrix(c(1, 5, 3, 7, 4, 2, 3, 8, 5, 4, 2, 9), nrow = 3,
#'   dimnames = list(LETTERS[1:3], letters[1:4]))
#' se <- SummarizedExperiment::SummarizedExperiment(assays = list(mat))
#' plot_heatmap(se)
#' plot_heatmap(se, row_cluster_tree = FALSE, col_cluster_tree = FALSE)
#' @export
plot_heatmap <- function(
  x,
  ...,
  scale = "row",
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  row_cluster_tree = TRUE,
  col_cluster_tree = TRUE,
  show_rownames = FALSE,
  show_colnames = NULL,
  na_col = "grey90",
  log_transform = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
) {
  rlang::check_dots_empty()
  UseMethod("plot_heatmap")
}

#' @rdname plot_heatmap
#' @export
plot_heatmap.glyexp_experiment <- function(
  x,
  ...,
  scale = "row",
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  row_cluster_tree = TRUE,
  col_cluster_tree = TRUE,
  show_rownames = FALSE,
  show_colnames = NULL,
  na_col = "grey90",
  log_transform = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
) {
  rlang::check_dots_empty()
  .plot_exp_heatmap(
    x,
    ...,
    title = title,
    width = width,
    height = height,
    fontsize = fontsize,
    family = family,
    palette = palette,
    scale = scale,
    cluster_rows = cluster_rows,
    cluster_cols = cluster_cols,
    row_cluster_tree = row_cluster_tree,
    col_cluster_tree = col_cluster_tree,
    show_rownames = show_rownames,
    show_colnames = show_colnames,
    na_col = na_col,
    log_transform = log_transform
  )
}

#' @rdname plot_heatmap
#' @export
plot_heatmap.SummarizedExperiment <- function(
  x,
  ...,
  scale = "row",
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  row_cluster_tree = TRUE,
  col_cluster_tree = TRUE,
  show_rownames = FALSE,
  show_colnames = NULL,
  na_col = "grey90",
  log_transform = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
) {
  rlang::check_dots_empty()
  .plot_exp_heatmap(
    x,
    ...,
    title = title,
    width = width,
    height = height,
    fontsize = fontsize,
    family = family,
    palette = palette,
    scale = scale,
    cluster_rows = cluster_rows,
    cluster_cols = cluster_cols,
    row_cluster_tree = row_cluster_tree,
    col_cluster_tree = col_cluster_tree,
    show_rownames = show_rownames,
    show_colnames = show_colnames,
    na_col = na_col,
    log_transform = log_transform
  )
}

#' Internal function to plot heatmap
#' @param exp A `glyexp_experiment` object.
#' @inheritParams glyvis_plot_options
#' @noRd
.plot_exp_heatmap <- function(
  exp,
  scale = "row",
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  row_cluster_tree = TRUE,
  col_cluster_tree = TRUE,
  show_rownames = FALSE,
  show_colnames = NULL,
  na_col = "grey90",
  palette = c("#2166AC", "#F7F7F7", "#B2182B"),
  ...,
  log_transform = NULL
) {
  if (is.null(palette)) {
    palette <- c("#2166AC", "#F7F7F7", "#B2182B")
  }
  checkmate::assert_choice(scale, c("row", "column", "none"))
  checkmate::assert_flag(row_cluster_tree)
  checkmate::assert_flag(col_cluster_tree)
  checkmate::assert_flag(show_rownames)
  checkmate::assert_flag(show_colnames, null.ok = TRUE)
  transformation <- .resolve_plot_transformation(exp, log_transform)
  mat <- .get_expr_mat(exp)
  if (transformation$log_transform) {
    mat <- log2(mat + 1e-6)
  }
  if (is.null(rownames(mat))) {
    rownames(mat) <- paste0("Variable ", seq_len(nrow(mat)))
  }
  if (is.null(colnames(mat))) {
    colnames(mat) <- paste0("Sample ", seq_len(ncol(mat)))
  }
  mat <- .filter_zero_variance(mat)$mat
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
  p <- .add_heatmap_trees(
    p,
    if (row_cluster_tree) row_tree else FALSE,
    if (col_cluster_tree) col_tree else FALSE,
    nrow(mat),
    ncol(mat)
  )
  p +
    labs(
      x = NULL,
      y = NULL,
      fill = if (scale == "none") {
        .abundance_label(transformation)
      } else {
        "Z score"
      },
      color = if (scale == "none") {
        .abundance_label(transformation)
      } else {
        "Z score"
      }
    ) +
    theme(axis.ticks = element_blank(), legend.position = "right")
}

# Keep trees in the same coordinate system as the heatmap so that tips stay
# aligned with cell centers when the returned tidyplot is resized or styled.
.add_heatmap_trees <- function(p, row_tree, col_tree, nrow, ncol) {
  xlim <- c(0.5, ncol + 0.5)
  ylim <- c(0.5, nrow + 0.5)
  for (axis in c("row", "col")) {
    tree <- if (axis == "row") row_tree else col_tree
    if (!inherits(tree, "hclust")) {
      next
    }
    segments <- .heatmap_tree_segments(tree)
    height <- max(abs(tree$height))
    if (height == 0) {
      height <- 1
    }
    if (axis == "row") {
      segments <- data.frame(
        x = 0.5 - ncol * (0.02 + 0.16 * segments$y / height),
        xend = 0.5 - ncol * (0.02 + 0.16 * segments$yend / height),
        y = nrow + 1 - segments$x,
        yend = nrow + 1 - segments$xend
      )
      xlim[1] <- 0.5 - ncol * 0.2
    } else {
      segments$y <- nrow + 0.5 + nrow * (0.02 + 0.16 * segments$y / height)
      segments$yend <- nrow +
        0.5 +
        nrow * (0.02 + 0.16 * segments$yend / height)
      ylim[2] <- nrow + 0.5 + nrow * 0.2
    }
    p <- p +
      ggplot2::geom_segment(
        data = segments,
        mapping = ggplot2::aes(
          x = .data$x,
          y = .data$y,
          xend = .data$xend,
          yend = .data$yend
        ),
        inherit.aes = FALSE,
        colour = "black",
        linewidth = 0.3,
        show.legend = FALSE
      )
  }
  # add_heatmap() already supplies Cartesian coordinates. Updating its limits
  # avoids a redundant coordinate replacement message.
  p$coordinates$limits <- list(x = xlim, y = ylim)
  p
}

.heatmap_tree_segments <- function(tree) {
  centers <- numeric(nrow(tree$merge))
  positions <- order(tree$order)
  segments <- vector("list", nrow(tree$merge))
  for (i in seq_len(nrow(tree$merge))) {
    children <- tree$merge[i, ]
    x <- vapply(
      children,
      \(child) {
        if (child < 0) positions[-child] else centers[child]
      },
      numeric(1)
    )
    y <- vapply(
      children,
      \(child) {
        if (child < 0) 0 else tree$height[child]
      },
      numeric(1)
    )
    centers[i] <- mean(x)
    segments[[i]] <- data.frame(
      x = c(x, x[1]),
      y = c(y, tree$height[i]),
      xend = c(x, x[2]),
      yend = rep(tree$height[i], 3)
    )
  }
  do.call(rbind, segments)
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

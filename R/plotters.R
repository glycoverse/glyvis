# The color palette was copied from the `colors_discrete_friendly` of `tidyplots` package.
glyvis_colors <- c("#0072B2", "#56B4E9", "#009E73", "#F5C710", "#E69F00", "#D55E00")

.glyvis_boxplot <- function(df, x, value, group = NULL) {
  if (!is.null(group)) {
    ggplot(df, aes(x = .data[[x]], y = .data[[value]], color = .data[[group]], fill = .data[[group]])) +
      geom_boxplot(
        alpha = 0.5,
        staplewidth = 0.5
      ) +
      scale_color_manual(values = glyvis_colors) +
      scale_fill_manual(values = glyvis_colors) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
  } else {
    ggplot(df, aes(x = .data[[x]], y = .data[[value]])) +
      geom_boxplot(
        fill = glyvis_colors[1],
        color = glyvis_colors[1],
        alpha = 0.5,
        staplewidth = 0.5
      ) +
      theme_bw() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
  }
}

.glyvis_scatter <- function(df, x, y, group = NULL, label = NULL, add_ellipse = FALSE) {
  if (is.null(group) && add_ellipse) {
    cli::cli_abort("Can't add ellipse to scatter plot without group.")
  }
  if (!is.null(group)) {
    p <- ggplot(df, aes(x = .data[[x]], y = .data[[y]], color = .data[[group]])) +
      geom_point() +
      theme_classic() +
      scale_color_manual(values = glyvis_colors)
  } else {
    p <- ggplot(df, aes(x = .data[[x]], y = .data[[y]])) +
      geom_point(color = glyvis_colors[1]) +
      theme_bw()
  }
  if (add_ellipse) {
    p <- p + stat_ellipse()
  }
  if (!is.null(label)) {
    p <- p + ggrepel::geom_text_repel(aes(label = .data[[label]]))
  }
  p
}

.glyvis_loadings <- function(df, x, y, label = NULL) {
  p <- ggplot(df) +
    geom_segment(
      aes(x = 0, y = 0, xend = .data[[x]], yend = .data[[y]]),
      arrow = arrow(length = unit(0.03, "npc")),
      color = glyvis_colors[1]
    ) +
    theme_bw()
  if (!is.null(label)) {
    p <- p + ggrepel::geom_text_repel(aes(.data[[x]], .data[[y]], label = .data[[label]]))
  }
  p
}

.glyvis_dotchart <- function(df, x, y) {
  ggplot(df, aes(x = stats::reorder(.data[[x]], dplyr::desc(.data[[y]])), y = .data[[y]])) +
    geom_point(color = glyvis_colors[1]) +
    theme_bw()
}

.glyvis_barplot <- function(df, x, y, ordered = FALSE) {
  if (ordered) {
    p <- ggplot(df, aes(stats::reorder(.data[[x]], dplyr::desc(.data[[y]])), .data[[y]]))
  } else {
    p <- ggplot(df, aes(.data[[x]], .data[[y]]))
  }
  p +
    geom_col(fill = glyvis_colors[1]) +
    theme_bw()
}

.glyvis_volcano <- function(df, p_col, log2fc_col, p_cutoff, log2fc_cutoff, ...) {
  rlang::check_installed("EnhancedVolcano")
  suppressWarnings(
    EnhancedVolcano::EnhancedVolcano(
      df,
      lab = df$variable,
      x = log2fc_col,
      y = p_col,
      pCutoff = p_cutoff,
      FCcutoff = log2fc_cutoff,
      labSize = 0,
      ...
    ),
    class = "lifecycle_warning_deprecated"
  )
}

#' Internal ROC plotter
#'
#' @param df A data frame with the following columns:
#'   - `variable`: a character vector of variable names.
#'   - `specificity`: a numeric vector of specificity values.
#'   - `sensitivity`: a numeric vector of sensitivity values.
#' @noRd
.glyvis_roc <- function(df) {
  ggplot(df, aes(1 - .data$specificity, .data$sensitivity)) +
    geom_path(aes(color = .data$variable)) +
    geom_abline(lty = 3) +
    coord_equal() +
    theme_bw()
}

#' Internal Forest plotter
#'
#' @param df A data frame with the following columns:
#'   - `variable`: a character vector of variable names.
#'   - `estimate`: a numeric vector of estimate values.
#'   - `lower`: a numeric vector of lower bound values.
#'   - `upper`: a numeric vector of upper bound values.
#' @noRd
.glyvis_forest <- function(df, estimate, lower, upper) {
  ggplot(df, aes(x = .data[[estimate]], y = .data[["variable"]])) +
    geom_point() +
    geom_errorbarh(aes(xmin = .data[[lower]], xmax = .data[[upper]])) +
    theme_bw()
}
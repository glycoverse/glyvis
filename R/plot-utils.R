# The color palette was copied from the `colors_discrete_friendly` of `tidyplots` package.
glyvis_colors <- c("#0072B2", "#56B4E9", "#009E73", "#F5C710", "#E69F00", "#D55E00")

.glyvis_heatmap <- function(df, x, y, value) {
  ggplot(df, aes(x = .data[[x]], y = .data[[y]], fill = .data[[value]])) +
    geom_tile() +
    scale_fill_viridis_c() +
    theme_bw() +
    theme(
      axis.text.x = element_text(angle = 90, hjust = 1),
      axis.text.y = element_blank()
    )
}

.glyvis_boxplot <- function(df, x, value, group = NULL) {
  if (!is.null(group)) {
    ggplot(df, aes(x = .data[[x]], y = .data[[value]], color = .data[[group]]), fill = .data[[group]]) +
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

.glyvis_scatter <- function(df, x, y, group = NULL) {
  if (!is.null(group)) {
    ggplot(df, aes(x = .data[[x]], y = .data[[y]], color = .data[[group]])) +
      geom_point() +
      theme_classic() +
      scale_color_manual(values = glyvis_colors)
  } else {
    ggplot(df, aes(x = .data[[x]], y = .data[[y]])) +
      geom_point(color = glyvis_colors[1]) +
      theme_bw()
  }
}

.glyvis_dotchart <- function(df, x, y) {
  ggplot(df, aes(x = stats::reorder(.data[[x]], dplyr::desc(.data[[y]])), y = .data[[y]])) +
    geom_point(color = glyvis_colors[1]) +
    theme_bw()
}
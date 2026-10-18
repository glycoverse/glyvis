#' Plots for Hierarchical Clustering
#'
#' Draw a dendrogram on a tidyplots canvas.
#'
#' @param object A `glystats_hclust_res` object.
#' @param rotate Display the dendrogram horizontally.
#' @param labels Display leaf labels.
#' @param ... Common and plot-specific options described in [glyvis_plot_options].
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
autoplot.glystats_hclust_res <- function(
  object,
  rotate = FALSE,
  labels = TRUE,
  ...
) {
  rlang::check_installed("ggdendro")
  checkmate::assert_flag(rotate)
  checkmate::assert_flag(labels)
  dendro <- ggdendro::dendro_data(object$raw_result)
  p <- .glyvis_plot(dendro$segments, "x", "y", ...) |>
    tidyplots::add(geom_segment(
      aes(xend = .data$xend, yend = .data$yend),
      color = "grey30",
      linewidth = 0.4
    ))
  p <- tidyplots::adjust_x_axis(
    p,
    breaks = dendro$labels$x,
    labels = if (labels) dendro$labels$label else NULL
  ) +
    labs(x = NULL, y = "Height") +
    theme(
      axis.line.x = element_blank(),
      axis.ticks.x = element_blank(),
      axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)
    )
  if (rotate) {
    p <- p + coord_flip() + theme(axis.text.y = element_text(angle = 0))
  }
  p
}

#' Plots for Principal Component Analysis (PCA)
#'
#' Visualization for `glystats_pca_res` results.
#' Possible `type`s of plots:
#' - "individual" (default): Plot samples as individuals.
#' - "variables": Plot loadings for variables.
#'
#' @param object A `glystats_pca_res` object.
#' @param type The type of plot, one of "individual" (default) or "variables".
#' @param group_col For "individual" plot, the column name of the group information in the sample information.
#' @param ... Other arguments passed to underlying functions.
#'
#' @returns A ggplot object.
#' @export
autoplot.glystats_pca_res <- function(object, type = "individual", group_col = "group", ...) {
  checkmate::assert_choice(type, c("individual", "variables"))
  switch(
    type,
    individual = .plot_pca_individual(object, group_col, ...),
    variables = .plot_pca_variables(object, ...)
  )
}

.plot_pca_individual <- function(object, group_col, ...) {
  df <- object$samples %>%
    dplyr::filter(.data$PC %in% 1:2) %>%
    tidyr::pivot_wider(names_from = "PC", values_from = "value", names_prefix = "PC")

  if (group_col %in% colnames(df)) {
    min_n_per_group <- df %>%
      dplyr::count(.data[[group_col]]) %>%
      dplyr::pull(.data$n) %>%
      min()
    p <- tidyplot(df, x = .data$PC1, y = .data$PC2, color = .data[[group_col]]) %>%
      add_data_points()
    if (min_n_per_group > 3) {
      p <- p %>% add(ggplot2::stat_ellipse(level = 0.95, alpha = 0.3))
    }
  } else {
    p <- tidyplot(df, x = .data$PC1, y = .data$PC2) %>%
      add_data_points()
  }
  p
}

.plot_pca_variables <- function(object, ...) {
  df <- object$variables %>%
    dplyr::filter(.data$PC %in% 1:2) %>%
    tidyr::pivot_wider(names_from = "PC", values_from = "value", names_prefix = "PC")

  tidyplot(df, x = .data$PC1, y = .data$PC2) %>%
    add_data_points()
}

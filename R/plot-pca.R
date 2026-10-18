#' PCA Plot
#'
#' Draw a PCA scores plot.
#' Currently supported data types:
#' - `glystats_pca_res`: Result from [glystats::gly_pca()].
#' - `SummarizedExperiment`: A [glyexp::GlycomicSE()],
#'   [glyexp::GlycoproteomicSE()], or other compatible container.
#'   PCA analysis is first performed using [glystats::gly_pca()],
#'   then the result is plotted.
#'
#' @param x An object to be plotted.
#' @param type The type of plot, one of "screeplot", "individual", "variables", or "biplot".
#' @param groups A factor or character vector specifying group membership for each sample.
#'   If provided, the plot will be colored by group.
#'   Only applicable to "individual" and "biplot" types.
#' @param group_col A character string specifying where to find the group information.
#'   If the result was produced from a supported Glycoverse data container,
#'   sample information has already been added to the result.
#'   In this case, you can specify the column name in the sample information tibble
#'   to be used for coloring.
#' @param ... Common and plot-specific options described in [glyvis_plot_options].
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
plot_pca <- function(
  x,
  type = "individual",
  groups = NULL,
  group_col = NULL,
  ...
) {
  UseMethod("plot_pca")
}

#' @rdname plot_pca
#' @export
plot_pca.glystats_pca_res <- function(
  x,
  type = "individual",
  groups = NULL,
  group_col = NULL,
  ...
) {
  .plot_pca(x, type = type, groups = groups, group_col = group_col, ...)
}

#' @rdname plot_pca
#' @param stats_args A list of keyword arguments to pass to [glystats::gly_pca()].
#' @export
plot_pca.glyexp_experiment <- function(
  x,
  type = "individual",
  groups = NULL,
  group_col = NULL,
  stats_args = list(),
  ...
) {
  pca_res <- rlang::exec(glystats::gly_pca, x, !!!stats_args)
  .plot_pca(pca_res, type = type, groups = groups, group_col = group_col, ...)
}

#' @rdname plot_pca
#' @export
plot_pca.SummarizedExperiment <- function(
  x,
  type = "individual",
  groups = NULL,
  group_col = NULL,
  stats_args = list(),
  ...
) {
  pca_res <- rlang::exec(glystats::gly_pca, x, !!!stats_args)
  .plot_pca(pca_res, type = type, groups = groups, group_col = group_col, ...)
}

.plot_pca <- function(
  pca_res,
  type = "individual",
  groups = NULL,
  group_col = NULL,
  axes = c(1L, 2L),
  label = FALSE,
  top_n = NULL,
  add_ellipse = FALSE,
  ...
) {
  checkmate::assert_choice(
    type,
    c("screeplot", "individual", "variables", "biplot")
  )
  model <- pca_res$raw_result
  if (!inherits(model, "prcomp")) {
    cli::cli_abort("PCA plotting requires a prcomp result.")
  }
  .validate_group_args(groups, group_col)
  variance <- model$sdev^2 / sum(model$sdev^2) * 100
  if (type == "screeplot") {
    df <- data.frame(
      component = factor(
        paste0("PC", seq_along(variance)),
        levels = paste0("PC", seq_along(variance))
      ),
      variance = variance
    )
    return(
      .glyvis_barplot(df, "component", "variance", ...) +
        labs(x = "Principal component", y = "Variance explained (%)")
    )
  }
  checkmate::assert_integerish(
    axes,
    len = 2,
    lower = 1,
    upper = ncol(model$x),
    any.missing = FALSE
  )
  if (axes[1] == axes[2]) {
    cli::cli_abort("{.arg axes} must select two different components.")
  }
  samples <- data.frame(
    sample = rownames(model$x),
    x = model$x[, axes[1]],
    y = model$x[, axes[2]]
  )
  groups <- .prepare_groups(pca_res, groups, group_col)
  if (!is.null(groups)) {
    samples$group <- groups[samples$sample]
  }
  variables <- data.frame(
    variable = rownames(model$rotation),
    x = model$rotation[, axes[1]],
    y = model$rotation[, axes[2]]
  )
  if (type == "variables") {
    p <- .glyvis_loadings(
      variables,
      "x",
      "y",
      "variable",
      label = label,
      top_n = top_n,
      ...
    )
  } else {
    p <- .glyvis_scatter(
      samples,
      "x",
      "y",
      if (is.null(groups)) NULL else "group",
      label_col = "sample",
      label = label,
      add_ellipse = add_ellipse,
      ...
    )
    if (type == "biplot") {
      variables <- .glyvis_top(variables, variables$x^2 + variables$y^2, top_n)
      # One common multiplier preserves loading angles and relative lengths.
      extent <- max(sqrt(variables$x^2 + variables$y^2))
      multiplier <- if (extent > 0) {
        0.75 * max(sqrt(samples$x^2 + samples$y^2)) / extent
      } else {
        1
      }
      variables$x <- variables$x * multiplier
      variables$y <- variables$y * multiplier
      p <- tidyplots::add(
        p,
        geom_segment(
          data = variables,
          aes(x = 0, y = 0, xend = .data$x, yend = .data$y),
          inherit.aes = FALSE,
          arrow = grid::arrow(length = grid::unit(1.5, "mm")),
          linewidth = 0.35,
          color = "grey45"
        )
      )
      if (label) {
        p <- tidyplots::add_data_labels_repel(
          p,
          label = !!rlang::sym("variable"),
          data = variables,
          color = "grey35",
          fontsize = 8,
          max.overlaps = 20
        )
      }
      p <- p + labs(caption = "Loading arrows use a common display multiplier.")
    }
  }
  p +
    labs(
      x = sprintf("PC%d (%.1f%%)", axes[1], variance[axes[1]]),
      y = sprintf("PC%d (%.1f%%)", axes[2], variance[axes[2]])
    ) +
    coord_equal()
}

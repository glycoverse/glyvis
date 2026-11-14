#' Correlation Plot
#'
#' Draw a correlation matrix heatmap.
#' Currently supported data types:
#' - `glystats_cor_res`: Result from [glystats::gly_cor()].
#' - `SummarizedExperiment`: A [glyexp::GlycomicSE()],
#'   [glyexp::GlycoproteomicSE()], or other compatible container.
#'   Correlation analysis is first performed using [glystats::gly_cor()],
#'   then the result is plotted.
#'
#' @param x An object to be plotted.
#' @param label Whether to display correlation coefficients in cells.
#' @param digits Number of decimal places for coefficient labels.
#' @param triangle Part of the matrix to display: `"lower"` (default), `"upper"`,
#'   or `"full"`. Colors always span -1 to 1.
#' @inheritParams glyvis_plot_options
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
plot_corrplot <- function(
  x,
  ...,
  label = FALSE,
  digits = 2,
  triangle = "lower",
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL,
  stats_args = list()
) {
  rlang::check_dots_empty()
  UseMethod("plot_corrplot")
}

#' @rdname plot_corrplot
#' @export
plot_corrplot.glystats_cor_res <- function(
  x,
  ...,
  label = FALSE,
  digits = 2,
  triangle = "lower",
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
) {
  rlang::check_dots_empty()
  .plot_corrplot(
    x,
    ...,
    title = title,
    width = width,
    height = height,
    fontsize = fontsize,
    family = family,
    palette = palette,
    label = label,
    digits = digits,
    triangle = triangle
  )
}

#' @rdname plot_corrplot
#' @param stats_args A list of keyword arguments to pass to [glystats::gly_cor()].
#' @export
plot_corrplot.glyexp_experiment <- function(
  x,
  ...,
  stats_args = list(),
  label = FALSE,
  digits = 2,
  triangle = "lower",
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
) {
  rlang::check_dots_empty()
  cor_res <- rlang::exec(glystats::gly_cor, x, !!!stats_args)
  .plot_corrplot(
    cor_res,
    ...,
    title = title,
    width = width,
    height = height,
    fontsize = fontsize,
    family = family,
    palette = palette,
    label = label,
    digits = digits,
    triangle = triangle
  )
}

#' @rdname plot_corrplot
#' @export
plot_corrplot.SummarizedExperiment <- function(
  x,
  ...,
  stats_args = list(),
  label = FALSE,
  digits = 2,
  triangle = "lower",
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
) {
  rlang::check_dots_empty()
  cor_res <- rlang::exec(glystats::gly_cor, x, !!!stats_args)
  .plot_corrplot(
    cor_res,
    ...,
    title = title,
    width = width,
    height = height,
    fontsize = fontsize,
    family = family,
    palette = palette,
    label = label,
    digits = digits,
    triangle = triangle
  )
}

#' Internal function to plot correlation matrix
#' @param cor_res A `glystats_cor_res` object.
#' @inheritParams glyvis_plot_options
#' @noRd
.plot_corrplot <- function(
  cor_res,
  label = FALSE,
  digits = 2,
  triangle = "lower",
  palette = NULL,
  ...
) {
  if (is.null(palette)) {
    palette <- glyvis_diverging_colors
  }
  checkmate::assert_choice(triangle, c("lower", "upper", "full"))
  checkmate::assert_flag(label)
  r <- cor_res$raw_result$r
  n <- nrow(r)
  ids <- colnames(r)
  if (is.null(ids)) {
    ids <- as.character(seq_len(n))
  }
  index <- which(
    switch(
      triangle,
      lower = lower.tri(r),
      upper = upper.tri(r),
      full = matrix(TRUE, n, n)
    ),
    arr.ind = TRUE
  )
  if (!nrow(index)) {
    cli::cli_abort(
      "At least two variables are required for a triangular correlation plot."
    )
  }
  df <- data.frame(
    x = factor(ids[index[, 2]], levels = ids),
    y = factor(ids[index[, 1]], levels = rev(ids)),
    coefficient = r[index]
  )
  p <- .glyvis_plot(df, "x", "y", "coefficient", palette = palette, ...) |>
    tidyplots::add_heatmap(rotate_labels = 45) |>
    tidyplots::adjust_colors(palette, limits = c(-1, 1), na.value = "grey90")
  p <- suppressMessages(
    p +
      labs(x = NULL, y = NULL, fill = "Correlation", color = "Correlation") +
      coord_equal() +
      theme(legend.position = "right", axis.ticks = element_blank())
  )
  if (label) {
    p <- tidyplots::add(
      p,
      geom_text(
        aes(label = round(.data$coefficient, digits)),
        color = "black",
        size = 2.6
      )
    )
  }
  p
}

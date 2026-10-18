# Shared tidyplots canvas. Named palettes can be reused across plots and subsets.
glyvis_colors <- c(
  "#0072B2",
  "#D55E00",
  "#009E73",
  "#CC79A7",
  "#E69F00",
  "#56B4E9"
)

.glyvis_plot <- function(
  df,
  x,
  y,
  group = NULL,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL,
  ...
) {
  rlang::check_dots_empty()
  checkmate::assert_number(fontsize, lower = 1)
  if (is.null(group)) {
    p <- tidyplots::tidyplot(
      df,
      x = !!rlang::sym(x),
      y = !!rlang::sym(y),
      width = width,
      height = height
    )
  } else {
    p <- tidyplots::tidyplot(
      df,
      x = !!rlang::sym(x),
      y = !!rlang::sym(y),
      color = !!rlang::sym(group),
      width = width,
      height = height
    )
  }
  p <- tidyplots::adjust_font(p, fontsize = fontsize, family = family)
  if (is.null(palette) && (is.null(group) || !is.numeric(df[[group]]))) {
    palette <- glyvis_colors
  }
  p <- tidyplots::adjust_colors(
    p,
    palette,
    downsample = "first",
    labels = identity
  )
  p +
    labs(title = title, color = NULL, fill = NULL) +
    theme(
      legend.position = "bottom",
      plot.title = element_text(face = "bold"),
      strip.text = element_text(face = "bold"),
      plot.margin = margin(8, 10, 8, 8)
    )
}

.glyvis_labels <- function(p, column, label) {
  checkmate::assert_flag(label)
  if (!label || is.null(column)) {
    return(p)
  }
  tidyplots::add_data_labels_repel(
    p,
    label = !!rlang::sym(column),
    fontsize = 8,
    max.overlaps = 20
  )
}

.glyvis_boxplot <- function(df, x, value, group = NULL, points = TRUE, ...) {
  checkmate::assert_flag(points)
  p <- .glyvis_plot(df, x, value, group, ...) |>
    tidyplots::add_boxplot(
      show_outliers = !points,
      linewidth = 0.4,
      alpha = 0.2
    )
  if (points) {
    p <- tidyplots::add_data_points_jitter(
      p,
      size = 1,
      alpha = 0.6,
      jitter_width = 0.12
    )
  }
  p + theme(legend.position = "none")
}

.glyvis_scatter <- function(
  df,
  x,
  y,
  group = NULL,
  label_col = NULL,
  label = FALSE,
  add_ellipse = FALSE,
  point_size = 2,
  alpha = 0.8,
  ...
) {
  if (!is.null(group) && !group %in% names(df)) {
    group <- NULL
  }
  if (is.null(group) && add_ellipse) {
    cli::cli_abort("Can't add ellipse to scatter plot without group.")
  }
  p <- .glyvis_plot(df, x, y, group, ...) |>
    tidyplots::add_data_points(size = point_size, alpha = alpha)
  if (add_ellipse) {
    p <- tidyplots::add_ellipse(p, linewidth = 0.4, show.legend = FALSE)
  }
  .glyvis_labels(p, label_col, label)
}

.glyvis_top <- function(df, score, top_n) {
  if (is.null(top_n)) {
    return(df)
  }
  checkmate::assert_count(top_n, positive = TRUE)
  df[
    utils::head(order(score, decreasing = TRUE, na.last = NA), top_n),
    ,
    drop = FALSE
  ]
}

.glyvis_loadings <- function(
  df,
  x,
  y,
  label_col = NULL,
  label = FALSE,
  top_n = NULL,
  ...
) {
  df <- .glyvis_top(df, df[[x]]^2 + df[[y]]^2, top_n)
  p <- .glyvis_plot(df, x, y, ...) |>
    tidyplots::add(geom_segment(
      aes(x = 0, y = 0, xend = .data[[x]], yend = .data[[y]]),
      arrow = grid::arrow(length = grid::unit(1.5, "mm")),
      linewidth = 0.4,
      color = glyvis_colors[1]
    ))
  .glyvis_labels(p, label_col, label)
}

.glyvis_dotchart <- function(df, x, y, top_n = NULL, palette = NULL, ...) {
  df <- .glyvis_top(df, df[[y]], top_n)
  df[[x]] <- factor(df[[x]], levels = unique(df[[x]][order(df[[y]])]))
  group <- if ("candidate" %in% names(df)) "candidate" else NULL
  if (!is.null(group)) {
    df$candidate <- factor(
      df$candidate,
      levels = c(FALSE, TRUE),
      labels = c("Below cutoff", "Selected")
    )
  }
  if (!is.null(group) && is.null(palette)) {
    palette <- c("Below cutoff" = "#B8BEC5", Selected = "#0072B2")
  }
  .glyvis_plot(df, x, y, group, palette = palette, ...) |>
    tidyplots::add_data_points(size = 2) |>
    tidyplots::add(coord_flip())
}

.glyvis_barplot <- function(df, x, y, ordered = FALSE, top_n = NULL, ...) {
  df <- .glyvis_top(df, df[[y]], top_n)
  if (ordered) {
    df[[x]] <- factor(
      df[[x]],
      levels = unique(df[[x]][order(df[[y]])])
    )
  }
  .glyvis_plot(df, x, y, ...) |> tidyplots::add_sum_bar()
}

.glyvis_volcano <- function(
  df,
  p_col,
  log2fc_col,
  p_cutoff,
  log2fc_cutoff,
  label = FALSE,
  point_size = 1.5,
  alpha = 0.7,
  palette = c(Down = "#0072B2", Unchanged = "#B8BEC5", Up = "#D55E00"),
  ...
) {
  checkmate::assert_number(p_cutoff, lower = 0, upper = 1)
  checkmate::assert_number(log2fc_cutoff, lower = 0)
  df$neglog10p <- -log10(pmax(df[[p_col]], .Machine$double.xmin))
  df$status <- ifelse(
    df[[p_col]] < p_cutoff & df[[log2fc_col]] > log2fc_cutoff,
    "Up",
    ifelse(
      df[[p_col]] < p_cutoff & df[[log2fc_col]] < -log2fc_cutoff,
      "Down",
      "Unchanged"
    )
  )
  df$status <- factor(df$status, levels = c("Down", "Unchanged", "Up"))
  p <- .glyvis_scatter(
    df,
    log2fc_col,
    "neglog10p",
    "status",
    label_col = "variable",
    label = label,
    point_size = point_size,
    alpha = alpha,
    palette = palette,
    ...
  )
  p <- tidyplots::add_reference_lines(
    p,
    x = c(-log2fc_cutoff, log2fc_cutoff),
    color = "grey60"
  )
  if (p_cutoff > 0) {
    p <- tidyplots::add_reference_lines(
      p,
      y = -log10(p_cutoff),
      color = "grey60"
    )
  }
  p +
    labs(
      x = expression(log[2] ~ "fold change"),
      y = if (p_col == "p_adj") {
        expression(-log[10] ~ "adjusted P")
      } else {
        expression(-log[10] ~ P)
      }
    )
}

.glyvis_roc <- function(df, ...) {
  df$false_positive_rate <- 1 - df$specificity
  .glyvis_plot(df, "false_positive_rate", "sensitivity", "variable", ...) |>
    tidyplots::add(geom_path(linewidth = 0.65)) |>
    tidyplots::add(geom_abline(
      linetype = "dashed",
      color = "grey65",
      linewidth = 0.35
    )) |>
    tidyplots::add(coord_equal(xlim = c(0, 1), ylim = c(0, 1))) |>
    tidyplots::add(labs(x = "1 - Specificity", y = "Sensitivity"))
}

.glyvis_forest <- function(df, estimate, lower, upper, ...) {
  .glyvis_plot(df, estimate, "variable", ...) |>
    tidyplots::add_data_points(size = 2) |>
    tidyplots::add(geom_errorbar(
      aes(xmin = .data[[lower]], xmax = .data[[upper]]),
      orientation = "y",
      width = 0.2
    ))
}

.glyvis_wrap <- function(x, width = 24) {
  vapply(
    x,
    function(text) {
      starts <- seq.int(1L, max(1L, nchar(text)), by = width)
      paste(substring(text, starts, starts + width - 1L), collapse = "\n")
    },
    character(1)
  )
}

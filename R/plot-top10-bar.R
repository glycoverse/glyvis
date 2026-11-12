#' Top ten glycans by site-specific glycoform count or abundance
#'
#' Draw mirrored horizontal bars with glycan cartoons at their outer ends.
#' The left side includes oligomannose; the right side excludes it. Each side
#' independently selects up to ten glycans, ranked from highest to lowest
#' from top to bottom, on a shared quantitative scale.
#'
#' @param x A [glyexp::GlycoproteomicSE()] with `glycan_structure`, `protein`,
#'   and `protein_site` row annotations and `glycan_type = "N"` in metadata.
#'   Glycomics, plain `SummarizedExperiment`, and legacy containers are rejected.
#' @param weight Either `"equal"` (default), counting distinct combinations of
#'   protein, site, and glycan structure, or `"abundance"`, summing linear-scale
#'   glycoform abundances across all rows and samples. Duplicate measurements
#'   count once in equal mode and contribute their summed abundance otherwise.
#' @param ... Common appearance options in [glyvis_plot_options]. The plot area
#'   uses the tidyplots default (50 by 50 mm). The first two default glyvis
#'   colours identify the left and right sides. Cartoon sizes adapt to the
#'   plot dimensions supplied here. No title is added unless `title` is supplied.
#'
#' @details
#' Classification uses [glydet::n_glycan_type()] with `merge_mannose = TRUE`:
#' oligomannose includes paucimannose and high-mannose. Missing structures and
#' structures without an N-glycan core are excluded with a warning; invalid
#' structures or ambiguous classifications raise an error.
#' Ties are resolved by canonical structure string. If fewer than ten glycans
#' are available, all are shown; an empty right side is labelled explicitly.
#'
#' Equal weighting uses annotations regardless of zero or missing abundance.
#' Abundance weighting requires non-negative finite values on a recorded raw
#' scale (missing scale metadata is treated as raw). Missing values are omitted;
#' all-zero or entirely missing eligible abundance raises an error. No
#' sample-wise normalization is applied.
#'
#' @returns A `tidyplot`, also inheriting from `ggplot`. Its `data` contains
#'   `glycan_structure`, `type`, `value`, `side`, and `rank`. Values are always
#'   non-negative; `signed_value` gives their mirrored plotting coordinates.
#' @examples
#' if (all(vapply(c("glydet", "glydraw", "glymotif", "glyparse", "glyrepr"),
#'                requireNamespace, logical(1), quietly = TRUE))) {
#'   plot_top10_bar(glyexp::real_experiment)
#'   plot_top10_bar(glyexp::real_experiment, weight = "abundance")
#' }
#' @export
plot_top10_bar <- function(
  x,
  ...,
  weight = "equal"
) {
  checkmate::assert_class(x, "GlycoproteomicSE")
  input <- .n_plot_input(x, weight)
  structures <- unique(input$structures)
  index <- match(input$structures, structures)
  values <- unname(rowsum(
    rowSums(input$abundance, na.rm = TRUE),
    index,
    reorder = FALSE
  )[, 1])
  type <- as.character(glydet::n_glycan_type(
    input$glycans[match(structures, input$structures)],
    merge_mannose = TRUE
  ))
  type[type == "oligo-mannose"] <- "oligomannose"
  if (anyNA(type) || any(!type %in% c("oligomannose", "hybrid", "complex"))) {
    cli::cli_abort("Some N-glycans could not be classified unambiguously.")
  }
  df <- tibble::tibble(
    glycan_structure = structures,
    type = type,
    value = values
  )
  df <- df[order(-df$value, df$glycan_structure), , drop = FALSE]
  sides <- c("Including oligomannose", "Excluding oligomannose")
  left <- utils::head(df, 10)
  right <- utils::head(df[df$type != "oligomannose", , drop = FALSE], 10)
  left$side <- rep(sides[1], nrow(left))
  right$side <- rep(sides[2], nrow(right))
  left$rank <- seq_len(nrow(left))
  right$rank <- seq_len(nrow(right))
  df <- dplyr::bind_rows(left, right)
  df$side <- factor(df$side, levels = sides)
  df$signed_value <- ifelse(df$side == sides[1], -df$value, df$value)
  .top10_bar_plot(df, weight, ...)
}

.top10_bar_plot <- function(
  df,
  weight,
  width = NULL,
  height = NULL,
  title = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL,
  ...
) {
  df$y <- -df$rank
  p <- .glyvis_plot(
    df,
    "signed_value",
    "y",
    "side",
    width = width,
    height = height,
    title = title,
    fontsize = fontsize,
    family = family,
    palette = palette,
    ...
  )
  panel_width <- if (is.null(width) || is.na(width)) 50 else width
  panel_height <- if (is.null(height) || is.na(height)) 50 else height
  n <- max(df$rank)
  dimensions <- vapply(
    df$glycan_structure,
    function(structure) {
      cartoon <- glydraw::draw_cartoon(structure, show_linkage = FALSE)
      attr(cartoon, "glydraw_panel_size_px")[c("width", "height")] / 300 * 25.4
    },
    numeric(2)
  )
  cartoon_size <- min(
    0.3,
    panel_height / (n + 2) * 0.9 / max(dimensions["height", ]),
    panel_width * 0.28 / max(dimensions["width", ])
  )
  left <- df$side == levels(df$side)[1]
  gap_mm <- min(1.5, panel_width * 0.02)
  # Reserve physical space for cartoons without changing the bar scale.
  padding <- vapply(
    list(left, !left),
    function(keep) {
      max(c(0, dimensions["width", keep])) * cartoon_size + 2 * gap_mm
    },
    numeric(1)
  )
  peaks <- c(max(df$value[left]), max(c(0, df$value[!left])))
  # Keep an empty side wide enough to display its heading and empty-state label.
  if (!any(!left)) {
    peaks[2] <- peaks[1]
  }
  span <- sum(peaks) / (1 - sum(padding) / panel_width)
  limits <- c(-1, 1) * (peaks + padding / panel_width * span)
  df$cartoon_x <- df$signed_value +
    ifelse(left, -1, 1) * gap_mm / panel_width * span
  # Rotate after justification so both reducing ends face the bars. A single
  # layer also avoids duplicate glydraw grob names hiding one side in grid.
  df$cartoon_angle <- ifelse(left, 0, 180)
  p$data <- df
  x_scale <- p$scales$get_scales("x")
  x_scale$limits <- limits
  x_scale$expand <- expansion(mult = 0)
  breaks <- pretty(c(-peaks[1], peaks[2]))
  breaks <- breaks[breaks >= -peaks[1] & breaks <= peaks[2]]
  if (weight == "equal") {
    breaks <- breaks[breaks == floor(breaks)]
  }
  x_scale$breaks <- breaks
  x_scale$labels <- function(x) format(abs(x), trim = TRUE)
  y_scale <- p$scales$get_scales("y")
  y_scale$limits <- c(-n - 0.6, 1.2)
  y_scale$expand <- expansion(mult = 0)
  y_scale$breaks <- NULL
  headings <- tibble::tibble(
    x = limits / 2,
    y = 0.5,
    side = factor(levels(df$side), levels = levels(df$side)),
    label = c("Including\noligomannose", "Excluding\noligomannose")
  )
  colours <- if (is.null(palette)) {
    glyvis_colors[1:2]
  } else if (is.null(names(palette))) {
    rep(palette, length.out = 2)
  } else {
    unname(palette[levels(df$side)])
  }
  heading_size <- fontsize * min(1, panel_width / 75)
  p <- p +
    geom_col(aes(fill = .data$side), orientation = "y", width = 0.72) +
    glydraw::geom_glycan(
      aes(
        x = .data$cartoon_x,
        structure = .data$glycan_structure,
        angle = .data$cartoon_angle
      ),
      orient = "left",
      hjust = 1,
      size = cartoon_size,
      show_linkage = FALSE,
      show.legend = FALSE
    ) +
    geom_text(
      data = headings,
      aes(x = .data$x, y = .data$y, label = .data$label),
      colour = colours,
      inherit.aes = FALSE,
      family = family,
      size = heading_size / (72.27 / 25.4),
      lineheight = 0.95
    ) +
    labs(
      x = if (weight == "equal") {
        "Site-specific glycoform count"
      } else {
        "Pooled abundance"
      },
      y = NULL
    ) +
    theme(
      legend.position = "none",
      axis.line.y = element_blank(),
      axis.ticks.y = element_blank(),
      panel.grid = element_blank()
    )
  if (!any(!left)) {
    p <- p +
      annotate(
        "text",
        x = limits[2] / 2,
        y = -(n + 1) / 2,
        label = "No eligible glycans",
        family = family,
        size = heading_size / (72.27 / 25.4)
      )
  }
  p
}

#' N-glycan core, type, and branch distributions
#'
#' Summarize an N-glycan experiment across all samples, with glycan cartoons
#' drawn by [glydraw::geom_glycan()].
#'
#' @param x A [glyexp::GlycomicSE()] or [glyexp::GlycoproteomicSE()] with
#'   `glycan_structure` in its row annotations and `glycan_type = "N"` in
#'   its metadata. Legacy `glyexp_experiment` objects are also supported.
#' @param weight Either `"equal"` (default) or `"abundance"`. Equal weighting
#'   counts distinct glycan structures in glycomics, or distinct combinations
#'   of `protein`, `protein_site`, and glycan structure in glycoproteomics.
#'   Abundance weighting uses [glydet::wsum()] to sum the original linear-scale
#'   abundances over all rows and samples. Duplicate measurements contribute
#'   their summed abundance. Missing abundances are omitted; negative or
#'   infinite values and recorded non-raw scales are rejected.
#' @param ... Common appearance options described in [glyvis_plot_options].
#'   The default plot area is 50 by 50 mm. Pie annotations scale with the
#'   panel size; core labels are split across lines to avoid crowding.
#'
#' @details
#' `plot_n_core_pie()` separates core fucosylation and bisecting GlcNAc into
#'   four combinations. Antennal fucose does not count as core fucose.
#' `plot_n_type_pie()` uses [glydet::n_glycan_type()] with
#'   `merge_mannose = TRUE`, labelled `oligomannose`, `hybrid`, and `complex`.
#'   Thus oligomannose includes both paucimannose and high-mannose glycans.
#'   Type cartoons are representative structures, not complete definitions.
#' `plot_n_branch_pie()` groups glycans by [glydet::n_antennae()], counting
#'   GlcNAc antennae attached to the core mannoses, excluding bisecting GlcNAc.
#'   Observed antenna counts (including zero) are ordered numerically. Each
#'   cartoon is the first input structure in that category, not its definition.
#'   Observed categories with zero total abundance remain visible.
#' `plot_n_branch_bar()` extracts branch motifs through
#'   [glymotif::extract_branch_motif()] and matches them with
#'   [glymotif::branch_motifs()], preserving the distinction between antennal
#'   and bisecting GlcNAc. Each glycan or site-specific glycoform contributes
#'   at most once to each branch type, even if it has repeated identical arms.
#'   Different branch types can overlap, so bar proportions need not sum to one.
#'   Cartoons above the bars show the extracted branches, without the core.
#'   Bars are ordered from highest to lowest value and share one colour
#'   (the first colour in `palette`, when supplied).
#'   Pie annotations follow their sectors and move apart when crowded.
#'   Bar limits reserve space for the actual cartoon heights.
#'
#' Missing structures and structures without the N-glycan core are excluded
#' with a warning. Invalid structure strings raise an error. Reducing-end
#' alditol status is ignored for classification, but retained when identifying
#' distinct glycoforms. Equal weighting counts annotated glycoforms regardless
#' of assay missingness or zero abundance. No sample-wise normalization is
#' applied. All-zero or entirely missing total abundance raises an error.
#'
#' @returns A `tidyplot`, also inheriting from `ggplot`. Its `data` contains
#'   `category`, `value`, `proportion`, and `glycan_structure`. Proportions use
#'   the total count or abundance of eligible N-glycoforms as the denominator.
#'   Pies retain zero-valued categories in `data` and in their cartoon labels.
#' @examples
#' if (all(vapply(c("glydet", "glydraw", "glymotif", "glyparse", "glyrepr"),
#'                requireNamespace, logical(1), quietly = TRUE))) {
#'   plot_n_core_pie(glyexp::real_experiment2)
#'   plot_n_type_pie(glyexp::real_experiment2, weight = "abundance")
#'   plot_n_branch_pie(glyexp::real_experiment2)
#'   plot_n_branch_bar(glyexp::real_experiment2)
#' }
#' @export
plot_n_core_pie <- function(x, weight = "equal", ...) {
  input <- .n_plot_input(x, weight)
  fuc <- glydet::n_core_fuc(input$glycans) > 0
  bisect <- glydet::has_bisecting(input$glycans)
  index <- ifelse(fuc, 0L, 2L) + ifelse(bisect, 1L, 2L)
  labels <- c(
    "Fuc+ / Bisection+",
    "Fuc+ / Bisection-",
    "Fuc- / Bisection+",
    "Fuc- / Bisection-"
  )
  structures <- .n_core_cartoons()
  membership <- outer(index, seq_along(labels), `==`)
  df <- .n_plot_summary(input, membership, labels, structures)
  .n_pie(df, ...)
}

#' @rdname plot_n_core_pie
#' @export
plot_n_type_pie <- function(x, weight = "equal", ...) {
  input <- .n_plot_input(x, weight)
  type <- as.character(glydet::n_glycan_type(
    input$glycans,
    merge_mannose = TRUE
  ))
  type[type == "oligo-mannose"] <- "oligomannose"
  labels <- c("oligomannose", "hybrid", "complex")
  structures <- c(
    "Man(a1-3)[Man(a1-6)]Man(a1-6)[Man(a1-3)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-",
    "GlcNAc(b1-2)Man(a1-3)[Man(a1-3)[Man(a1-6)]Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-",
    "GlcNAc(b1-2)Man(a1-3)[GlcNAc(b1-2)Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-"
  )
  df <- .n_plot_summary(input, outer(type, labels, `==`), labels, structures)
  .n_pie(df, ...)
}

#' @rdname plot_n_core_pie
#' @export
plot_n_branch_pie <- function(x, weight = "equal", ...) {
  input <- .n_plot_input(x, weight)
  antennae <- glydet::n_antennae(input$glycans)
  if (anyNA(antennae)) {
    cli::cli_abort("Some N-glycans could not be classified unambiguously.")
  }
  counts <- sort(unique(antennae))
  labels <- paste(counts, ifelse(counts == 1, "antenna", "antennae"))
  structures <- unname(as.character(input$glycans[match(counts, antennae)]))
  df <- .n_plot_summary(
    input,
    outer(antennae, counts, `==`),
    labels,
    structures
  )
  .n_pie(df, ...)
}

#' @rdname plot_n_core_pie
#' @export
plot_n_branch_bar <- function(x, weight = "equal", ...) {
  input <- .n_plot_input(x, weight)
  branches <- glymotif::extract_branch_motif(input$glycans)
  if (!length(branches)) {
    cli::cli_abort("No N-glycan branch motifs were found.")
  }
  membership <- glymotif::have_motifs(input$glycans, glymotif::branch_motifs())
  structures <- colnames(membership)
  df <- .n_plot_summary(
    input,
    membership,
    paste0("B", seq_along(structures)),
    structures
  )
  .n_branch_plot(df, weight, ...)
}

.n_core_cartoons <- function() {
  arms <- "Man(a1-3)"
  bisect <- "[GlcNAc(b1-4)]"
  stem <- "[Man(a1-6)]Man(b1-4)GlcNAc(b1-4)"
  fuc <- "[Fuc(a1-6)]"
  end <- "GlcNAc(b1-"
  c(
    paste0(arms, bisect, stem, fuc, end),
    paste0(arms, stem, fuc, end),
    paste0(arms, bisect, stem, end),
    paste0(arms, stem, end)
  )
}

.n_plot_input <- function(x, weight) {
  checkmate::assert_choice(weight, c("equal", "abundance"))
  rlang::check_installed(
    c(
      "glydet",
      "glydraw",
      "glymotif",
      "glyparse",
      "glyrepr"
    ),
    version = c("0.14.0", "0.9.0", "1.0.1", "1.0.1", "1.2.0")
  )
  checkmate::assert_multi_class(
    x,
    c("GlycomicSE", "GlycoproteomicSE", "glyexp_experiment")
  )
  legacy <- inherits(x, "glyexp_experiment")
  meta <- if (legacy) glyexp::get_meta_data(x) else S4Vectors::metadata(x)
  if (!identical(meta$glycan_type, "N")) {
    cli::cli_abort("These plots require metadata {.code glycan_type = \"N\"}.")
  }
  proteomics <- if (legacy) {
    checkmate::assert_choice(meta$exp_type, c("glycomics", "glycoproteomics"))
    meta$exp_type == "glycoproteomics"
  } else {
    methods::is(x, "GlycoproteomicSE")
  }
  info <- .get_var_info(x)
  if (!nrow(info)) {
    cli::cli_abort("No eligible N-glycan structures remain.")
  }
  required <- c(
    "glycan_structure",
    if (proteomics) c("protein", "protein_site")
  )
  missing <- setdiff(required, names(info))
  if (length(missing)) {
    cli::cli_abort("Missing row annotations: {.field {missing}}.")
  }
  original <- if (glyrepr::is_glycan_structure(info$glycan_structure)) {
    info$glycan_structure
  } else {
    glyparse::auto_parse(info$glycan_structure)
  }
  # The categories describe branching and substitution, independent of reduction.
  glycans <- glyparse::auto_parse(sub(
    "-ol\\(([^()]*)$",
    "(\\1",
    as.character(original)
  ))
  core <- "Hex(??-?)[Hex(??-?)]Hex(??-?)HexNAc(??-?)HexNAc(??-"
  keep <- which(
    glymotif::have_motif(
      glycans,
      core,
      alignment = "core",
      ignore_linkages = TRUE
    ) %in%
      TRUE
  )
  if (length(keep) < nrow(info)) {
    cli::cli_warn(
      "Excluded {nrow(info) - length(keep)} row{?s} with missing structures or without an N-glycan core."
    )
  }
  if (!length(keep)) {
    cli::cli_abort("No eligible N-glycan structures remain.")
  }
  info <- info[keep, , drop = FALSE]
  glycans <- glycans[keep]
  if (
    proteomics &&
      any(vapply(
        info[c("protein", "protein_site")],
        function(z) any(is.na(z) | trimws(as.character(z)) == ""),
        logical(1)
      ))
  ) {
    cli::cli_abort(
      "Site-specific glycoforms require non-missing {.field protein} and {.field protein_site} annotations."
    )
  }
  if (weight == "equal") {
    keys <- data.frame(structure = as.character(original[keep]))
    if (proteomics) {
      keys <- cbind(keys, as.data.frame(info[c("protein", "protein_site")]))
    }
    unique_rows <- !duplicated(keys)
    glycans <- glycans[unique_rows]
    abundance <- matrix(1, nrow = length(glycans), ncol = 1)
  } else {
    if (.resolve_plot_transformation(x, FALSE)$input_scale != "raw") {
      cli::cli_abort(
        "Abundance weighting requires raw, linear-scale abundances."
      )
    }
    abundance <- .get_expr_mat(x)[keep, , drop = FALSE]
    if (any(is.infinite(abundance) | abundance < 0, na.rm = TRUE)) {
      cli::cli_abort("Abundances must be non-negative and finite, or missing.")
    }
  }
  total <- sum(abundance, na.rm = TRUE)
  if (!is.finite(total) || total <= 0) {
    cli::cli_abort(
      "The total eligible count or abundance must be positive and finite."
    )
  }
  list(glycans = glycans, abundance = abundance, total = total, weight = weight)
}

.n_plot_summary <- function(input, membership, labels, structures) {
  if (anyNA(membership)) {
    cli::cli_abort("Some N-glycans could not be classified unambiguously.")
  }
  weighted_sum <- glydet::wsum(.data$.present)
  values <- vapply(
    seq_len(ncol(membership)),
    function(i) {
      sum(weighted_sum(
        input$abundance,
        tibble::tibble(.present = as.numeric(membership[, i]))
      ))
    },
    numeric(1)
  )
  tibble::tibble(
    category = factor(labels, levels = labels),
    value = values,
    proportion = values / input$total,
    glycan_structure = structures
  )
}

.n_pie <- function(
  df,
  width = 50,
  height = 50,
  fontsize = 9,
  family = "sans",
  ...
) {
  ends <- cumsum(df$proportion)
  starts <- c(0, utils::head(ends, -1))
  angles <- 2 * pi * (starts + ends) / 2
  df$x <- 0
  df$y <- 0
  polygons <- lapply(which(df$value > 0), function(i) {
    theta <- seq(
      2 * pi * starts[i],
      2 * pi * ends[i],
      length.out = max(3, ceiling(360 * df$proportion[i]))
    )
    data.frame(
      category = df$category[i],
      x = if (df$proportion[i] == 1) sin(theta) else c(0, sin(theta), 0),
      y = if (df$proportion[i] == 1) cos(theta) else c(0, cos(theta), 0)
    )
  })
  panel_width <- if (is.null(width) || is.na(width)) 50 else width
  panel_height <- if (is.null(height) || is.na(height)) 50 else height
  unit_mm <- min(panel_width, panel_height) / 6.8
  label_fontsize <- fontsize * min(1, min(panel_width, panel_height) / 70)
  cartoon_size <- min(0.18, 0.08 * min(panel_width, panel_height) / 50)
  labels <- .n_pie_labels(
    df,
    angles,
    label_fontsize,
    family,
    cartoon_size,
    unit_mm
  )
  connectors <- labels[labels$value > 0, , drop = FALSE]
  p <- .glyvis_plot(
    df,
    "x",
    "y",
    "category",
    width = width,
    height = height,
    fontsize = fontsize,
    family = family,
    ...
  )
  # Keep the category-to-colour mapping even when some wedges have zero area.
  for (aesthetic in c("fill", "colour")) {
    colour_scale <- p$scales$get_scales(aesthetic)
    colour_scale$drop <- FALSE
  }
  # Keep the physical coordinate scale equal in both directions.
  extent <- c(panel_width, panel_height) / (2 * unit_mm)
  p +
    geom_polygon(
      data = do.call(rbind, polygons),
      aes(
        x = .data$x,
        y = .data$y,
        fill = .data$category,
        group = .data$category
      ),
      inherit.aes = FALSE,
      colour = "white",
      linewidth = 0.4
    ) +
    geom_segment(
      data = connectors,
      aes(
        x = .data$anchor_x,
        y = .data$anchor_y,
        xend = .data$line_x,
        yend = .data$line_y,
        colour = .data$category
      ),
      inherit.aes = FALSE,
      linewidth = 0.35
    ) +
    glydraw::geom_glycan(
      data = labels,
      aes(
        x = .data$label_x,
        y = .data$cartoon_y,
        structure = .data$glycan_structure
      ),
      inherit.aes = FALSE,
      size = cartoon_size,
      show_linkage = FALSE
    ) +
    geom_text(
      data = labels,
      aes(x = .data$label_x, y = .data$text_y, label = .data$text),
      inherit.aes = FALSE,
      size = label_fontsize / .pt,
      family = family,
      lineheight = 1.1
    ) +
    coord_fixed(
      xlim = c(-1, 1) * extent[1],
      ylim = c(-1, 1) * extent[2],
      expand = FALSE,
      clip = "off"
    ) +
    labs(x = NULL, y = NULL) +
    theme(
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      axis.line = element_blank(),
      panel.grid = element_blank(),
      legend.position = "none"
    )
}

.n_pie_labels <- function(df, angles, fontsize, family, cartoon_size, unit_mm) {
  df$text <- paste0(
    gsub(" / ", "\n", as.character(df$category), fixed = TRUE),
    "\n",
    formatC(100 * df$proportion, format = "f", digits = 1),
    "%"
  )
  dimensions <- vapply(
    seq_len(nrow(df)),
    function(i) {
      text <- grid::textGrob(
        df$text[i],
        gp = grid::gpar(
          fontsize = fontsize,
          fontfamily = family,
          lineheight = 1.1
        )
      )
      cartoon <- glydraw::draw_cartoon(
        df$glycan_structure[i],
        show_linkage = FALSE
      )
      size <- attr(cartoon, "glydraw_panel_size_px") / 300 * 25.4 * cartoon_size
      c(
        width = max(
          size[["width"]],
          grid::convertWidth(grid::grobWidth(text), "mm", TRUE)
        ),
        cartoon_height = size[["height"]],
        text_height = grid::convertHeight(grid::grobHeight(text), "mm", TRUE)
      )
    },
    numeric(3)
  )
  half_width <- (dimensions["width", ] + 1.5) / (2 * unit_mm)
  half_height <- (dimensions["cartoon_height", ] +
    dimensions["text_height", ] +
    2.5) /
    (2 * unit_mm)
  positions <- .n_pie_label_layout(
    angles,
    which(df$value > 0),
    half_width,
    half_height
  )
  df$box_width <- 2 * half_width
  df$box_height <- 2 * half_height
  df$label_x <- positions[, "x"]
  df$label_y <- positions[, "y"]
  df$anchor_x <- sin(angles)
  df$anchor_y <- cos(angles)
  dx <- df$label_x - df$anchor_x
  dy <- df$label_y - df$anchor_y
  edge <- pmin(half_width / abs(dx), half_height / abs(dy))
  df$line_x <- df$label_x - edge * dx
  df$line_y <- df$label_y - edge * dy
  df$cartoon_y <- df$label_y + (dimensions["text_height", ] + 1) / (2 * unit_mm)
  df$text_y <- df$label_y - (dimensions["cartoon_height", ] + 1) / (2 * unit_mm)
  df
}

.n_pie_label_layout <- function(angles, present, half_width, half_height) {
  label_angles <- angles
  # Zero-valued categories have no sector: place them in unused angular gaps.
  for (i in setdiff(seq_along(angles), present)) {
    occupied <- sort(label_angles[present] %% (2 * pi))
    gaps <- diff(c(occupied, occupied[1] + 2 * pi))
    gap <- which.max(gaps)
    label_angles[i] <- (occupied[gap] + gaps[gap] / 2) %% (2 * pi)
    present <- c(present, i)
  }
  centres <- function(theta) {
    # Clear the circle's tangent with the complete cartoon-and-text box.
    radius <- 1.08 +
      half_width * abs(sin(theta)) +
      half_height * abs(cos(theta))
    cbind(x = radius * sin(theta), y = radius * cos(theta))
  }
  if (length(angles) == 1L) {
    return(centres(label_angles))
  }
  pairs <- utils::combn(seq_along(angles), 2)
  for (iteration in seq_len(720)) {
    moved <- FALSE
    for (pair in seq_len(ncol(pairs))) {
      i <- pairs[1, pair]
      j <- pairs[2, pair]
      positions <- centres(label_angles)
      overlap <- abs(positions[i, ] - positions[j, ]) <
        c(sum(half_width[c(i, j)]) + 0.06, sum(half_height[c(i, j)]) + 0.06)
      if (all(overlap)) {
        direction <- sign(
          (label_angles[j] - label_angles[i] + pi) %%
            (2 * pi) -
            pi
        )
        if (direction == 0) {
          direction <- 1
        }
        label_angles[c(i, j)] <- label_angles[c(i, j)] +
          c(-1, 1) * direction * 0.015
        moved <- TRUE
      }
    }
    if (!moved) break
  }
  positions <- centres(label_angles)
  collides <- function(positions) {
    any(vapply(
      seq_len(ncol(pairs)),
      function(k) {
        i <- pairs[1, k]
        j <- pairs[2, k]
        all(
          abs(positions[i, ] - positions[j, ]) <
            c(sum(half_width[c(i, j)]), sum(half_height[c(i, j)]))
        )
      },
      logical(1)
    ))
  }
  # A bounded relaxation must never return a still-overlapping arrangement.
  # Four exterior corners provide a collision-free fallback for three/four labels.
  if (collides(positions) && length(angles) > 4L) {
    # Stack labels outside the pie when more than four categories are crowded.
    side <- ifelse(sin(label_angles) < 0, -1, 1)
    for (s in c(-1, 1)) {
      ids <- which(side == s)
      ids <- ids[order(positions[ids, "y"])]
      heights <- 2 * half_height[ids] + 0.06
      positions[ids, "x"] <- s * (1.08 + half_width[ids])
      positions[ids, "y"] <- cumsum(heights) - heights / 2 - sum(heights) / 2
    }
  } else if (collides(positions)) {
    corners <- cbind(
      x = c(-1, 1, -1, 1) * (max(half_width) + 0.8),
      y = c(-1, -1, 1, 1) * (max(half_height) + 0.8)
    )
    assignments <- as.matrix(expand.grid(rep(list(1:4), length(angles))))
    assignments <- assignments[
      apply(assignments, 1, function(x) !anyDuplicated(x)),
      ,
      drop = FALSE
    ]
    costs <- apply(assignments, 1, function(x) {
      sum((corners[x, ] - positions)^2)
    })
    positions <- corners[assignments[which.min(costs), ], , drop = FALSE]
  }
  positions
}

.n_branch_plot <- function(
  df,
  weight,
  width = 50,
  height = 50,
  palette = NULL,
  ...
) {
  df <- df[order(df$value, decreasing = TRUE), , drop = FALSE]
  df$category <- factor(df$category, levels = as.character(df$category))
  peak <- max(df$value)
  if (peak == 0) {
    peak <- 1
  }
  df$cartoon_y <- df$value + peak * 0.025
  cartoon_size <- min(0.22, 1 / nrow(df))
  # Use glydraw's native panel dimensions, excluding standalone export borders.
  cartoon_height <- vapply(
    df$glycan_structure,
    function(structure) {
      cartoon <- glydraw::draw_cartoon(
        structure,
        orient = "up",
        show_linkage = FALSE
      )
      attr(cartoon, "glydraw_panel_size_px")[["height"]] / 300 * 25.4
    },
    numeric(1)
  ) *
    cartoon_size
  panel_height <- if (is.null(height)) {
    50
  } else if (is.na(height)) {
    50
  } else {
    height
  }
  shrink <- min(1, panel_height * 0.5 / max(cartoon_height))
  cartoon_size <- cartoon_size * shrink
  cartoon_height <- cartoon_height * shrink
  top_gap <- min(2, panel_height * 0.05)
  upper <- max(df$cartoon_y / (1 - (cartoon_height + top_gap) / panel_height))
  p <- .glyvis_plot(
    df,
    "category",
    "value",
    width = width,
    height = height,
    palette = palette,
    ...
  )
  y_scale <- p$scales$get_scales("y")
  y_scale$limits <- c(0, upper)
  y_scale$expand <- expansion(mult = 0)
  p +
    geom_col(
      fill = if (is.null(palette)) glyvis_colors[1] else palette[[1]],
      width = 0.65,
      show.legend = FALSE
    ) +
    glydraw::geom_glycan(
      aes(y = .data$cartoon_y, structure = .data$glycan_structure),
      orient = "up",
      vjust = 0,
      size = cartoon_size,
      show_linkage = FALSE,
      show.legend = FALSE
    ) +
    labs(
      x = "Branch motif",
      y = if (weight == "equal") {
        "Glycan / site-specific glycoform count"
      } else {
        "Pooled abundance"
      }
    ) +
    theme(legend.position = "none")
}

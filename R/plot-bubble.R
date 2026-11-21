#' Bubble plots for glystats test results
#'
#' Plot one row per test with the supplied `-log10(P)` on the horizontal
#' axis. Bubble area represents effect magnitude, and colors indicate positive
#' or negative effects only when the result supplies a signed effect.
#'
#' @param x A result from [glystats::gly_set_test()], [glystats::gly_ttest()],
#'   [glystats::gly_wilcox()], [glystats::gly_anova()], [glystats::gly_kruskal()],
#'   [glystats::gly_ancova()], [glystats::gly_limma()],
#'   [glystats::gly_linear_model()], [glystats::gly_cox()], or
#'   [glystats::gly_cor()]. The plot does not fit a test from an experiment.
#' @param variables Character vector of unique fitted IDs to display, in
#'   top-to-bottom order. Use set IDs for a set test, and variable or sample
#'   IDs for correlation, depending on how it was fit. A correlation pair
#'   is included once if either endpoint matches; it is ordered by the first
#'   matching ID. All terms or contrasts for a selected variable are retained.
#'   `NULL` (the default) displays up to ten rows with the smallest plotted
#'   p-values, preserving input order for ties. Explicit selection is not
#'   limited to ten rows.
#' @param p_col Plot supplied adjusted p-values (`"p_adj"`, the default) or
#'   explicitly request unadjusted p-values (`"p_val"`). If adjusted p-values
#'   were not computed, request `"p_val"`. The plot does not adjust p-values.
#' @param palette Color vector. Unsigned plots use the first color, or the
#'   default glyvis blue. Signed plots accept colors for `"Negative"`,
#'   `"Zero"` and `"Positive"`; an unnamed palette follows this order.
#'   Defaults are orange, glyvis blue, and dark blue, respectively. Missing
#'   effects use the default glyvis blue. All points use alpha 0.3.
#' @inheritParams glyvis_plot_options
#'
#' @section Effects and test rows:
#' - Set test: Mahalanobis distance (unsigned), not member count or covariance rank.
#' - t-test: absolute Cohen's d (paired: absolute d-z), with sign by color.
#' - Wilcoxon: absolute rank-biserial correlation, with sign by color.
#' - ANOVA: eta-squared (paired: partial eta-squared), unsigned.
#' - Kruskal/Friedman: epsilon-squared or Kendall's W, unsigned.
#' - ANCOVA: the main group tests supply no effect magnitude; dots have a
#'   uniform size and no direction. ANOVA, Kruskal and ANCOVA use main tests,
#'   not post-hoc comparisons.
#' - Limma: absolute log2 fold change, or absolute native contrast estimate
#'   for raw or logx analysis. Linear model: absolute estimated coefficient or
#'   contrast, with sign by color for both. Labels identify the respective
#'   contrast or term. Don't compare sizes between differently scaled terms.
#' - Cox: absolute log hazard ratio, with sign by color.
#' - Correlation: absolute correlation coefficient, with sign by color; rows
#'   are tested variable or sample pairs.
#'
#' Results without identifiable row-level p-values (e.g., ROC, untested
#' fold changes, ordination and clustering) are not supported.
#'
#' @section Missing and zero values:
#' Positive p-values are plotted at their exact `-log10(P)` positions. Values
#' reported as zero share a finite display position one unit beyond the largest
#' plotted finite score (or at 1 if there are none). The position is reported
#' in the caption and does not replace the original p-values.
#'
#' The default ranking excludes rows with missing p-values or failed set
#' tests. If no p-value is available, the first ten rows are labeled without
#' bubbles. Explicitly selected rows with unavailable p-values also retain
#' their labels without bubbles. A rank-deficient set is eligible if the test
#' succeeded. With a valid p-value, an open circle marks an unavailable effect,
#' including a negative estimate of an unsigned magnitude (e.g., epsilon-squared).
#' A small filled dot marks zero effect. Empty results raise an error.
#'
#' @returns A composable `tidyplot` object, also inheriting from `ggplot`.
#' @examples
#' if (requireNamespace("glystats", quietly = TRUE)) {
#'   mat <- rbind(
#'     "glycan A" = c(1, 3, 2, 3, 5, 6),
#'     "glycan B" = c(2, 1, 4, 5, 2, 6)
#'   )
#'   colnames(mat) <- paste0("S", 1:6)
#'   exp <- SummarizedExperiment::SummarizedExperiment(
#'     assays = list(abundance = mat),
#'     colData = S4Vectors::DataFrame(group = rep(c("A", "B"), each = 3))
#'   )
#'   fit <- glystats::gly_set_test(
#'     exp,
#'     sets = list(singleton = "glycan A", "two glycans" = rownames(mat)),
#'     log_transform = FALSE
#'   )
#'   plot_bubble(fit, variables = "two glycans", title = "Set-test overview")
#' }
#' @export
plot_bubble <- function(
  x,
  ...,
  variables = NULL,
  p_col = "p_adj",
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
) {
  rlang::check_dots_empty()
  checkmate::assert_choice(p_col, c("p_adj", "p_val"))
  checkmate::assert_character(
    variables,
    min.len = 1,
    any.missing = FALSE,
    unique = TRUE,
    null.ok = TRUE
  )
  checkmate::assert_character(
    palette,
    min.len = 1,
    any.missing = FALSE,
    null.ok = TRUE
  )

  spec <- .bubble_test_data(x, p_col, variables)
  plot_data <- spec$data
  p_available <- plot_data$status == "ok" & !is.na(plot_data$p)
  if (is.null(variables)) {
    ranked <- which(p_available)
    if (length(ranked)) {
      ranked <- ranked[order(plot_data$p[ranked], ranked)]
    } else {
      ranked <- seq_len(nrow(plot_data))
    }
    keep <- sort(utils::head(ranked, 10L))
    plot_data <- plot_data[keep, , drop = FALSE]
    p_available <- p_available[keep]
  }
  score <- rep(NA_real_, nrow(plot_data))
  positive_p <- p_available & plot_data$p > 0
  zero_p <- p_available & plot_data$p == 0
  score[positive_p] <- -log10(plot_data$p[positive_p])
  captions <- character()
  if (any(zero_p)) {
    zero_x <- max(c(0, score[positive_p])) + 1
    score[zero_p] <- zero_x
    captions <- sprintf("Reported P = 0 shown at x = %.6g.", zero_x)
  }
  plot_data$score <- score

  effect_ok <- is.finite(plot_data$effect)
  if (!spec$signed) {
    effect_ok <- effect_ok & plot_data$effect >= 0
  }
  plot_data$magnitude <- ifelse(effect_ok, abs(plot_data$effect), NA_real_)
  size_known <- p_available & effect_ok & plot_data$magnitude > 0
  size_zero <- p_available & effect_ok & plot_data$magnitude == 0
  size_unknown <- p_available & !effect_ok
  if (spec$fixed) {
    captions <- c(captions, "Effect size not supplied; dots have uniform size.")
  } else {
    if (any(size_unknown)) {
      captions <- c(captions, "Open circle: effect size unavailable.")
    }
    if (any(size_zero)) {
      captions <- c(captions, "Small dot: zero effect.")
    }
  }

  default_blue <- glyvis_colors[[1L]]
  group <- NULL
  if (spec$signed) {
    if (any(p_available & effect_ok)) {
      group <- "direction"
    }
    plot_data$direction <- factor(
      ifelse(
        !effect_ok,
        NA_character_,
        ifelse(
          plot_data$effect > 0,
          "Positive",
          ifelse(plot_data$effect < 0, "Negative", "Zero")
        )
      ),
      levels = c("Negative", "Zero", "Positive")
    )
    if (!is.null(group) && is.null(palette)) {
      palette <- c(
        Negative = "#B14A18",
        Zero = default_blue,
        Positive = "#216698"
      )
    }
  }
  if (is.null(group)) {
    palette <- if (is.null(palette)) default_blue else unname(palette[1L])
  }

  display_order <- order(
    plot_data$selection,
    !p_available,
    replace(plot_data$p, !p_available, NA_real_)
  )
  plot_data$row <- factor(seq_len(nrow(plot_data)), levels = rev(display_order))
  labels <- paste0(
    plot_data$label,
    ifelse(
      p_available,
      "",
      ifelse(plot_data$status == "failed", " (test failed)", " (P unavailable)")
    )
  )
  names(labels) <- seq_along(labels)
  p <- .glyvis_plot(
    plot_data,
    "score",
    "row",
    group,
    title = title,
    width = width,
    height = height,
    fontsize = fontsize,
    family = family,
    palette = palette
  ) |>
    tidyplots::adjust_y_axis(labels = labels, drop = FALSE) |>
    tidyplots::adjust_x_axis(
      breaks = if (any(p_available)) ggplot2::waiver() else NULL
    )

  if (spec$fixed) {
    p <- p +
      geom_point(
        data = p$data[p_available, , drop = FALSE],
        size = 2,
        alpha = 0.3
      )
  } else {
    p <- p +
      geom_point(
        data = p$data[size_known, , drop = FALSE],
        aes(size = .data$magnitude),
        alpha = 0.3
      )
    if (any(size_zero)) {
      p <- p +
        geom_point(
          data = p$data[size_zero, , drop = FALSE],
          size = 1.5,
          alpha = 0.3
        )
    }
    if (any(size_unknown)) {
      p <- p +
        geom_point(
          data = p$data[size_unknown, , drop = FALSE],
          aes(x = .data$score, y = .data$row),
          inherit.aes = FALSE,
          colour = default_blue,
          alpha = 0.3,
          size = 2,
          shape = 1
        )
    }
    p <- p +
      scale_size_area(
        max_size = 6,
        name = spec$size_label,
        guide = guide_legend(
          nrow = 2,
          theme = theme(legend.title.position = "top")
        )
      )
  }

  p +
    geom_blank(aes(x = 0, y = .data$row), inherit.aes = FALSE) +
    theme(legend.box = "vertical") +
    labs(
      x = if (p_col == "p_adj") {
        expression(-log[10] ~ italic(P)[adjusted])
      } else {
        expression(-log[10] ~ italic(P)[raw])
      },
      y = spec$axis_label,
      colour = if (!is.null(group)) "Effect sign" else NULL,
      caption = if (length(captions)) paste(captions, collapse = "\n") else NULL
    )
}

#' @rdname plot_bubble
#' @param object A set-test result from [glystats::gly_set_test()].
#' @export
autoplot.glystats_set_test_res <- function(
  object,
  ...,
  variables = NULL,
  p_col = "p_adj",
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
) {
  rlang::check_dots_empty()
  plot_bubble(
    object,
    variables = variables,
    p_col = p_col,
    title = title,
    width = width,
    height = height,
    fontsize = fontsize,
    family = family,
    palette = palette
  )
}

.bubble_test_data <- function(x, p_col, variables) {
  kind <- c(
    "set_test",
    "ttest",
    "wilcox",
    "anova",
    "kruskal",
    "ancova",
    "limma",
    "linear_model",
    "cox",
    "cor"
  )
  supported <- intersect(paste0("glystats_", kind, "_res"), class(x))
  if (length(supported) != 1L) {
    cli::cli_abort(
      "Unsupported result for {.fn plot_bubble}. See {.help [plot_bubble](glyvis::plot_bubble)} for supported glystats tests."
    )
  }
  kind <- kind[match(supported, paste0("glystats_", kind, "_res"))]

  tab <- x$tidy_result
  if (kind == "set_test") {
    tab <- tab$sets
  } else if (kind %in% c("anova", "kruskal", "ancova")) {
    tab <- tab$main_test
  }
  if (!is.data.frame(tab)) {
    cli::cli_abort("Expected a tidy result table for the fitted test.")
  }
  if (nrow(tab) == 0L) {
    cli::cli_abort("The fitted test has no rows to plot.")
  }
  if (!p_col %in% names(tab)) {
    if (p_col == "p_adj") {
      cli::cli_abort(
        "Adjusted p-values are not available. Use {.code p_col = \"p_val\"} to plot raw p-values."
      )
    }
    cli::cli_abort("Raw p-values are not available in the fitted result.")
  }

  ids <- switch(
    kind,
    set_test = "set_id",
    cor = .bubble_pair_columns(x, tab),
    .result_id_column(x, "variable")
  )
  if (!all(ids %in% names(tab))) {
    cli::cli_abort("Fitted result identifiers are missing from the test table.")
  }
  id <- as.character(tab[[ids[1L]]])
  partner <- if (length(ids) == 2L) as.character(tab[[ids[2L]]]) else NULL
  status <- rep("ok", length(id))
  axis_label <- "Variable"
  label <- id
  if (kind == "set_test") {
    axis_label <- "Set"
    if (!"status" %in% names(tab)) {
      cli::cli_abort("The fitted set result has no test status.")
    }
    status <- ifelse(tab$status %in% "ok", "ok", "failed")
  } else if (kind == "cor") {
    axis_label <- if (grepl("sample", ids[1L], fixed = TRUE)) {
      "Sample pair"
    } else {
      "Variable pair"
    }
    label <- paste(id, "|", partner)
  } else if (kind == "linear_model" && "term" %in% names(tab)) {
    label <- paste0(id, " [", tab$term, "]")
  } else if (
    kind == "limma" && all(c("test_group", "ref_group") %in% names(tab))
  ) {
    label <- paste0(id, " [", tab$test_group, " vs ", tab$ref_group, "]")
  }

  selection <- rep(1, length(id))
  keep <- seq_along(id)
  if (!is.null(variables)) {
    unknown <- setdiff(variables, c(id, partner))
    if (length(unknown)) {
      cli::cli_abort("Unknown fitted IDs: {.val {unknown}}.")
    }
    selection <- match(id, variables, nomatch = NA_integer_)
    selection[is.na(selection)] <- Inf
    if (!is.null(partner)) {
      partner_selection <- match(partner, variables, nomatch = NA_integer_)
      partner_selection[is.na(partner_selection)] <- Inf
      selection <- pmin(selection, partner_selection)
    }
    keep <- which(is.finite(selection))
  }
  p <- tab[[p_col]][keep]
  checkmate::assert_numeric(p, lower = 0, upper = 1)

  signed <- kind %in%
    c("ttest", "wilcox", "limma", "linear_model", "cox", "cor")
  native_limma_scale <- isTRUE(
    x$preprocessing$analysis_scale %in% c("raw", "logx")
  )
  effect_col <- switch(
    kind,
    ancova = "effect_size",
    limma = if (
      "estimate" %in%
        names(tab) &&
        (native_limma_scale || !"log2fc" %in% names(tab))
    ) {
      "estimate"
    } else {
      "log2fc"
    },
    linear_model = "estimate",
    cox = "coefficient",
    cor = "cor",
    "effect_size"
  )
  effect <- if (kind != "ancova" && effect_col %in% names(tab)) {
    tab[[effect_col]][keep]
  } else {
    rep(NA_real_, length(keep))
  }
  checkmate::assert_numeric(effect)
  size_label <- switch(
    kind,
    set_test = "Mahalanobis distance",
    ttest = "Absolute Cohen's d",
    wilcox = "Absolute rank-biserial correlation",
    anova = "Eta-squared (partial if paired)",
    kruskal = "Epsilon-squared or Kendall's W",
    limma = if (effect_col == "estimate") {
      "Absolute contrast estimate"
    } else {
      "Absolute log2 fold change"
    },
    linear_model = "Absolute estimate",
    cox = "Absolute log hazard ratio",
    cor = "Absolute correlation"
  )
  list(
    data = tibble::tibble(
      id = id[keep],
      label = label[keep],
      selection = selection[keep],
      partner = if (is.null(partner)) NA_character_ else partner[keep],
      status = status[keep],
      p = p,
      effect = effect
    ),
    fixed = kind == "ancova",
    signed = signed,
    axis_label = axis_label,
    size_label = size_label
  )
}

.bubble_pair_columns <- function(x, tab) {
  variables <- paste0(.result_id_column(x, "variable"), 1:2)
  samples <- paste0(.result_id_column(x, "sample"), 1:2)
  if (all(variables %in% names(tab))) {
    variables
  } else if (all(samples %in% names(tab))) {
    samples
  } else {
    cli::cli_abort(
      "Fitted correlation endpoints are missing from the test table."
    )
  }
}

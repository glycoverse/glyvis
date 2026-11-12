#' Boxplot
#'
#' Draw a boxplot.
#' Currently supported data types:
#' - `SummarizedExperiment`: A [glyexp::GlycomicSE()],
#'   [glyexp::GlycoproteomicSE()], or other compatible container.
#'   Expression values are plotted, grouped by the group column, with
#'   scale-aware log transformation controlled by `log_transform`.
#'
#' @param x An object to be plotted.
#' @param points Whether to show observations as jittered points. Boxes show
#'   medians and quartiles with 1.5-IQR whiskers. Outliers are drawn separately
#'   only when `points = FALSE`.
#' @param ncol Number of facet columns. `NULL` chooses up to three columns.
#' @param label_width Width used to wrap facet labels without truncation.
#' @param scales Facet axis scales, passed to [ggplot2::facet_wrap()]. Defaults
#'   to `"free_y"`; use `"fixed"` for comparisons across facets.
#' @inheritParams glyvis_plot_options
#' @inheritParams glyvis_abundance_scale
#' @seealso [glyvis_abundance_scale] for scale metadata and compatibility rules.
#'
#' @returns A `tidyplot` object, also inheriting from `ggplot`.
#' @export
plot_boxplot <- function(
  x,
  ...,
  group_col = "group",
  ncol = NULL,
  label_width = 24,
  scales = "free_y",
  log_transform = NULL,
  points = TRUE,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL,
  variables = NULL
) {
  rlang::check_dots_empty()
  UseMethod("plot_boxplot")
}

#' @rdname plot_boxplot
#' @param group_col A character string specifying the column name in sample information
#'   that contains group labels. Default is "group".
#' @export
plot_boxplot.glyexp_experiment <- function(
  x,
  ...,
  group_col = "group",
  ncol = NULL,
  label_width = 24,
  scales = "free_y",
  log_transform = NULL,
  points = TRUE,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
) {
  rlang::check_dots_empty()
  .plot_exp_boxplot(
    x,
    group_col,
    ...,
    title = title,
    width = width,
    height = height,
    fontsize = fontsize,
    family = family,
    palette = palette,
    points = points,
    ncol = ncol,
    label_width = label_width,
    scales = scales,
    log_transform = log_transform
  )
}

#' @rdname plot_boxplot
#' @param variables A character vector of row names to plot from a
#'   `SummarizedExperiment`. `NULL` (the default) plots all rows. Names must
#'   exist in `rownames(x)`. Matching rows retain their original order;
#'   repeated names in `variables` do not repeat rows. The 25-variable limit
#'   applies after selection.
#' @export
plot_boxplot.SummarizedExperiment <- function(
  x,
  ...,
  group_col = "group",
  ncol = NULL,
  label_width = 24,
  scales = "free_y",
  log_transform = NULL,
  variables = NULL,
  points = TRUE,
  title = NULL,
  width = NULL,
  height = NULL,
  fontsize = 9,
  family = "sans",
  palette = NULL
) {
  rlang::check_dots_empty()
  if (!is.null(variables)) {
    checkmate::assert_character(variables, any.missing = FALSE, min.len = 1L)
    missing_variables <- setdiff(variables, rownames(x))
    if (length(missing_variables) > 0L) {
      cli::cli_abort(
        "Can't find variables in row names: {.val {missing_variables}}."
      )
    }
    x <- x[rownames(x) %in% variables, , drop = FALSE]
  }
  .plot_exp_boxplot(
    x,
    group_col,
    ...,
    title = title,
    width = width,
    height = height,
    fontsize = fontsize,
    family = family,
    palette = palette,
    points = points,
    ncol = ncol,
    label_width = label_width,
    scales = scales,
    log_transform = log_transform
  )
}

#' Internal function to plot boxplot
#' @param exp A `glyexp_experiment` object.
#' @param group_col A character string specifying the column name in sample information
#'   that contains group labels. Default is "group".
#' @inheritParams glyvis_plot_options
#' @noRd
.plot_exp_boxplot <- function(
  exp,
  group_col,
  ncol = NULL,
  label_width = 24,
  scales = "free_y",
  ...,
  log_transform = NULL
) {
  # We don't want to plot too many variables.
  if (nrow(exp) > 25) {
    cli::cli_abort(c(
      "The number of variables must be less than or equal to 25 for boxplot.",
      "x" = "Current number of variables: {.val {nrow(exp)}}",
      "i" = "Consider filtering variables with conditions or using heatmap."
    ))
  }

  # Check if the group column is in the sample information tibble.
  is_se <- methods::is(exp, "SummarizedExperiment")
  sample_info <- if (is_se) {
    SummarizedExperiment::colData(exp)
  } else {
    .get_sample_info(exp)
  }
  if (!group_col %in% colnames(sample_info)) {
    cli::cli_abort(c(
      "Can't find column {.field {group_col}} in the sample information tibble.",
      "i" = "Available columns: {.field {colnames(sample_info)}}"
    ))
  }

  transformation <- .resolve_plot_transformation(exp, log_transform)
  df <- .fortify_experiment(exp)
  variable_col <- if (is_se) ".variable" else "variable"
  if (is_se) {
    # Select from colData before fortification repairs annotation collisions.
    plot_group <- make.unique(c(names(df), ".plot_group"))[[ncol(df) + 1L]]
    df[[plot_group]] <- rep(sample_info[[group_col]], times = nrow(exp))
    group_col <- plot_group
  }
  if (transformation$log_transform) {
    df$value <- log2(df$value + 1e-6)
  }

  if (is.null(ncol)) {
    ncol <- min(3L, ceiling(sqrt(nrow(exp))))
  }
  checkmate::assert_count(label_width, positive = TRUE)
  .glyvis_boxplot(df, x = group_col, value = "value", group = group_col, ...) +
    labs(x = "Group", y = .abundance_label(transformation, boxplot = TRUE)) +
    facet_wrap(
      vars(!!rlang::sym(variable_col)),
      scales = scales,
      ncol = ncol,
      labeller = as_labeller(function(x) .glyvis_wrap(x, label_width))
    )
}

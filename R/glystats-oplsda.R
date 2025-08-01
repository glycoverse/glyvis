#' Plots for OPLS-DA
#'
#' Visualization for results from [glystats::gly_oplsda()] (`glystats_oplsda_res` object).
#' Possible `type`s of plots:
#' - "scores" (default): Plot scores for samples.
#' - "loadings": Plot loadings for variables.
#' - "vip": Plot VIP scores for variables.
#' - "variance": Plot explained variance for each component.
#' - "s-plot": Plot the correlation between p1 and pcorr1.
#'
#' @param object A `glystats_oplsda_res` object.
#' @param type The type of plot, one of "loadings", "scores", "vip", "variance", or "s-plot". Defaults to "scores".
#' @param y_type What to plot on the y-axis when `type` is "scores" or "loadings". Either "p2" or "o1". Defaults to "o1".
#' @param groups A factor or character vector specifying group membership for each sample.
#'   If provided, the plot will be colored by group.
#'   Only applicable to "scores" and "loadings" types.
#' @param group_col A character string specifying where to find the group information.
#'   If you uses [glystats::gly_oplsda()] on a [glyexp::experiment()] to get the result,
#'   sample information has already been added to the result.
#'   In this case, you can specify the column name in the sample information tibble
#'   to be used for coloring.
#'   If not provided, this function will try "group".
#' @param ... Ignored.
#'
#' @returns A ggplot object.
#' @export
autoplot.glystats_oplsda_res <- function(object, type = "scores", y_type = "o1", groups = NULL, group_col = NULL, ...) {
  checkmate::assert_choice(type, c("loadings", "scores", "vip", "variance", "s-plot"))
  checkmate::assert_choice(y_type, c("p2", "o1"))
  .validate_group_args(groups, group_col)

  # The `samples` tibble of `gly_oplsda()` has similar structure as `gly_pca()`,
  # so we can reuse the same group extractor.
  groups <- .prepare_groups(object, groups, group_col)

  switch(
    type,
    scores = .plot_oplsda_scores(object, y_type, groups),
    loadings = .plot_oplsda_loadings(object, y_type),
    vip = .plot_oplsda_vip(object),
    variance = .plot_oplsda_variance(object),
    "s-plot" = .plot_oplsda_splot(object)
  )
}

.plot_oplsda_scores <- function(object, y_type, groups) {
  switch(
    y_type,
    p2 = .plot_oplsda_scores_p1vp2(object$tidy_result$samples, "sample", groups),
    o1 = .plot_oplsda_scores_p1vo1(object$tidy_result$samples, "sample", groups)
  )
}

.plot_oplsda_loadings <- function(object, y_type) {
  switch(
    y_type,
    p2 = .plot_oplsda_loadings_p1vp2(object$tidy_result$variables, "variable"),
    o1 = .plot_oplsda_loadings_p1vo1(object$tidy_result$variables, "variable")
  )
}

.plot_oplsda_vip <- function(object) {
  .glyvis_barplot(object$tidy_result$vip, "variable", "vip", ordered = TRUE) +
    labs(x = "Variable", y = "VIP score")
}

.plot_oplsda_variance <- function(object) {
  .glyvis_barplot(object$tidy_result$variance, "component", "prop_var_explained", ordered = TRUE) +
    labs(x = "Component", y = "Proportion of variance explained")
}

.plot_oplsda_splot <- function(object) {
  df <- object$tidy_result$variables %>%
    dplyr::mutate(color = dplyr::case_when(
      .data$pcorr1 > 0.5 ~ glyvis_colors[[6]],
      .data$pcorr1 < -0.5 ~ glyvis_colors[[1]],
      TRUE ~ "lightgrey"
    ))
  ggplot(df, aes(.data$p1, .data$pcorr1)) +
    geom_point(aes(color = .data$color)) +
    scale_color_identity() +
    ggrepel::geom_label_repel(aes(label = .data$variable)) +
    geom_hline(yintercept = c(-0.5, 0.5), linetype = "dashed", alpha = 0.7) +
    theme_bw() +
    labs(x = "Predictive component 1 (p1)", y = "Correlation with p1")
}

.assert_oplsda_o1_exist <- function(df) {
  if (!"o1" %in% colnames(df)) {
    cli::cli_abort(c(
      "Can't find orthogonal component scores (o1) in the result.",
      "i" = "This happens when you set `ortho_i` to 0, or to NA and the model didn't benefit from orthogonal components."
    ))
  }
}

.assert_oplsda_p2_exist <- function(df) {
  if (!"p2" %in% colnames(df)) {
    cli::cli_abort(c(
      "Can't find predictive component scores (p2) in the result.",
      "i" = "Did you forget to set {.arg pred_i} to 2 or higher in {.fn glystats::gly_oplsda}?"
    ))
  }
}

.plot_oplsda_scores_p1vo1 <- function(df, label_col, groups) {
  .assert_oplsda_o1_exist(df)
  if (!is.null(groups)) {
    df$group <- groups
  }
  .glyvis_scatter(df, "p1", "o1", label = label_col, group = "group", add_ellipse = TRUE)
}

.plot_oplsda_scores_p1vp2 <- function(df, label_col, groups) {
  .assert_oplsda_p2_exist(df)
  if (!is.null(groups)) {
    df$group <- groups
  }
  .glyvis_scatter(df, "p1", "p2", label = label_col, group = "group", add_ellipse = TRUE)
}

.plot_oplsda_loadings_p1vo1 <- function(df, label_col) {
  .assert_oplsda_o1_exist(df)
  .glyvis_loadings(df, "p1", "o1", label = label_col)
}

.plot_oplsda_loadings_p1vp2 <- function(df, label_col) {
  .assert_oplsda_p2_exist(df)
  .glyvis_loadings(df, "p1", "p2", label = label_col)
}
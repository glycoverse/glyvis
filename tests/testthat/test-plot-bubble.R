bubble_fixture <- function(kind, table, identifiers = NULL, scale = NULL) {
  tidy <- switch(
    kind,
    set_test = list(sets = table),
    anova = ,
    ancova = ,
    kruskal = list(main_test = table),
    table
  )
  structure(
    list(
      tidy_result = tidy,
      identifiers = identifiers,
      preprocessing = list(analysis_scale = scale)
    ),
    class = c(paste0("glystats_", kind, "_res"), "glystats_res")
  )
}

test_that("set bubbles use original p-values and unsigned Mahalanobis effects", {
  sets <- tibble::tibble(
    set_id = c(
      "rank #1",
      "A: singleton",
      "failed",
      "no adjusted value",
      "zero"
    ),
    status = c("ok", "ok", "failed", "ok", "ok"),
    n_variables = c(8L, 1L, 9L, 1L, 3L),
    test_dimension = c(1L, 1L, 2L, 1L, 2L),
    p_adj = c(0.001, 0.05, NA_real_, NA_real_, 0),
    p_val = c(0.0005, 0.025, NA_real_, 0.01, 0),
    effect_size = c(2, 4, NA_real_, 7, 1)
  )
  fit <- bubble_fixture("set_test", sets)
  p <- autoplot(fit, title = "Overview", width = 80, height = 60, fontsize = 11)
  expect_s3_class(p, "tidyplot")
  expect_equal(p$tidyplot$width, 80)
  expect_equal(p$tidyplot$height, 60)
  expect_equal(p$labels$title, "Overview")
  expect_equal(p$data$p, sets$p_adj)
  expect_equal(p$data$effect, sets$effect_size)
  expect_equal(p$data$score, c(3, -log10(0.05), NA, NA, 4))
  expect_match(p$labels$caption, "Reported P = 0 shown at x = 4", fixed = TRUE)
  b <- ggplot2::ggplot_build(p)
  expect_equal(b$data[[1]]$x, c(3, -log10(0.05), 4))
  expect_length(unique(b$data[[1]]$colour), 1L)
  expect_equal(unname(b$data[[1]]$size^2 / b$data[[1]]$size[3]^2), c(2, 4, 1))
  expect_equal(
    as.character(b$layout$panel_params[[1]]$y$get_labels()),
    c(
      "no adjusted value (P unavailable)",
      "failed (test failed)",
      "A: singleton",
      "rank #1",
      "zero"
    )
  )
  expect_length(
    ggplot2::ggplot_build(p + ggplot2::geom_vline(xintercept = 2))$data,
    3
  )
  filtered <- plot_bubble(fit, variables = c("A: singleton", "rank #1"))
  expect_equal(
    as.character(ggplot2::ggplot_build(filtered)$layout$panel_params[[
      1
    ]]$y$get_labels()),
    c("rank #1", "A: singleton")
  )
  expect_error(plot_bubble(fit, variables = "not fitted"), "Unknown fitted IDs")
  expect_error(
    plot_bubble(fit, variables = c("rank #1", "rank #1")),
    "duplicated"
  )
  expect_error(
    plot_bubble(bubble_fixture("set_test", sets[0, ])),
    "has no rows"
  )
  expect_error(plot_bubble(fit, p_col = "p"), "p_adj")
})

test_that("raw, unavailable and extreme p-values do not invent significance", {
  table <- tibble::tibble(
    variable = c("largest", "subnormal", "zero", "unknown"),
    p_val = c(1, .Machine$double.xmin / 2, 0, NA_real_),
    effect_size = c(0, -1, 2, 3)
  )
  fit <- bubble_fixture("ttest", table)
  expect_error(plot_bubble(fit), 'Use `p_col = "p_val"`')
  p <- plot_bubble(fit, p_col = "p_val")
  expect_equal(
    p$data$score,
    c(0, -log10(table$p_val[2]), -log10(table$p_val[2]) + 1, NA)
  )
  expect_match(paste(deparse(p$labels$x), collapse = ""), "raw")
  expect_match(p$labels$caption, "Small dot: zero effect", fixed = TRUE)
  expect_equal(p$data$magnitude, c(0, 1, 2, 3))
  expect_equal(
    as.character(p$data$direction),
    c("Zero", "Negative", "Positive", "Positive")
  )
  expect_equal(
    ggplot2::ggplot_build(p)$data[[1]]$colour,
    c("#B14A18", "#216698")
  )

  missing_only <- plot_bubble(fit, p_col = "p_val", variables = "unknown")
  expect_no_warning(ggplot2::ggplot_build(missing_only))
  expect_equal(
    as.character(ggplot2::ggplot_build(missing_only)$layout$panel_params[[
      1
    ]]$y$get_labels()),
    "unknown (P unavailable)"
  )
  fit$tidy_result$p_val[1] <- -0.1
  expect_error(plot_bubble(fit, p_col = "p_val"), ">= 0", fixed = TRUE)
})

test_that("supplied effects, unavailable effects and unsigned effects stay distinct", {
  tbl <- tibble::tibble(variable = c("x", "y"), p_adj = c(.03, .08))
  fits <- list(
    wilcox = dplyr::mutate(tbl, effect_size = c(-0.25, 0.5)),
    cox = dplyr::mutate(tbl, coefficient = c(-0.3, 0.4), hr = c(.74, 1.49)),
    anova = dplyr::mutate(tbl, effect_size = c(.1, .5)),
    kruskal = dplyr::mutate(tbl, effect_size = c(-.02, .5)),
    ancova = dplyr::mutate(tbl, statistic = c(15, 20))
  )
  for (kind in names(fits)) {
    p <- plot_bubble(bubble_fixture(kind, fits[[kind]]))
    expect_equal(p$data$p, tbl$p_adj)
    expect_no_warning(ggplot2::ggplot_build(p))
  }
  k <- plot_bubble(bubble_fixture("kruskal", fits$kruskal))
  expect_equal(k$data$effect, c(-.02, .5))
  expect_equal(k$data$magnitude, c(NA, .5))
  expect_null(k$labels$colour)
  expect_match(k$labels$caption, "Open circle", fixed = TRUE)
  expect_equal(ggplot2::ggplot_build(k)$data[[2]]$shape, 1)
  a <- plot_bubble(bubble_fixture("ancova", fits$ancova))
  expect_equal(ggplot2::ggplot_build(a)$data[[1]]$size, c(2, 2))
  expect_null(a$scales$get_scales("size"))
  expect_match(a$labels$caption, "uniform size", fixed = TRUE)
})

test_that("variable selection preserves model contexts and correlation endpoints", {
  model <- tibble::tibble(
    .variable = c("measured #1", "reserve", "measured #1"),
    variable = c("metadata", "metadata", "metadata"),
    term = c("term 2", "term 1", "term 1"),
    p_adj = c(.2, .3, .1),
    estimate = c(-3, 1, 2)
  )
  ids <- list(columns = c(variable = ".variable", sample = ".sample"))
  p <- plot_bubble(
    bubble_fixture("linear_model", model, ids),
    variables = "measured #1"
  )
  expect_equal(p$data$label, c("measured #1 [term 2]", "measured #1 [term 1]"))
  expect_equal(p$data$effect, c(-3, 2))
  limma <- dplyr::mutate(
    model,
    test_group = term,
    ref_group = "reference",
    log2fc = c(NA_real_, NA, NA)
  )
  p <- plot_bubble(
    bubble_fixture("limma", limma, ids, scale = "raw"),
    variables = "measured #1"
  )
  expect_equal(p$data$effect, c(-3, 2))
  expect_equal(
    p$data$label,
    c(
      "measured #1 [term 2 vs reference]",
      "measured #1 [term 1 vs reference]"
    )
  )

  pairs <- tibble::tibble(
    .sample1 = c("s1", "s2", "s3"),
    .sample2 = c("s2", "s3", "s4"),
    p_adj = c(.1, .2, .03),
    cor = c(.5, -.4, .8)
  )
  p <- plot_bubble(bubble_fixture("cor", pairs, ids), variables = c("s2", "s3"))
  expect_equal(p$data$label, c("s1 | s2", "s2 | s3", "s3 | s4"))
  expect_equal(p$data$selection, c(1, 1, 2))
  expect_equal(p$labels$y, "Sample pair")
  expect_equal(p$data$magnitude, c(.5, .4, .8))
  expect_error(
    plot_bubble(bubble_fixture("roc", model)),
    "Unsupported result"
  )
})

test_that("actual glystats set results plot overlapping sets without recomputation", {
  skip_if_not_installed("glystats")
  mat <- rbind(
    "glycan A" = c(1, 3, 2, 3, 5, 6),
    "glycan B" = c(2, 1, 4, 5, 2, 6)
  )
  colnames(mat) <- paste0("S", 1:6)
  se <- SummarizedExperiment::SummarizedExperiment(
    assays = list(abundance = mat),
    colData = S4Vectors::DataFrame(group = rep(c("A", "B"), each = 3))
  )
  fit <- glystats::gly_set_test(
    se,
    sets = list(singleton = "glycan A", "two glycans" = rownames(mat)),
    log_transform = FALSE
  )
  p <- plot_bubble(fit)
  expect_equal(p$data$id, fit$tidy_result$sets$set_id)
  expect_equal(p$data$p, fit$tidy_result$sets$p_adj)
  expect_equal(p$data$magnitude, fit$tidy_result$sets$effect_size)
  expect_no_warning(ggplot2::ggplot_build(p))
})

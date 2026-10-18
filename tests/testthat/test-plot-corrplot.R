test_that("expanded correlation layouts preserve spacer and feature labels", {
  skip_if_not_installed("GGally")
  labels <- c("A B", "A-B", "C")
  r <- diag(3)
  dimnames(r) <- list(labels, labels)
  x <- structure(list(raw_result = list(r = r)), class = "glystats_cor_res")
  for (spacing in c(1, 3)) {
    p <- plot_corrplot(x, layout.exp = spacing, label = TRUE)
    diagonal <- tail(p$layers, 1)[[1]]$data
    expect_equal(diagonal$diagLabel, c(rep(NA_character_, spacing), labels))
    expect_s3_class(ggplot2::ggplot_build(p), "ggplot_built")
  }
})

test_that("correlation plots preserve coefficients and forward label options", {
  skip_if_not_installed("GGally")
  r <- matrix(
    c(1, 0.2, -0.4, 0.2, 1, 0.6, -0.4, 0.6, 1),
    3,
    dimnames = list(c("A B", "A-B", "C"), c("A B", "A-B", "C"))
  )
  x <- structure(list(raw_result = list(r = r)), class = "glystats_cor_res")
  p <- plot_corrplot(x)
  expect_equal(sort(p$data$coefficient), sort(r[lower.tri(r)]))
  expect_equal(tail(p$layers, 1)[[1]]$data$diagLabel, colnames(r))
  expect_length(plot_corrplot(x, label = TRUE)$layers, length(p$layers) + 1)
  expect_equal(autoplot(x)$data, p$data)
  for (container in list(
    legacy_toy_experiment(),
    SummarizedExperiment::SummarizedExperiment()
  )) {
    local_mocked_bindings(gly_cor = function(...) x, .package = "glystats")
    expect_length(
      plot_corrplot(container, label = TRUE)$layers,
      length(p$layers) + 1
    )
  }
})

skip_on_ci()
skip_on_cran()
skip_if_not_installed("Hmisc")

test_that("plot_corrplot retains correlations with non-syntactic feature names", {
  cor_res <- suppressMessages(
    glystats::gly_cor(subset_test_gp_se(variables = seq_len(5)))
  )

  plot_data <- ggplot2::ggplot_build(plot_corrplot(cor_res))$data[[1]]

  expect_gt(nrow(plot_data), 0)
})

test_that("plot_corrplot works for SummarizedExperiment with default parameters", {
  vdiffr::expect_doppelganger(
    "plot_corrplot",
    suppressMessages(plot_corrplot(
      subset_test_gp_se(variables = seq_len(5))
    ))
  )
})

test_that("plot_corrplot works for SummarizedExperiment with on = 'sample'", {
  vdiffr::expect_doppelganger(
    "plot_corrplot_sample",
    suppressMessages(plot_corrplot(
      subset_test_gp_se(variables = seq_len(5)),
      stats_args = list(on = "sample")
    ))
  )
})

test_that("plot_corrplot works for glystats_cor_res with default parameters", {
  suppressMessages(
    cor_res <- glystats::gly_cor(subset_test_gp_se(variables = seq_len(5)))
  )
  vdiffr::expect_doppelganger(
    "plot_corrplot_cor_res",
    plot_corrplot(cor_res)
  )
})

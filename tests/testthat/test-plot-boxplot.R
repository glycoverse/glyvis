test_that("boxplots show log2 abundance plus one", {
  x <- legacy_toy_experiment()
  x$expr_mat[1, 1] <- 0
  p <- plot_boxplot(x)
  expect_equal(p$data$value, log2(as.vector(t(x$expr_mat)) + 1))
  se <- SummarizedExperiment::SummarizedExperiment(
    assays = list(abundance = x$expr_mat),
    colData = S4Vectors::DataFrame(group = x$sample_info$group)
  )
  expect_equal(plot_boxplot(se)$data$value, p$data$value)
})

skip_on_ci()
skip_on_cran()

test_that("plot_boxplot works", {
  vdiffr::expect_doppelganger(
    "plot_boxplot",
    plot_boxplot(legacy_toy_experiment())
  )
})

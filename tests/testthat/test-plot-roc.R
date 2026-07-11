skip_on_ci()
skip_on_cran()

test_that("plot_roc works for SummarizedExperiment with default parameters", {
  exp <- subset_test_gp_se(variables = seq_len(10), groups = c("H", "C"))
  vdiffr::expect_doppelganger(
    "plot_roc",
    suppressMessages(plot_roc(exp))
  )
})

test_that("plot_roc works for glystats_roc_res with default parameters", {
  exp <- subset_test_gp_se(variables = seq_len(10), groups = c("H", "C"))
  suppressMessages(roc_res <- glystats::gly_roc(exp))
  vdiffr::expect_doppelganger("plot_roc_roc_res", plot_roc(roc_res))
})

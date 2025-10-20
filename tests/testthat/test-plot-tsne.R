skip_on_ci()
skip_on_cran()
skip_if_not_installed("Rtsne")

test_that("plot_tsne works for glyexp_experiment", {
  skip("Waiting for stats_args parameter to be implemented")
  vdiffr::expect_doppelganger(
    "plot_tsne",
    suppressMessages(plot_tsne(test_gp_exp))
  )
})

test_that("plot_tsne works for glystats_tsne_res", {
  set.seed(123)
  vdiffr::expect_doppelganger(
    "plot_tsne_tsne_res",
    suppressMessages(plot_tsne(glystats::gly_tsne(test_gp_exp, perplexity = 3)))
  )
})
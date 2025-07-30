skip_on_ci()
skip_on_cran()
skip_if_not_installed("Rtsne")

test_that("plot_tsne works correctly", {
  vdiffr::expect_doppelganger(
    "plot_tsne",
    suppressMessages(plot_tsne(test_gp_exp, perplexity = 3))
  )
})
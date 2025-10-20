skip_on_ci()
skip_on_cran()
skip_if_not_installed("uwot")

test_that("plot_umap works correctly", {
  skip("Waiting for stats_args parameter to be implemented")
  vdiffr::expect_doppelganger(
    "plot_umap",
    suppressMessages(plot_umap(test_gp_exp, n_neighbors = 3))
  )
})
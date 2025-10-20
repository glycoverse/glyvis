skip_on_ci()
skip_on_cran()
skip_if_not_installed("uwot")

test_that("plot_umap works for glyexp_experiment", {
  skip("Waiting for stats_args parameter to be implemented")
  vdiffr::expect_doppelganger(
    "plot_umap",
    suppressMessages(plot_umap(test_gp_exp, n_neighbors = 3))
  )
})

test_that("plot_umap works for glystats_umap_res", {
  set.seed(123)
  vdiffr::expect_doppelganger(
    "plot_umap_umap_res",
    suppressMessages(plot_umap(glystats::gly_umap(test_gp_exp, n_neighbors = 3)))
  )
})
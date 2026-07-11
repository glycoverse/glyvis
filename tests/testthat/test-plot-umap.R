skip_on_ci()
skip_on_cran()
skip_if_not_installed("uwot")

test_that("plot_umap works for SummarizedExperiment", {
  set.seed(123)
  vdiffr::expect_doppelganger(
    "plot_umap",
    suppressMessages(plot_umap(test_gp_se, stats_args = list(n_neighbors = 3)))
  )
})

test_that("plot_umap works for glystats_umap_res", {
  set.seed(123)
  vdiffr::expect_doppelganger(
    "plot_umap_umap_res",
    suppressMessages(plot_umap(glystats::gly_umap(
      test_gp_se,
      n_neighbors = 3
    )))
  )
})

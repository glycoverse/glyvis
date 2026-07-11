skip_on_ci()
skip_on_cran()
skip_if_not_installed("uwot")

test_that("autoplot works for glystats umap results", {
  set.seed(123)
  suppressMessages(
    umap_res <- glystats::gly_umap(test_gp_se, n_neighbors = 3)
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_umap_res",
    autoplot(umap_res)
  )
})

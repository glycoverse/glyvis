skip_on_ci()
skip_on_cran()

test_that("plot_pca works for glyexp_experiment with default parameters", {
  vdiffr::expect_doppelganger(
    "plot_pca",
    plot_pca(test_gp_exp)
  )
})

test_that("plot_pca works for glystats_pca_res with default parameters", {
  vdiffr::expect_doppelganger(
    "plot_pca_pca_res",
    plot_pca(glystats::gly_pca(test_gp_exp))
  )
})
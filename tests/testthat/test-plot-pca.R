skip_on_ci()
skip_on_cran()

test_that("plot_pca works with default parameters", {
  vdiffr::expect_doppelganger(
    "plot_pca",
    plot_pca(test_gp_exp)
  )
})

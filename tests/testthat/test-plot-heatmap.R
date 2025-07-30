skip_on_ci()
skip_on_cran()

test_that("plot_heatmap works with default parameters", {
  vdiffr::expect_doppelganger(
    "plot_heatmap",
    plot_heatmap(test_gp_exp)
  )
})

skip_on_ci()
skip_on_cran()

test_that("autoplot for glyexp_experiment", {
  x <- glyexp::toy_experiment

  vdiffr::expect_doppelganger(
    "autoplot.glyexp_experiment.boxplot",
    autoplot(x, type = "boxplot")
  )

  vdiffr::expect_doppelganger(
    "autoplot.glyexp_experiment.heatmap",
    autoplot(x, type = "heatmap")
  )
})

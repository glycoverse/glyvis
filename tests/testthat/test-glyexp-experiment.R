test_that("autoplot for glyexp_experiment", {
  x <- glyexp::toy_experiment()

  vdiffr::expect_doppelganger(
    "autoplot.glyexp_experiment.barplot",
    autoplot(x, type = "barplot")
  )

  vdiffr::expect_doppelganger(
    "autoplot.glyexp_experiment.heatmap",
    autoplot(x, type = "heatmap")
  )
})

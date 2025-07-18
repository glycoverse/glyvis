test_that("autoplot for glyrepr_experiment", {
  x <- glyexp::toy_experiment()

  vdiffr::expect_doppelganger(
    "autoplot.glyrepr_experiment.barplot",
    autoplot(x, type = "barplot")
  )

  vdiffr::expect_doppelganger(
    "autoplot.glyrepr_experiment.heatmap",
    autoplot(x, type = "heatmap")
  )
})

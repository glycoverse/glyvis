test_that("plot_boxplot works", {
  vdiffr::expect_doppelganger(
    "plot_boxplot",
    plot_boxplot(glyexp::toy_experiment)
  )
})
skip_on_ci()
skip_on_cran()

test_that("plot_boxplot works", {
  vdiffr::expect_doppelganger(
    "plot_boxplot",
    plot_boxplot(glyexp::toy_experiment)
  )
})
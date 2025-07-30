skip_on_ci()
skip_on_cran()
skip_if_not_installed("Hmisc")

test_that("plot_corrplot works with default parameters", {
  vdiffr::expect_doppelganger(
    "plot_corrplot",
    suppressMessages(plot_corrplot(test_gp_exp |> glyexp::slice_head_var(n = 5)))
  )
})

test_that("plot_corrplot works with on = 'sample'", {
  vdiffr::expect_doppelganger(
    "plot_corrplot_sample",
    suppressMessages(plot_corrplot(test_gp_exp |> glyexp::slice_head_var(n = 5), on = "sample"))
  )
})

skip_on_ci()
skip_on_cran()

test_that("plot_roc works with default parameters", {
  vdiffr::expect_doppelganger(
    "plot_roc",
    test_gp_exp |>
      glyexp::slice_head_var(n = 10) |>
      glyexp::filter_obs(group %in% c("H", "C")) |>
      plot_roc()
  )
})
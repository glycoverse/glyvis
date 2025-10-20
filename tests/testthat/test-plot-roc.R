skip_on_ci()
skip_on_cran()

test_that("plot_roc works for glyexp_experiment with default parameters", {
  vdiffr::expect_doppelganger(
    "plot_roc",
    test_gp_exp |>
      glyexp::slice_head_var(n = 10) |>
      glyexp::filter_obs(group %in% c("H", "C")) |>
      plot_roc()
  )
})

test_that("plot_roc works for glystats_roc_res with default parameters", {
  vdiffr::expect_doppelganger(
    "plot_roc_roc_res",
    test_gp_exp |>
      glyexp::slice_head_var(n = 10) |>
      glyexp::filter_obs(group %in% c("H", "C")) |>
      glystats::gly_roc() |>
      plot_roc()
  )
})
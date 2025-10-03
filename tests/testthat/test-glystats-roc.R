skip_on_ci()
skip_on_cran()
skip_if_not_installed("pROC")

test_that("autoplot works for glystats roc results", {
  suppressMessages(
    roc_res <- test_gp_exp |>
      glyexp::mutate_obs(group = dplyr::if_else(group %in% c("H", "M"), "control", "case")) |>
      glystats::gly_roc()
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_roc_res",
    autoplot(roc_res)
  )
})

test_that("autoplot works for glystats roc results with type = 'roc'", {
  suppressMessages(
    roc_res <- test_gp_exp |>
      glyexp::slice_head_var(n = 10) |>
      glyexp::mutate_obs(group = dplyr::if_else(group %in% c("H", "C"), "control", "case")) |>
      glystats::gly_roc()
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_roc_res with type = 'roc'",
    autoplot(roc_res, type = "roc")
  )
})
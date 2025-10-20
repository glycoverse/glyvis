skip_on_ci()
skip_on_cran()

test_that("plot_roc works for glyexp_experiment with default parameters", {
  exp <- test_gp_exp |>
    glyexp::slice_head_var(n = 10) |>
    glyexp::filter_obs(group %in% c("H", "C"))
  vdiffr::expect_doppelganger(
    "plot_roc",
    suppressMessages(plot_roc(exp))
  )
})

test_that("plot_roc works for glystats_roc_res with default parameters", {
  exp <- test_gp_exp |>
    glyexp::slice_head_var(n = 10) |>
    glyexp::filter_obs(group %in% c("H", "C"))
  suppressMessages(roc_res <- glystats::gly_roc(exp))
  vdiffr::expect_doppelganger("plot_roc_roc_res", plot_roc(roc_res))
})
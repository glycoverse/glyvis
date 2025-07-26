skip_on_ci()
skip_on_cran()

test_that("autoplot works for glystats cor results", {
  skip_if_not_installed("Hmisc")
  suppressMessages(
    cor_res <- test_gp_exp |>
      glyexp::slice_sample_var(n = 5) |>
      glystats::gly_cor()
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_cor_res",
    autoplot(cor_res)
  )
})
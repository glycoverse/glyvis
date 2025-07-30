skip_on_ci()
skip_on_cran()
skip_if_not_installed("WGCNA")

test_that("autoplot works for glystats wgcna results", {
  suppressWarnings(suppressMessages(
    wgcna_res <- glystats::gly_wgcna(test_gp_exp)
  ))
  vdiffr::expect_doppelganger(
    "autoplot.glystats_wgcna_res",
    autoplot(wgcna_res)
  )
})

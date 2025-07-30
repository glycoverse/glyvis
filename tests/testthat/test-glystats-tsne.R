skip_on_ci()
skip_on_cran()
skip_if_not_installed("Rtsne")

test_that("autoplot works for glystats tsne results", {
  suppressWarnings(suppressMessages(
    tsne_res <- glystats::gly_tsne(test_gp_exp)
  ))
  vdiffr::expect_doppelganger(
    "autoplot.glystats_tsne_res",
    autoplot(tsne_res)
  )
})

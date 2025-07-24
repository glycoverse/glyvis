test_that("autoplot works for glystats_pca_res", {
  suppressMessages(
    pca_res <- glystats::gly_pca(test_gp_exp)
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_pca_res_individual",
    autoplot(pca_res)
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_pca_res_variables",
    autoplot(pca_res, type = "variables")
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_pca_res_screeplot",
    autoplot(pca_res, type = "screeplot")
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_pca_res_biplot",
    autoplot(pca_res, type = "biplot")
  )
})

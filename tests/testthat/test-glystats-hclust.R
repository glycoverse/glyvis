skip_on_ci()
skip_on_cran()

test_that("autoplot works for glystats hclust results", {
  set.seed(1234)
  suppressMessages(
    hclust_res <- glystats::gly_hclust(test_gp_exp, on = "sample")
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_hclust_res",
    autoplot(hclust_res)
  )
})

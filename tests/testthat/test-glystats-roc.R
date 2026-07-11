skip_on_ci()
skip_on_cran()
skip_if_not_installed("pROC")

test_that("autoplot works for glystats roc results", {
  exp <- set_test_gp_col(
    col = "group",
    value = dplyr::if_else(
      SummarizedExperiment::colData(test_gp_se)$group %in% c("H", "M"),
      "control",
      "case"
    )
  )
  suppressMessages(
    roc_res <- glystats::gly_roc(exp)
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_roc_res",
    autoplot(roc_res)
  )
})

test_that("autoplot works for glystats roc results with type = 'roc'", {
  exp <- subset_test_gp_se(variables = seq_len(10))
  exp <- set_test_gp_col(
    exp,
    "group",
    dplyr::if_else(
      SummarizedExperiment::colData(exp)$group %in% c("H", "C"),
      "control",
      "case"
    )
  )
  suppressMessages(
    roc_res <- glystats::gly_roc(exp)
  )
  vdiffr::expect_doppelganger(
    "autoplot.glystats_roc_res with type = 'roc'",
    autoplot(roc_res, type = "roc")
  )
})
